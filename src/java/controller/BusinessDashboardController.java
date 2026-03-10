package controller;

import dao.BusinessReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebServlet(name = "BusinessDashboardController", urlPatterns = {"/dashboard"})
public class BusinessDashboardController extends HttpServlet {

    private boolean ensureAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 0) {
            response.sendRedirect("login");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureAdmin(request, response)) {
            return;
        }

        BusinessReportDAO dao = new BusinessReportDAO();

        request.setAttribute("totalProducts", dao.countProducts());
        request.setAttribute("activeProducts", dao.countActiveProducts());
        request.setAttribute("lowStockProducts", dao.countLowStockProducts(5));
        request.setAttribute("inventoryValueCost", dao.inventoryValueByCost());
        request.setAttribute("inventoryValuePrice", dao.inventoryValueByPrice());

        request.setAttribute("ordersToday", dao.ordersToday());
        request.setAttribute("revenueToday", dao.revenueToday());
        request.setAttribute("revenueThisMonth", dao.revenueThisMonth());
        request.setAttribute("stockInThisMonth", dao.stockInThisMonth());
        request.setAttribute("refundedThisMonth", dao.refundedThisMonth());

        request.setAttribute("sales7d", dao.salesLast7Days());
        request.setAttribute("top30d", dao.topProductsLast30Days(10));
        request.setAttribute("claimStatusCounts", dao.warrantyClaimsByStatus());
        request.setAttribute("returnStatusCounts", dao.returnsByStatus());

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}

