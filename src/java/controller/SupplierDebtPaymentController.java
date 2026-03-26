package controller;

import dao.SupplierDAO;
import dao.SupplierDebtDAO;
import dao.SystemLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.SupplierDebt;
import model.SupplierDebtPayment;
import model.SystemLog;
import model.User;

@WebServlet(name = "SupplierDebtPaymentController", urlPatterns = {"/supplierDebtPayments"})
public class SupplierDebtPaymentController extends HttpServlet {

    private final SupplierDebtDAO debtDAO = new SupplierDebtDAO();
    private final SupplierDAO supplierDAO = new SupplierDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getUser(request, response);
        if (user == null) return;

        Integer supplierId = parseInt(request.getParameter("supplierId"));
        Integer debtId = parseInt(request.getParameter("debtId"));
        if (supplierId == null || debtId == null) {
            response.sendRedirect("supplierList");
            return;
        }

        SupplierDebt debt = debtDAO.getDebtById(debtId);
        if (debt == null || debt.getSupplierID() != supplierId) {
            response.sendRedirect("supplierDebt?supplierId=" + supplierId + "&error=debt_not_found");
            return;
        }

        List<SupplierDebtPayment> payments = debtDAO.getPaymentHistoryByDebtId(debtId);
        request.setAttribute("selectedSupplierId", supplierId);
        request.setAttribute("selectedSupplierName", supplierDAO.getSupplierNameById(supplierId));
        request.setAttribute("debt", debt);
        request.setAttribute("paymentList", payments);
        insertLog(user, request, "VIEW_SUPPLIER_DEBT_PAYMENT_HISTORY", "Debt ID: " + debtId,
                "Viewed payment history of supplier debt.");
        request.getRequestDispatcher("supplierDebtPaymentHistory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getUser(request, response);
        if (user == null) return;
        if (user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        Integer supplierId = parseInt(request.getParameter("supplierId"));
        Integer debtId = parseInt(request.getParameter("debtId"));
        String action = request.getParameter("action");
        if (supplierId == null || debtId == null) {
            response.sendRedirect("supplierList");
            return;
        }

        if ("addPayment".equalsIgnoreCase(action)) {
            try {
                double amount = Double.parseDouble(request.getParameter("paymentAmount"));
                String note = request.getParameter("note");
                boolean ok = debtDAO.addInstallmentPayment(debtId, amount, user.getUserID(), note);
                insertLog(user, request, "ADD_SUPPLIER_DEBT_PAYMENT", "Debt ID: " + debtId,
                        ok ? "Added installment payment for supplier debt." : "Failed to add installment payment for supplier debt.");
                response.sendRedirect("supplierDebtPayments?supplierId=" + supplierId + "&debtId=" + debtId + (ok ? "&msg=payment_added" : "&error=payment_add_failed"));
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("supplierDebtPayments?supplierId=" + supplierId + "&debtId=" + debtId + "&error=invalid_payment_amount");
                return;
            }
        }

        if ("confirmPaid".equalsIgnoreCase(action)) {
            String note = request.getParameter("note");
            boolean ok = debtDAO.confirmPaid(debtId, user.getUserID(), note);
            insertLog(user, request, "CONFIRM_SUPPLIER_DEBT_PAID", "Debt ID: " + debtId,
                    ok ? "Confirmed supplier debt as fully paid." : "Failed to confirm supplier debt as fully paid.");
            response.sendRedirect("supplierDebtPayments?supplierId=" + supplierId + "&debtId=" + debtId + (ok ? "&msg=paid_confirmed" : "&error=paid_confirm_failed"));
            return;
        }

        response.sendRedirect("supplierDebtPayments?supplierId=" + supplierId + "&debtId=" + debtId);
    }

    private User getUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("acc");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return null;
        }
        if (user.getRoleID() != 1 && user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return null;
        }
        return user;
    }

    private Integer parseInt(String value) {
        try {
            return value == null || value.trim().isEmpty() ? null : Integer.parseInt(value.trim());
        } catch (Exception e) {
            return null;
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
