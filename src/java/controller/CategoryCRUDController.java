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
        String path = request.getServletPath();
        CategoryDAO dao = new CategoryDAO();

        try {
            // Always fetch categories for dropdowns in add/edit forms
            List<Category> allCategories = dao.getAllCategories();
            request.setAttribute("allCategoriesList", allCategories);
            request.setAttribute("categories", allCategories); // For compatibility with categoryForm.jsp

            if (path.contains("manageCategories")) {
                String parentIdFilterRaw = request.getParameter("parentIdFilter");
                String sortBy = request.getParameter("sortBy");

                Integer parentIdFilter = null;
                if (parentIdFilterRaw != null && !parentIdFilterRaw.isEmpty()) {
                    try {
                        parentIdFilter = Integer.parseInt(parentIdFilterRaw);
                        request.setAttribute("selectedParentId", parentIdFilter);
                    } catch (NumberFormatException e) {
                        // Ignore invalid filter
                    }
                }

                request.setAttribute("selectedSortBy", sortBy);

                // Fetch filtered/sorted categories for the management table
                List<Category> filteredCategories = dao.searchCategories(parentIdFilter, sortBy);
                request.setAttribute("categories", filteredCategories); // Overwrite 'categories' for the table

                request.getRequestDispatcher("manageCategories.jsp").forward(request, response);
            } else if (path.contains("addCategory")) {
                request.getRequestDispatcher("categoryForm.jsp").forward(request, response);
            } else if (path.contains("editCategory")) {
                String idRaw = request.getParameter("id");
                if (idRaw != null) {
                    int id = Integer.parseInt(idRaw);
                    Category category = dao.getCategoryById(id);
                    request.setAttribute("category", category);
                }
                request.getRequestDispatcher("categoryForm.jsp").forward(request, response);
            } else if (path.contains("deleteCategory")) {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.deleteCategory(id);
                response.sendRedirect("manageCategories");
            } else {
                // Fallback for unexpected paths mapped to this servlet
                response.sendRedirect("category");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error in Category CRUD: " + e.getMessage());
            // If it's a list request, try to show the JSP anyway with an empty list
            if (path.contains("manageCategories")) {
                request.getRequestDispatcher("manageCategories.jsp").forward(request, response);
            } else {
                response.sendRedirect("category");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        CategoryDAO dao = new CategoryDAO();

        try {
            String name = request.getParameter("name");
            String parentIdRaw = request.getParameter("parentId");

            Category c = new Category();
            c.setName(name);
            if (parentIdRaw != null && !parentIdRaw.isEmpty()) {
                c.setParentId(Integer.parseInt(parentIdRaw));
            }

            if (path.contains("addCategory")) {
                if (dao.isCategoryExists(name)) {
                    request.setAttribute("error", "Category name already exists!");
                    request.setAttribute("categories", dao.getAllCategories());
                    request.getRequestDispatcher("categoryForm.jsp").forward(request, response);
                    return;
                }
                dao.addCategory(c);
            } else if (path.contains("editCategory")) {
                int id = Integer.parseInt(request.getParameter("id"));
                c.setId(id);
                dao.updateCategory(c);
            }
            response.sendRedirect("manageCategories");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error processing category: " + e.getMessage());
            try {
                request.setAttribute("categories", dao.getAllCategories());
            } catch (Exception ex) {
            }
            request.getRequestDispatcher("categoryForm.jsp").forward(request, response);
        }
    }
}
