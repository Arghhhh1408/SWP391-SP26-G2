package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.ReturnDAO;
import dao.StaffDashboardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import model.Product;
import model.ReturnRequest;
import model.User;
import utils.ExcelUtils;

@WebServlet(name = "StaffExportReportController", urlPatterns = {"/exportStaffReport"})
public class StaffExportReportController extends HttpServlet {

    private boolean ensureStaff(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 1) {
            response.sendRedirect("login");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureStaff(request, response)) {
            return;
        }

        // Optional date range (defaults: all time)
        String fromDate = safeTrim(request.getParameter("fromDate"));
        String toDate = safeTrim(request.getParameter("toDate"));
        if (fromDate == null || fromDate.isEmpty()) {
            fromDate = "2000-01-01";
        }
        if (toDate == null || toDate.isEmpty()) {
            toDate = "2099-12-31";
        }

        try {
            ProductDAO pDao = new ProductDAO();
            CategoryDAO cDao = new CategoryDAO();
            ReturnDAO rDao = new ReturnDAO();
            StaffDashboardDAO sdDao = new StaffDashboardDAO();

            List<Product> products = pDao.getAllProducts();
            Map<Integer, String> catMap = cDao.getCategoryIdToNameMap();

            var dailySales = sdDao.getDailyCompletedSalesReport(fromDate, toDate);
            var soldDetails = sdDao.getCompletedStockOutDetailsReport(fromDate, toDate);
            List<ReturnRequest> returns = rDao.listNotCancelled();

            String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            String filename = "Staff_Report_" + today + ".xlsx";

            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=" + filename);
            ExcelUtils.exportStaffMultiSheetReport(products, catMap, dailySales, soldDetails, returns, response.getOutputStream());
            response.getOutputStream().flush();
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi khi xuất báo cáo Excel: " + e.getMessage());
            response.sendRedirect("staff_dashboard?tab=dashboard");
        }
    }

    private static String safeTrim(String s) {
        return s == null ? null : s.trim();
    }
}

