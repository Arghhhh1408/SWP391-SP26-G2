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

/**
 *
 * @author minhtuan
 */
@WebServlet(name = "RestoreUserController", urlPatterns = { "/restoreUser" })
public class RestoreUserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        int userID = Integer.parseInt(request.getParameter("id"));
        UserDAO dao = new UserDAO();
        boolean success = dao.restoreUser(userID);

        if (success) {
            session.setAttribute("notification", "Khôi phục tài khoản thành công");
        } else {
            session.setAttribute("notification", "Khôi phục tài khoản thất bại");
        }
        response.sendRedirect("deletedUsers");

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }

}
