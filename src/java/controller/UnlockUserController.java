package controller;

import dao.UserDAO;
import dao.SystemLogDAO;
import model.User;
import model.SystemLog;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "UnlockUserController", urlPatterns = {"/unlockUser"})
public class UnlockUserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User acc = (User) session.getAttribute("acc");
        if (acc == null || acc.getRoleID() != 0) {
            response.sendRedirect("login");
            return;
        }

        try {
            int userId = Integer.parseInt(request.getParameter("id"));
            UserDAO dao = new UserDAO();
            User targetUser = dao.getUserByUsername(request.getParameter("username"));
            
            boolean success = dao.unlockUser(userId);
            if (success) {
                // Log the action
                SystemLogDAO logDAO = new SystemLogDAO();
                SystemLog log = new SystemLog();
                log.setUserID(acc.getUserID());
                log.setAction("UNLOCK_USER");
                log.setTargetObject("User ID: " + userId);
                log.setDescription("Admin unlocked user: " + (targetUser != null ? targetUser.getUsername() : userId));
                log.setIpAddress(request.getRemoteAddr());
                logDAO.insertLog(log);
                
                session.setAttribute("notification", "Mở khóa tài khoản thành công!");
            } else {
                session.setAttribute("notification", "Mở khóa tài khoản thất bại!");
            }
        } catch (Exception e) {
            session.setAttribute("notification", "Lỗi: " + e.getMessage());
        }
        
        response.sendRedirect("lockedUsers");
    }
}
