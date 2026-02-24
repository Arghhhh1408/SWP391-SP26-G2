/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dao.RoleDAO;
import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Role;
import model.User;

/**
 *
 * @author minhtuan
 */
@WebServlet(name = "UpdateUserController", urlPatterns = { "/updateuser" })
public class UpdateUserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        UserDAO dao1 = new UserDAO();
        User user = new User();
        user = dao1.searchUserByID(id);
        request.setAttribute("user", user);

        RoleDAO dao = new RoleDAO();
        List<Role> listOfRole = dao.getAllRole();
        request.setAttribute("listOfRole", listOfRole);
        request.getRequestDispatcher("userDetail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String username = request.getParameter("username");
            String fullname = request.getParameter("fullname");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            int roleID = Integer.parseInt(request.getParameter("role"));

            User user = new User();
            user.setUserID(id);
            user.setUsername(username);
            user.setFullName(fullname);
            user.setEmail(email);
            user.setPhone(phone);
            user.setRoleID(roleID);

            // Validate Phone Format
            if (!utils.ValidationUtils.isValidPhone(phone)) {
                request.setAttribute("error",
                        "Invalid phone number format! Must be 10 digits starting with 03, 07, 08, 09.");
                // Preserve input (user object is already populated above)
                request.setAttribute("user", user);
                // Load roles
                RoleDAO roleDao = new RoleDAO();
                List<Role> listOfRole = roleDao.getAllRole();
                request.setAttribute("listOfRole", listOfRole);
                request.getRequestDispatcher("userDetail.jsp").forward(request, response);
                return;
            }

            // Validate Email Format
            if (!utils.ValidationUtils.isValidEmail(email)) {
                request.setAttribute("error", "Invalid email format!");
                // Preserve input
                request.setAttribute("user", user);
                // Load roles
                RoleDAO roleDao = new RoleDAO();
                List<Role> listOfRole = roleDao.getAllRole();
                request.setAttribute("listOfRole", listOfRole);
                request.getRequestDispatcher("userDetail.jsp").forward(request, response);
                return;
            }

            UserDAO dao = new UserDAO();

            String error = dao.checkDuplicateForUpdate(id, username, email, phone);
            if (error != null) {
                request.setAttribute("error", error);

                request.setAttribute("user", user);

                RoleDAO roleDao = new RoleDAO();
                List<Role> listOfRole = roleDao.getAllRole();
                request.setAttribute("listOfRole", listOfRole);

                request.getRequestDispatcher("userDetail.jsp").forward(request, response);
                return;
            }

            boolean result = dao.updateUser(user);

            if (result) {
                request.setAttribute("message", "Sửa tài khoản thành công");
                request.setAttribute("status", "success");

                // Log the action
                dao.SystemLogDAO logDAO = new dao.SystemLogDAO();
                model.SystemLog log = new model.SystemLog();
                HttpSession session = request.getSession();
                User admin = (User) session.getAttribute("acc");
                int adminId = (admin != null) ? admin.getUserID() : 0;

                log.setUserID(adminId);
                log.setAction("UPDATE_USER");
                log.setTargetObject("User ID: " + id);
                log.setDescription("Updated user profile: " + username);
                log.setIpAddress(request.getRemoteAddr());
                logDAO.insertLog(log);

                request.setAttribute("user", user);
                // Load roles
                RoleDAO roleDao = new RoleDAO();
                List<Role> listOfRole = roleDao.getAllRole();
                request.setAttribute("listOfRole", listOfRole);
                request.getRequestDispatcher("userDetail.jsp").forward(request, response);
            } else {
                request.setAttribute("message", "Sửa tài khoản thất bại");
                request.setAttribute("status", "failure");
                request.setAttribute("user", user);
                RoleDAO roleDao = new RoleDAO();
                List<Role> listOfRole = roleDao.getAllRole();
                request.setAttribute("listOfRole", listOfRole);
                request.getRequestDispatcher("userDetail.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("userDetail.jsp").forward(request, response);
        }
    }

}
