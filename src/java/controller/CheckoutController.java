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
@WebServlet(name="CheckoutController", urlPatterns={"/checkout"})
public class CheckoutController extends HttpServlet {
   
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
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
            out.println("<h1>Servlet CheckoutController at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
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
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect("pos");
            return;
        }

        // createdBy: lấy từ session login (bạn đang set "acc" trong LoginController)
        User acc = (User) session.getAttribute("acc");
        int createdBy = (acc != null) ? acc.getUserID() : 1; // fallback tạm

        // customerId có thể null
        Integer customerId = null;
        String customerRaw = request.getParameter("customerId");
        if (customerRaw != null && !customerRaw.trim().isEmpty()) {
            customerId = Integer.parseInt(customerRaw.trim());
        }

        String note = request.getParameter("note");
        if (note == null) note = "";

        double totalAmount = 0;
        for (CartItem it : cart.values()) totalAmount += it.getLineTotal();

        DBContext db = new DBContext();
        Connection con = db.connection;

        try {
            con.setAutoCommit(false);

            // 1) CHECK tồn kho đủ trước (tránh trừ âm)
            String checkSql = "SELECT StockQuantity FROM dbo.Products WHERE ProductID = ?";
            try (PreparedStatement checkStm = con.prepareStatement(checkSql)) {
                for (CartItem it : cart.values()) {
                    checkStm.setInt(1, it.getProductId());
                    try (ResultSet rs = checkStm.executeQuery()) {
                        if (!rs.next()) {
                            throw new RuntimeException("Product not found: " + it.getProductId());
                        }
                        int stock = rs.getInt("StockQuantity");
                        if (stock < it.getQty()) {
                            throw new RuntimeException("Not enough stock for productId=" + it.getProductId()
                                    + " stock=" + stock + " need=" + it.getQty());
                        }
                    }
                }
            }

            // 2) INSERT StockOut (lấy StockOutID)
            String insertOutSql = """
                INSERT INTO dbo.StockOut (CustomerID, Date, TotalAmount, CreatedBy, Note, Status)
                VALUES (?, ?, ?, ?, ?, ?)
            """;

            int stockOutId;
            try (PreparedStatement stm = con.prepareStatement(insertOutSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                if (customerId == null) stm.setNull(1, java.sql.Types.INTEGER);
                else stm.setInt(1, customerId);

                stm.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
                stm.setDouble(3, totalAmount);
                stm.setInt(4, createdBy);
                stm.setString(5, note);
                stm.setString(6, "Completed"); // hoặc "Paid" tuỳ bạn

                stm.executeUpdate();

                try (ResultSet keys = stm.getGeneratedKeys()) {
                    if (!keys.next()) throw new RuntimeException("Cannot get StockOutID");
                    stockOutId = keys.getInt(1);
                }
            }

            // 3) INSERT StockOutDetails
            String insertDetailSql = """
                INSERT INTO dbo.StockOutDetails (StockOutID, ProductID, Quantity, UnitPrice)
                VALUES (?, ?, ?, ?)
            """;

            try (PreparedStatement stm = con.prepareStatement(insertDetailSql)) {
                for (CartItem it : cart.values()) {
                    stm.setInt(1, stockOutId);
                    stm.setInt(2, it.getProductId());
                    stm.setInt(3, it.getQty());
                    stm.setDouble(4, it.getPrice());
                    stm.addBatch();
                }
                stm.executeBatch();
            }

            // 4) TRỪ kho trong Products.StockQuantity
            String updateStockSql = "UPDATE dbo.Products SET StockQuantity = StockQuantity - ? WHERE ProductID = ?";
            try (PreparedStatement stm = con.prepareStatement(updateStockSql)) {
                for (CartItem it : cart.values()) {
                    stm.setInt(1, it.getQty());
                    stm.setInt(2, it.getProductId());
                    stm.addBatch();
                }
                stm.executeBatch();
            }

            con.commit();

            // 5) Clear cart
            session.removeAttribute("cart");

            // Redirect về pos hoặc sang trang hóa đơn / chi tiết đơn
            // Đổi từ "pos?success=1" thành:
            response.sendRedirect("sales_dashboard?tab=pos&success=1");

        } catch (Exception e) {
            try { con.rollback(); } catch (Exception ignore) {}
            throw new ServletException("Checkout failed: " + e.getMessage(), e);
        } finally {
            try { con.setAutoCommit(true); } catch (Exception ignore) {}
            // DBContext của bạn có closeConnection() thì gọi
            try { db.closeConnection(); } catch (Exception ignore) {}
        }
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
