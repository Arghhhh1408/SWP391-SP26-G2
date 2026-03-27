package controller;

import dao.SupplierDAO;
import dao.SupplierUpdateRequestDAO;
import dao.SystemLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Supplier;
import model.SupplierUpdateRequest;
import model.SystemLog;
import model.User;
import utils.AppUrlUtils;
import utils.SupplierEmailService;
import utils.ValidationUtils;

@WebServlet(name = "addSupplierController", urlPatterns = {"/addSupplier"})
public class addSupplierController extends HttpServlet {

    private SupplierDAO dao;

    @Override
    public void init() throws ServletException {
        dao = new SupplierDAO();
    }

    private String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void forwardAddFormError(HttpServletRequest request, HttpServletResponse response,
            String errorMessage, boolean formStatus)
            throws ServletException, IOException {
        request.setAttribute("error", errorMessage);
        request.setAttribute("formStatus", formStatus);
        request.getRequestDispatcher("addsupplierform.jsp").forward(request, response);
    }

    private void forwardEditFormError(HttpServletRequest request, HttpServletResponse response,
            Supplier supplierForm, String errorMessage)
            throws ServletException, IOException {
        request.setAttribute("supplier", supplierForm);
        request.setAttribute("error", errorMessage);
        request.getRequestDispatcher("addsupplierform.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");

        if ("delete".equals(action) && u.getRoleID() != 2) {
            request.setAttribute("message", "Bạn không có quyền ngừng hoạt động nhà cung cấp.");
            request.getRequestDispatcher("supplierList").forward(request, response);
            return;
        }

        if (("add".equals(action) || "edit".equals(action)) && u.getRoleID() != 2) {
            request.setAttribute("message", "Bạn không có quyền thực hiện chức năng này.");
            request.getRequestDispatcher("supplierList").forward(request, response);
            return;
        }

        if ("delete".equals(action) && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                Supplier s = dao.getSupplierById(id);
                boolean ok = dao.deactivateSupplier(id);
                if (ok) {
                    session.setAttribute("message", "Ngừng hoạt động nhà cung cấp thành công!");
                    session.setAttribute("status", "success");
                    insertLog(u, request, "DEACTIVATE_SUPPLIER", "Supplier ID: " + id,
                            "Ngừng hoạt động nhà cung cấp: " + (s != null ? s.getSupplierName() : "Unknown") + " (ID: " + id + ")");
                } else {
                    session.setAttribute("message", "Không tìm thấy nhà cung cấp để cập nhật trạng thái!");
                    session.setAttribute("status", "error");
                }
            } catch (Exception e) {
                session.setAttribute("message", "Lỗi xử lý nhà cung cấp: " + e.getMessage());
                session.setAttribute("status", "error");
            }
            response.sendRedirect(request.getContextPath() + "/supplierList");
            return;
        }

        if ("add".equals(action)) {
            request.setAttribute("formStatus", true);
            request.getRequestDispatcher("addsupplierform.jsp").forward(request, response);
            return;
        }

        if ("edit".equals(action) && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                Supplier supplier = dao.getSupplierById(id);
                if (supplier != null) request.setAttribute("supplier", supplier);
                else request.setAttribute("error", "Không tìm thấy nhà cung cấp!");
            } catch (Exception e) {
                request.setAttribute("error", "Lỗi tải nhà cung cấp: " + e.getMessage());
            }
            request.getRequestDispatcher("addsupplierform.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/supplierList");
    }

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
        if (user == null || user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String message = null;
        String status = null;

        try {
            if ("addSupplier".equals(action)) {
                String name = trimToNull(request.getParameter("supplierName"));
                String phone = trimToNull(request.getParameter("phone"));
                String address = trimToNull(request.getParameter("address"));
                String email = trimToNull(request.getParameter("email"));
                boolean supplierActive = request.getParameter("status") != null;

                if (!ValidationUtils.isValidPhone(phone)) {
                    forwardAddFormError(request, response, "Số điện thoại không hợp lệ!", supplierActive);
                    return;
                }
                if (!ValidationUtils.isValidEmail(email)) {
                    forwardAddFormError(request, response, "Email không hợp lệ!", supplierActive);
                    return;
                }
                String error = dao.checkDuplicate(name, email, phone, supplierActive);
                if (error != null) {
                    forwardAddFormError(request, response, error, supplierActive);
                    return;
                }
                boolean ok = dao.addSupplier(name, phone, address, email, supplierActive);
                if (!ok) {
                    forwardAddFormError(request, response, "Thêm nhà cung cấp thất bại!", supplierActive);
                    return;
                }
                message = "Thêm nhà cung cấp thành công. Vui lòng gửi email xác nhận để nhà cung cấp kích hoạt tài khoản làm việc.";
                status = "success";
                insertLog(user, request, "CREATE_SUPPLIER", "Supplier: " + name,
                        "Thêm nhà cung cấp mới: " + name + " | Active=" + supplierActive + " | EmailVerified=false");

            } else if ("updateSupplier".equals(action)) {
                int id = Integer.parseInt(request.getParameter("supplierID"));
                String newName = trimToNull(request.getParameter("supplierName"));
                String newPhone = trimToNull(request.getParameter("phone"));
                String newAddress = trimToNull(request.getParameter("address"));
                String newEmail = trimToNull(request.getParameter("email"));
                boolean newStatus = request.getParameter("status") != null;
                Supplier supplierForm = new Supplier(id, newName, newPhone, newAddress, newEmail, newStatus);

                if (!ValidationUtils.isValidPhone(newPhone)) {
                    forwardEditFormError(request, response, supplierForm, "Số điện thoại không hợp lệ!");
                    return;
                }
                if (!ValidationUtils.isValidEmail(newEmail)) {
                    forwardEditFormError(request, response, supplierForm, "Email không hợp lệ!");
                    return;
                }
                String duplicateError = dao.checkDuplicateForUpdate(id, newName, newEmail, newPhone, newStatus);
                if (duplicateError != null) {
                    forwardEditFormError(request, response, supplierForm, duplicateError);
                    return;
                }

                Supplier current = dao.getSupplierById(id);
                if (current == null) {
                    forwardEditFormError(request, response, supplierForm, "Không tìm thấy nhà cung cấp để cập nhật!");
                    return;
                }

                SupplierEmailService emailService = new SupplierEmailService();
                SupplierUpdateRequest req = emailService.createSupplierUpdateRequest(id, user.getUserID(), newName, newPhone, newAddress, newEmail, newStatus);
                if (req == null) {
                    forwardEditFormError(request, response, supplierForm, "Không thể tạo yêu cầu xác nhận cập nhật thông tin.");
                    return;
                }
                boolean mailSent = emailService.sendSupplierUpdateApprovalEmail(current, req, AppUrlUtils.resolveBaseUrl(request));
                if (!mailSent) {
                    forwardEditFormError(request, response, supplierForm, "Không thể gửi email xác nhận cho nhà cung cấp.");
                    return;
                }

                message = "Đã gửi email xác nhận cập nhật cho nhà cung cấp. Thông tin mới chỉ được áp dụng sau khi nhà cung cấp chấp nhận.";
                status = "success";
                insertLog(user, request, "REQUEST_SUPPLIER_UPDATE", "Supplier ID: " + id,
                        "Tạo yêu cầu cập nhật nhà cung cấp và gửi email xác nhận.");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            message = "Lỗi xử lý nhà cung cấp: " + ex.getMessage();
            status = "error";
        }

        session.setAttribute("message", message);
        session.setAttribute("status", status);
        response.sendRedirect(request.getContextPath() + "/supplierList");
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
