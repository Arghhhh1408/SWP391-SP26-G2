package controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import dao.InventoryAdjustmentDAO;
import dao.NotificationDAO;
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
import java.util.List;
import model.InventoryAdjustment;
import model.InventoryAdjustmentItem;
import model.Notification;
import model.SystemLog;
import model.User;

@WebServlet(name = "InventoryAdjustmentController", urlPatterns = {"/inventoryAdjustment"})
public class InventoryAdjustmentController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User user = getUser(request);
        if (user == null || (user.getRoleID() != 1 && user.getRoleID() != 2)) {
            response.sendRedirect("login");
            return;
        }

        String mode = request.getParameter("mode");

        // AJAX: tìm sản phẩm
        if ("searchProduct".equals(mode)) {
            handleSearchProduct(request, response);
            return;
        }

        // Xem chi tiết phiếu
        if ("view".equals(mode)) {
            handleView(request, response, user);
            return;
        }

        // Tạo phiếu mới
        if ("create".equals(mode)) {
            InventoryAdjustmentDAO dao = new InventoryAdjustmentDAO();
            request.setAttribute("adjCode", dao.generateAdjustmentCode());
            request.setAttribute("mode", "create");
            request.getRequestDispatcher("inventoryAdjustmentForm.jsp").forward(request, response);
            return;
        }

        // Danh sách phiếu
        int page = parsePage(request.getParameter("page"));
        int pageSize = 10;
        InventoryAdjustmentDAO dao = new InventoryAdjustmentDAO();
        int total = dao.countAdjustments();
        int totalPages = Math.max(1, (int) Math.ceil((double) total / pageSize));
        if (page > totalPages) page = totalPages;

        request.setAttribute("adjustments", dao.listAdjustments(page, pageSize));
        request.setAttribute("adjPage", page);
        request.setAttribute("adjTotalPages", totalPages);
        request.setAttribute("adjTotal", total);
        request.setAttribute("currentPage", "inventoryAdjustment");
        request.getRequestDispatcher("inventoryAdjustmentList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User user = getUser(request);
        if (user == null || (user.getRoleID() != 1 && user.getRoleID() != 2)) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");

        if ("save".equals(action) || "confirm".equals(action)) {
            handleSave(request, response, user, "confirm".equals(action));
            return;
        }

        if ("confirmExisting".equals(action)) {
            handleConfirmExisting(request, response, user);
            return;
        }

        response.sendRedirect("inventoryAdjustment");
    }

    // -----------------------------------------------------------------------
    // AJAX: tìm sản phẩm
    // -----------------------------------------------------------------------
    private void handleSearchProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String keyword = request.getParameter("q");
        InventoryAdjustmentDAO dao = new InventoryAdjustmentDAO();
        List<InventoryAdjustmentItem> products = dao.searchProducts(keyword);

        JsonArray arr = new JsonArray();
        for (InventoryAdjustmentItem p : products) {
            JsonObject obj = new JsonObject();
            obj.addProperty("productId", p.getProductId());
            obj.addProperty("sku", p.getSku());
            obj.addProperty("name", p.getProductName());
            obj.addProperty("unit", p.getUnit());
            obj.addProperty("stock", p.getOldQuantity());
            obj.addProperty("cost", p.getUnitCost() != null ? p.getUnitCost().doubleValue() : 0);
            obj.addProperty("image", p.getImageUrl() != null ? p.getImageUrl() : "");
            arr.add(obj);
        }
        try (PrintWriter out = response.getWriter()) {
            out.print(arr.toString());
        }
    }

    // -----------------------------------------------------------------------
    // Xem chi tiết phiếu
    // -----------------------------------------------------------------------
    private void handleView(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        int id = parseInt(request.getParameter("id"), 0);
        if (id <= 0) { response.sendRedirect("inventoryAdjustment"); return; }

        InventoryAdjustmentDAO dao = new InventoryAdjustmentDAO();
        InventoryAdjustment adj = dao.getAdjustmentById(id);
        if (adj == null) { response.sendRedirect("inventoryAdjustment"); return; }

        request.setAttribute("adj", adj);
        request.setAttribute("mode", "view");
        request.setAttribute("currentPage", "inventoryAdjustment");
        request.getRequestDispatcher("inventoryAdjustmentForm.jsp").forward(request, response);
    }

    // -----------------------------------------------------------------------
    // Lưu phiếu mới (Draft hoặc Confirmed)
    // -----------------------------------------------------------------------
    private void handleSave(HttpServletRequest request, HttpServletResponse response,
                            User user, boolean confirm) throws IOException {
        String adjCode    = request.getParameter("adjCode");
        String adjDate    = request.getParameter("adjDate");
        String warehouse  = request.getParameter("warehouse");
        String genReason  = request.getParameter("generalReason");
        String note       = request.getParameter("note");

        String[] productIds  = request.getParameterValues("productId[]");
        String[] oldQtys     = request.getParameterValues("oldQty[]");
        String[] newQtys     = request.getParameterValues("newQty[]");
        String[] reasons     = request.getParameterValues("reason[]");
        String[] itemNotes   = request.getParameterValues("itemNote[]");

        if (productIds == null || productIds.length == 0) {
            request.getSession().setAttribute("adjError", "Chưa có sản phẩm nào trong phiếu.");
            response.sendRedirect("inventoryAdjustment?mode=create");
            return;
        }

        List<InventoryAdjustmentItem> items = new ArrayList<>();
        for (int i = 0; i < productIds.length; i++) {
            int pid    = parseInt(productIds[i], 0);
            int oldQty = parseInt(safeGet(oldQtys, i), 0);
            int newQty = parseInt(safeGet(newQtys, i), -1);
            if (pid <= 0 || newQty < 0) continue;

            InventoryAdjustmentItem item = new InventoryAdjustmentItem();
            item.setProductId(pid);
            item.setOldQuantity(oldQty);
            item.setNewQuantity(newQty);
            item.setVariance(newQty - oldQty);
            item.setReason(safeGet(reasons, i));
            item.setItemNote(safeGet(itemNotes, i));
            items.add(item);
        }

        if (items.isEmpty()) {
            request.getSession().setAttribute("adjError", "Không có dòng hợp lệ nào.");
            response.sendRedirect("inventoryAdjustment?mode=create");
            return;
        }

        InventoryAdjustment adj = new InventoryAdjustment();
        adj.setAdjustmentCode(adjCode);
        adj.setAdjustmentDate(adjDate);
        adj.setWarehouse(warehouse);
        adj.setCreatedBy(user.getUserID());
        adj.setGeneralReason(genReason);
        adj.setNote(note);
        adj.setStatus(confirm ? "Confirmed" : "Draft");

        InventoryAdjustmentDAO dao = new InventoryAdjustmentDAO();
        int newId = dao.saveAdjustment(adj, items);

        if (newId > 0) {
            // System log
            try {
                String actor = user.getFullName() != null && !user.getFullName().isBlank()
                        ? user.getFullName() : user.getUsername();
                SystemLogDAO logDao = new SystemLogDAO();
                SystemLog log = new SystemLog();
                log.setUserID(user.getUserID());
                log.setAction(confirm ? "INVENTORY_ADJ_CONFIRM" : "INVENTORY_ADJ_DRAFT");
                log.setTargetObject("InventoryAdjustment");
                log.setDescription(actor + (confirm ? " xác nhận" : " lưu nháp") + " phiếu điều chỉnh " + adjCode);
                log.setIpAddress(request.getRemoteAddr());
                logDao.insertLog(log);
            } catch (Exception e) { e.printStackTrace(); }

            // Thông báo manager nếu xác nhận
            if (confirm) {
                try {
                    NotificationDAO nDao = new NotificationDAO();
                    String actor = user.getFullName() != null && !user.getFullName().isBlank()
                            ? user.getFullName() : user.getUsername();
                    for (Integer mid : nDao.getManagerIds()) {
                        Notification n = new Notification();
                        n.setUserId(mid);
                        n.setTitle("Điều chỉnh tồn kho mới");
                        n.setMessage(actor + " đã xác nhận phiếu điều chỉnh " + adjCode);
                        n.setType("INVENTORY_ADJUSTMENT");
                        nDao.insert(n);
                    }
                } catch (Exception e) { e.printStackTrace(); }
            }

            request.getSession().setAttribute("adjSuccess",
                    confirm ? "Phiếu " + adjCode + " đã xác nhận và cập nhật tồn kho."
                            : "Phiếu " + adjCode + " đã lưu nháp.");
            response.sendRedirect("inventoryAdjustment?mode=view&id=" + newId);
        } else {
            request.getSession().setAttribute("adjError", "Lưu phiếu thất bại. Vui lòng thử lại.");
            response.sendRedirect("inventoryAdjustment?mode=create");
        }
    }

    // -----------------------------------------------------------------------
    // Xác nhận phiếu Draft đã tồn tại
    // -----------------------------------------------------------------------
    private void handleConfirmExisting(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        int id = parseInt(request.getParameter("id"), 0);
        if (id <= 0) { response.sendRedirect("inventoryAdjustment"); return; }

        InventoryAdjustmentDAO dao = new InventoryAdjustmentDAO();
        InventoryAdjustment adj = dao.getAdjustmentById(id);
        if (adj == null) { response.sendRedirect("inventoryAdjustment"); return; }

        boolean ok = dao.confirmAdjustment(id);
        if (ok) {
            try {
                String actor = user.getFullName() != null && !user.getFullName().isBlank()
                        ? user.getFullName() : user.getUsername();
                SystemLogDAO logDao = new SystemLogDAO();
                SystemLog log = new SystemLog();
                log.setUserID(user.getUserID());
                log.setAction("INVENTORY_ADJ_CONFIRM");
                log.setTargetObject("InventoryAdjustment");
                log.setDescription(actor + " xác nhận phiếu điều chỉnh " + adj.getAdjustmentCode());
                log.setIpAddress(request.getRemoteAddr());
                logDao.insertLog(log);
            } catch (Exception e) { e.printStackTrace(); }
            request.getSession().setAttribute("adjSuccess", "Phiếu đã xác nhận và cập nhật tồn kho.");
        } else {
            request.getSession().setAttribute("adjError", "Xác nhận thất bại.");
        }
        response.sendRedirect("inventoryAdjustment?mode=view&id=" + id);
    }

    // -----------------------------------------------------------------------
    private User getUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute("acc");
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s == null ? "" : s.trim()); }
        catch (Exception e) { return def; }
    }

    private int parsePage(String s) {
        int p = parseInt(s, 1);
        return p < 1 ? 1 : p;
    }

    private String safeGet(String[] arr, int i) {
        return (arr != null && i < arr.length) ? arr[i] : null;
    }
}
