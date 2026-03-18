/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.SystemLogDAO;
import dao.UserDAO;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.SystemLog;
import model.User;
import utils.DBContext;

/**
 *
 * @author minhtuan
 */
@WebServlet(name = "AdminController", urlPatterns = { "/admin" })
public class AdminController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 0) {
            response.sendRedirect("login");
            return;
        }

        String notification = (String) session.getAttribute("notification");
        if (notification != null) {
            request.setAttribute("notification", notification);
            session.removeAttribute("notification");
        }

        // --- Dashboard data ---
        UserDAO userDAO = new UserDAO();
        List<User> allUsers = userDAO.getAllUsers();
        int totalAccounts = (allUsers != null) ? allUsers.size() : 0;
        request.setAttribute("totalAccounts", totalAccounts);

        // Role distribution: map roleName -> count
        Map<String, Integer> roleDistribution = new LinkedHashMap<>();
        if (allUsers != null) {
            for (User user : allUsers) {
                String roleName = getRoleName(user.getRoleID());
                roleDistribution.merge(roleName, 1, Integer::sum);
            }
        }
        request.setAttribute("roleDistribution", roleDistribution);

        // Recent system logs (top 5)
        SystemLogDAO logDAO = new SystemLogDAO();
        List<SystemLog> allLogs = logDAO.getLogs();
        List<SystemLog> recentLogs = new ArrayList<>();
        if (allLogs != null) {
            for (int i = 0; i < Math.min(5, allLogs.size()); i++) {
                recentLogs.add(allLogs.get(i));
            }
        }
        request.setAttribute("recentLogs", recentLogs);

        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }

    private String getRoleName(int roleID) {
        switch (roleID) {
            case 0:
                return "Administrator";
            case 1:
                return "Warehouse Staff";
            case 2:
                return "Manager";
            case 3:
                return "Salesperson";
            default:
                return "Unknown";
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }

}
