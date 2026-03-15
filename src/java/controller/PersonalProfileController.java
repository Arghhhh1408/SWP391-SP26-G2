/*
 * PersonalProfileController.java
 * Handles GET /personalProfile - displays the logged-in admin's profile info.
 * Uses PRG (Post-Redirect-Get) pattern to avoid blank page on form submit.
 */
package controller;

import dao.UserDAO;
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
        request.setAttribute("sidebarType", u.getRoleID() == 0 ? "admin" : "manager");

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
                // Update the session so the page shows fresh data immediately
                session.setAttribute("acc", updatedUser);
                session.setAttribute("profileSuccess", "Đã lưu chỉnh sửa");
            } else {
                session.setAttribute("profileError", "Có lỗi xảy ra khi cập nhật hồ sơ!");
            }
        }

        // PRG: always redirect to GET after POST (prevents blank-page / double-submit)
        response.sendRedirect("personalProfile");
    }
}
