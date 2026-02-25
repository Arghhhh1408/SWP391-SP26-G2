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

        // snapshot giỏ để dùng sau khi xóa cart
        java.util.List<CartItem> items = new java.util.ArrayList<>(cart.values());

        // =========================
        // (A) TRỪ KHO + XÓA GIỎ (BẮT BUỘC OK)
        // =========================
        ProductDAO productDAO = new ProductDAO();
        Connection conn = productDAO.connection;

        try {
            conn.setAutoCommit(false);

            for (CartItem it : items) {
                boolean ok = productDAO.decreaseStock(conn, 0, 0);
                if (!ok) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + "/pos?err=not_enough_stock");
                    return;
                }
            }

            conn.commit();
            session.removeAttribute("cart"); // chỉ xóa sau commit OK

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
                conn.close();
            } catch (Exception ignored) {
            }
        }

        // =========================
        // (B) LƯU LỊCH SỬ (LỖI THÌ BỎ QUA)
        // =========================
        String redirectUrl = request.getContextPath() + "/orders"; // mặc định nhảy lịch sử
        try {
            model.User user = (model.User) session.getAttribute("acc");
            int userId = user.getUserID();
            String createdBy = user.getUsername();

            double totalAmount = 0;
            for (CartItem it : items) {
                totalAmount += it.getLineTotal();
            }

            // mở connection mới để lưu lịch sử
            utils.DBContext db = new utils.DBContext();
            Connection c2 = db.connection;

            try {
                c2.setAutoCommit(false);

                // ===== LẤY THÔNG TIN KHÁCH TỪ FORM =====
                String customerName = request.getParameter("customerName");
                String customerPhone = request.getParameter("customerPhone");
                if (customerName == null) {
                    customerName = "";
                }
                if (customerPhone == null) {
                    customerPhone = "";
                }
                customerName = customerName.trim();
                customerPhone = customerPhone.trim();

                // ===== TÍNH CUSTOMER ID =====
                dao.CustomerDAO customerDAO = new dao.CustomerDAO();
                customerDAO.connection = c2;

                int customerId;
                if (customerName.isEmpty() && customerPhone.isEmpty()) {
                    customerId = customerDAO.getWalkInCustomerId(); // thường = 1
                } else {
                    customerId = customerDAO.getOrCreateCustomerId(customerName, customerPhone);
                }

                // log để chắc chắn không còn luôn = 1
                int walkinId = customerDAO.getWalkInCustomerId();
                System.out.println("FINISH: name=[" + customerName + "] phone=[" + customerPhone + "] -> customerId="
                        + customerId + " (walkinId=" + walkinId + ")");
                model.User u = (model.User) session.getAttribute("acc");

                String note = request.getParameter("note");
                if (note == null) {
                    note = "";
                }

                String status = "PAID";
                Timestamp now = new Timestamp(System.currentTimeMillis());

                dao.StockOutDAO stockOutDAO = new dao.StockOutDAO(c2);

                // totalAmount bạn đã tính sẵn
                int stockOutId = stockOutDAO.insertStockOut(customerId, userId, totalAmount, createdBy);

                // items là List<CartItem> snapshot
                stockOutDAO.insertDetails(stockOutId, items);

                c2.commit();

            } catch (Exception ex) {
                try {
                    c2.rollback();
                } catch (Exception ignored) {
                }
                ex.printStackTrace();
                // lịch sử lỗi thì vẫn coi như bán xong
                redirectUrl = request.getContextPath() + "/pos?msg=done_no_history";
            } finally {
                try {
                    c2.setAutoCommit(true);
                } catch (Exception ignored) {
                }
                try {
                    c2.close();
                } catch (Exception ignored) {
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            redirectUrl = request.getContextPath() + "/pos?msg=done_no_history";
        }

        response.sendRedirect(redirectUrl);
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
