/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

/**
 *
 * @author minhtuan
 */
@WebServlet(name = "LoginController", urlPatterns = { "/login" })
public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        UserDAO dao = new UserDAO();
        User user = dao.login(username, password);
        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("acc", user);
            if (user.getRoleID() == 0) {
                response.sendRedirect("admin");
            } else {
                response.sendRedirect("category");
            }
        } else {
            request.setAttribute("err", "Sai tài khoản hoặc mật khẩu!");
            request.setAttribute("username", username);
            request.setAttribute("password", password);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

}
