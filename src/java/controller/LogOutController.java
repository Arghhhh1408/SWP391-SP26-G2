/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

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
@WebServlet(name = "LogOutController", urlPatterns = { "/logout" })
public class LogOutController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("acc") != null) {
            model.User user = (model.User) session.getAttribute("acc");

            // Log logout
            dao.SystemLogDAO logDAO = new dao.SystemLogDAO();
            model.SystemLog log = new model.SystemLog();
            log.setUserID(user.getUserID());
            log.setAction("LOGOUT");
            log.setTargetObject("User: " + user.getUsername());
            log.setDescription("User logged out");
            log.setIpAddress(request.getRemoteAddr());
            logDAO.insertLog(log);

            session.invalidate();
        }
        response.sendRedirect("login");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }

}
