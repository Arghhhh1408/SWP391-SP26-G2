/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.ProductDAO;
import dao.StockInDAO;
import dao.SystemLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Product;
import model.StockIn;
import model.StockInDetail;
import model.SystemLog;
import model.User;

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

    private void forwardToForm(HttpServletRequest request, HttpServletResponse response,
            Map<Integer, Product> cart,
            String supplierIdDraft,
            String noteDraft,
            String stockStatusDraft,
            String paymentStatusDraft,
            String keyword,
            String message) throws ServletException, IOException {

        ProductDAO pdao = new ProductDAO();
        List<Product> productList = pdao.search(keyword);

        request.setAttribute("message", message);
        request.setAttribute("cart", cart);
        request.setAttribute("keyword", keyword);
        request.setAttribute("productList", productList);

        request.setAttribute("supplierIdDraft", supplierIdDraft);
        request.setAttribute("noteDraft", noteDraft);
        request.setAttribute("stockStatusDraft", stockStatusDraft);
        request.setAttribute("paymentStatusDraft", paymentStatusDraft);

        request.getRequestDispatcher("stockinForm.jsp").forward(request, response);
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
            request.setAttribute("message", "Chỉ Warehouse Staff hoặc Quản lý mới được tạo phiếu nhập.");
            request.getRequestDispatcher("stockinList").forward(request, response);
            return;
        }

        @SuppressWarnings("unchecked")
        Map<Integer, Product> cart = (Map<Integer, Product>) session.getAttribute("stockinCart");

        if (cart == null) {
            cart = new LinkedHashMap<>();
            session.setAttribute("stockinCart", cart);
        }

        ProductDAO pdao = new ProductDAO();

        String supplierId = request.getParameter("supplierId");
        String note = request.getParameter("note");
        String stockStatus = request.getParameter("stockStatus");
        String paymentStatus = request.getParameter("paymentStatus");
        String keyword = request.getParameter("keyword");

        if (supplierId == null) {
            supplierId = (String) session.getAttribute("stockin_supplierId");
        }
        if (note == null) {
            note = (String) session.getAttribute("stockin_note");
        }
        if (stockStatus == null) {
            stockStatus = (String) session.getAttribute("stockin_stockStatus");
        }
        if (paymentStatus == null) {
            paymentStatus = (String) session.getAttribute("stockin_paymentStatus");
        }

        if (stockStatus == null || stockStatus.trim().isEmpty()) {
            stockStatus = StockIn.STOCK_STATUS_PENDING;
        }
        if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
            paymentStatus = StockIn.PAYMENT_STATUS_UNPAID;
        }

        String action = request.getParameter("action");
        String addPidRaw = request.getParameter("addPid");
        String removePidRaw = request.getParameter("removePid");

        if ("clear".equals(action)) {
            cart.clear();
            session.removeAttribute("stockin_supplierId");
            session.removeAttribute("stockin_note");
            session.removeAttribute("stockin_stockStatus");
            session.removeAttribute("stockin_paymentStatus");

            if ("1".equals(request.getParameter("redirect"))) {
                response.sendRedirect("stockinList");
                return;
            }

            supplierId = null;
            note = null;
            stockStatus = StockIn.STOCK_STATUS_PENDING;
            paymentStatus = StockIn.PAYMENT_STATUS_UNPAID;
            keyword = null;

        } else {
            session.setAttribute("stockin_supplierId", supplierId);
            session.setAttribute("stockin_note", note);
            session.setAttribute("stockin_stockStatus", stockStatus);
            session.setAttribute("stockin_paymentStatus", paymentStatus);

            if (addPidRaw != null && !addPidRaw.trim().isEmpty()) {
                try {
                    int pid = Integer.parseInt(addPidRaw);
                    Product p = pdao.getById(pid);
                    if (p != null) {
                        cart.put(pid, p);
                    }
                } catch (NumberFormatException ignored) {
                }
            }

            if (removePidRaw != null && !removePidRaw.trim().isEmpty()) {
                try {
                    int pid = Integer.parseInt(removePidRaw);
                    cart.remove(pid);
                } catch (NumberFormatException ignored) {
                }
            }
        }

        List<Product> productList = pdao.search(keyword);

        request.setAttribute("keyword", keyword);
        request.setAttribute("productList", productList);
        request.setAttribute("cart", cart);

        request.setAttribute("supplierIdDraft", supplierId);
        request.setAttribute("noteDraft", note);
        request.setAttribute("stockStatusDraft", stockStatus);
        request.setAttribute("paymentStatusDraft", paymentStatus);

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
            Map<Integer, Product> cart = (Map<Integer, Product>) session.getAttribute("stockinCart");

            if (cart == null) {
                cart = new LinkedHashMap<>();
                session.setAttribute("stockinCart", cart);
            }

            String supplierRaw = request.getParameter("supplierId");
            String note = request.getParameter("note");
            String stockStatus = request.getParameter("stockStatus");
            String paymentStatus = request.getParameter("paymentStatus");
            String keyword = request.getParameter("keyword");

            session.setAttribute("stockin_supplierId", supplierRaw);
            session.setAttribute("stockin_note", note);
            session.setAttribute("stockin_stockStatus", stockStatus);
            session.setAttribute("stockin_paymentStatus", paymentStatus);

            if (cart.isEmpty()) {
                forwardToForm(request, response, cart, supplierRaw, note, stockStatus, paymentStatus, keyword,
                        "Vui lòng chọn ít nhất 1 sản phẩm!");
                return;
            }

            if (supplierRaw == null || supplierRaw.trim().isEmpty()) {
                forwardToForm(request, response, cart, supplierRaw, note, stockStatus, paymentStatus, keyword,
                        "Vui lòng nhập mã nhà cung cấp!");
                return;
            }

            int supplierId;
            try {
                supplierId = Integer.parseInt(supplierRaw.trim());
            } catch (NumberFormatException e) {
                forwardToForm(request, response, cart, supplierRaw, note, stockStatus, paymentStatus, keyword,
                        "Nhà cung cấp không tồn tại!");
                return;
            }

            if (stockStatus == null || stockStatus.trim().isEmpty()) {
                stockStatus = StockIn.STOCK_STATUS_PENDING;
            }

            if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
                paymentStatus = StockIn.PAYMENT_STATUS_UNPAID;
            }

            boolean validStockStatus
                    = StockIn.STOCK_STATUS_PENDING.equals(stockStatus)
                    || StockIn.STOCK_STATUS_COMPLETED.equals(stockStatus)
                    || StockIn.STOCK_STATUS_CANCELLED.equals(stockStatus);

            boolean validPaymentStatus
                    = StockIn.PAYMENT_STATUS_UNPAID.equals(paymentStatus)
                    || StockIn.PAYMENT_STATUS_PARTIAL.equals(paymentStatus)
                    || StockIn.PAYMENT_STATUS_PAID.equals(paymentStatus)
                    || StockIn.PAYMENT_STATUS_CANCELLED.equals(paymentStatus);

            if (!validStockStatus) {
                forwardToForm(request, response, cart, supplierRaw, note, stockStatus, paymentStatus, keyword,
                        "Trạng thái nhập hàng không hợp lệ!");
                return;
            }

            if (!validPaymentStatus) {
                forwardToForm(request, response, cart, supplierRaw, note, stockStatus, paymentStatus, keyword,
                        "Trạng thái thanh toán không hợp lệ!");
                return;
            }

            StockIn stockIn = new StockIn();
            stockIn.setSupplierId(supplierId);
            stockIn.setCreatedBy(user.getUserID());
            stockIn.setNote(note);
            stockIn.setStockStatus(stockStatus);
            stockIn.setPaymentStatus(paymentStatus);

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

                int qty;
                double cost;

                try {
                    qty = Integer.parseInt(qtyRaw.trim());
                    cost = Double.parseDouble(costRaw.trim());
                } catch (NumberFormatException e) {
                    continue;
                }

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
                forwardToForm(request, response, cart, supplierRaw, note, stockStatus, paymentStatus, keyword,
                        "Vui lòng nhập số lượng và giá nhập hợp lệ!");
                return;
            }

            stockIn.setTotalAmount(total);

            StockInDAO dao = new StockInDAO();
            boolean result = dao.insertStockInWithDetails(stockIn, details);

            if (result) {
                if (StockIn.STOCK_STATUS_COMPLETED.equals(stockIn.getStockStatus())) {
                    ProductDAO productDAO = new ProductDAO();
                    for (StockInDetail d : details) {
                        productDAO.increaseQuantity(d.getProductId(), d.getQuantity());
                    }
                }

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
                            + " | StockStatus: " + stockIn.getStockStatus()
                            + " | PaymentStatus: " + stockIn.getPaymentStatus();

                    log.setDescription(description);
                    log.setIpAddress(request.getRemoteAddr());

                    logDAO.insertLog(log);

                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                cart.clear();
                session.removeAttribute("stockin_supplierId");
                session.removeAttribute("stockin_note");
                session.removeAttribute("stockin_stockStatus");
                session.removeAttribute("stockin_paymentStatus");

                response.sendRedirect(request.getContextPath() + "/stockinList");

            } else {
                try {
                    SystemLogDAO logDAO = new SystemLogDAO();
                    SystemLog log = new SystemLog();

                    int userID = (user != null) ? user.getUserID() : 2;

                    log.setUserID(userID);
                    log.setAction("CREATE_STOCKIN");
                    log.setTargetObject("StockIn");

                    String description = "Tạo phiếu nhập thất bại | SupplierID: "
                            + stockIn.getSupplierId()
                            + " | Total: " + stockIn.getTotalAmount()
                            + " | Items: " + details.size()
                            + " | StockStatus: " + stockIn.getStockStatus()
                            + " | PaymentStatus: " + stockIn.getPaymentStatus();

                    log.setDescription(description);
                    log.setIpAddress(request.getRemoteAddr());

                    logDAO.insertLog(log);

                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                forwardToForm(request, response, cart, supplierRaw, note, stockStatus, paymentStatus, keyword,
                        "Tạo phiếu nhập thất bại!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Lỗi: " + e.getMessage());
        }
    }

    @Override
    public String getServletInfo() {
        return "Create StockIn Controller";
    }
}
