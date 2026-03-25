package controller;

import dao.StockInDAO;
import dao.SupplierDAO;
import dao.SupplierProductDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.StockInDetail;
import model.Supplier;
import model.SupplierProduct;
import model.User;

@WebServlet(name = "ReturnToVendorLookupController", urlPatterns = {"/rtv-lookup"})
public class ReturnToVendorLookupController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ReturnToVendorLookupController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ReturnToVendorLookupController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    private Integer parseInteger(String value) {
        try {
            return value == null || value.trim().isEmpty() ? null : Integer.parseInt(value.trim());
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User acc = session == null ? null : (User) session.getAttribute("acc");
        PrintWriter out = response.getWriter();

        if (acc == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("<div class='lookup-item'>Session expired. Please login again.</div>");
            return;
        }

        String type = request.getParameter("type");
        String keyword = request.getParameter("keyword");
        if (keyword == null) {
            keyword = "";
        }

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception ignored) {
        }
        if (page < 1) {
            page = 1;
        }

        int pageSize = 5;

        try {
            if ("supplier".equals(type)) {
                SupplierDAO dao = new SupplierDAO();
                List<Supplier> list = dao.searchActiveSuppliersForLookup(keyword, page, pageSize);
                out.print(renderSupplierHtml(list));
                return;
            }

            if ("product".equals(type)) {
                Integer supplierID = parseInteger(request.getParameter("supplierID"));
                if (supplierID == null) {
                    out.print("<div class='lookup-item'>Please select supplier first.</div>");
                    return;
                }
                SupplierProductDAO dao = new SupplierProductDAO();
                List<SupplierProduct> list = dao.searchProductsBySupplierPaged(supplierID, keyword, page, pageSize);
                out.print(renderProductHtml(list));
                return;
            }

            if ("detail".equals(type)) {
                Integer supplierID = parseInteger(request.getParameter("supplierID"));
                Integer productID = parseInteger(request.getParameter("productID"));
                if (supplierID == null || productID == null) {
                    out.print("<div class='lookup-item'>Please select supplier and product first.</div>");
                    return;
                }
                StockInDAO dao = new StockInDAO();
                List<StockInDetail> list = dao.searchReturnableStockInDetails(supplierID, productID, keyword, page, pageSize);
                out.print(renderDetailHtml(list, dao));
                return;
            }

            out.print("<div class='lookup-item'>No data found.</div>");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("<div class='lookup-item'>Error loading data.</div>");
        }
    }

    private String renderSupplierHtml(List<Supplier> list) {
        StringBuilder sb = new StringBuilder();

        if (list == null || list.isEmpty()) {
            sb.append("<div class='lookup-item'>No supplier found.</div>");
            return sb.toString();
        }

        for (Supplier s : list) {
            sb.append("<div class=\"lookup-item\" ")
                    .append("onclick=\"selectSupplier(")
                    .append(s.getId())
                    .append(", '")
                    .append(escapeJs(s.getSupplierName()))
                    .append("')\">")
                    .append(s.getId())
                    .append(" - ")
                    .append(escapeHtml(s.getSupplierName()))
                    .append("</div>");
        }

        return sb.toString();
    }

    private String renderProductHtml(List<SupplierProduct> list) {
        StringBuilder sb = new StringBuilder();

        if (list == null || list.isEmpty()) {
            sb.append("<div class='lookup-item'>No product found.</div>");
            return sb.toString();
        }

        for (SupplierProduct p : list) {
            sb.append("<div class='lookup-item' onclick=\"selectProduct(")
                    .append("CURRENT_ROW_INDEX")
                    .append(", ")
                    .append(p.getProductID())
                    .append(", '")
                    .append(escapeJs(p.getProductName()))
                    .append("')\">")
                    .append(p.getProductID())
                    .append(" - ")
                    .append(escapeHtml(p.getProductName()))
                    .append("</div>");
        }

        return sb.toString();
    }

    private String renderDetailHtml(List<StockInDetail> list, StockInDAO dao) {
        StringBuilder sb = new StringBuilder();

        if (list == null || list.isEmpty()) {
            sb.append("<div class='lookup-item'>No stock-in detail found.</div>");
            return sb.toString();
        }

        for (StockInDetail d : list) {
            int remainingQty = dao.getRemainingReturnableQuantity(d.getDetailId());
            if (remainingQty <= 0) {
                continue;
            }

            sb.append("<div class='lookup-item' onclick=\"selectDetail(")
                    .append("CURRENT_ROW_INDEX")
                    .append(", ")
                    .append(d.getDetailId())
                    .append(", ")
                    .append(d.getStockInId())
                    .append(", ")
                    .append(d.getProductId())
                    .append(", ")
                    .append(remainingQty)
                    .append(", ")
                    .append(d.getUnitCost())
                    .append(")\">")
                    .append("Detail ")
                    .append(d.getDetailId())
                    .append(" | StockIn ")
                    .append(d.getStockInId())
                    .append(" | Received ")
                    .append(d.getReceivedQuantity())
                    .append("/")
                    .append(d.getQuantity())
                    .append(" | Returnable ")
                    .append(remainingQty)
                    .append(" | UnitCost ")
                    .append(d.getUnitCost())
                    .append("</div>");
        }

        if (sb.length() == 0) {
            sb.append("<div class='lookup-item'>No stock-in detail found.</div>");
        }
        return sb.toString();
    }

    private String escapeHtml(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String escapeJs(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\")
                .replace("\r", "\\r")
                .replace("\n", "\\n")
                .replace("'", "\\'")
                .replace("\"", "\\\"");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
