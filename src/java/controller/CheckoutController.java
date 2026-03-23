/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.sql.Connection;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.Map;
import model.CartItem;
import model.User;
import utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

/**
 *
 * @author DELL
 */
@WebServlet(name = "CheckoutController", urlPatterns = {"/checkout"})
public class CheckoutController extends HttpServlet {

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
            out.println("<title>Servlet CheckoutController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CheckoutController at " + request.getContextPath() + "</h1>");
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

        request.getRequestDispatcher("/checkout.jsp").forward(request, response);

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
        HttpSession session = request.getSession();
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");

        // 0) Kiểm tra giỏ hàng
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect("sales_dashboard?tab=pos");
            return;
        }

        // 1) Lấy thông tin người bán (CreatedBy)
        model.User acc = (model.User) session.getAttribute("acc");
        int createdBy = (acc != null) ? acc.getUserID() : 1;

        // 2) Lấy dữ liệu từ Form POS (SĐT, Tên, Ghi chú, Tiền trả)
        String phone = request.getParameter("phone");
        String name = request.getParameter("customerName");
        String note = request.getParameter("note");
        if (note == null) {
            note = "";
        }

        String paidRaw = request.getParameter("amountPaid");
        double amountPaid = (paidRaw != null && !paidRaw.isEmpty()) ? Double.parseDouble(paidRaw) : 0;

        double totalAmount = 0;
        for (CartItem it : cart.values()) {
            totalAmount += it.getLineTotal();
        }

        // 3) Xử lý ID khách hàng (Dùng hàm tự động bạn đã viết trong CustomerDAO)
        dao.CustomerDAO customerDAO = new dao.CustomerDAO();
        int finalCustomerId;
        try {
            // Hàm này tự check: có SĐT thì lấy ID, chưa có thì tạo mới rồi lấy ID
            finalCustomerId = customerDAO.getOrCreateCustomerId(name, phone);
        } catch (Exception e) {
            e.printStackTrace();
            finalCustomerId = 1; // Fallback về Khách lẻ nếu lỗi
        }

        utils.DBContext db = new utils.DBContext();
        Connection con = db.connection;

        try {
            con.setAutoCommit(false); // Bắt đầu Transaction

            // BƯỚC 1: Kiểm tra tồn kho (An toàn dữ liệu)
            String checkSql = "SELECT StockQuantity FROM dbo.Products WHERE ProductID = ?";
            try (PreparedStatement checkStm = con.prepareStatement(checkSql)) {
                for (CartItem it : cart.values()) {
                    checkStm.setInt(1, it.getProductId());
                    try (ResultSet rs = checkStm.executeQuery()) {
                        if (rs.next()) {
                            int stock = rs.getInt("StockQuantity");
                            if (stock < it.getQty()) {
                                throw new RuntimeException("Sản phẩm ID " + it.getProductId() + " không đủ kho!");
                            }
                        }
                    }
                }
            }

            // BƯỚC 2: INSERT hóa đơn tổng (StockOut)
            String insertOutSql = "INSERT INTO dbo.StockOut (CustomerID, Date, TotalAmount, CreatedBy, Note, Status) VALUES (?, GETDATE(), ?, ?, ?, 'Completed')";
            int stockOutId;
            try (PreparedStatement stm = con.prepareStatement(insertOutSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                stm.setInt(1, finalCustomerId);
                stm.setDouble(2, totalAmount);
                stm.setInt(3, createdBy);
                stm.setString(4, note);
                stm.executeUpdate();

                try (ResultSet keys = stm.getGeneratedKeys()) {
                    if (!keys.next()) {
                        throw new RuntimeException("Không lấy được mã hóa đơn!");
                    }
                    stockOutId = keys.getInt(1);
                }
            }

            // BƯỚC 3: INSERT chi tiết hóa đơn (StockOutDetails)
            String insertDetailSql = "INSERT INTO dbo.StockOutDetails (StockOutID, ProductID, Quantity, UnitPrice) VALUES (?, ?, ?, ?)";
            try (PreparedStatement detStm = con.prepareStatement(insertDetailSql)) {
                for (CartItem it : cart.values()) {
                    detStm.setInt(1, stockOutId);
                    detStm.setInt(2, it.getProductId());
                    detStm.setInt(3, it.getQty());
                    detStm.setDouble(4, it.getPrice());
                    detStm.addBatch();
                }
                detStm.executeBatch();
            }

            // BƯỚC 4: Trừ tồn kho trong bảng Products
            String updateStockSql = "UPDATE dbo.Products SET StockQuantity = StockQuantity - ? WHERE ProductID = ?";
            try (PreparedStatement stockStm = con.prepareStatement(updateStockSql)) {
                for (CartItem it : cart.values()) {
                    stockStm.setInt(1, it.getQty());
                    stockStm.setInt(2, it.getProductId());
                    stockStm.addBatch();
                }
                stockStm.executeBatch();
            }

            // BƯỚC 5: Cập nhật công nợ nếu khách trả thiếu (Chỉ áp dụng khách có ID khác khách lẻ)
            if (totalAmount > amountPaid && finalCustomerId != 1) {
                // 1. Tính số tiền khách còn thiếu
                double debtIncrement = totalAmount - amountPaid;

                // 2. Gọi hàm CỘNG NỢ (không phải trừ nợ) và truyền vào 'debtIncrement'
                customerDAO.addDebtFromOrder(finalCustomerId, debtIncrement);
            }

            con.commit(); // Hoàn tất Transaction
            session.removeAttribute("cart");
            response.sendRedirect("sales_dashboard?tab=pos&success=1");

        } catch (Exception e) {

            response.sendRedirect("sales_dashboard?tab=pos&error=" + e.getMessage());
        } finally {
            try {
                con.setAutoCommit(true);
                db.closeConnection();
            } catch (Exception ignore) {
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

    private static class SQLException {

        public SQLException() {
        }
    }

}
