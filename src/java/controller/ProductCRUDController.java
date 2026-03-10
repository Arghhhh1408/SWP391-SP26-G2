package controller;

import dao.CategoryDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import model.Product;

@WebServlet(name = "ProductCRUDController", urlPatterns = { "/addProduct", "/editProduct", "/deleteProduct" })
public class ProductCRUDController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();
        CategoryDAO dao = new CategoryDAO();
        try {
            if (action.equals("/addProduct")) {
                List<Category> categories = dao.getAllCategories();
                request.setAttribute("categories", categories);
                request.getRequestDispatcher("productForm.jsp").forward(request, response);
            } else if (action.equals("/editProduct")) {
                int id = Integer.parseInt(request.getParameter("id"));
                Product p = dao.getProductById(id);
                if (p != null) {
                    List<Category> categories = dao.getAllCategories();
                    request.setAttribute("product", p);
                    request.setAttribute("categories", categories);
                    request.getRequestDispatcher("productForm.jsp").forward(request, response);
                } else {
                    response.sendRedirect("category");
                }
            } else if (action.equals("/deleteProduct")) {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.deleteProduct(id);
                response.sendRedirect("category");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("category");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();
        CategoryDAO dao = new CategoryDAO();

        try {
            request.setCharacterEncoding("UTF-8");
            String idStr = request.getParameter("id");
            String name = request.getParameter("name");
            String sku = request.getParameter("sku");
            String unit = request.getParameter("unit");
            String description = request.getParameter("description");
            String imageURL = request.getParameter("imageURL");
            String status = request.getParameter("status");
            int categoryId = 0;

            double cost = 0;
            double price = 0;
            int quantity = 0;

            try {
                categoryId = Integer.parseInt(request.getParameter("categoryId"));
                String costStr = request.getParameter("cost");
                String priceStr = request.getParameter("price");
                String quantityStr = request.getParameter("quantity");

                if (costStr != null && !costStr.isEmpty())
                    cost = Double.parseDouble(costStr);
                if (priceStr != null && !priceStr.isEmpty())
                    price = Double.parseDouble(priceStr);
                if (quantityStr != null && !quantityStr.isEmpty())
                    quantity = Integer.parseInt(quantityStr);

            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid number format for Cost, Price, or Quantity");
                List<Category> categories = dao.getAllCategories();
                request.setAttribute("categories", categories);

                Product pError = new Product();
                pError.setName(name);
                pError.setSku(sku);
                // Store raw strings effectively by defaulting to 0 or we could add temp fields
                // to JSP, but 0 is safer for now if parsing failed
                pError.setUnit(unit);
                pError.setDescription(description);
                pError.setImageURL(imageURL);
                pError.setStatus(status);
                pError.setCategoryId(categoryId);
                request.setAttribute("product", pError);
                request.getRequestDispatcher("productForm.jsp").forward(request, response);
                return;
            }

            if (cost < 0 || price < 0 || quantity < 0) {
                request.setAttribute("error", "Cost, Price, and Quantity must be non-negative!");
                List<Category> categories = dao.getAllCategories();
                request.setAttribute("categories", categories);

                Product pError = new Product();
                pError.setName(name);
                pError.setSku(sku);
                pError.setCost(cost);
                pError.setPrice(price);
                pError.setQuantity(quantity);
                pError.setUnit(unit);
                pError.setDescription(description);
                pError.setImageURL(imageURL);
                pError.setStatus(status);
                pError.setCategoryId(categoryId);

                request.setAttribute("product", pError);
                request.getRequestDispatcher("productForm.jsp").forward(request, response);
                return;
            }

            Product p = new Product();
            p.setName(name);
            p.setSku(sku);
            p.setCost(cost);
            p.setPrice(price);
            p.setQuantity(quantity);
            p.setUnit(unit);
            p.setDescription(description);
            p.setImageURL(imageURL);
            p.setStatus(status);
            p.setCategoryId(categoryId);

            if (idStr == null || idStr.isEmpty()) {
                // Check SKU exists
                if (dao.isProductSkuExists(sku)) {
                    request.setAttribute("error", "SKU already exists!");
                    List<Category> categories = dao.getAllCategories();
                    request.setAttribute("categories", categories);
                    request.setAttribute("product", p);
                    request.getRequestDispatcher("productForm.jsp").forward(request, response);
                    return;
                }
                dao.addProduct(p);
            } else {
                p.setId(Integer.parseInt(idStr));
                dao.updateProduct(p);
            }
            response.sendRedirect("category");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("category");
        }
    }
}
