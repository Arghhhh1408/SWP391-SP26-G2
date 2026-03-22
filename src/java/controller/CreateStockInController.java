/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.ProductDAO;
import dao.StockInDAO;
import dao.SupplierDAO;
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
import model.Supplier;
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
            String paymentStatusDraft,
            String paidNowDraft,
            String keyword,
            String message) throws ServletException, IOException {

        SupplierDAO supplierDAO = new SupplierDAO();
        ProductDAO productDAO = new ProductDAO();

        List<Supplier> supplierList = supplierDAO.getAllActiveSuppliers();
        List<Product> productList = new ArrayList<>();

        if (supplierIdDraft != null && !supplierIdDraft.trim().isEmpty()) {
            try {
                int supplierId = Integer.parseInt(supplierIdDraft);
                productList = productDAO.searchBySupplier(supplierId, keyword == null ? "" : keyword.trim());
            } catch (Exception e) {
                productList = new ArrayList<>();
            }
        }

        request.setAttribute("message", message);
        request.setAttribute("cart", cart);
        request.setAttribute("keyword", keyword);
        request.setAttribute("productList", productList);
        request.setAttribute("supplierList", supplierList);

        request.setAttribute("supplierIdDraft", supplierIdDraft);
        request.setAttribute("noteDraft", noteDraft);
        request.setAttribute("stockStatusDraft", StockIn.STOCK_STATUS_PENDING);
        request.setAttribute("paymentStatusDraft", paymentStatusDraft);
        request.setAttribute("paidNowDraft", paidNowDraft);

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

        @SuppressWarnings("unchecked")
        Map<Integer, Product> cart = (Map<Integer, Product>) session.getAttribute("stockinCart");
        if (cart == null) {
            cart = new LinkedHashMap<>();
            session.setAttribute("stockinCart", cart);
        }

        SupplierDAO supplierDAO = new SupplierDAO();
        ProductDAO productDAO = new ProductDAO();

        String supplierId = request.getParameter("supplierId");
        String note = request.getParameter("note");
        String paymentStatus = request.getParameter("paymentStatus");
        String paidNow = request.getParameter("paidNow");
        String keyword = request.getParameter("keyword");

        String oldSupplierId = (String) session.getAttribute("stockin_supplierId");

        if (supplierId == null) {
            supplierId = oldSupplierId;
        }
        if (note == null) {
            note = (String) session.getAttribute("stockin_note");
        }
        if (paymentStatus == null) {
            paymentStatus = (String) session.getAttribute("stockin_paymentStatus");
        }
        if (paidNow == null) {
            paidNow = (String) session.getAttribute("stockin_paidNow");
        }

        if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
            paymentStatus = StockIn.PAYMENT_STATUS_UNPAID;
        }
        if (paidNow == null || paidNow.trim().isEmpty()) {
            paidNow = "0";
        }

        String action = request.getParameter("action");
        String addPidRaw = request.getParameter("addPid");
        String removePidRaw = request.getParameter("removePid");

        if ("clear".equals(action)) {
            cart.clear();
            session.removeAttribute("stockin_supplierId");
            session.removeAttribute("stockin_note");
            session.removeAttribute("stockin_paymentStatus");
            session.removeAttribute("stockin_paidNow");

            response.sendRedirect("stockinList");
            return;
        }

        // Reset cart nếu người dùng đổi nhà cung cấp
        boolean supplierChanged = false;
        if (supplierId != null && oldSupplierId != null && !supplierId.equals(oldSupplierId)) {
            supplierChanged = true;
        }
        if (supplierId != null && oldSupplierId == null && !supplierId.trim().isEmpty()) {
            supplierChanged = false; // lần đầu chọn supplier thì không coi là đổi
        }

        if (supplierChanged) {
            cart.clear();
        }

        session.setAttribute("stockin_supplierId", supplierId);
        session.setAttribute("stockin_note", note);
        session.setAttribute("stockin_paymentStatus", paymentStatus);
        session.setAttribute("stockin_paidNow", paidNow);

        if (addPidRaw != null && !addPidRaw.trim().isEmpty()) {
            try {
                int pid = Integer.parseInt(addPidRaw);
                if (supplierId != null && !supplierId.trim().isEmpty()) {
                    int sid = Integer.parseInt(supplierId);

                    if (productDAO.existsInSupplier(sid, pid)) {
                        Product p = productDAO.getByIdAndSupplier(pid, sid);
                        if (p != null) {
                            cart.put(pid, p);
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (removePidRaw != null && !removePidRaw.trim().isEmpty()) {
            try {
                int pid = Integer.parseInt(removePidRaw);
                cart.remove(pid);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        List<Product> productList = new ArrayList<>();
        if (supplierId != null && !supplierId.trim().isEmpty()) {
            try {
                int sid = Integer.parseInt(supplierId);
                productList = productDAO.searchBySupplier(sid, keyword == null ? "" : keyword.trim());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (supplierChanged) {
            request.setAttribute("message", "Đã đổi nhà cung cấp, danh sách sản phẩm đã chọn được làm mới.");
        }

        request.setAttribute("supplierList", supplierDAO.getAllActiveSuppliers());
        request.setAttribute("productList", productList);
        request.setAttribute("cart", cart);
        request.setAttribute("keyword", keyword);

        request.setAttribute("supplierIdDraft", supplierId);
        request.setAttribute("noteDraft", note);
        request.setAttribute("stockStatusDraft", StockIn.STOCK_STATUS_PENDING);
        request.setAttribute("paymentStatusDraft", paymentStatus);
        request.setAttribute("paidNowDraft", paidNow);

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

        @SuppressWarnings("unchecked")
        Map<Integer, Product> cart = (Map<Integer, Product>) session.getAttribute("stockinCart");
        if (cart == null) {
            cart = new LinkedHashMap<>();
            session.setAttribute("stockinCart", cart);
        }

        String supplierRaw = request.getParameter("supplierId");
        String note = request.getParameter("note");
        String paymentStatus = request.getParameter("paymentStatus");
        String paidNowRaw = request.getParameter("paidNow");
        String keyword = request.getParameter("keyword");

        session.setAttribute("stockin_supplierId", supplierRaw);
        session.setAttribute("stockin_note", note);
        session.setAttribute("stockin_paymentStatus", paymentStatus);
        session.setAttribute("stockin_paidNow", paidNowRaw);

        if (cart.isEmpty()) {
            forwardToForm(request, response, cart, supplierRaw, note, paymentStatus, paidNowRaw, keyword,
                    "Vui lòng chọn ít nhất 1 sản phẩm.");
            return;
        }

        if (supplierRaw == null || supplierRaw.trim().isEmpty()) {
            forwardToForm(request, response, cart, supplierRaw, note, paymentStatus, paidNowRaw, keyword,
                    "Vui lòng chọn nhà cung cấp.");
            return;
        }

        int supplierId;
        try {
            supplierId = Integer.parseInt(supplierRaw.trim());
        } catch (Exception e) {
            forwardToForm(request, response, cart, supplierRaw, note, paymentStatus, paidNowRaw, keyword,
                    "Nhà cung cấp không hợp lệ.");
            return;
        }

        SupplierDAO supplierDAO = new SupplierDAO();
        if (!supplierDAO.isActiveSupplier(supplierId)) {
            forwardToForm(request, response, cart, supplierRaw, note, paymentStatus, paidNowRaw, keyword,
                    "Nhà cung cấp không tồn tại hoặc đã ngừng hoạt động.");
            return;
        }

        if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
            paymentStatus = StockIn.PAYMENT_STATUS_UNPAID;
        }

        boolean validPaymentStatus
                = StockIn.PAYMENT_STATUS_UNPAID.equals(paymentStatus)
                || StockIn.PAYMENT_STATUS_PARTIAL.equals(paymentStatus)
                || StockIn.PAYMENT_STATUS_PAID.equals(paymentStatus);

        if (!validPaymentStatus) {
            forwardToForm(request, response, cart, supplierRaw, note, paymentStatus, paidNowRaw, keyword,
                    "Trạng thái thanh toán không hợp lệ.");
            return;
        }

        double paidNow = 0;
        try {
            if (paidNowRaw != null && !paidNowRaw.trim().isEmpty()) {
                paidNow = Double.parseDouble(paidNowRaw.trim());
            }
        } catch (Exception e) {
            forwardToForm(request, response, cart, supplierRaw, note, paymentStatus, paidNowRaw, keyword,
                    "Số tiền thanh toán ban đầu không hợp lệ.");
            return;
        }

        if (paidNow < 0) {
            forwardToForm(request, response, cart, supplierRaw, note, paymentStatus, paidNowRaw, keyword,
                    "Số tiền thanh toán ban đầu phải >= 0.");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        List<StockInDetail> details = new ArrayList<>();
        double total = 0;

        for (Integer pid : cart.keySet()) {
            if (!productDAO.existsInSupplier(supplierId, pid)) {
                continue;
            }

            String qtyRaw = request.getParameter("qty_" + pid);
            String costRaw = request.getParameter("cost_" + pid);

            if (qtyRaw == null || qtyRaw.trim().isEmpty() || costRaw == null || costRaw.trim().isEmpty()) {
                continue;
            }

            try {
                int qty = Integer.parseInt(qtyRaw.trim());
                double cost = Double.parseDouble(costRaw.trim());

                if (qty <= 0 || cost < 0) {
                    continue;
                }

                StockInDetail d = new StockInDetail();
                d.setProductId(pid);
                d.setQuantity(qty);
                d.setReceivedQuantity(0);
                d.setUnitCost(cost);
                details.add(d);

                total += qty * cost;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (details.isEmpty()) {
            forwardToForm(request, response, cart, supplierRaw, note, paymentStatus, paidNowRaw, keyword,
                    "Vui lòng nhập số lượng và đơn giá hợp lệ.");
            return;
        }

        if (paidNow > total) {
            forwardToForm(request, response, cart, supplierRaw, note, paymentStatus, paidNowRaw, keyword,
                    "Thanh toán ban đầu không được lớn hơn tổng tiền phiếu.");
            return;
        }

        String finalPaymentStatus = paidNow <= 0
                ? StockIn.PAYMENT_STATUS_UNPAID
                : (paidNow < total ? StockIn.PAYMENT_STATUS_PARTIAL : StockIn.PAYMENT_STATUS_PAID);

        StockIn stockIn = new StockIn();
        stockIn.setSupplierId(supplierId);
        stockIn.setCreatedBy(user.getUserID());
        stockIn.setNote(note);
        stockIn.setStockStatus(StockIn.STOCK_STATUS_PENDING);
        stockIn.setPaymentStatus(finalPaymentStatus);
        stockIn.setTotalAmount(total);

        StockInDAO stockInDAO = new StockInDAO();
        int stockInId = stockInDAO.insertStockInWithDetailsAndDebt(stockIn, details, paidNow);

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

            cart.clear();
            session.removeAttribute("stockin_supplierId");
            session.removeAttribute("stockin_note");
            session.removeAttribute("stockin_paymentStatus");
            session.removeAttribute("stockin_paidNow");

            response.sendRedirect(request.getContextPath() + "/stockinList");
        } else {
            forwardToForm(request, response, cart, supplierRaw, note, paymentStatus, paidNowRaw, keyword,
                    "Tạo phiếu nhập thất bại.");
        }
    }

    @Override
    public String getServletInfo() {
        return "Create StockIn Controller";
    }
}
