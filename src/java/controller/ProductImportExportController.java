package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.SystemLogDAO;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.Category;
import model.Product;
import model.SystemLog;
import model.User;
import utils.ExcelUtils;

@WebServlet(name = "ProductImportExportController", urlPatterns = {"/exportProducts", "/importProducts"})
@MultipartConfig
public class ProductImportExportController extends HttpServlet {

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
        if (!ensureStaffOrManager(request, response)) return;

        String path = request.getServletPath();
        if ("/exportProducts".equals(path)) {
            handleExport(request, response);
        } else {
            response.sendRedirect("staff_dashboard?tab=products");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureStaffOrManager(request, response)) return;

        String path = request.getServletPath();
        if ("/importProducts".equals(path)) {
            handleImport(request, response);
        } else {
            response.sendRedirect("staff_dashboard?tab=products");
        }
    }

    private void handleExport(HttpServletRequest request, HttpServletResponse response) throws IOException {
        ProductDAO dao = new ProductDAO();
        CategoryDAO catDao = new CategoryDAO();
        try {
            List<Product> products = dao.getAllProducts();
            
            // Prepare category map for the util
            List<Category> cats = catDao.getAllCategories();
            Map<Integer, String> catMap = new HashMap<>();
            for (Category c : cats) {
                catMap.put(c.getId(), c.getName());
            }

            java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
            ExcelUtils.exportProducts(products, catMap, baos);
            
            byte[] content = baos.toByteArray();
            
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=products_export.xlsx");
            response.setContentLength(content.length);
            
            response.getOutputStream().write(content);
            response.getOutputStream().flush();
            
            logAction(request, "EXPORT_PRODUCTS", "Xuất danh sách sản phẩm ra file Excel (" + products.size() + " sản phẩm)");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi khi xuất file Excel: " + e.getMessage());
            response.sendRedirect("staff_dashboard?tab=products");
        }
    }

    private void handleImport(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute("error", "Vui lòng chọn file Excel để import.");
            request.getRequestDispatcher("importResult.jsp").forward(request, response);
            return;
        }

        try (InputStream is = filePart.getInputStream()) {
            // Parse raw data from Excel
            List<ExcelUtils.ImportedProduct> imported = ExcelUtils.parseProducts(is);
            
            CategoryDAO catDao = new CategoryDAO();
            ProductDAO prodDao = new ProductDAO();
            
            List<Product> productsToInsert = new ArrayList<>();
            List<String> dataErrors = new ArrayList<>();
            int totalAttempted = imported.size();
            
            for (ExcelUtils.ImportedProduct ip : imported) {
                // Validation (Logic moved from Utility to Controller)
                if (ip.name == null || ip.name.isEmpty() || ip.sku == null || ip.sku.isEmpty()) {
                    dataErrors.add("Dòng " + ip.rowNum + ": Tên và SKU là bắt buộc.");
                    continue;
                }
                if (prodDao.isProductSkuExists(ip.sku)) {
                    dataErrors.add("Dòng " + ip.rowNum + ": SKU '" + ip.sku + "' đã tồn tại.");
                    continue;
                }
                Integer categoryId = catDao.getCategoryIdByName(ip.categoryName);
                if (categoryId == null) {
                    dataErrors.add("Dòng " + ip.rowNum + ": Không tìm thấy danh mục '" + ip.categoryName + "'.");
                    continue;
                }

                Product p = new Product();
                p.setName(ip.name);
                p.setSku(ip.sku);
                p.setCost(ip.cost);
                p.setPrice(ip.price);
                p.setQuantity(ip.quantity);
                p.setUnit(ip.unit);
                p.setCategoryId(categoryId);
                p.setStatus(ip.status == null || ip.status.isEmpty() ? "Active" : ip.status);
                p.setDescription(ip.description);
                p.setImageURL(ip.imageUrl);
                productsToInsert.add(p);
            }
            
            // Database updates
            int successCount = 0;
            List<String> dbErrors = new ArrayList<>();
            for (Product p : productsToInsert) {
                try {
                    int newId = prodDao.addProduct(p);
                    if (newId > 0) {
                        successCount++;
                    } else {
                        dbErrors.add("Sản phẩm '" + p.getName() + "': Lỗi DB không xác định.");
                    }
                } catch (Exception e) {
                    dbErrors.add("Sản phẩm '" + p.getName() + "': " + e.getMessage());
                }
            }

            request.setAttribute("successCount", successCount);
            request.setAttribute("totalAttempted", totalAttempted);
            request.setAttribute("errors", dataErrors);
            request.setAttribute("dbErrors", dbErrors);
            
            logAction(request, "IMPORT_PRODUCTS", "Import sản phẩm: Thành công " + successCount + "/" + totalAttempted);
            
            request.getRequestDispatcher("importResult.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi gửi file hoặc định dạng file: " + e.getMessage());
            request.getRequestDispatcher("importResult.jsp").forward(request, response);
        }
    }

    private void logAction(HttpServletRequest request, String action, String description) {
        try {
            HttpSession session = request.getSession(false);
            User u = (User) session.getAttribute("acc");
            SystemLog log = new SystemLog();
            log.setUserID(u != null ? u.getUserID() : 0);
            log.setAction(action);
            log.setTargetObject("Product");
            log.setDescription(description);
            log.setIpAddress(request.getRemoteAddr());
            new SystemLogDAO().insertLog(log);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
