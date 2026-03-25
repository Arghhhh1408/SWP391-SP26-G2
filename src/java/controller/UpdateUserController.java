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
            UserDAO userDAO = new UserDAO();
            User existingUser = userDAO.searchUserByID(id);

            if (existingUser == null) {
                request.setAttribute("error", "User not found!");
                request.getRequestDispatcher("userDetail.jsp").forward(request, response);
                return;
            }

            int roleID = Integer.parseInt(request.getParameter("role"));

            // Admin is only allowed to change the Role during update.
            // All other fields are preserved from existingUser to prevent tampering.
            User user = new User();
            user.setUserID(id);
            user.setUsername(existingUser.getUsername());
            user.setFullName(existingUser.getFullName());
            user.setEmail(existingUser.getEmail());
            user.setPhone(existingUser.getPhone());
            user.setRoleID(roleID);

            // Since we use current DB values for profile fields, 
            // no need for validation or duplicate checks on those fields.

            boolean result = userDAO.updateUser(user);

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
                log.setDescription("Updated user role for: " + existingUser.getUsername());
                log.setIpAddress(request.getRemoteAddr());
                logDAO.insertLog(log);

                request.setAttribute("user", user);
                // Load roles for the dropdown
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
