package controller;

import dao.ProductDAO;
import dao.ReturnDAO;
import dao.WarrantyClaimDAO;
import dao.WarrantyLookupDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Product;
import model.ReturnLookupResult;
import model.ReturnRequest;
import model.User;
import model.WarrantyClaim;
import model.WarrantyLookupResult;

@WebServlet(name = "SalesWarrantyController", urlPatterns = {
        "/sales-warranty-create", "/sales-warranty-lookup", "/sales-warranty-submit"
})
public class SalesWarrantyController extends HttpServlet {

    private boolean ensureSales(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 3) {
            response.sendRedirect("login");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureSales(request, response)) {
            return;
        }

        String servletPath = request.getServletPath();
        if ("/sales-warranty-lookup".equals(servletPath)) {
            showLookup(request, response);
        } else {
            String stockOutIdStr = safeTrim(request.getParameter("stockOutId"));
            String sku = safeTrim(request.getParameter("sku"));

            request.setAttribute("stockOutId", stockOutIdStr);
            request.setAttribute("sku", sku);

            WarrantyLookupDAO wlDao = new WarrantyLookupDAO();
            Integer stockOutId = tryParseInt(stockOutIdStr);
            if (stockOutId != null && sku != null && !sku.isBlank()) {
                WarrantyLookupResult r = wlDao.lookupItemByStockOutIdAndSku(stockOutId, sku);
                if (r != null) {
                    request.setAttribute("productName", r.getProductName());
                    request.setAttribute("customerName", r.getCustomerName());
                    request.setAttribute("customerPhone", r.getCustomerPhone());
                }
            }

            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureSales(request, response)) {
            return;
        }

        if ("/sales-warranty-submit".equals(request.getServletPath())) {
            handleLookupModalPost(request, response);
            return;
        }

        String sku = safeTrim(request.getParameter("sku"));
        String issue = safeTrim(request.getParameter("issueDescription"));
        String stockOutIdStr = safeTrim(request.getParameter("stockOutId"));

        request.setAttribute("sku", sku);
        request.setAttribute("stockOutId", stockOutIdStr);
        request.setAttribute("issueDescription", issue);

        if (stockOutIdStr == null || stockOutIdStr.isEmpty()) {
            request.setAttribute("error", "Vui lòng tra cứu bảo hành trước (nhập mã phiếu xuất).");
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
            return;
        }
        Integer stockOutId = tryParseInt(stockOutIdStr);
        if (stockOutId == null) {
            request.setAttribute("error", "Mã phiếu xuất không hợp lệ.");
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
            return;
        }
        if (sku == null || sku.isEmpty()) {
            request.setAttribute("error", "SKU là bắt buộc.");
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
            return;
        }
        if (issue == null || issue.isEmpty()) {
            request.setAttribute("error", "Mô tả lỗi là bắt buộc.");
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
            return;
        }

        WarrantyLookupDAO wlDao = new WarrantyLookupDAO();
        WarrantyLookupResult lookup = wlDao.lookupItemByStockOutIdAndSku(stockOutId, sku);
        if (lookup == null) {
            request.setAttribute("error", "Không tìm thấy SKU trong đơn/phiếu xuất đã nhập.");
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
            return;
        }
        if (!wlDao.isItemInWarranty(stockOutId, sku)) {
            request.setAttribute("error", "Sản phẩm đã hết hạn bảo hành. Không thể tạo yêu cầu.");
            request.setAttribute("productName", lookup.getProductName());
            request.setAttribute("customerName", lookup.getCustomerName());
            request.setAttribute("customerPhone", lookup.getCustomerPhone());
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
            return;
        }

        WarrantyClaimDAO dao = new WarrantyClaimDAO();
        WarrantyClaim claim = dao.create(
                sku,
                lookup.getProductName(),
                lookup.getCustomerName(),
                lookup.getCustomerPhone(),
                issue,
                getActor(request)
        );
        if (claim == null) {
            request.setAttribute("error", "Không thể tạo yêu cầu bảo hành, vui lòng kiểm tra dữ liệu hoặc DB.");
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
            return;
        }

        response.sendRedirect("sales-warranty-lookup?created=" + claim.getClaimCode());
    }

    private void handleLookupModalPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        boolean toDashboard = "dashboard".equalsIgnoreCase(safeTrim(request.getParameter("redirectTarget")));
        String lookupHome = toDashboard ? "sales_dashboard?tab=warranty-lookup" : "sales-warranty-lookup";
        String returnLookupHome = toDashboard ? "sales_dashboard?tab=return-lookup" : "sales-warranty-lookup";

        String type = safeTrim(request.getParameter("requestType"));
        String stockOutIdStr = safeTrim(request.getParameter("stockOutId"));
        String sku = safeTrim(request.getParameter("sku"));
        String issue = safeTrim(request.getParameter("issueDescription"));

        if (stockOutIdStr == null || stockOutIdStr.isEmpty() || sku == null || sku.isEmpty()) {
            session.setAttribute("lookupFlashError", "Thiếu mã phiếu xuất hoặc SKU.");
            response.sendRedirect(lookupHome);
            return;
        }
        if (issue == null || issue.isEmpty()) {
            session.setAttribute("lookupFlashError", "Vui lòng nhập mô tả lỗi / lý do.");
            response.sendRedirect(lookupHome);
            return;
        }

        Integer stockOutId = tryParseInt(stockOutIdStr);
        if (stockOutId == null) {
            session.setAttribute("lookupFlashError", "Mã phiếu xuất không hợp lệ.");
            response.sendRedirect(lookupHome);
            return;
        }

        WarrantyLookupDAO wlDao = new WarrantyLookupDAO();
        WarrantyLookupResult lookup = wlDao.lookupItemByStockOutIdAndSku(stockOutId, sku);
        if (lookup == null) {
            session.setAttribute("lookupFlashError", "Không tìm thấy dòng bán hàng tương ứng.");
            response.sendRedirect(lookupHome);
            return;
        }

        String actor = getActor(request);

        if ("return".equalsIgnoreCase(type)) {
            if (!ReturnLookupResult.isPurchaseWithinReturnWindow(lookup.getPurchaseDate())) {
                session.setAttribute("lookupFlashError",
                        "Chỉ được trả hàng trong vòng 7 ngày kể từ ngày mua (theo ngày trên phiếu xuất này).");
                response.sendRedirect(returnLookupHome);
                return;
            }
            String productName = lookup.getProductName();
            if (productName == null || productName.isBlank()) {
                ProductDAO pDao = new ProductDAO();
                Product p = pDao.getBySku(sku);
                productName = p == null ? "" : p.getName();
            }
            if (productName == null || productName.isBlank()) {
                session.setAttribute("lookupFlashError", "Không xác định được tên sản phẩm.");
                response.sendRedirect(returnLookupHome);
                return;
            }
            ReturnDAO rDao = new ReturnDAO();
            ReturnRequest rr = rDao.create(
                    sku,
                    productName,
                    lookup.getCustomerName(),
                    lookup.getCustomerPhone(),
                    issue,
                    "",
                    actor
            );
            if (rr == null) {
                session.setAttribute("lookupFlashError", "Không thể tạo yêu cầu trả hàng.");
            } else if (toDashboard) {
                response.sendRedirect("sales_dashboard?tab=return-lookup&returnCreated=" + rr.getReturnCode());
                return;
            } else {
                response.sendRedirect("sales-warranty-lookup?returnCreated=" + rr.getReturnCode());
                return;
            }
            response.sendRedirect(returnLookupHome);
            return;
        }

        if (!wlDao.isItemInWarranty(stockOutId, sku)) {
            session.setAttribute("lookupFlashError", "Sản phẩm đã hết hạn bảo hành (12 tháng). Chọn \"Trả hàng\" nếu áp dụng, hoặc không thể tạo bảo hành.");
            response.sendRedirect(lookupHome);
            return;
        }

        WarrantyClaimDAO wcDao = new WarrantyClaimDAO();
        WarrantyClaim claim = wcDao.create(
                sku,
                lookup.getProductName(),
                lookup.getCustomerName(),
                lookup.getCustomerPhone(),
                issue,
                actor
        );
        if (claim == null) {
            session.setAttribute("lookupFlashError", "Không thể tạo yêu cầu bảo hành.");
            response.sendRedirect(lookupHome);
            return;
        }
        if (toDashboard) {
            response.sendRedirect("sales_dashboard?tab=warranty-lookup&created=" + claim.getClaimCode());
        } else {
            response.sendRedirect("sales-warranty-lookup?created=" + claim.getClaimCode());
        }
    }

    private void showLookup(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object fe = session.getAttribute("lookupFlashError");
            if (fe != null) {
                request.setAttribute("error", fe.toString());
                session.removeAttribute("lookupFlashError");
            }
            Object fs = session.getAttribute("lookupFlashSuccess");
            if (fs != null) {
                request.setAttribute("lookupSuccess", fs.toString());
                session.removeAttribute("lookupFlashSuccess");
            }
        }

        String created = safeTrim(request.getParameter("created"));
        String returnCreated = safeTrim(request.getParameter("returnCreated"));
        WarrantyLookupServletHelper.applyLookup(request);
        request.setAttribute("created", created);
        request.setAttribute("returnCreated", returnCreated);

        String showClaims = safeTrim(request.getParameter("showClaims"));
        boolean showInProgressClaims = "1".equals(showClaims);
        request.setAttribute("showInProgressClaims", showInProgressClaims);
        if (showInProgressClaims) {
            WarrantyClaimDAO wcDao = new WarrantyClaimDAO();
            request.setAttribute("inProgressClaims", wcDao.listInProgressByCreator(getActor(request)));
        }

        request.getRequestDispatcher("sales_warranty_lookup.jsp").forward(request, response);
    }

    private String getActor(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object acc = session.getAttribute("acc");
        if (acc instanceof User) {
            User u = (User) acc;
            if (u.getUsername() != null && !u.getUsername().isBlank()) {
                return u.getUsername();
            }
            return "user#" + u.getUserID();
        }
        return "unknown";
    }

    private String safeTrim(String s) {
        return s == null ? null : s.trim();
    }

    private Integer tryParseInt(String s) {
        if (s == null || s.isBlank()) {
            return null;
        }
        try {
            return Integer.parseInt(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
