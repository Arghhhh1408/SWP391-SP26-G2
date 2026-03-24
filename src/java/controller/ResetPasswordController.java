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
        User admin = (User) request.getSession().getAttribute("acc");
        int adminId = (admin != null) ? admin.getUserID() : 0; // 0 or handle error

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
            
            dao.SystemLogDAO logDAO = new dao.SystemLogDAO();
            model.SystemLog log = new model.SystemLog();
           
            log.setUserID(adminId);
            log.setAction("RESET_PASSWORD");
            log.setTargetObject("User ID: " + id);
            log.setDescription("Reset password to 123");
            log.setIpAddress(request.getRemoteAddr());
            logDAO.insertLog(log);
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

