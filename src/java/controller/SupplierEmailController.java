package controller;

import dao.SupplierDAO;
import dao.SystemLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Supplier;
import model.SystemLog;
import model.User;
import utils.AppUrlUtils;
import utils.SupplierEmailService;

@WebServlet(name = "SupplierEmailController", urlPatterns = {"/supplier-email"})
public class SupplierEmailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("confirm".equalsIgnoreCase(action)) {
            handleConfirm(request, response);
            return;
        }
        response.sendRedirect("supplierList");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User acc = session == null ? null : (User) session.getAttribute("acc");
        if (acc == null || acc.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }
        String action = request.getParameter("action");
        if (!"sendVerification".equalsIgnoreCase(action)) {
            response.sendRedirect("supplierList");
            return;
        }

        String supplierIdRaw = request.getParameter("supplierId");
        SupplierDAO supplierDAO = new SupplierDAO();
        try {
            int supplierId = Integer.parseInt(supplierIdRaw);
            Supplier supplier = supplierDAO.getSupplierById(supplierId);
            if (supplier == null || supplier.getEmail() == null || supplier.getEmail().trim().isEmpty()) {
                session.setAttribute("message", "Nhà cung cấp chưa có email để xác nhận.");
                session.setAttribute("status", "error");
                response.sendRedirect("supplierList");
                return;
            }
            SupplierEmailService emailService = new SupplierEmailService();
            boolean ok = emailService.sendSupplierVerificationEmail(supplier, AppUrlUtils.resolveBaseUrl(request));
            session.setAttribute("message", ok ? "Đã gửi email xác nhận cho nhà cung cấp." : "Gửi email xác nhận thất bại.");
            session.setAttribute("status", ok ? "success" : "error");
            if (ok) insertLog(acc, request, supplierId, "Gửi email xác nhận nhà cung cấp.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Lỗi gửi email xác nhận: " + e.getMessage());
            session.setAttribute("status", "error");
        }
        response.sendRedirect("supplierList");
    }

    private void handleConfirm(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String token = request.getParameter("token");
        SupplierDAO dao = new SupplierDAO();
        boolean ok = token != null && dao.verifySupplierByToken(token);
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().write("<html><body style='font-family:Arial;padding:30px'>"
                + (ok ? "<h2>Xác nhận nhà cung cấp thành công</h2><p>Email của nhà cung cấp đã được xác nhận. Bạn có thể đóng trang này.</p>"
                        : "<h2>Liên kết không hợp lệ hoặc đã hết hạn</h2><p>Vui lòng liên hệ quản lý để gửi lại email xác nhận.</p>")
                + "</body></html>");
    }

    private void insertLog(User user, HttpServletRequest request, int supplierId, String description) {
        try {
            SystemLogDAO logDao = new SystemLogDAO();
            SystemLog log = new SystemLog();
            log.setUserID(user.getUserID());
            log.setAction("SEND_SUPPLIER_VERIFY_EMAIL");
            log.setTargetObject("Supplier ID: " + supplierId);
            log.setDescription(description);
            log.setIpAddress(request.getRemoteAddr());
            logDao.insertLog(log);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
