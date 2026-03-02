package controller;

import dao.CategoryDAO;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Category;
import model.Product;
import model.User;

@WebServlet(name = "ProductCRUDController", urlPatterns = { "/addProduct", "/editProduct", "/deleteProduct" })
public class ProductCRUDController extends HttpServlet {

    private boolean ensureAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 0) {
            response.sendRedirect("login");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureAdmin(request, response)) {
            return;
        }
        String action = request.getServletPath();
        CategoryDAO dao = new CategoryDAO();

        try {
            // Needed for category dropdown in forms
            List<Category> categories = dao.getAllCategories();
            request.setAttribute("categories", categories);

            if (action.equals("/addProduct")) {
                request.getRequestDispatcher("productForm.jsp").forward(request, response);
            } else if (action.equals("/editProduct")) {
                int id = Integer.parseInt(request.getParameter("id"));
                Product product = dao.getProductById(id);
                request.setAttribute("product", product);
                request.getRequestDispatcher("productForm.jsp").forward(request, response);
            } else if (action.equals("/deleteProduct")) {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.deleteProduct(id);
                response.sendRedirect("products");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("products");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureAdmin(request, response)) {
            return;
        }
        String action = request.getServletPath();
        CategoryDAO dao = new CategoryDAO();

        try {
            String name = request.getParameter("name").trim();
            String sku = request.getParameter("sku").trim();
            String unit = request.getParameter("unit");
            String description = request.getParameter("description");
            String imageURL = request.getParameter("imageURL");
            String status = request.getParameter("status") != null ? request.getParameter("status").trim() : "Active";
            int categoryId = 0;

            double cost = 0;
            double price = 0;
            int quantity = 0;
            int warrantyPeriod = 0;

            try {
                categoryId = Integer.parseInt(request.getParameter("categoryId"));
                String costStr = request.getParameter("cost");
                String priceStr = request.getParameter("price");
                String quantityStr = request.getParameter("quantity");
                String warrantyStr = request.getParameter("warrantyPeriod");

                if (costStr != null && !costStr.isEmpty())
                    cost = Double.parseDouble(costStr);
                if (priceStr != null && !priceStr.isEmpty())
                    price = Double.parseDouble(priceStr);
                if (quantityStr != null && !quantityStr.isEmpty())
                    quantity = Integer.parseInt(quantityStr);
                if (warrantyStr != null && !warrantyStr.isEmpty())
                    warrantyPeriod = Integer.parseInt(warrantyStr);

            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid number format for Cost, Price, Quantity, or Warranty Period");
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
                pError.setWarrantyPeriod(warrantyPeriod);
                request.setAttribute("product", pError);
                request.getRequestDispatcher("productForm.jsp").forward(request, response);
                return;
            }

            if (cost < 0 || price < 0 || quantity < 0 || warrantyPeriod < 0) {
                request.setAttribute("error", "Cost, Price, Quantity, and Warranty Period must be non-negative!");
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
                pError.setWarrantyPeriod(warrantyPeriod);

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
            p.setWarrantyPeriod(warrantyPeriod);

            if (action.equals("/addProduct")) {
                if (dao.isProductSkuExists(sku)) {
                    request.setAttribute("error", "Product SKU already exists!");
                    List<Category> categories = dao.getAllCategories();
                    request.setAttribute("categories", categories);
                    request.setAttribute("product", p);
                    request.getRequestDispatcher("productForm.jsp").forward(request, response);
                    return;
                }
                if (!dao.addProduct(p)) {
                    request.setAttribute("error", "Failed to add product! Check database constraints.");
                    List<Category> categories = dao.getAllCategories();
                    request.setAttribute("categories", categories);
                    request.setAttribute("product", p);
                    request.getRequestDispatcher("productForm.jsp").forward(request, response);
                    return;
                }
            } else if (action.equals("/editProduct")) {
                int id = Integer.parseInt(request.getParameter("id"));
                p.setId(id);
                try {
                    if (!dao.updateProduct(p)) {
                        request.setAttribute("error",
                                "Failed to update product! No rows affected.");
                        List<Category> categories = dao.getAllCategories();
                        request.setAttribute("categories", categories);
                        request.setAttribute("product", p);
                        request.getRequestDispatcher("productForm.jsp").forward(request, response);
                        return;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("error", "Database Error: " + e.getMessage());
                    List<Category> categories = dao.getAllCategories();
                    request.setAttribute("categories", categories);
                    request.setAttribute("product", p);
                    request.getRequestDispatcher("productForm.jsp").forward(request, response);
                    return;
                }
            }
            response.sendRedirect("products");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            try {
                // Reload categories just in case
                List<Category> categories = dao.getAllCategories();
                request.setAttribute("categories", categories);
            } catch (Exception ex) {
            }
            request.getRequestDispatcher("productForm.jsp").forward(request, response);
        }
    }
}
