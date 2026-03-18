package controller;

import dao.ReturnDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import model.ReturnRequest;
import model.ReturnStatus;
import model.User;

@WebServlet(name = "ReturnRefundController", urlPatterns = {"/returns", "/return"})
public class ReturnRefundController extends HttpServlet {

    private boolean ensureAuthorized(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || (u.getRoleID() != 0 && u.getRoleID() != 3)) {
            response.sendRedirect("login");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureAuthorized(request, response)) {
            return;
        }

        String servletPath = request.getServletPath();
        ReturnDAO dao = new ReturnDAO();

        if ("/return".equals(servletPath)) {
            showDetail(request, response, dao);
        } else {
            showList(request, response, dao);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureAuthorized(request, response)) {
            return;
        }

        String action = safeTrim(request.getParameter("action"));
        if (action == null || action.isEmpty()) {
            action = "create";
        }

        ReturnDAO dao = new ReturnDAO();
        String actor = getActor(request);

        switch (action) {
            case "create" -> handleCreate(request, response, dao, actor);
            case "updateStatus" -> handleUpdateStatus(request, response, dao, actor);
            case "addNote" -> handleAddNote(request, response, dao, actor);
            case "recordRefund" -> handleRecordRefund(request, response, dao, actor);
            default -> response.sendRedirect("returns");
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response, ReturnDAO dao)
            throws ServletException, IOException {
        List<ReturnRequest> returns = dao.listAll();
        request.setAttribute("returns", returns);
        request.getRequestDispatcher("returns.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response, ReturnDAO dao)
            throws ServletException, IOException {
        Integer id = tryParseInt(safeTrim(request.getParameter("id")));
        if (id == null) {
            response.sendRedirect("returns");
            return;
        }

        ReturnRequest rr = dao.getById(id);
        if (rr == null) {
            request.setAttribute("error", "Không tìm thấy yêu cầu trả hàng với ID: " + id);
        }

        request.setAttribute("rr", rr);
        request.setAttribute("statuses", Arrays.asList(ReturnStatus.values()));
        request.getRequestDispatcher("returnDetail.jsp").forward(request, response);
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response, ReturnDAO dao, String actor)
            throws IOException, ServletException {
        String sku = safeTrim(request.getParameter("sku"));
        String productName = safeTrim(request.getParameter("productName"));
        String customerName = safeTrim(request.getParameter("customerName"));
        String customerPhone = safeTrim(request.getParameter("customerPhone"));
        String reason = safeTrim(request.getParameter("reason"));
        String conditionNote = safeTrim(request.getParameter("conditionNote"));

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
        if (reason == null || reason.isEmpty()) {
            request.setAttribute("error", "Lý do trả hàng là bắt buộc.");
            forwardBackToListWithData(request, response, dao);
            return;
        }

        ReturnRequest rr = dao.create(sku, productName, customerName, customerPhone, reason, conditionNote, actor);
        if (rr == null) {
            request.setAttribute("error", "Không thể tạo yêu cầu (kiểm tra DB/tables).");
            forwardBackToListWithData(request, response, dao);
            return;
        }
        response.sendRedirect("return?id=" + rr.getId());
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, ReturnDAO dao, String actor)
            throws IOException, ServletException {
        Integer id = tryParseInt(safeTrim(request.getParameter("id")));
        String statusStr = safeTrim(request.getParameter("newStatus"));
        String note = safeTrim(request.getParameter("note"));

        if (id == null) {
            response.sendRedirect("returns");
            return;
        }
        ReturnStatus st = parseStatus(statusStr);
        if (st == null) {
            request.setAttribute("error", "Trạng thái không hợp lệ.");
            showDetail(request, response, dao);
            return;
        }

        dao.updateStatus(id, st, note, actor);
        response.sendRedirect("return?id=" + id);
    }

    private void handleAddNote(HttpServletRequest request, HttpServletResponse response, ReturnDAO dao, String actor)
            throws IOException {
        Integer id = tryParseInt(safeTrim(request.getParameter("id")));
        String note = safeTrim(request.getParameter("note"));
        if (id == null) {
            response.sendRedirect("returns");
            return;
        }
        if (note == null || note.isEmpty()) {
            response.sendRedirect("return?id=" + id);
            return;
        }
        dao.addNote(id, note, actor);
        response.sendRedirect("return?id=" + id);
    }

    private void handleRecordRefund(HttpServletRequest request, HttpServletResponse response, ReturnDAO dao, String actor)
            throws IOException, ServletException {
        Integer id = tryParseInt(safeTrim(request.getParameter("id")));
        if (id == null) {
            response.sendRedirect("returns");
            return;
        }
        Double amount = tryParseDouble(safeTrim(request.getParameter("refundAmount")));
        String method = safeTrim(request.getParameter("refundMethod"));
        String reference = safeTrim(request.getParameter("refundReference"));
        String note = safeTrim(request.getParameter("note"));

        if (amount == null) {
            request.setAttribute("error", "Số tiền hoàn là bắt buộc (định dạng số).");
            showDetail(request, response, dao);
            return;
        }

        dao.recordRefund(id, amount, method, reference, note, actor);
        response.sendRedirect("return?id=" + id);
    }

    private void forwardBackToListWithData(HttpServletRequest request, HttpServletResponse response, ReturnDAO dao)
            throws ServletException, IOException {
        request.setAttribute("sku", safeTrim(request.getParameter("sku")));
        request.setAttribute("productName", safeTrim(request.getParameter("productName")));
        request.setAttribute("customerName", safeTrim(request.getParameter("customerName")));
        request.setAttribute("customerPhone", safeTrim(request.getParameter("customerPhone")));
        request.setAttribute("reason", safeTrim(request.getParameter("reason")));
        request.setAttribute("conditionNote", safeTrim(request.getParameter("conditionNote")));
        showList(request, response, dao);
    }

    private ReturnStatus parseStatus(String statusStr) {
        if (statusStr == null || statusStr.isEmpty()) {
            return null;
        }
        try {
            return ReturnStatus.valueOf(statusStr);
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

    private Double tryParseDouble(String s) {
        if (s == null || s.isEmpty()) {
            return null;
        }
        try {
            return Double.parseDouble(s);
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

