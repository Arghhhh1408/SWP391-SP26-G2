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
@WebServlet(name = "UserListController", urlPatterns = { "/userList" })
public class UserListController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 0) {
            response.sendRedirect("login");
            return;
        }

        UserDAO dao = new UserDAO();
        RoleDAO dao1 = new RoleDAO();
        List<Role> listOfRole = dao1.getAllRole();
        request.setAttribute("listOfRole", listOfRole);

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String roleName = request.getParameter("option");
        List<User> list;

        if (name != null || email != null || phone != null || roleName != null) {
            list = dao.searchUsers(name, email, phone, roleName);
        } else {
            list = dao.getAllUsers();
        }

        String notification = (String) session.getAttribute("notification");
        if (notification != null) {
            request.setAttribute("notification", notification);
            session.removeAttribute("notification");
        }

        request.setAttribute("list", list);
        request.getRequestDispatcher("userList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }
}
