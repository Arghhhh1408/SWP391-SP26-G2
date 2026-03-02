/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.StockInDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.List;
import model.StockIn;
import model.StockInDetail;
import model.User;

/**
 *
 * @author dotha
 */
@WebServlet(name = "CreateStockInController", urlPatterns = {"/createStockIn"})
public class CreateStockInController extends HttpServlet {

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
            out.println("<title>Servlet CreateStockInController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CreateStockInController at " + request.getContextPath() + "</h1>");
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
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("acc");

        // 2 = Warehouse (đổi theo DB của bạn)
        if (user.getRoleID() != 1) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Chỉ Warehouse Staff mới được tạo phiếu nhập.");
            return;
        }

        request.getRequestDispatcher("stockinForm.jsp")
                .forward(request, response);
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

        try {

            request.setCharacterEncoding("UTF-8");

            // ======= PHIẾU CHÍNH =======
            StockIn stockIn = new StockIn();
            stockIn.setSupplierId(Integer.parseInt(request.getParameter("supplierId")));

            HttpSession session = request.getSession(false);
            User user = (User) session.getAttribute("acc");
            stockIn.setCreatedBy(user.getUserID());

            stockIn.setNote(request.getParameter("note"));
            String paymentOption = request.getParameter("paymentOption");
            // paid => Complete, pay_later => Pending
            if ("paid".equals(paymentOption)) {
                stockIn.setStatus("Complete");
            } else {
                stockIn.setStatus("Pending");
            }

            // ======= CHI TIẾT =======
            String[] productIds = request.getParameterValues("productId");
            String[] quantities = request.getParameterValues("quantity");
            String[] unitCosts = request.getParameterValues("unitCost");

            List<StockInDetail> details = new ArrayList<>();

            double total = 0;

            for (int i = 0; i < productIds.length; i++) {

                // Bỏ qua dòng trống (dòng user không nhập)
                if (productIds[i] == null || productIds[i].trim().isEmpty()) {
                    continue;
                }
                if (quantities[i] == null || quantities[i].trim().isEmpty()) {
                    continue;
                }
                if (unitCosts[i] == null || unitCosts[i].trim().isEmpty()) {
                    continue;
                }

                StockInDetail detail = new StockInDetail();
                detail.setProductId(Integer.parseInt(productIds[i].trim()));
                detail.setQuantity(Integer.parseInt(quantities[i].trim()));
                detail.setUnitCost(Double.parseDouble(unitCosts[i].trim()));

                total += detail.getQuantity() * detail.getUnitCost();
                details.add(detail);
            }

            if (details.isEmpty()) {
                request.setAttribute("message", "Vui lòng nhập ít nhất 1 sản phẩm!");
                request.getRequestDispatcher("stockinForm.jsp").forward(request, response);
                return;
            }

            stockIn.setTotalAmount(total);

            // ======= LƯU DATABASE =======
            StockInDAO dao = new StockInDAO();
            boolean result = dao.insertStockInWithDetails(stockIn, details);

            if (result) {
                response.sendRedirect(request.getContextPath() + "/category");
            } else {
                request.setAttribute("message", "Tạo phiếu nhập thất bại!");
                request.getRequestDispatcher("stockinForm.jsp")
                        .forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Lỗi: " + e.getMessage());
        }
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
