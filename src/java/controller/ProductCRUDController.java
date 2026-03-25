package controller;

import dao.CategoryDAO;
import dao.NotificationDAO;
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
import model.Notification;
import model.Product;
import model.SystemLog;
import model.User;

@WebServlet(name = "ProductCRUDController", urlPatterns = { "/addProduct", "/editProduct", "/deleteProduct" })
public class ProductCRUDController extends HttpServlet {

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

        String action = request.getServletPath();
        CategoryDAO dao = new CategoryDAO();
        ProductDAO pDao = new ProductDAO();
        try {
            if (action.equals("/addProduct")) {
                List<Category> categories = dao.getHierarchicalList();
                request.setAttribute("categories", categories);
                request.getRequestDispatcher("productForm.jsp").forward(request, response);
            } else if (action.equals("/editProduct")) {
                int id = Integer.parseInt(request.getParameter("id"));
                Product p = pDao.getProductById(id);
                if (p != null) {
                    List<Category> categories = dao.getHierarchicalList();
                    request.setAttribute("product", p);
                    request.setAttribute("categories", categories);
                    request.getRequestDispatcher("productForm.jsp").forward(request, response);
                } else {
                    response.sendRedirect("category");
                }
            } else if (action.equals("/deleteProduct")) {
                int id = Integer.parseInt(request.getParameter("id"));
                Product pToDelete = pDao.getProductById(id);
                pDao.deleteProduct(id);
                if (pToDelete != null) {
                    logProductAction(request, "DELETE_PRODUCT", "Xóa sản phẩm: " + pToDelete.getName() + " | SKU: " + pToDelete.getSku() + " | ID: " + id);
                }
                response.sendRedirect(getAfterCrudRedirect(request));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(getAfterCrudRedirect(request));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureStaffOrManager(request, response)) {
            return;
        }

        CategoryDAO dao = new CategoryDAO();
        ProductDAO pDao = new ProductDAO();

        try {
            request.setCharacterEncoding("UTF-8");
            String idStr = request.getParameter("id");
            String name = request.getParameter("name");
            String sku = request.getParameter("sku");
            String unit = request.getParameter("unit");
            String description = request.getParameter("description");
            String imageURL = request.getParameter("imageURL");
            String status = request.getParameter("status");
            String lowStockThresholdStr = request.getParameter("lowStockThreshold");
            int categoryId = 0;

            double cost = 0;
            double price = 0;
            int lowStockThreshold = 10; // Default

            try {
                categoryId = Integer.parseInt(request.getParameter("categoryId"));
                String costStr = request.getParameter("cost");
                String priceStr = request.getParameter("price");

                if (costStr != null && !costStr.isEmpty())
                    cost = Double.parseDouble(costStr);
                if (priceStr != null && !priceStr.isEmpty())
                    price = Double.parseDouble(priceStr);
                if (lowStockThresholdStr != null && !lowStockThresholdStr.isEmpty())
                    lowStockThreshold = Integer.parseInt(lowStockThresholdStr);

            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid number format for Cost or Price");
                List<Category> categories = dao.getHierarchicalList();
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

            if (cost < 0 || price < 0) {
                request.setAttribute("error", "Cost and Price must be non-negative!");
                List<Category> categories = dao.getHierarchicalList();
                request.setAttribute("categories", categories);

                Product pError = new Product();
                pError.setName(name);
                pError.setSku(sku);
                pError.setCost(cost);
                pError.setPrice(price);
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
            p.setUnit(unit);
            p.setDescription(description);
            p.setImageURL(imageURL);
            p.setStatus(status);
            p.setCategoryId(categoryId);
            p.setLowStockThreshold(lowStockThreshold);

            if (idStr == null || idStr.isEmpty()) {
                // Check SKU exists
                if (pDao.isProductSkuExists(sku)) {
                    request.setAttribute("error", "SKU already exists!");
                    List<Category> categories = dao.getHierarchicalList();
                    request.setAttribute("categories", categories);
                    request.setAttribute("product", p);
                    request.getRequestDispatcher("productForm.jsp").forward(request, response);
                    return;
                }
                int newId = pDao.addProduct(p);
                if (newId > 0) {
                    new dao.LowStockDAO().saveOrUpdateAlert(newId, lowStockThreshold);
                    
                    // Notify staff if added by Manager
                    HttpSession session = request.getSession(false);
                    User currentUser = (User) session.getAttribute("acc");
                    if (currentUser != null && currentUser.getRoleID() == 2) {
                        NotificationDAO nDao = new NotificationDAO();
                        Category cat = dao.getCategoryById(p.getCategoryId());
                        String categoryName = (cat != null) ? cat.getName() : "Không xác định";
                        
                        String message = String.format("Manager Đã thêm 1 sản phẩm | Tên sản phẩm: %s | Danh mục sản phẩm: %s",
                                p.getName(), categoryName);
                                
                        List<Integer> staffIds = nDao.getStaffIds();
                        for (int staffId : staffIds) {
                            Notification n = new Notification();
                            n.setUserId(staffId);
                            n.setTitle("Sản phẩm mới");
                            n.setMessage(message);
                            n.setType("PRODUCT_ADDED");
                            nDao.insert(n);
                        }
                    }
                }
                logProductAction(request, "ADD_PRODUCT", "Thêm sản phẩm mới: " + p.getName() + " | SKU: " + p.getSku() + " | ID: " + newId);
            } else {
                int id = Integer.parseInt(idStr);
                Product oldP = pDao.getProductById(id);
                p.setId(id);
                // Preserve existing stock quantity (managed via stock-in only)
                if (oldP != null) {
                    p.setQuantity(oldP.getQuantity());
                }
                pDao.updateProduct(p);
                new dao.LowStockDAO().saveOrUpdateAlert(id, lowStockThreshold);
                logProductEdit(request, oldP, p);
            }
            response.sendRedirect(getAfterCrudRedirect(request));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("category");
        }
    }

    private void logProductAction(HttpServletRequest request, String action, String description) {
        try {
            HttpSession session = request.getSession(false);
            User u = (User) session.getAttribute("acc");
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

    private void logProductEdit(HttpServletRequest request, Product oldP, Product newP) {
        if (oldP == null) return;
        StringBuilder changes = new StringBuilder("Sửa sản phẩm: " + oldP.getName() + " (ID: " + oldP.getId() + ") | Thay đổi: ");
        boolean changed = false;

        if (!oldP.getName().equals(newP.getName())) {
            changes.append("Name [").append(oldP.getName()).append(" -> ").append(newP.getName()).append("], ");
            changed = true;
        }
        if (oldP.getPrice() != newP.getPrice()) {
            changes.append("Price [").append(oldP.getPrice()).append(" -> ").append(newP.getPrice()).append("], ");
            changed = true;
        }
        if (oldP.getCost() != newP.getCost()) {
            changes.append("Cost [").append(oldP.getCost()).append(" -> ").append(newP.getCost()).append("], ");
            changed = true;
        }
        // Quantity is no longer editable via product form (managed via stock-in)
        if (!oldP.getStatus().equals(newP.getStatus())) {
            changes.append("Status [").append(oldP.getStatus()).append(" -> ").append(newP.getStatus()).append("], ");
            changed = true;
        }
        if (oldP.getCategoryId() != newP.getCategoryId()) {
            changes.append("Category ID [").append(oldP.getCategoryId()).append(" -> ").append(newP.getCategoryId()).append("], ");
            changed = true;
        }

        if (changed) {
            String desc = changes.toString();
            if (desc.endsWith(", ")) desc = desc.substring(0, desc.length() - 2);
            logProductAction(request, "EDIT_PRODUCT", desc);
        }
    }

    private String getAfterCrudRedirect(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("acc");
        if (u != null && u.getRoleID() == 1) {
            return "staff_dashboard?tab=products";
        }
        return "category";
    }
}
