package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import model.Product;

@WebServlet(name = "CategoryController", urlPatterns = { "/category" })
public class CategoryController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        CategoryDAO dao = new CategoryDAO();
        ProductDAO pDao = new ProductDAO();

        try {
            // Always get list of categories for the sidebar/menu
            List<Category> categories = dao.getCategoryTree();
            request.setAttribute("categories", categories);

            String categoryIdRaw = request.getParameter("categoryId");
            String keyword = request.getParameter("keyword");
            String minPriceRaw = request.getParameter("minPrice");
            String maxPriceRaw = request.getParameter("maxPrice");
            String pageRaw = request.getParameter("page");

            Integer categoryId = null;
            Double minPrice = null;
            Double maxPrice = null;
            int page = 1;
            int pageSize = 10; // Products per page

            // Parse page number
            if (pageRaw != null && !pageRaw.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageRaw);
                    if (page < 1)
                        page = 1;
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            // Parse category ID
            if (categoryIdRaw != null && !categoryIdRaw.isEmpty()) {
                try {
                    categoryId = Integer.parseInt(categoryIdRaw);
                    request.setAttribute("selectedCategoryId", categoryId);
                } catch (NumberFormatException e) {
                    // Ignore invalid category ID
                }
            }

            // Parse price range
            try {
                if (minPriceRaw != null && !minPriceRaw.trim().isEmpty()) {
                    minPrice = Double.parseDouble(minPriceRaw.trim());
                }
                if (maxPriceRaw != null && !maxPriceRaw.trim().isEmpty()) {
                    maxPrice = Double.parseDouble(maxPriceRaw.trim());
                }
            } catch (NumberFormatException e) {
                // Ignore invalid price format
            }

            // Get total count for pagination
            int totalProducts = pDao.countProducts(keyword, minPrice, maxPrice, categoryId);
            int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

            // Get paginated products
            List<Product> products = pDao.searchProductsPaginated(keyword, minPrice, maxPrice, categoryId, page,
                    pageSize);

            // Preserve search parameters in request
            request.setAttribute("keyword", keyword);
            request.setAttribute("minPrice", minPriceRaw);
            request.setAttribute("maxPrice", maxPriceRaw);
            request.setAttribute("products", products);

            // Pagination attributes
            request.setAttribute("currentPaginationPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalProducts", totalProducts);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database Error: " + e.getMessage());
        }

        request.getRequestDispatcher("category.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
