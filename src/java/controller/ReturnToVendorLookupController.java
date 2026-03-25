/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
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
import java.util.List;
import model.StockInDetail;
import model.Supplier;
import model.SupplierProduct;

/**
 *
 * @author dotha
 */
@WebServlet(name = "ReturnToVendorLookupController", urlPatterns = {"/rtv-lookup"})
public class ReturnToVendorLookupController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
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

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

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

        int pageSize = 5;
        PrintWriter out = response.getWriter();

        try {
            if ("supplier".equals(type)) {
                SupplierDAO dao = new SupplierDAO();
                List<Supplier> list = dao.searchActiveSuppliersForLookup(keyword, page, pageSize);
                out.print(renderSupplierHtml(list));
                return;
            }

            if ("product".equals(type)) {
                int supplierID = Integer.parseInt(request.getParameter("supplierID"));
                SupplierProductDAO dao = new SupplierProductDAO();
                List<SupplierProduct> list = dao.searchProductsBySupplierPaged(supplierID, keyword, page, pageSize);
                out.print(renderProductHtml(list));
                return;
            }

            if ("detail".equals(type)) {
                int supplierID = Integer.parseInt(request.getParameter("supplierID"));
                int productID = Integer.parseInt(request.getParameter("productID"));
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
                    .append(" | Remain ")
                    .append(remainingQty)
                    .append(" | Cost ")
                    .append(d.getUnitCost())
                    .append("</div>");
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
                .replace("'", "\\'")
                .replace("\"", "\\\"");
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
