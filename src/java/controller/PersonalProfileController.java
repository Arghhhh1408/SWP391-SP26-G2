/*
 * PersonalProfileController.java
 * Handles GET /personalProfile - displays the logged-in admin's profile info.
 * Uses PRG (Post-Redirect-Get) pattern to avoid blank page on form submit.
 */
package controller;

import dao.SystemLogDAO;
import dao.UserDAO;
import model.SystemLog;
import utils.SecurityUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebServlet(name = "PersonalProfileController", urlPatterns = { "/personalProfile" })
public class PersonalProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User u = (session != null) ? (User) session.getAttribute("acc") : null;

        // Allow any authenticated user
        if (u == null) {
            response.sendRedirect("login");
            return;
        }
        // Tell the JSP which sidebar to include
        String sidebarType;
        switch (u.getRoleID()) {
            case 0: sidebarType = "admin"; break;
            case 1: sidebarType = "staff"; break;
            case 3: sidebarType = "sales"; break;
            default: sidebarType = "manager"; break;
        }
        request.setAttribute("sidebarType", sidebarType);

        // Flash messages: read from session then remove (PRG pattern)
        String successMsg = (String) session.getAttribute("profileSuccess");
        String errorMsg = (String) session.getAttribute("profileError");
        if (successMsg != null) {
            request.setAttribute("success", successMsg);
            session.removeAttribute("profileSuccess");
        }
        if (errorMsg != null) {
            request.setAttribute("error", errorMsg);
            session.removeAttribute("profileError");
        }

        // Password change flash messages
        String pwSuccess = (String) session.getAttribute("passwordSuccess");
        String pwError = (String) session.getAttribute("passwordError");
        if (pwSuccess != null) {
            request.setAttribute("passwordSuccess", pwSuccess);
            session.removeAttribute("passwordSuccess");
        }
        if (pwError != null) {
            request.setAttribute("passwordError", pwError);
            session.removeAttribute("passwordError");
        }

        request.setAttribute("currentPage", "personalProfile");
        request.getRequestDispatcher("personalProfile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User u = (session != null) ? (User) session.getAttribute("acc") : null;

        if (u == null) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        if ("update".equals(action)) {
            String fullName = request.getParameter("fullName");
            if (fullName != null)
                fullName = fullName.trim();
            String email = request.getParameter("email");
            if (email != null)
                email = email.trim();
            String phone = request.getParameter("phone");
            if (phone != null)
                phone = phone.trim();

            UserDAO userDAO = new UserDAO();

            // Check for duplicate email/phone
            String duplicateError = userDAO.checkDuplicateForUpdate(u.getUserID(), u.getUsername(), email, phone);
            if (duplicateError != null) {
                session.setAttribute("profileError", duplicateError);
                response.sendRedirect("personalProfile");
                return;
            }

            // Build updated user object (keep username and role)
            User updatedUser = new User();
            updatedUser.setUserID(u.getUserID());
            updatedUser.setUsername(u.getUsername());
            updatedUser.setFullName(fullName);
            updatedUser.setRoleID(u.getRoleID());
            updatedUser.setEmail(email);
            updatedUser.setPhone(phone);
            updatedUser.setPasswordHash(u.getPasswordHash());
            updatedUser.setIsActive(u.isIsActive());
            updatedUser.setCreateDate(u.getCreateDate());

            if (userDAO.updateUser(updatedUser)) {
                // Log action
                SystemLogDAO logDAO = new SystemLogDAO();
                SystemLog log = new SystemLog();
                log.setUserID(u.getUserID());
                log.setAction("Update Profile");
                log.setTargetObject("User: " + u.getUsername());
                log.setDescription("User updated their personal profile.");
                log.setIpAddress(request.getRemoteAddr());
                logDAO.insertLog(log);
                
                // Update the session so the page shows fresh data immediately
                session.setAttribute("acc", updatedUser);
                session.setAttribute("profileSuccess", "Đã lưu chỉnh sửa");
            } else {
                session.setAttribute("profileError", "Có lỗi xảy ra khi cập nhật hồ sơ!");
            }
        } else if ("changePassword".equals(action)) {
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            // Validate inputs
            if (currentPassword == null || currentPassword.trim().isEmpty()
                    || newPassword == null || newPassword.trim().isEmpty()
                    || confirmPassword == null || confirmPassword.trim().isEmpty()) {
                session.setAttribute("passwordError", "Vui lòng điền đầy đủ thông tin!");
                response.sendRedirect("personalProfile");
                return;
            }

            // Verify current password
            UserDAO userDAO = new UserDAO();
            User dbUser = userDAO.searchUserByID(u.getUserID());
            String currentHash = SecurityUtils.hashPassword(currentPassword);
            if (dbUser == null || !dbUser.getPasswordHash().equals(currentHash)) {
                session.setAttribute("passwordError", "Mật khẩu hiện tại không đúng!");
                response.sendRedirect("personalProfile");
                return;
            }

            // Validate new password length
//            if (newPassword.length() < 6) {
//                session.setAttribute("passwordError", "Mật khẩu mới phải có ít nhất 6 ký tự!");
//                response.sendRedirect("personalProfile");
//                return;
//            }

            // Check confirm match
            if (!newPassword.equals(confirmPassword)) {
                session.setAttribute("passwordError", "Mật khẩu xác nhận không khớp!");
                response.sendRedirect("personalProfile");
                return;
            }

            // Update password
            String newHash = SecurityUtils.hashPassword(newPassword);
            if (userDAO.resetPassword(u.getUserID(), newHash)) {
                // Log action
                SystemLogDAO logDAO = new SystemLogDAO();
                SystemLog log = new SystemLog();
                log.setUserID(u.getUserID());
                log.setAction("Change Password");
                log.setTargetObject("User: " + u.getUsername());
                log.setDescription("User changed their password.");
                log.setIpAddress(request.getRemoteAddr());
                logDAO.insertLog(log);

                u.setPasswordHash(newHash);
                session.setAttribute("acc", u);
                session.setAttribute("passwordSuccess", "Đổi mật khẩu thành công!");
            } else {
                session.setAttribute("passwordError", "Có lỗi xảy ra khi đổi mật khẩu!");
            }
        }

        // PRG: always redirect to GET after POST (prevents blank-page / double-submit)
        response.sendRedirect("personalProfile");
    }
}
