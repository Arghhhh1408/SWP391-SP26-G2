package controller;

import dao.SystemLogDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.SystemLog;
import model.User;

@WebServlet(name = "ProductHistoryController", urlPatterns = { "/productHistory" })
public class ProductHistoryController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("acc") : null;

        // Strict Access Control: Only Manager (RoleID 2)
        if (user == null || user.getRoleID() != 2) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        SystemLogDAO logDao = new SystemLogDAO();
        List<SystemLog> history = logDao.getAllProductHistory();
        
        request.setAttribute("history", history);
        request.setAttribute("currentPage", "productHistory");
        request.getRequestDispatcher("productHistory.jsp").forward(request, response);
    }
}
