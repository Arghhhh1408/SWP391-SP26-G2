package controller;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.Product;
import model.User;

@WebServlet(name = "WarrantyLookupController", urlPatterns = {"/warrantyLookup"})
public class WarrantyLookupController extends HttpServlet {

    private boolean ensureAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 0) {
            response.sendRedirect("login");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureAdmin(request, response)) {
            return;
        }
        request.getRequestDispatcher("warrantyLookup.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureAdmin(request, response)) {
            return;
        }

        String lookupType = safeTrim(request.getParameter("lookupType"));
        if (lookupType == null || lookupType.isEmpty()) {
            lookupType = "sku";
        }
        if (!"sku".equals(lookupType) && !"productName".equals(lookupType)) {
            lookupType = "sku";
        }

        String query = safeTrim(request.getParameter("query"));

        request.setAttribute("lookupType", lookupType);
        request.setAttribute("query", query);

        if (query == null || query.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập giá trị cần tra cứu.");
            request.getRequestDispatcher("warrantyLookup.jsp").forward(request, response);
            return;
        }

        ProductDAO dao = new ProductDAO();

        List<Product> products = new ArrayList<>();
        if ("sku".equals(lookupType)) {
            Product p = dao.getBySku(query);
            if (p != null) {
                products.add(p);
            }
        } else if ("productName".equals(lookupType)) {
            products = dao.searchByName(query);
        }

        if (products == null || products.isEmpty()) {
            request.setAttribute("message", "Không tìm thấy sản phẩm cho: " + query);
        } else {
            request.setAttribute("products", products);
            request.setAttribute("message", "Tìm thấy " + products.size() + " sản phẩm.");
        }

        request.getRequestDispatcher("warrantyLookup.jsp").forward(request, response);
    }

    private String safeTrim(String s) {
        return s == null ? null : s.trim();
    }
}

