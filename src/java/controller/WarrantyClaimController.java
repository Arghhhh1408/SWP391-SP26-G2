package controller;

import dao.SystemLogDAO;
import dao.WarrantyClaimDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import model.SystemLog;
import model.User;
import model.WarrantyClaim;
import model.WarrantyClaimStatus;

@WebServlet(name = "WarrantyClaimController", urlPatterns = {"/warrantyClaims", "/warrantyClaim"})
public class WarrantyClaimController extends HttpServlet {

    private boolean ensureAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 0) {
            response.sendRedirect("login");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureAdmin(request, response)) {
            return;
        }

        String servletPath = request.getServletPath();
        WarrantyClaimDAO dao = new WarrantyClaimDAO();

        if ("/warrantyClaim".equals(servletPath)) {
            showDetail(request, response, dao);
        } else {
            showList(request, response, dao);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureAdmin(request, response)) {
            return;
        }

        String action = safeTrim(request.getParameter("action"));
        if (action == null || action.isEmpty()) {
            action = "create";
        }

        WarrantyClaimDAO dao = new WarrantyClaimDAO();
        String actor = getActor(request);

        switch (action) {
            case "create" -> handleCreate(request, response, dao, actor);
            case "updateStatus" -> handleUpdateStatus(request, response, dao, actor);
            case "addNote" -> handleAddNote(request, response, dao, actor);
            default -> {
                response.sendRedirect("warrantyClaims");
            }
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response, WarrantyClaimDAO dao)
            throws ServletException, IOException {
        List<WarrantyClaim> claims = dao.listAll();
        request.setAttribute("claims", claims);

        request.getRequestDispatcher("warrantyClaims.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response, WarrantyClaimDAO dao)
            throws ServletException, IOException {
        String idStr = safeTrim(request.getParameter("id"));
        Integer id = tryParseInt(idStr);

        if (id == null) {
            response.sendRedirect("warrantyClaims");
            return;
        }

        WarrantyClaim claim = dao.getById(id);
        if (claim == null) {
            request.setAttribute("error", "Không tìm thấy yêu cầu bảo hành với ID: " + id);
        }

        request.setAttribute("claim", claim);
        request.setAttribute("statuses", Arrays.asList(WarrantyClaimStatus.values()));

        request.getRequestDispatcher("warrantyClaimDetail.jsp").forward(request, response);
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response, WarrantyClaimDAO dao, String actor)
            throws IOException, ServletException {
        String sku = safeTrim(request.getParameter("sku"));
        String productName = safeTrim(request.getParameter("productName"));
        String customerName = safeTrim(request.getParameter("customerName"));
        String customerPhone = safeTrim(request.getParameter("customerPhone"));
        String issue = safeTrim(request.getParameter("issueDescription"));

        if (sku == null || sku.isEmpty()) {
            request.setAttribute("error", "SKU là bắt buộc.");
            forwardBackToListWithData(request, response, dao);
            return;
        }
        if (customerName == null || customerName.isEmpty()) {
            request.setAttribute("error", "Tên khách hàng là bắt buộc.");
            forwardBackToListWithData(request, response, dao);
            return;
        }
        if (issue == null || issue.isEmpty()) {
            request.setAttribute("error", "Mô tả lỗi là bắt buộc.");
            forwardBackToListWithData(request, response, dao);
            return;
        }

        WarrantyClaim c = dao.create(sku, productName, customerName, customerPhone, issue, actor);
        if (c == null) {
            request.setAttribute("error", "Không thể tạo yêu cầu (kiểm tra DB/tables).");
            forwardBackToListWithData(request, response, dao);
            return;
        }
        response.sendRedirect("warrantyClaim?id=" + c.getId());
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, WarrantyClaimDAO dao, String actor)
            throws IOException, ServletException {
        Integer id = tryParseInt(safeTrim(request.getParameter("id")));
        String statusStr = safeTrim(request.getParameter("newStatus"));
        String note = safeTrim(request.getParameter("note"));

        if (id == null) {
            response.sendRedirect("warrantyClaims");
            return;
        }
        WarrantyClaimStatus st = parseStatus(statusStr);
        if (st == null) {
            request.setAttribute("error", "Trạng thái không hợp lệ.");
            showDetail(request, response, dao);
            return;
        }

        dao.updateStatus(id, st, note, actor);

        // System Log
        try {
            User user = (User) request.getSession().getAttribute("acc");
            SystemLogDAO logDAO = new SystemLogDAO();
            SystemLog log = new SystemLog();
            log.setUserID(user.getUserID());
            
            String action = "UPDATE_STATUS_WARRANTY";
            if (st == WarrantyClaimStatus.COMPLETED) action = "COMPLETE_WARRANTY";
            if (st == WarrantyClaimStatus.REJECTED) action = "REJECT_WARRANTY";
            
            log.setAction(action);
            log.setTargetObject("WarrantyClaim: " + id);
            log.setDescription("Cập nhật trạng thái bảo hành: " + st.name() + (note != null ? " | Note: " + note : ""));
            log.setIpAddress(request.getRemoteAddr());
            logDAO.insertLog(log);
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        response.sendRedirect("warrantyClaim?id=" + id);
    }

    private void handleAddNote(HttpServletRequest request, HttpServletResponse response, WarrantyClaimDAO dao, String actor)
            throws IOException, ServletException {
        Integer id = tryParseInt(safeTrim(request.getParameter("id")));
        String note = safeTrim(request.getParameter("note"));
        if (id == null) {
            response.sendRedirect("warrantyClaims");
            return;
        }
        if (note == null || note.isEmpty()) {
            response.sendRedirect("warrantyClaim?id=" + id);
            return;
        }
        dao.addNote(id, note, actor);

        // System Log
        try {
            User user = (User) request.getSession().getAttribute("acc");
            SystemLogDAO logDAO = new SystemLogDAO();
            SystemLog log = new SystemLog();
            log.setUserID(user.getUserID());
            log.setAction("ADD_NOTE_WARRANTY");
            log.setTargetObject("WarrantyClaim: " + id);
            log.setDescription("Thêm ghi chú bảo hành: " + note);
            log.setIpAddress(request.getRemoteAddr());
            logDAO.insertLog(log);
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        response.sendRedirect("warrantyClaim?id=" + id);
    }

    private void forwardBackToListWithData(HttpServletRequest request, HttpServletResponse response, WarrantyClaimDAO dao)
            throws ServletException, IOException {
        request.setAttribute("sku", safeTrim(request.getParameter("sku")));
        request.setAttribute("productName", safeTrim(request.getParameter("productName")));
        request.setAttribute("customerName", safeTrim(request.getParameter("customerName")));
        request.setAttribute("customerPhone", safeTrim(request.getParameter("customerPhone")));
        request.setAttribute("issueDescription", safeTrim(request.getParameter("issueDescription")));
        showList(request, response, dao);
    }

    private WarrantyClaimStatus parseStatus(String statusStr) {
        if (statusStr == null || statusStr.isEmpty()) {
            return null;
        }
        try {
            return WarrantyClaimStatus.valueOf(statusStr);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private Integer tryParseInt(String s) {
        if (s == null || s.isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String safeTrim(String s) {
        return s == null ? null : s.trim();
    }

private String getActor(HttpServletRequest request) {
    HttpSession session = request.getSession();
    Object acc = session.getAttribute("acc");

    if (acc instanceof User) {
        User u = (User) acc;
        if (u.getUsername() != null && !u.getUsername().isBlank()) {
            return u.getUsername();
        }
        return "user#" + u.getUserID();
    }

    return "unknown";
}
}

