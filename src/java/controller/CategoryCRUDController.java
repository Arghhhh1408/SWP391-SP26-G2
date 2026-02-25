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

@WebServlet(name = "CategoryCRUDController", urlPatterns = { "/addCategory", "/editCategory", "/deleteCategory",
        "/manageCategories" })
public class CategoryCRUDController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();
        CategoryDAO dao = new CategoryDAO();

        try {
            if (action.equals("/manageCategories")) {
                List<Category> categories = dao.getAllCategories();
                request.setAttribute("categories", categories);
                request.getRequestDispatcher("manageCategories.jsp").forward(request, response);
            } else if (action.equals("/addCategory")) {
                request.getRequestDispatcher("categoryForm.jsp").forward(request, response);
            } else if (action.equals("/editCategory")) {
                int id = Integer.parseInt(request.getParameter("id"));
                Category category = dao.getCategoryById(id);
                request.setAttribute("category", category);
                request.getRequestDispatcher("categoryForm.jsp").forward(request, response);
            } else if (action.equals("/deleteCategory")) {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.deleteCategory(id);
                response.sendRedirect("manageCategories");
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
            String name = request.getParameter("name");
            Category c = new Category();
            c.setName(name);

            if (action.equals("/addCategory")) {
                if (dao.isCategoryExists(name)) {
                    request.setAttribute("error", "Category name already exists!");
                    request.getRequestDispatcher("categoryForm.jsp").forward(request, response);
                    return;
                }
                dao.addCategory(c);
            } else if (action.equals("/editCategory")) {
                int id = Integer.parseInt(request.getParameter("id"));
                c.setId(id);
                dao.updateCategory(c);
            }
            response.sendRedirect("manageCategories");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error processing category: " + e.getMessage());
            request.getRequestDispatcher("categoryForm.jsp").forward(request, response);
        }
    }
}
