/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.ProductDAO;
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
import model.Product;
import model.SupplierProduct;
import model.User;

/**
 *
 * @author dotha
 */
@WebServlet(name = "SupplierProductController", urlPatterns = {"/supplierProduct"})
public class SupplierProductController extends HttpServlet {

    private SupplierProductDAO dao;

    @Override
    public void init() {
        dao = new SupplierProductDAO();
    }

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
            out.println("<title>Servlet SupplierProductController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet SupplierProductController at " + request.getContextPath() + "</h1>");
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

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("acc") : null;

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        String supplierIdRaw = request.getParameter("supplierId");
        if (supplierIdRaw == null || supplierIdRaw.trim().isEmpty()) {
            response.sendRedirect("supplierList");
            return;
        }

        try {
            int supplierId = Integer.parseInt(supplierIdRaw);

            List<SupplierProduct> list = dao.getProductsBySupplier(supplierId);

            ProductDAO productDAO = new ProductDAO();
            List<Product> productList = productDAO.getAllActiveProducts();

            request.setAttribute("supplierId", supplierId);
            request.setAttribute("supplierProducts", list);
            request.setAttribute("productList", productList);

            request.getRequestDispatcher("supplierProductList.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("supplierList");
        }
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

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("acc") : null;

        if (user == null || user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String supplierIdRaw = request.getParameter("supplierId");

        if (supplierIdRaw == null || supplierIdRaw.trim().isEmpty()) {
            response.sendRedirect("supplierList");
            return;
        }

        int supplierId = Integer.parseInt(supplierIdRaw);

        try {
            if ("add".equals(action)) {
                String productIdRaw = request.getParameter("productId");
                String supplyPriceRaw = request.getParameter("supplyPrice");

                if (productIdRaw == null || productIdRaw.trim().isEmpty()) {
                    session.setAttribute("message", "Vui lòng chọn sản phẩm từ danh sách!");
                    session.setAttribute("status", "error");
                    response.sendRedirect("supplierProduct?supplierId=" + supplierId);
                    return;
                }

                int productId = Integer.parseInt(productIdRaw);
                double supplyPrice = Double.parseDouble(supplyPriceRaw);

                if (dao.checkDuplicate(supplierId, productId)) {
                    session.setAttribute("message", "Sản phẩm này đã tồn tại trong nhà cung cấp!");
                    session.setAttribute("status", "error");
                } else {
                    boolean ok = dao.addSupplierProduct(supplierId, productId, supplyPrice);
                    if (ok) {
                        session.setAttribute("message", "Thêm sản phẩm cho nhà cung cấp thành công!");
                        session.setAttribute("status", "success");
                    } else {
                        session.setAttribute("message", "Thêm sản phẩm thất bại!");
                        session.setAttribute("status", "error");
                    }
                }

            } else if ("update".equals(action)) {
                int supplierProductId = Integer.parseInt(request.getParameter("supplierProductId"));
                double supplyPrice = Double.parseDouble(request.getParameter("supplyPrice"));
                boolean isActive = request.getParameter("isActive") != null;

                boolean ok = dao.updateSupplierProduct(supplierProductId, supplyPrice, isActive);

                if (ok) {
                    session.setAttribute("message", "Cập nhật sản phẩm nhà cung cấp thành công!");
                    session.setAttribute("status", "success");
                } else {
                    session.setAttribute("message", "Cập nhật thất bại!");
                    session.setAttribute("status", "error");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Lỗi: " + e.getMessage());
            session.setAttribute("status", "error");
        }

        response.sendRedirect("supplierProduct?supplierId=" + supplierId);
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
