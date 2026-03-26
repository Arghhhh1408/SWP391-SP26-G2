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
import model.User;

/**
 *
 * @author minhtuan
 */
@WebServlet(name = "DeleteUserController", urlPatterns = { "/deleteUser" })
public class DeleteUserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        UserDAO dao = new UserDAO();
        HttpSession session = request.getSession();
        String redirect = request.getParameter("redirect");
        try {
            boolean success = dao.deleteUser(id); 
            if (success) {
                session.setAttribute("message", "Xóa tài khoản thành công");
                session.setAttribute("status", "success");

                // Log the action
                dao.SystemLogDAO logDAO = new dao.SystemLogDAO();
                model.SystemLog log = new model.SystemLog();
                model.User admin = (model.User) session.getAttribute("acc");
                int adminId = (admin != null) ? admin.getUserID() : 0;

                log.setUserID(adminId);
                log.setAction("DELETE_USER");
                log.setTargetObject("User ID: " + id);
                log.setDescription("Deleted user with ID: " + id);
                log.setIpAddress(request.getRemoteAddr());
                logDAO.insertLog(log);
            } else {
                session.setAttribute("message", "Xóa tài khoản thất bại");
                session.setAttribute("status", "failure");
            }
        } catch (Exception e) {
            session.setAttribute("message", "Xóa tài khoản thất bại: " + e.getMessage());
            session.setAttribute("status", "failure");
            e.printStackTrace();
        }
        
        if (redirect != null && !redirect.isEmpty()) {
            response.sendRedirect(redirect);
        } else {
            response.sendRedirect("userList");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }

}
