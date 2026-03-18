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
            String paymentOptionDraft,
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
        request.setAttribute("paymentOptionDraft", paymentOptionDraft);

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

        // Lấy dữ liệu draft từ request trước
        String supplierId = request.getParameter("supplierId");
        String note = request.getParameter("note");
        String paymentOption = request.getParameter("paymentOption");
        String keyword = request.getParameter("keyword");

        // Nếu request không có thì lấy từ session
        if (supplierId == null) {
            supplierId = (String) session.getAttribute("stockin_supplierId");
        }
        if (note == null) {
            note = (String) session.getAttribute("stockin_note");
        }
        if (paymentOption == null) {
            paymentOption = (String) session.getAttribute("stockin_paymentOption");
        }

        // Action xử lý
        String action = request.getParameter("action");
        String addPidRaw = request.getParameter("addPid");
        String removePidRaw = request.getParameter("removePid");

        if ("clear".equals(action)) {
            cart.clear();
            session.removeAttribute("stockin_supplierId");
            session.removeAttribute("stockin_note");
            session.removeAttribute("stockin_paymentOption");

            if ("1".equals(request.getParameter("redirect"))) {
                response.sendRedirect("stockinList");
                return;
            }

            supplierId = null;
            note = null;
            paymentOption = null;
            keyword = null;
        } else {
            // Lưu draft vào session
            session.setAttribute("stockin_supplierId", supplierId);
            session.setAttribute("stockin_note", note);
            session.setAttribute("stockin_paymentOption", paymentOption);

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
        request.setAttribute("paymentOptionDraft", paymentOption);

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
            String paymentOption = request.getParameter("paymentOption");
            String keyword = request.getParameter("keyword");

            // Lưu draft lại vào session để nếu lỗi thì form vẫn giữ dữ liệu
            session.setAttribute("stockin_supplierId", supplierRaw);
            session.setAttribute("stockin_note", note);
            session.setAttribute("stockin_paymentOption", paymentOption);

            if (cart.isEmpty()) {
                forwardToForm(request, response, cart, supplierRaw, note, paymentOption, keyword,
                        "Vui lòng chọn ít nhất 1 sản phẩm!");
                return;
            }

            if (supplierRaw == null || supplierRaw.trim().isEmpty()) {
                forwardToForm(request, response, cart, supplierRaw, note, paymentOption, keyword,
                        "Vui lòng nhập Supplier ID!");
                return;
            }

            int supplierId;
            try {
                supplierId = Integer.parseInt(supplierRaw.trim());
            } catch (NumberFormatException e) {
                forwardToForm(request, response, cart, supplierRaw, note, paymentOption, keyword,
                        "Supplier ID không hợp lệ!");
                return;
            }

            StockIn stockIn = new StockIn();
            stockIn.setSupplierId(supplierId);
            stockIn.setCreatedBy(user.getUserID());
            stockIn.setNote(note);

            if ("paid".equals(paymentOption)) {
                stockIn.setStatus("Complete");
            } else {
                stockIn.setStatus("Pending");
            }

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
                forwardToForm(request, response, cart, supplierRaw, note, paymentOption, keyword,
                        "Vui lòng nhập số lượng và giá nhập hợp lệ!");
                return;
            }

            stockIn.setTotalAmount(total);

            StockInDAO dao = new StockInDAO();
            boolean result = dao.insertStockInWithDetails(stockIn, details);

            if (result) {
                // Nếu phiếu nhập đã thanh toán (Complete) thì cập nhật số lượng sản phẩm
                if ("Complete".equals(stockIn.getStatus())) {
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
                            + " | Status: " + stockIn.getStatus();

                    log.setDescription(description);
                    log.setIpAddress(request.getRemoteAddr());

                    logDAO.insertLog(log);

                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                cart.clear();
                session.removeAttribute("stockin_supplierId");
                session.removeAttribute("stockin_note");
                session.removeAttribute("stockin_paymentOption");

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
                            + " | Status: " + stockIn.getStatus();

                    log.setDescription(description);
                    log.setIpAddress(request.getRemoteAddr());

                    logDAO.insertLog(log);

                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                forwardToForm(request, response, cart, supplierRaw, note, paymentOption, keyword,
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
