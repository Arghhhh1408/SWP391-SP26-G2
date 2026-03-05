/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.StockInDAO;
import dao.SystemLogDAO;
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
import java.util.Map;
import model.StockIn;
import model.StockInDetail;
import model.SystemLog;
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
        if (user.getRoleID() != 1 && user.getRoleID() != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Chỉ Warehouse Staff hoặc Quản lý mới được tạo phiếu nhập.");
            return;
        }

        // ====== CART trong session: Map<productId, Product>
        @SuppressWarnings("unchecked")
        Map<Integer, model.Product> cart
                = (Map<Integer, model.Product>) session.getAttribute("stockinCart");

        if (cart == null) {
            cart = new java.util.LinkedHashMap<>();
            session.setAttribute("stockinCart", cart);
        }

        // ====== Xử lý action: add/remove/clear
        String action = request.getParameter("action");
        String pidRaw = request.getParameter("pid");

        dao.ProductDAO pdao = new dao.ProductDAO();

        if ("add".equals(action) && pidRaw != null) {
            try {
                int pid = Integer.parseInt(pidRaw);
                model.Product p = pdao.getById(pid);
                if (p != null) {
                    cart.put(pid, p);
                }
            } catch (NumberFormatException ignored) {
            }
        } else if ("remove".equals(action) && pidRaw != null) {
            try {
                int pid = Integer.parseInt(pidRaw);
                cart.remove(pid);
            } catch (NumberFormatException ignored) {
            }
        } else if ("clear".equals(action)) {
            cart.clear();
            if ("1".equals(request.getParameter("redirect"))) {
                response.sendRedirect("stockinList");
                return;
            }
        }

        // ====== Search products (submit GET)
        String keyword = request.getParameter("keyword");
        List<model.Product> productList = pdao.search(keyword);
        request.setAttribute("keyword", keyword);
        request.setAttribute("productList", productList);

        // Đưa cart sang JSP để render
        request.setAttribute("cart", cart);

        request.getRequestDispatcher("stockinForm.jsp").forward(request, response);
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

            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("acc") == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            User user = (User) session.getAttribute("acc");

            @SuppressWarnings("unchecked")
            Map<Integer, model.Product> cart
                    = (Map<Integer, model.Product>) session.getAttribute("stockinCart");

            if (cart == null || cart.isEmpty()) {
                request.setAttribute("message", "Vui lòng chọn ít nhất 1 sản phẩm!");
                request.getRequestDispatcher("stockinForm.jsp").forward(request, response);
                return;
            }

            // ======= PHIẾU CHÍNH =======
            StockIn stockIn = new StockIn();
            stockIn.setSupplierId(Integer.parseInt(request.getParameter("supplierId")));
            stockIn.setCreatedBy(user.getUserID());
            stockIn.setNote(request.getParameter("note"));

            // Status theo lựa chọn thanh toán
            String paymentOption = request.getParameter("paymentOption");
            if ("paid".equals(paymentOption)) {
                stockIn.setStatus("Complete");
            } else {
                stockIn.setStatus("Pending");
            }

            // ======= CHI TIẾT từ cart =======
            List<StockInDetail> details = new ArrayList<>();
            double total = 0;

            for (Integer pid : cart.keySet()) {
                String qtyRaw = request.getParameter("qty_" + pid);
                String costRaw = request.getParameter("cost_" + pid);

                if (qtyRaw == null || qtyRaw.trim().isEmpty()) {
                    continue;
                }
                if (costRaw == null || costRaw.trim().isEmpty()) {
                    continue;
                }

                int qty = Integer.parseInt(qtyRaw.trim());
                double cost = Double.parseDouble(costRaw.trim());

                if (qty <= 0 || cost < 0) {
                    continue;
                }

                StockInDetail d = new StockInDetail();
                d.setProductId(pid);
                d.setQuantity(qty);
                d.setUnitCost(cost);

                total += qty * cost;
                details.add(d);
            }

            if (details.isEmpty()) {
                request.setAttribute("message", "Vui lòng nhập số lượng và giá nhập hợp lệ!");
                request.getRequestDispatcher("stockinForm.jsp").forward(request, response);
                return;
            }

            stockIn.setTotalAmount(total);

            // ======= LƯU DATABASE =======
            StockInDAO dao = new StockInDAO();
            boolean result = dao.insertStockInWithDetails(stockIn, details);

            if (result) {
                try {
                    SystemLogDAO logDAO = new SystemLogDAO();
                    SystemLog log = new SystemLog();

                    int userID = (user != null) ? user.getUserID() : 2;

                    log.setUserID(userID);
                    log.setAction("CREATE_STOCKIN");
                    log.setTargetObject("StockIn");

                    String description = "Tạo phiếu nhập | SupplierID: "
                            + stockIn.getSupplierId()
                            + " | Total: " + stockIn.getTotalAmount()
                            + " | Items: " + details.size()
                            + " | Status: " + stockIn.getStatus();

                    log.setDescription(description);
                    log.setIpAddress(request.getRemoteAddr());

                    logDAO.insertLog(log);

                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                cart.clear(); // clear cart sau khi tạo thành công
                response.sendRedirect(request.getContextPath() + "/stockinList");
            } else {
                try {
                    SystemLogDAO logDAO = new SystemLogDAO();
                    SystemLog log = new SystemLog();

                    int userID = (user != null) ? user.getUserID() : 2;

                    log.setUserID(userID);
                    log.setAction("CREATE_STOCKIN");
                    log.setTargetObject("StockIn");

                    String description = "Tạo phiếu nhập | SupplierID: "
                            + stockIn.getSupplierId()
                            + " | Total: " + stockIn.getTotalAmount()
                            + " | Items: " + details.size()
                            + " | Status: " + stockIn.getStatus();

                    log.setDescription(description);
                    log.setIpAddress(request.getRemoteAddr());

                    logDAO.insertLog(log);

                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                request.setAttribute("message", "Tạo phiếu nhập thất bại!");
                request.getRequestDispatcher("stockinForm.jsp").forward(request, response);
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
