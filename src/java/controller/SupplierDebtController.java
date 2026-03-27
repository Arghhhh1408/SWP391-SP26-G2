package controller;

import dao.SupplierDAO;
import dao.SupplierDebtDAO;
import dao.SystemLogDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import model.SupplierDebt;
import model.SystemLog;
import model.User;
import utils.SupplierEmailService;

@WebServlet(name = "SupplierDebtController", urlPatterns = {"/supplierDebt"})
public class SupplierDebtController extends HttpServlet {

    private final SupplierDebtDAO debtDAO = new SupplierDebtDAO();
    private final SupplierDAO supplierDAO = new SupplierDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("acc") : null;
        if (user == null) { response.sendRedirect("login.jsp"); return; }
        if (user.getRoleID() != 1 && user.getRoleID() != 2) { response.sendRedirect("login.jsp"); return; }

        String supplierIdRaw = request.getParameter("supplierId");
        String status = request.getParameter("status");
        String fromDateRaw = request.getParameter("fromDate");
        String toDateRaw = request.getParameter("toDate");
        Integer supplierId;
        Date fromDate = null;
        Date toDate = null;
        try {
            if (supplierIdRaw == null || supplierIdRaw.trim().isEmpty()) { response.sendRedirect("supplierList"); return; }
            supplierId = Integer.parseInt(supplierIdRaw);
            if (fromDateRaw != null && !fromDateRaw.trim().isEmpty()) fromDate = Date.valueOf(fromDateRaw);
            if (toDateRaw != null && !toDateRaw.trim().isEmpty()) toDate = Date.valueOf(toDateRaw);
        } catch (Exception e) {
            request.setAttribute("error", "Dữ liệu tìm kiếm không hợp lệ!");
            request.getRequestDispatcher("supplierDebtList.jsp").forward(request, response);
            return;
        }

        String supplierName = supplierDAO.getSupplierNameById(supplierId);
        List<SupplierDebt> list = debtDAO.searchDebts(supplierId, status, fromDate, toDate);
        sendDueSoonReminders(list);
        insertLog(user, request, "VIEW_SUPPLIER_DEBT", "SupplierDebt", "Viewed supplier debt of supplierId=" + supplierId);
        request.setAttribute("selectedSupplierId", supplierId);
        request.setAttribute("selectedSupplierName", supplierName);
        request.setAttribute("debtList", list);
        request.getRequestDispatcher("supplierDebtList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("acc") : null;
        if (user == null) { response.sendRedirect("login.jsp"); return; }
        String action = request.getParameter("action");
        if (!"confirmPaid".equalsIgnoreCase(action)) {
            response.sendRedirect("supplierList");
            return;
        }
        if (user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }
        String supplierIdRaw = request.getParameter("supplierId");
        String debtIdRaw = request.getParameter("debtId");
        String note = request.getParameter("note");
        try {
            int supplierId = Integer.parseInt(supplierIdRaw);
            int debtId = Integer.parseInt(debtIdRaw);
            boolean ok = debtDAO.confirmPaid(debtId, user.getUserID(), note);
            insertLog(user, request, "CONFIRM_SUPPLIER_DEBT_PAID", "Debt ID: " + debtId, ok ? "Manager xác nhận đã thanh toán công nợ nhà cung cấp." : "Xác nhận thanh toán công nợ thất bại.");
            response.sendRedirect("supplierDebt?supplierId=" + supplierId + (ok ? "&msg=paid_confirmed" : "&error=paid_confirm_failed"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("supplierList");
        }
    }

    private void sendDueSoonReminders(List<SupplierDebt> debts) {
        if (debts == null || debts.isEmpty()) return;
        UserDAO userDAO = new UserDAO();
        SupplierEmailService mailService = new SupplierEmailService();
        java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
        List<String> managerEmails = userDAO.getActiveManagerEmails();
        List<Integer> managerIds = userDAO.getActiveManagerIds();
        if (managerEmails.isEmpty() || managerIds.isEmpty()) return;
        for (SupplierDebt debt : debts) {
            if (debt.getDueDate() == null) continue;
            long days = (debt.getDueDate().getTime() - today.getTime()) / (24L * 60 * 60 * 1000);
            if (days < 0 || days >= 7) continue;
            boolean anyNeedSend = false;
            for (int i = 0; i < managerIds.size(); i++) {
                int managerId = managerIds.get(i);
                if (!debtDAO.hasReminderAudit(debt.getDebtID(), managerId, "DUE_SOON_7D", today)) {
                    anyNeedSend = true;
                    debtDAO.insertReminderAudit(debt.getDebtID(), managerId, "DUE_SOON_7D", today);
                }
            }
            if (anyNeedSend) {
                mailService.sendSupplierDebtReminders(managerEmails, debt, debt.getSupplierName());
            }
        }
    }

    private void insertLog(User user, HttpServletRequest request, String action, String target, String desc) {
        try {
            SystemLogDAO logDao = new SystemLogDAO();
            SystemLog log = new SystemLog();
            log.setUserID(user.getUserID());
            log.setAction(action);
            log.setTargetObject(target);
            log.setDescription(desc);
            log.setIpAddress(request.getRemoteAddr());
            logDao.insertLog(log);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
