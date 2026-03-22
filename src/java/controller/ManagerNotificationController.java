package controller;

import dao.NotificationDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Notification;
import model.User;

@WebServlet(name = "ManagerNotificationController", urlPatterns = {"/manager_notification"})
public class ManagerNotificationController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("acc") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("acc");
        if (user.getRoleID() != 2) { // 2 = Manager
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        NotificationDAO notifDAO = new NotificationDAO();

        if ("markRead".equals(action)) {
            String idRaw = request.getParameter("id");
            if (idRaw != null) {
                try {
                    int id = Integer.parseInt(idRaw);
                    notifDAO.markAsRead(id);
                } catch (NumberFormatException e) {
                }
            }
            response.sendRedirect("manager_notification");
            return;
        } else if ("markAllRead".equals(action)) {
            notifDAO.markAllAsRead(user.getUserID());
            response.sendRedirect("manager_notification");
            return;
        }

        List<Notification> notifications = notifDAO.getNotificationsByUserId(user.getUserID());
        int unreadCount = notifDAO.getUnreadCount(user.getUserID());
        
        request.setAttribute("notifications", notifications);
        request.setAttribute("unreadCount", unreadCount);
        request.getRequestDispatcher("manager_notification.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Manager Notification Controller";
    }
}
