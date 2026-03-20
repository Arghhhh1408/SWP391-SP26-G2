package controller;

import dao.ProductDAO;
import dao.SystemLogDAO;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
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
        try {
            List<model.Product> products = dao.getAllProducts();
            
            java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
            ExcelUtils.exportProducts(products, baos);
            
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
            ExcelUtils.ImportResult result = ExcelUtils.importProducts(is);
            
            ProductDAO dao = new ProductDAO();
            int successCount = 0;
            java.util.List<String> dbErrors = new java.util.ArrayList<>();
            
            for (Product p : result.getValidProducts()) {
                try {
                    int newId = dao.addProduct(p);
                    if (newId > 0) {
                        successCount++;
                    } else {
                        dbErrors.add("Sản phẩm '" + p.getName() + "' (SKU: " + p.getSku() + "): Lỗi không xác định khi thêm vào database.");
                    }
                } catch (Exception e) {
                    dbErrors.add("Sản phẩm '" + p.getName() + "' (SKU: " + p.getSku() + "): " + e.getMessage());
                }
            }

            request.setAttribute("successCount", successCount);
            request.setAttribute("totalValid", result.getValidProducts().size());
            request.setAttribute("errors", result.getErrors());
            request.setAttribute("dbErrors", dbErrors);
            
            logAction(request, "IMPORT_PRODUCTS", "Import sản phẩm từ Excel: Thành công " + successCount + "/" + result.getValidProducts().size() + ". Lỗi data: " + result.getErrors().size() + ". Lỗi DB: " + dbErrors.size());
            
            request.getRequestDispatcher("importResult.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi xử lý file (có thể file không đúng định dạng): " + e.getMessage());
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
