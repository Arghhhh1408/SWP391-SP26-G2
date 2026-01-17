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

        UserDAO dao = new UserDAO();
        List<User> list = dao.getDeletedUsers();

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
