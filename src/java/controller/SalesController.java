package controller;

import dao.CategoryDAO;
import dao.ReturnDAO;
import dao.WarrantyClaimDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
import model.ReturnRequest;
import model.User;
import model.WarrantyClaim;

@WebServlet(name = "SalesController", urlPatterns = {"/sales_dashboard"})
public class SalesController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureSales(request, response)) {
            return;
        }

        String tab = safeTrim(request.getParameter("tab"));
        if (tab == null || tab.isEmpty()) {
            tab = "dashboard";
        }
        request.setAttribute("tab", tab);

        if ("warranty-lookup".equals(tab)) {
            WarrantyClaimDAO dao = new WarrantyClaimDAO();
            String q = safeTrim(request.getParameter("q"));
            String created = safeTrim(request.getParameter("created"));
            request.setAttribute("q", q);
            request.setAttribute("created", created);
            request.setAttribute("claims", dao.listByCreator(getActor(request), q));
        } else if ("return-lookup".equals(tab)) {
            ReturnDAO dao = new ReturnDAO();
            String q = safeTrim(request.getParameter("rq"));
            String returnCreated = safeTrim(request.getParameter("returnCreated"));
            request.setAttribute("rq", q);
            request.setAttribute("returnCreated", returnCreated);
            request.setAttribute("returnClaims", dao.listByCreator(getActor(request), q));
        } else if ("return-create".equals(tab)) {
            String returnCreated = safeTrim(request.getParameter("returnCreated"));
            request.setAttribute("returnCreated", returnCreated);
        } else if ("products".equals(tab)) {
            try {
                CategoryDAO dao = new CategoryDAO();
                List<Product> products = dao.getAllProducts();
                request.setAttribute("salesProducts", products);
            } catch (Exception e) {
                request.setAttribute("error", "Không thể tải danh sách sản phẩm.");
            }
        }

        request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureSales(request, response)) {
            return;
        }

        String action = safeTrim(request.getParameter("action"));
        if (action == null || action.isEmpty()) {
            action = "";
        }

        switch (action) {
            case "createWarranty" ->
                handleCreateWarranty(request, response);
            case "createReturn" ->
                handleCreateReturn(request, response);
            default ->
                response.sendRedirect("sales_dashboard");
        }
    }

    private void handleCreateWarranty(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String sku = safeTrim(request.getParameter("sku"));
        String productName = safeTrim(request.getParameter("productName"));
        String customerName = safeTrim(request.getParameter("customerName"));
        String customerPhone = safeTrim(request.getParameter("customerPhone"));
        String issue = safeTrim(request.getParameter("issueDescription"));

        request.setAttribute("tab", "warranty-create");
        request.setAttribute("sku", sku);
        request.setAttribute("productName", productName);
        request.setAttribute("customerName", customerName);
        request.setAttribute("customerPhone", customerPhone);
        request.setAttribute("issueDescription", issue);

        if (sku == null || sku.isEmpty()) {
            request.setAttribute("error", "SKU là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }
        if (customerName == null || customerName.isEmpty()) {
            request.setAttribute("error", "Tên khách hàng là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }
        if (issue == null || issue.isEmpty()) {
            request.setAttribute("error", "Mô tả lỗi là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }

        WarrantyClaimDAO dao = new WarrantyClaimDAO();
        WarrantyClaim claim = dao.create(sku, productName, customerName, customerPhone, issue, getActor(request));
        if (claim == null) {
            request.setAttribute("error", "Không thể tạo yêu cầu bảo hành, vui lòng kiểm tra dữ liệu hoặc DB.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }

        response.sendRedirect("sales_dashboard?tab=warranty-lookup&created=" + claim.getClaimCode());
    }

    private void handleCreateReturn(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String sku = safeTrim(request.getParameter("returnSku"));
        String productName = safeTrim(request.getParameter("returnProductName"));
        String customerName = safeTrim(request.getParameter("returnCustomerName"));
        String customerPhone = safeTrim(request.getParameter("returnCustomerPhone"));
        String reason = safeTrim(request.getParameter("returnReason"));
        String conditionNote = safeTrim(request.getParameter("returnConditionNote"));

        request.setAttribute("tab", "return-create");
        request.setAttribute("returnSku", sku);
        request.setAttribute("returnProductName", productName);
        request.setAttribute("returnCustomerName", customerName);
        request.setAttribute("returnCustomerPhone", customerPhone);
        request.setAttribute("returnReason", reason);
        request.setAttribute("returnConditionNote", conditionNote);

        if (sku == null || sku.isEmpty()) {
            request.setAttribute("error", "SKU là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }
        if (customerName == null || customerName.isEmpty()) {
            request.setAttribute("error", "Tên khách hàng là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }
        if (reason == null || reason.isEmpty()) {
            request.setAttribute("error", "Lý do trả hàng là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }

        ReturnDAO dao = new ReturnDAO();
        ReturnRequest rr = dao.create(sku, productName, customerName, customerPhone, reason, conditionNote, getActor(request));
        if (rr == null) {
            request.setAttribute("error", "Không thể tạo yêu cầu trả hàng, vui lòng kiểm tra dữ liệu hoặc DB.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }

        response.sendRedirect("sales_dashboard?tab=return-lookup&returnCreated=" + rr.getReturnCode());
    }

    private boolean ensureSales(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 3) {
            response.sendRedirect("login");
            return false;
        }
        return true;
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
