package controller;

import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import model.Notification;
import model.User;

@WebServlet(name = "NotificationController", urlPatterns = { "/notifications" })
public class NotificationController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getLoggedInUser(request, response);
        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        NotificationDAO dao = new NotificationDAO();
        List<Notification> list = dao.getByReceiver(user.getUserID());

        request.setAttribute("notifications", list);

        String targetJsp = "notification_manager.jsp";
        switch (user.getRoleID()) {
            case 0:
                targetJsp = "notification_admin.jsp";
                break;
            case 1:
                targetJsp = "notification_staff.jsp";
                break;
            case 2:
                targetJsp = "notification_manager.jsp";
                break;
            case 3:
                targetJsp = "notification_sales.jsp";
                break;
        }
        request.getRequestDispatcher(targetJsp).forward(request, response);
    }

    /**
     * POST /notifications?action=markRead&id=123
     * Marks specific notification (or all) as read, returns { "unreadCount": N }
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        User user = getLoggedInUser(request, response);
        if (user == null)
            return;

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        NotificationDAO dao = new NotificationDAO();

        if ("markRead".equals(action)) {
            if (idParam != null && !idParam.isEmpty()) {
                try {
                    int notifId = Integer.parseInt(idParam);
                    dao.markAsRead(user.getUserID(), notifId);
                } catch (NumberFormatException ignored) {}
            } else {
                dao.markAllRead(user.getUserID());
            }
        }

        int remainingUnread = dao.countUnread(user.getUserID());

        try (PrintWriter out = response.getWriter()) {
            out.print("{\"unreadCount\":" + remainingUnread + "}");
        }
    }

    // -----------------------------------------------------------------------
    private User getLoggedInUser(HttpServletRequest req, HttpServletResponse res) throws IOException {
        var session = req.getSession(false);
        if (session == null || session.getAttribute("acc") == null) {
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return null;
        }
        return (User) session.getAttribute("acc");
    }
}
