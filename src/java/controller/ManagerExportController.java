package controller;

import dao.CategoryDAO;
import dao.OrderHistoryDAO;
import dao.ProductDAO;
import dao.StockInDAO;
import dao.SystemLogDAO;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
import model.SystemLog;
import model.User;
import utils.ExcelUtils;

@WebServlet(name = "ManagerExportController", urlPatterns = {"/exportManager"})
public class ManagerExportController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User acc = (User) session.getAttribute("acc");

        // Phân quyền: Chỉ Manager (roleID = 2) được phép xuất báo cáo
        if (acc == null || acc.getRoleID() != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập tính năng này.");
            return;
        }

        String type = request.getParameter("type");
        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        // Default date range if not provided (Current month)
        if (fromDate == null || fromDate.isEmpty()) fromDate = "2000-01-01";
        if (toDate == null || toDate.isEmpty()) toDate = "2099-12-31";

        try {
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            
            if ("inventory".equals(type)) {
                response.setHeader("Content-Disposition", "attachment; filename=Inventory_Report.xlsx");
                ProductDAO pDao = new ProductDAO();
                CategoryDAO cDao = new CategoryDAO();
                List<Product> products = pDao.getAllProducts();
                Map<Integer, String> catMap = cDao.getCategoryIdToNameMap();
                ExcelUtils.exportInventoryReport(products, catMap, response.getOutputStream());
                logAction(request, "EXPORT_INVENTORY", "Xuất báo cáo tồn kho (" + products.size() + " sản phẩm)");

            } else if ("sales".equals(type)) {
                response.setHeader("Content-Disposition", "attachment; filename=Sales_Profit_Report.xlsx");
                OrderHistoryDAO oDao = new OrderHistoryDAO();
                List<OrderHistoryDAO.DailyReport> data = oDao.getDailySalesReport(fromDate, toDate);
                ExcelUtils.exportSalesReport(data, response.getOutputStream());
                logAction(request, "EXPORT_SALES_REPORT", "Xuất báo cáo doanh thu từ " + fromDate + " đến " + toDate);

            } else if ("stockin_details".equals(type)) {
                response.setHeader("Content-Disposition", "attachment; filename=StockIn_Details.xlsx");
                StockInDAO sDao = new StockInDAO();
                List<StockInDAO.StockInDetailReport> data = sDao.getStockInDetailsReport(fromDate, toDate);
                ExcelUtils.exportStockInDetails(data, response.getOutputStream());
                logAction(request, "EXPORT_STOCKIN_DETAILS", "Xuất báo cáo chi tiết nhập kho từ " + fromDate + " đến " + toDate);

            } else if ("stockout_details".equals(type)) {
                response.setHeader("Content-Disposition", "attachment; filename=StockOut_Details.xlsx");
                OrderHistoryDAO oDao = new OrderHistoryDAO();
                List<OrderHistoryDAO.StockOrderDetail> data = oDao.getStockOutDetailsReport(fromDate, toDate);
                ExcelUtils.exportStockOutDetails(data, response.getOutputStream());
                logAction(request, "EXPORT_STOCKOUT_DETAILS", "Xuất báo cáo chi tiết xuất kho từ " + fromDate + " đến " + toDate);

            } else if ("performance".equals(type)) {
                response.setHeader("Content-Disposition", "attachment; filename=Top_Performance_Report.xlsx");
                ProductDAO pDao = new ProductDAO();
                List<ProductDAO.ProductPerformance> data = pDao.getTopSellingProducts(20);
                ExcelUtils.exportPerformanceReport(data, response.getOutputStream());
                logAction(request, "EXPORT_PERFORMANCE_REPORT", "Xuất báo cáo hiệu suất bán hàng (Top 20 sản phẩm)");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("Error generating report: " + e.getMessage());
        }
    }

    private void logAction(HttpServletRequest request, String action, String description) {
        try {
            HttpSession session = request.getSession(false);
            User u = (User) session.getAttribute("acc");
            SystemLog log = new SystemLog();
            log.setUserID(u != null ? u.getUserID() : 0);
            log.setAction(action);
            log.setTargetObject("Report");
            log.setDescription(description);
            log.setIpAddress(request.getRemoteAddr());
            new SystemLogDAO().insertLog(log);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
