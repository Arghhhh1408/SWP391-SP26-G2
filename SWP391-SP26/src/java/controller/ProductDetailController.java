package controller;

import dao.ProductDAO;
import dao.SystemLogDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
import model.SystemLog;
import model.User;

@WebServlet(name = "ProductDetailController", urlPatterns = { "/productDetail" })
public class ProductDetailController extends HttpServlet {

    private boolean ensureStaffOrManager(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("acc");
        if (u == null || (u.getRoleID() != 1 && u.getRoleID() != 2)) {
            response.sendRedirect("login");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureStaffOrManager(request, response)) {
            return;
        }

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            ProductDAO pDao = new ProductDAO();
            Product product = pDao.getProductById(id);

            if (product != null) {
                // Strict check: only fetch history for Managers (RoleID 2)
                HttpSession session = request.getSession(false);
                User user = (session != null) ? (User) session.getAttribute("acc") : null;
                
                if (user != null && user.getRoleID() == 2) {
                    SystemLogDAO logDao = new SystemLogDAO();
                    List<SystemLog> history = logDao.getProductHistory(id);
                    request.setAttribute("productHistory", history);
                }

                request.setAttribute("product", product);
                request.getRequestDispatcher("productDetail.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Product not found!");
                request.getRequestDispatcher("category").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("category");
        }
    }
}
