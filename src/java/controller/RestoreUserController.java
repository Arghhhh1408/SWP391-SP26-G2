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
@WebServlet(name = "RestoreUserController", urlPatterns = { "/restoreUser" })
public class RestoreUserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("acc");
        if (currentUser == null || currentUser.getRoleID() != 0) {
            response.sendRedirect("login");
            return;
        }

        int userID = Integer.parseInt(request.getParameter("id"));
        UserDAO dao = new UserDAO();

        String conflictMessage = dao.validateRestoreConflict(userID);
        if (conflictMessage != null) {
            session.setAttribute("notification", "Không thể khôi phục tài khoản: " + conflictMessage);
            response.sendRedirect("deletedUsers");
            return;
        }

        boolean success = dao.restoreUser(userID);

        if (success) {
            session.setAttribute("notification", "Khôi phục tài khoản thành công");

            dao.SystemLogDAO logDAO = new dao.SystemLogDAO();
            model.SystemLog log = new model.SystemLog();
            int adminId = currentUser.getUserID();

            log.setUserID(adminId);
            log.setAction("RESTORE_USER");
            log.setTargetObject("User ID: " + userID);
            log.setDescription("Restored user with ID: " + userID);
            log.setIpAddress(request.getRemoteAddr());
            logDAO.insertLog(log);
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
