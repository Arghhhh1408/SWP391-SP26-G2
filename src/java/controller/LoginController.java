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
@WebServlet(name = "LoginController", urlPatterns = {"/login"})
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
        User user = dao.getUserByUsername(username);

        if (user != null) {
            // Check if account is deactivated
            if (!user.isIsActive()) {
                request.setAttribute("err", "Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ Admin.");
                request.setAttribute("username", username);
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            // Check if account is locked
            if (user.getLockoutEnd() != null && user.getLockoutEnd().after(new java.util.Date())) {
                long diff = user.getLockoutEnd().getTime() - System.currentTimeMillis();
                long minutes = diff / (60 * 1000);
                if (minutes < 1) minutes = 1;
                request.setAttribute("err", "Tài khoản bị khóa tạm thời. Vui lòng thử lại sau " + minutes + " phút.");
                request.setAttribute("username", username);
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
        }

        user = dao.login(username, password);
        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("acc", user);

            // Log success
            dao.SystemLogDAO logDAO = new dao.SystemLogDAO();
            model.SystemLog log = new model.SystemLog();
            log.setUserID(user.getUserID());
            log.setAction("LOGIN");
            log.setTargetObject("User: " + user.getUsername());
            log.setDescription("Login successful");
            log.setIpAddress(request.getRemoteAddr());
            logDAO.insertLog(log);
            
            if (user.getRoleID() == 0) {
                response.sendRedirect("admin");
            } else if (user.getRoleID() == 1) {
                response.sendRedirect("staff_dashboard");
            } else if (user.getRoleID() == 2) {
                response.sendRedirect("manager_dashboard");
            } else if (user.getRoleID() == 3) {
                response.sendRedirect("sales_dashboard");
            } else {
                response.sendRedirect("category");
            }
        } else {
            // Log failure and check if it caused a lockout
            User failedUser = dao.getUserByUsername(username);
            String errorMessage = "Sai tài khoản hoặc mật khẩu!";
            
            if (failedUser != null) {
                if (failedUser.getLockoutEnd() != null && failedUser.getLockoutEnd().after(new java.util.Date())) {
                    errorMessage = "Tài khoản đã bị khóa 30 phút do nhập sai quá 5 lần.";
                } else {
                    int remaining = 5 - failedUser.getFailedAttempts();
                    if (remaining > 0 && remaining <= 3) {
                        errorMessage += " Bạn còn " + remaining + " lần thử trước khi bị khóa.";
                    }
                }
            }

            request.setAttribute("err", errorMessage);
            request.setAttribute("username", username);
            request.setAttribute("password", password);

            dao.SystemLogDAO logDAO = new dao.SystemLogDAO();
            model.SystemLog log = new model.SystemLog();
            log.setUserID(0);
            log.setAction("LOGIN_FAILED");
            log.setTargetObject("IP: " + request.getRemoteAddr());
            log.setDescription("Failed login attempt for username: " + username);
            log.setIpAddress(request.getRemoteAddr());
            logDAO.insertLog(log);

            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

}
