package controller;

import dao.UserDAO;
import model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LockedUsersController", urlPatterns = {"/lockedUsers"})
public class LockedUsersController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User acc = (User) session.getAttribute("acc");
        if (acc == null || acc.getRoleID() != 0) {
            response.sendRedirect("login");
            return;
        }

        UserDAO dao = new UserDAO();
        List<User> lockedUsers = dao.getLockedUsers();
        request.setAttribute("lockedUsers", lockedUsers);
        request.getRequestDispatcher("lockedUsers.jsp").forward(request, response);
    }
}
