/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dao.RoleDAO;
import dao.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.User;
import utils.SecurityUtils;

/**
 *
 * @author minhtuan
 */
@WebServlet(name = "ResetPasswordController", urlPatterns = { "/resetpassword" })
public class ResetPasswordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        UserDAO userDAO = new UserDAO();
        // Reset password to 123
        boolean success = userDAO.resetPassword(id, SecurityUtils.hashPassword("123"));

        RoleDAO listOfRole = new RoleDAO();
        List<User> list = userDAO.getAllUsers();
        request.setAttribute("listOfRole", listOfRole.getAllRole());
        request.setAttribute("list", list);

        if (success) {
            request.setAttribute("notification", "Reset password successfully.");
        } else {
            request.setAttribute("notification", "Reset password failed.");
        }

        request.getRequestDispatcher("userList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }

}
