package controller;

import dao.CategoryDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;

@WebServlet(name = "ProductDetailController", urlPatterns = { "/productDetail" })
public class ProductDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            CategoryDAO dao = new CategoryDAO();
            Product product = dao.getProductById(id);

            if (product != null) {
                // Get category name for display if needed, or just rely on ID
                // For now, simpler is better.
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
