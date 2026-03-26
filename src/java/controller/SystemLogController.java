/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dao.SystemLogDAO;
import dao.UserDAO;
import model.SystemLog;
import java.io.IOException;
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
@WebServlet(name = "SystemLogController", urlPatterns = { "/systemlog" })
public class SystemLogController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User acc = (User) session.getAttribute("acc");
        if (acc == null || acc.getRoleID() != 0) {
            response.sendRedirect("login");
            return;
        }

        SystemLogDAO dao = new SystemLogDAO();
        UserDAO userDAO = new UserDAO();

        String userIdStr = request.getParameter("userId");
        String action = request.getParameter("action");
        String date = request.getParameter("date");

        Integer userId = null;
        if (userIdStr != null && !userIdStr.isEmpty()) {
            try {
                userId = Integer.parseInt(userIdStr);
            } catch (NumberFormatException e) {
                // Ignore invalid format
            }
        }

        List<SystemLog> logs = dao.getLogs(userId, action, date);

        // Audit log for viewing the system log
        if (userIdStr == null && action == null && date == null) {
            SystemLog auditLog = new SystemLog();
            auditLog.setUserID(acc.getUserID());
            auditLog.setAction("VIEW_SYSTEM_LOG");
            auditLog.setTargetObject("SystemLog");
            auditLog.setDescription("Admin viewed the audit logs");
            auditLog.setIpAddress(request.getRemoteAddr());
            dao.insertLog(auditLog);
        }

        // Populate user names (Actor and Target)
        for (SystemLog log : logs) {
            // Actor name
            log.setName(userDAO.getNameByID(log.getUserID()));
            
            // Target user name if applicable
            String target = log.getTargetObject();
            if (target != null && target.startsWith("User ID: ")) {
                try {
                    int targetId = Integer.parseInt(target.split(": ")[1]);
                    String targetName = userDAO.getNameByID(targetId);
                    log.setTargetName(targetName); 
                } catch (Exception e) {
                    // Ignore parsing errors
                }
            }
        }

        request.setAttribute("logs", logs);
        request.setAttribute("userId", userIdStr);
        request.setAttribute("action", action);
        request.setAttribute("date", date);

        request.getRequestDispatcher("systemLog.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }

}
