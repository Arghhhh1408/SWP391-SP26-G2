package controller;

import dao.DashboardDAO;
import dao.ProductDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
import model.User;

@WebServlet(name = "DashboardController", urlPatterns = {"/sales_dashboard_controller"})
public class DashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Kiểm tra Session (Bỏ false để tránh bị văng ra Login vô lý)
        HttpSession session = request.getSession();
        User acc = (User) session.getAttribute("acc");
        
        if (acc == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Lấy dữ liệu từ DAO
        DashboardDAO dao = new DashboardDAO();
        ProductDAO pDao = new ProductDAO(); 

        // Lấy dữ liệu doanh thu
        double revenueToday = dao.getRevenueToday();
        double revenueWeek = dao.getRevenueThisWeek();
        double revenueMonth = dao.getRevenueThisMonth();

        // 3. Xử lý tồn kho thấp (Dưới 5 món)
        List<Product> allProducts = pDao.getAllProducts(""); // Lấy toàn bộ sản phẩm
        List<Product> warningList = new ArrayList<>();
        
        if (allProducts != null) {
            for (Product p : allProducts) {
                if (p.getQuantity() < 5) {
                    warningList.add(p);
                }
            }
        }

        // 4. Đẩy dữ liệu sang JSP
        request.setAttribute("revenueToday", revenueToday);
        request.setAttribute("revenueWeek", revenueWeek);
        request.setAttribute("revenueMonth", revenueMonth);
        request.setAttribute("lowStockProducts", warningList);
        request.setAttribute("lowStockCount", warningList.size());

        // 5. Forward sang trang JSP (Đảm bảo file là dashboard.jsp nằm ở webapp/web)
        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Dashboard Controller for Sales";
    }
}