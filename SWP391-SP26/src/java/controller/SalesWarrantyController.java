package controller;

import dao.WarrantyClaimDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.User;
import model.WarrantyClaim;

@WebServlet(name = "SalesWarrantyController", urlPatterns = {"/sales-warranty-create", "/sales-warranty-lookup"})
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
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureSales(request, response)) {
            return;
        }

        String sku = safeTrim(request.getParameter("sku"));
        String productName = safeTrim(request.getParameter("productName"));
        String customerName = safeTrim(request.getParameter("customerName"));
        String customerPhone = safeTrim(request.getParameter("customerPhone"));
        String issue = safeTrim(request.getParameter("issueDescription"));

        request.setAttribute("sku", sku);
        request.setAttribute("productName", productName);
        request.setAttribute("customerName", customerName);
        request.setAttribute("customerPhone", customerPhone);
        request.setAttribute("issueDescription", issue);

        if (sku == null || sku.isEmpty()) {
            request.setAttribute("error", "SKU là bắt buộc.");
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
            return;
        }
        if (customerName == null || customerName.isEmpty()) {
            request.setAttribute("error", "Tên khách hàng là bắt buộc.");
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
            return;
        }
        if (issue == null || issue.isEmpty()) {
            request.setAttribute("error", "Mô tả lỗi là bắt buộc.");
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
            return;
        }

        WarrantyClaimDAO dao = new WarrantyClaimDAO();
        WarrantyClaim claim = dao.create(sku, productName, customerName, customerPhone, issue, getActor(request));
        if (claim == null) {
            request.setAttribute("error", "Không thể tạo yêu cầu bảo hành, vui lòng kiểm tra dữ liệu hoặc DB.");
            request.getRequestDispatcher("sales_warranty_form.jsp").forward(request, response);
            return;
        }

        response.sendRedirect("sales-warranty-lookup?created=" + claim.getClaimCode());
    }

    private void showLookup(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        WarrantyClaimDAO dao = new WarrantyClaimDAO();
        String query = safeTrim(request.getParameter("q"));
        String created = safeTrim(request.getParameter("created"));

        List<WarrantyClaim> claims = dao.listByCreator(getActor(request), query);
        request.setAttribute("claims", claims);
        request.setAttribute("q", query);
        request.setAttribute("created", created);
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
}
