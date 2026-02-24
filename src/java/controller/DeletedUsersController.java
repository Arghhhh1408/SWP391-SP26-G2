/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

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
import model.User;

/**
 *
 * @author minhtuan
 */
@WebServlet(name = "DeletedUsersController", urlPatterns = { "/deletedUsers" })
public class DeletedUsersController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 0) {
            response.sendRedirect("login");
            return;
        }

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String roleStr = request.getParameter("role");
        int roleID = -1;
        try {
            if (roleStr != null && !roleStr.isEmpty()) {
                roleID = Integer.parseInt(roleStr);
            }
        } catch (NumberFormatException e) {
            roleID = -1;
        }

        UserDAO dao = new UserDAO();
        List<User> list = dao.getDeletedUsers(name, email, phone, roleID);

        dao.RoleDAO roleDAO = new dao.RoleDAO();
        request.setAttribute("listOfRole", roleDAO.getAllRole());

        request.setAttribute("list", list);
        String notification = (String) session.getAttribute("notification");
        if (notification != null) {
            request.setAttribute("notification", notification);
            session.removeAttribute("notification");
        }
        request.getRequestDispatcher("deletedUsers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }

}
