package controller;

import dao.SupplierDAO;
import dao.SupplierUpdateRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Supplier;
import model.SupplierUpdateRequest;
import utils.AppUrlUtils;
import utils.SupplierEmailService;

@WebServlet(name = "SupplierUpdateApprovalController", urlPatterns = {"/supplier-update-approval"})
public class SupplierUpdateApprovalController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        String action = request.getParameter("action");
        SupplierUpdateRequestDAO dao = new SupplierUpdateRequestDAO();
        SupplierUpdateRequest req = dao.getByToken(token);
        SupplierDAO supplierDAO = new SupplierDAO();
        SupplierEmailService emailService = new SupplierEmailService();
        boolean ok = false;
        String message;

        if (req == null) {
            message = "Yêu cầu cập nhật không tồn tại hoặc đã hết hạn.";
        } else if ("approve".equalsIgnoreCase(action)) {
            ok = dao.approveRequest(token);
            Supplier supplier = supplierDAO.getSupplierById(req.getSupplierID());
            if (supplier != null) {
                emailService.sendSupplierUpdateResultMail(supplier, ok);
                if (ok && supplier.getEmail() != null && !supplier.isEmailVerified()) {
                    emailService.sendSupplierVerificationEmail(supplier, AppUrlUtils.resolveBaseUrl(request));
                }
            }
            message = ok ? "Đã chấp nhận cập nhật thông tin nhà cung cấp." : "Không thể chấp nhận yêu cầu cập nhật.";
        } else if ("reject".equalsIgnoreCase(action)) {
            ok = dao.rejectRequest(token, "Supplier rejected change request.");
            Supplier supplier = supplierDAO.getSupplierById(req.getSupplierID());
            if (supplier != null) {
                emailService.sendSupplierUpdateResultMail(supplier, false);
            }
            message = ok ? "Đã từ chối cập nhật thông tin nhà cung cấp." : "Không thể từ chối yêu cầu cập nhật.";
        } else {
            message = "Thao tác không hợp lệ.";
        }

        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().write("<html><body style='font-family:Arial;padding:30px'><h2>" + message + "</h2><p>Bạn có thể đóng trang này.</p></body></html>");
    }
}
