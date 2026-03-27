package controller;

import dao.CategoryDAO;
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
import model.Category;
import model.SystemLog;
import model.User;

@WebServlet(name = "CategoryCRUDController", urlPatterns = { "/addCategory", "/editCategory", "/deleteCategory",
        "/manageCategories" })
public class CategoryCRUDController extends HttpServlet {

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
        String path = request.getServletPath();

        CategoryDAO dao = new CategoryDAO();

        try {
            // Always fetch categories for dropdowns in add/edit forms
            List<Category> allCategories = dao.getHierarchicalList();
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
                ProductDAO pDao = new ProductDAO();
                
                if (!pDao.getProductsByCategoryId(id).isEmpty()) {
                    request.setAttribute("error", "Không thể xóa danh mục này vì vẫn còn sản phẩm thuộc danh mục!");
                } else if (dao.hasSubCategories(id)) {
                    request.setAttribute("error", "Không thể xóa danh mục này vì nó có danh mục con!");
                } else {
                    Category cToDelete = dao.getCategoryById(id);
                    boolean success = dao.deleteCategory(id);
                    if (!success) {
                        request.setAttribute("error", "Lỗi hệ thống: Không thể xóa danh mục.");
                    } else if (cToDelete != null) {
                        logCategoryAction(request, "DELETE_CATEGORY", "Xóa danh mục: " + cToDelete.getName() + " | ID: " + id);
                    }
                }
                
                // If there's an error, we need to re-populate attributes for manageCategories.jsp
                if (request.getAttribute("error") != null) {
                    List<Category> allCats = dao.getHierarchicalList();
                    request.setAttribute("allCategoriesList", allCats);
                    request.setAttribute("categories", dao.searchCategories(null, null));
                    request.getRequestDispatcher("manageCategories.jsp").forward(request, response);
                } else {
                    response.sendRedirect("manageCategories");
                }
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
        if (!ensureStaffOrManager(request, response)) {
            return;
        }
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
                logCategoryAction(request, "ADD_CATEGORY", "Thêm danh mục mới: " + name);
            } else if (path.contains("editCategory")) {
                int id = Integer.parseInt(request.getParameter("id"));
                if (dao.isCategoryExists(name, id)) {
                    request.setAttribute("error", "Category name already exists!");
                    // Re-populate data for the form
                    Category category = dao.getCategoryById(id);
                    request.setAttribute("category", category);
                    List<Category> allCategories = dao.getHierarchicalList();
                    request.setAttribute("allCategoriesList", allCategories);
                    request.setAttribute("categories", allCategories);
                    request.getRequestDispatcher("categoryForm.jsp").forward(request, response);
                    return;
                }
                Category oldC = dao.getCategoryById(id);
                c.setId(id);
                dao.updateCategory(c);
                logCategoryEdit(request, oldC, c);
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

    private void logCategoryAction(HttpServletRequest request, String action, String description) {
        try {
            HttpSession session = request.getSession(false);
            User u = session != null ? (User) session.getAttribute("acc") : null;
            SystemLog log = new SystemLog();
            log.setUserID(u != null ? u.getUserID() : 0);
            log.setAction(action);
            
            String userName = "Unknown";
            if (u != null) {
                userName = u.getUsername();
            }
            log.setTargetObject("User: " + userName);
            
            log.setDescription(description);
            log.setIpAddress(request.getRemoteAddr());
            new SystemLogDAO().insertLog(log);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void logCategoryEdit(HttpServletRequest request, Category oldC, Category newC) {
        if (oldC == null) return;
        StringBuilder changes = new StringBuilder("Sửa danh mục: " + oldC.getName() + " (ID: " + oldC.getId() + ") | Thay đổi: ");
        boolean changed = false;

        if (!oldC.getName().equals(newC.getName())) {
            changes.append("Name [").append(oldC.getName()).append(" -> ").append(newC.getName()).append("], ");
            changed = true;
        }
        if (oldC.getParentId() != newC.getParentId()) {
            changes.append("Parent ID [").append(oldC.getParentId()).append(" -> ").append(newC.getParentId()).append("], ");
            changed = true;
        }

        if (changed) {
            String desc = changes.toString();
            if (desc.endsWith(", ")) desc = desc.substring(0, desc.length() - 2);
            logCategoryAction(request, "EDIT_CATEGORY", desc);
        }
    }
}
