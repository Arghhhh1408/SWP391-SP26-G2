/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.sql.*;
import dao.ProductDAO;
import dao.StockOutDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Date;
import java.util.Map;
import model.CartItem;
import utils.DBContext;

/**
 *
 * @author DELL
 */
@WebServlet(name = "InvoiceFinish", urlPatterns = {"/invoice/finish"})
public class InvoiceFinish extends HttpServlet {

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
            out.println("<title>Servlet InvoiceFinish</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet InvoiceFinish at " + request.getContextPath() + "</h1>");
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
        processRequest(request, response);
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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("acc") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        @SuppressWarnings("unchecked")
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        java.util.List<CartItem> items = new java.util.ArrayList<>(cart.values());

        model.User user = (model.User) session.getAttribute("acc");
        int userId = user.getUserID();
        String createdBy = user.getUsername();

        // Lấy thông tin khách: ưu tiên request, nếu rỗng thì lấy từ session (Checkout đã set)
        String customerName = request.getParameter("customerName");
        String customerPhone = request.getParameter("customerPhone");
        if (customerName == null) {
            customerName = (String) session.getAttribute("customerName");
        }
        if (customerPhone == null) {
            customerPhone = (String) session.getAttribute("customerPhone");
        }
        if (customerName == null) {
            customerName = "";
        }
        if (customerPhone == null) {
            customerPhone = "";
        }
        customerName = customerName.trim();
        customerPhone = customerPhone.trim();

        double totalAmount = 0;
        for (CartItem it : items) {
            totalAmount += it.getLineTotal();
        }

        DBContext db = new DBContext();
        Connection conn = db.connection;

        try {
            conn.setAutoCommit(false);

            // 1) TRỪ KHO (chặn âm)
            ProductDAO productDAO = new ProductDAO();
            for (CartItem it : items) {
                int pid = it.getProductId();
                int qty = it.getQty(); // đảm bảo CartItem có getQty()

                boolean ok = productDAO.decreaseStock(conn, pid, qty);
                if (!ok) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/pos?err=not_enough_stock");
                    return;
                }
            }

            // 2) CUSTOMER ID
            dao.CustomerDAO customerDAO = new dao.CustomerDAO();
            customerDAO.connection = conn;

            int customerId = (customerName.isEmpty() && customerPhone.isEmpty())
                    ? customerDAO.getWalkInCustomerId()
                    : customerDAO.getOrCreateCustomerId(customerName, customerPhone);

            // 3) INSERT StockOut + Details (lịch sử)
            dao.StockOutDAO stockOutDAO = new dao.StockOutDAO(conn);
            String note = request.getParameter("note");
            if (note == null) note = "";
            int stockOutId = stockOutDAO.insertStockOut(customerId, userId, totalAmount, note);
            stockOutDAO.insertDetails(stockOutId, items);

            conn.commit();

            // 4) XÓA GIỎ SAU COMMIT
            session.removeAttribute("cart");

            // (tuỳ) clear info khách
            // session.removeAttribute("customerName");
            // session.removeAttribute("customerPhone");
            response.sendRedirect(request.getContextPath() + "/pos?success=1");
            return;

        } catch (Exception e) {
            try {
                conn.rollback();
            } catch (Exception ignored) {
            }
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pos?err=finish_failed");
            return;

        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (Exception ignored) {
            }
            try {
                db.closeConnection();
            } catch (Exception ignored) {
            }
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
