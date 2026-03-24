/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.ProductDAO;
import dao.StockInDAO;
import dao.SupplierDAO;
import dao.SystemLogDAO;
import dao.NotificationDAO;
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
import model.Notification;
import model.Product;
import model.StockIn;
import model.StockInDetail;
import model.StockInDraftItem;
import model.Supplier;
import model.SystemLog;
import model.User;
import websocket.NotificationEndpoint;

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

    private Map<Integer, StockInDraftItem> getCart(HttpSession session) {
        @SuppressWarnings("unchecked")
        Map<Integer, StockInDraftItem> cart
                = (Map<Integer, StockInDraftItem>) session.getAttribute("stockinCart");

        if (cart == null) {
            cart = new LinkedHashMap<>();
            session.setAttribute("stockinCart", cart);
        }
        return cart;
    }

    private double calculateTotal(Map<Integer, StockInDraftItem> cart) {
        double total = 0;
        for (StockInDraftItem item : cart.values()) {
            total += item.getQuantity() * item.getUnitCost();
        }
        return total;
    }

    private String calculatePaymentStatus(double paidNow, double total) {
        if (total <= 0) {
            return "AUTO";
        }
        if (paidNow <= 0) {
            return StockIn.PAYMENT_STATUS_UNPAID;
        }
        if (paidNow < total) {
            return StockIn.PAYMENT_STATUS_PARTIAL;
        }
        return StockIn.PAYMENT_STATUS_PAID;
    }

    private void clearDraft(HttpSession session) {
        Map<Integer, StockInDraftItem> cart = getCart(session);
        cart.clear();
        session.removeAttribute("stockin_supplierId");
        session.removeAttribute("stockin_note");
        session.removeAttribute("stockin_paidNow");
    }

    private void forwardForm(HttpServletRequest request, HttpServletResponse response,
            String message, String messageType)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        ProductDAO productDAO = new ProductDAO();
        SupplierDAO supplierDAO = new SupplierDAO();

        Map<Integer, StockInDraftItem> cart = getCart(session);

        String supplierIdDraft = (String) session.getAttribute("stockin_supplierId");
        String noteDraft = (String) session.getAttribute("stockin_note");
        String paidNowDraft = (String) session.getAttribute("stockin_paidNow");
        String keyword = request.getParameter("keyword");

        double paidNow = 0;
        try {
            if (paidNowDraft != null && !paidNowDraft.trim().isEmpty()) {
                paidNow = Double.parseDouble(paidNowDraft.trim());
            }
        } catch (Exception e) {
            paidNow = 0;
        }

        boolean showDropdown = "true".equals(request.getParameter("showDropdown"));
        List<Product> productList = new ArrayList<>();

        if (showDropdown && supplierIdDraft != null && !supplierIdDraft.trim().isEmpty()) {
            try {
                int sid = Integer.parseInt(supplierIdDraft);
                productList = productDAO.searchBySupplier(sid, keyword == null ? "" : keyword.trim());
            } catch (Exception e) {
                productList = new ArrayList<>();
            }
        }

        List<Supplier> supplierList = supplierDAO.getAllActiveSuppliers();
        double totalDraft = calculateTotal(cart);
        String paymentStatusDraft = calculatePaymentStatus(paidNow, totalDraft);

        request.setAttribute("supplierList", supplierList);
        request.setAttribute("productList", productList);
        request.setAttribute("cart", cart);
        request.setAttribute("supplierIdDraft", supplierIdDraft);
        request.setAttribute("noteDraft", noteDraft == null ? "" : noteDraft);
        request.setAttribute("paidNowDraft", paidNowDraft == null ? "" : paidNowDraft);
        request.setAttribute("keyword", keyword == null ? "" : keyword);
        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
        request.setAttribute("totalDraft", totalDraft);
        request.setAttribute("paymentStatusDraft", paymentStatusDraft);
        request.setAttribute("showDropdown", showDropdown);

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
            response.sendRedirect("login.jsp");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        Map<Integer, StockInDraftItem> cart = getCart(session);

        String action = request.getParameter("action");
        String supplierId = request.getParameter("supplierId");
        String note = request.getParameter("note");
        String paidNow = request.getParameter("paidNow");

        String oldSupplierId = (String) session.getAttribute("stockin_supplierId");

        if (supplierId != null) {
            if (oldSupplierId != null && !oldSupplierId.equals(supplierId)) {
                cart.clear();
            }
            session.setAttribute("stockin_supplierId", supplierId);
        }

        if (note != null) {
            session.setAttribute("stockin_note", note);
        }

        if (paidNow != null) {
            session.setAttribute("stockin_paidNow", paidNow);
        }

        if ("clear".equals(action)) {
            clearDraft(session);
            response.sendRedirect("createStockIn");
            return;
        }

        if ("add".equals(action)) {
            try {
                String pidRaw = request.getParameter("pid");
                String supplierIdDraft = (String) session.getAttribute("stockin_supplierId");

                if (pidRaw != null && supplierIdDraft != null && !supplierIdDraft.trim().isEmpty()) {
                    int pid = Integer.parseInt(pidRaw);
                    int sid = Integer.parseInt(supplierIdDraft);

                    if (productDAO.existsInSupplier(sid, pid)) {
                        Product p = productDAO.getByIdAndSupplier(pid, sid);
                        if (p != null && !cart.containsKey(pid)) {
                            StockInDraftItem item = new StockInDraftItem();
                            item.setProductId(p.getId());
                            item.setProductName(p.getName());
                            item.setSku(p.getSku());
                            item.setUnit(p.getUnit());
                            item.setDefaultCost(p.getCost());
                            item.setQuantity(1);
                            item.setUnitCost(p.getCost());
                            cart.put(pid, item);
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if ("remove".equals(action)) {
            try {
                String pidRaw = request.getParameter("pid");
                if (pidRaw != null) {
                    int pid = Integer.parseInt(pidRaw);
                    cart.remove(pid);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        forwardForm(request, response, null, null);
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

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("acc") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("acc");
        if (user.getRoleID() != 1 && user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        Map<Integer, StockInDraftItem> cart = getCart(session);

        String supplierRaw = request.getParameter("supplierId");
        String note = request.getParameter("note");
        String paidNowRaw = request.getParameter("paidNow");

        session.setAttribute("stockin_supplierId", supplierRaw);
        session.setAttribute("stockin_note", note);
        session.setAttribute("stockin_paidNow", paidNowRaw);

        if (supplierRaw == null || supplierRaw.trim().isEmpty()) {
            forwardForm(request, response, "Vui lòng chọn nhà cung cấp.", "error");
            return;
        }

        if (cart.isEmpty()) {
            forwardForm(request, response, "Vui lòng chọn ít nhất 1 sản phẩm.", "error");
            return;
        }

        int supplierId;
        try {
            supplierId = Integer.parseInt(supplierRaw.trim());
        } catch (Exception e) {
            forwardForm(request, response, "Nhà cung cấp không hợp lệ.", "error");
            return;
        }

        SupplierDAO supplierDAO = new SupplierDAO();
        if (!supplierDAO.isActiveSupplier(supplierId)) {
            forwardForm(request, response, "Nhà cung cấp không tồn tại hoặc đã ngừng hoạt động.", "error");
            return;
        }

        double paidNow = 0;
        try {
            if (paidNowRaw != null && !paidNowRaw.trim().isEmpty()) {
                paidNow = Double.parseDouble(paidNowRaw.trim());
            }
        } catch (Exception e) {
            forwardForm(request, response, "Số tiền thanh toán ban đầu không hợp lệ.", "error");
            return;
        }

        if (paidNow < 0) {
            forwardForm(request, response, "Số tiền thanh toán ban đầu phải >= 0.", "error");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        List<StockInDetail> details = new ArrayList<>();
        double total = 0;

        for (StockInDraftItem item : cart.values()) {
            if (!productDAO.existsInSupplier(supplierId, item.getProductId())) {
                forwardForm(request, response, "Có sản phẩm không còn thuộc nhà cung cấp đã chọn.", "error");
                return;
            }

            String qtyRaw = request.getParameter("qty_" + item.getProductId());
            String costRaw = request.getParameter("cost_" + item.getProductId());

            int qty;
            double cost;

            try {
                qty = Integer.parseInt(qtyRaw.trim());
                cost = Double.parseDouble(costRaw.trim());
            } catch (Exception e) {
                forwardForm(request, response, "Số lượng hoặc giá nhập không hợp lệ.", "error");
                return;
            }

            if (qty <= 0) {
                forwardForm(request, response, "Số lượng nhập phải lớn hơn 0.", "error");
                return;
            }

            if (cost < 0) {
                forwardForm(request, response, "Giá nhập phải >= 0.", "error");
                return;
            }

            item.setQuantity(qty);
            item.setUnitCost(cost);

            StockInDetail d = new StockInDetail();
            d.setProductId(item.getProductId());
            d.setQuantity(qty);
            d.setReceivedQuantity(0);
            d.setUnitCost(cost);
            details.add(d);

            total += qty * cost;
        }

        if (details.isEmpty()) {
            forwardForm(request, response, "Không có chi tiết phiếu nhập hợp lệ.", "error");
            return;
        }

        if (paidNow > total) {
            forwardForm(request, response, "Thanh toán ban đầu không được lớn hơn tổng tiền phiếu.", "error");
            return;
        }

        String finalPaymentStatus = calculatePaymentStatus(paidNow, total);
        if ("AUTO".equals(finalPaymentStatus)) {
            finalPaymentStatus = StockIn.PAYMENT_STATUS_UNPAID;
        }

        StockIn stockIn = new StockIn();
        stockIn.setSupplierId(supplierId);
        stockIn.setCreatedBy(user.getUserID());
        stockIn.setNote(note);
        stockIn.setStockStatus(StockIn.STOCK_STATUS_PENDING);
        stockIn.setPaymentStatus(finalPaymentStatus);
        stockIn.setTotalAmount(total);
        stockIn.setInitialPaidAmount(paidNow);

        StockInDAO stockInDAO = new StockInDAO();
        int stockInId;

        try {
            stockInId = stockInDAO.insertStockInWithDetailsAndDebt(stockIn, details, paidNow);
        } catch (Exception ex) {
            ex.printStackTrace();
            forwardForm(request, response, "Tạo phiếu nhập thất bại: " + ex.getMessage(), "error");
            return;
        }

        if (stockInId > 0) {
            try {
                SystemLogDAO logDAO = new SystemLogDAO();
                SystemLog log = new SystemLog();
                log.setUserID(user.getUserID());
                log.setAction("CREATE_STOCKIN");
                log.setTargetObject("StockIn");
                log.setDescription("Tạo phiếu nhập | StockInID: " + stockInId
                        + " | SupplierID: " + supplierId
                        + " | Total: " + total
                        + " | PaidNow: " + paidNow
                        + " | PaymentStatus: " + finalPaymentStatus
                        + " | Items: " + details.size());
                log.setIpAddress(request.getRemoteAddr());
                logDAO.insertLog(log);
            } catch (Exception e) {
                e.printStackTrace();
            }

            clearDraft(session);
            session.setAttribute("flashMessage", "Tạo phiếu nhập thành công.");
            session.setAttribute("flashType", "success");

            // ---- Notification dispatch ----
            try {
                SupplierDAO supplierDAO2 = new SupplierDAO();
                Supplier supplier = supplierDAO2.getSupplierById(supplierId);
                String supplierName = (supplier != null) ? supplier.getSupplierName() : "#" + supplierId;
                sendStockInNotification(user, stockInId, supplierName, details, total, paidNow, finalPaymentStatus);
            } catch (Exception notifEx) {
                notifEx.printStackTrace(); // notification failure must NOT break the main flow
            }

            response.sendRedirect("stockinList");
        } else {
            forwardForm(request, response, "Tạo phiếu nhập thất bại.", "error");
        }
    }

    @Override
    public String getServletInfo() {
        return "Create StockIn Controller";
    }

    // -----------------------------------------------------------------------
    // Notification helper
    // -----------------------------------------------------------------------
    private void sendStockInNotification(User staff, int stockInId, String supplierName,
            List<StockInDetail> details, double total, double initialPaidAmount, String paymentStatus) {

        // Build human-readable message
        StringBuilder msg = new StringBuilder();
        msg.append("Nhân viên ").append(staff.getFullName() != null ? staff.getFullName() : staff.getUsername())
                .append(" đã tạo phiếu nhập thành công.\n")
                .append("Nhà cung cấp: ").append(supplierName).append("\n")
                .append("Chi tiết sản phẩm:\n");

        for (StockInDetail d : details) {
            String pName = d.getProductName() != null ? d.getProductName() : "SP#" + d.getProductId();
            msg.append("  - ").append(pName)
                    .append(" | Số lượng: ").append(d.getQuantity())
                    .append(" | Đơn giá: ").append(String.format("%,.0f đ", d.getUnitCost()))
                    .append(" | Thành tiền: ").append(String.format("%,.0f đ", d.getQuantity() * d.getUnitCost()))
                    .append("\n");
        }
        msg.append("Tổng tiền: ").append(String.format("%,.0f đ", total)).append("\n");
        msg.append("Thanh toán ban đầu: ").append(String.format("%,.0f đ", initialPaidAmount)).append("\n");
        msg.append("Công nợ phát sinh: ").append(String.format("%,.0f đ", total - initialPaidAmount)).append("\n");
        String ps;
        switch (paymentStatus) {
            case StockIn.PAYMENT_STATUS_PAID:
                ps = "Đã thanh toán";
                break;
            case StockIn.PAYMENT_STATUS_PARTIAL:
                ps = "Thanh toán một phần";
                break;
            default:
                ps = "Chưa thanh toán";
        }
        msg.append("Trạng thái thanh toán: ").append(ps);

        String title = "Phiếu nhập #" + stockInId + " mới từ "
                + (staff.getFullName() != null ? staff.getFullName() : staff.getUsername());

        NotificationDAO notifDAO = new NotificationDAO();
        List<Integer> managerIds = notifDAO.getManagerIds();

        for (int managerId : managerIds) {
            Notification n = new Notification();
            n.setUserId(managerId);
            n.setTitle(title);
            n.setMessage(msg.toString());
            n.setType("STOCKIN_CREATED");
            notifDAO.insert(n);

            // Push WebSocket badge update to this manager
            int unread = notifDAO.countUnread(managerId);
            NotificationEndpoint.sendToUser(managerId,
                    "{\"unreadCount\":" + unread + "}");
        }
    }
}
