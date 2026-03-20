/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.DashboardDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author DELL
 */
@WebServlet(name = "DashboardController", urlPatterns = {"/dashboard"})
public class DashboardController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet DashboardController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet DashboardController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("acc") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        DashboardDAO dao = new DashboardDAO();
        dao.ProductDAO pDao = new dao.ProductDAO(); // Gọi thêm ProductDAO

        // 1. Lấy dữ liệu doanh thu
        double revenueToday = dao.getRevenueToday();
        double revenueWeek = dao.getRevenueThisWeek();
        double revenueMonth = dao.getRevenueThisMonth();

        // 2. Lấy danh sách sản phẩm tồn kho thấp (Dưới 5 món)
        // Bạn cần viết hàm getAllProducts hoặc getLowStock trong ProductDAO trước nhé
        java.util.List<model.Product> lowStockProducts = pDao.getAllProducts("");

        // Lọc thủ công nếu chưa có hàm getLowStock riêng:
        java.util.List<model.Product> warningList = new java.util.ArrayList<>();
        for (model.Product p : lowStockProducts) {
            if (p.getQuantity() < 5) {
                warningList.add(p);
            }
        }

        // 3. Đẩy dữ liệu sang JSP
        request.setAttribute("revenueToday", revenueToday);
        request.setAttribute("revenueWeek", revenueWeek);
        request.setAttribute("revenueMonth", revenueMonth);

        // Đẩy danh sách và số lượng để Dashboard hiện đúng
        request.setAttribute("lowStockProducts", warningList);
        request.setAttribute("lowStockCount", warningList.size());

        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
