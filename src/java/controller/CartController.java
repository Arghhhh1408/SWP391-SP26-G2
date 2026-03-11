/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.ProductDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;
import model.CartItem;
import model.Product;

/**
 *
 * @author DELL
 */
@WebServlet(name = "CartController", urlPatterns = {"/cart"})
public class CartController extends HttpServlet {

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
            out.println("<title>Servlet CartController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CartController at " + request.getContextPath() + "</h1>");
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
        request.getRequestDispatcher("/cart.jsp").forward(request, response);
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

        HttpSession session = request.getSession();
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new HashMap<>();
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "add";
        }

        int productId = Integer.parseInt(request.getParameter("productId"));

        ProductDAO pdao = new ProductDAO();
        Product p = pdao.getById(productId);
        if (p == null) {
            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        CartItem item = cart.get(productId);

        String keyword = request.getParameter("keyword");
        if (keyword == null) {
            keyword = "";
        }

        String from = request.getParameter("from");
        if (from == null) {
            from = "pos";
        }

        String backUrl;
        if ("cart".equalsIgnoreCase(from)) {
            backUrl = request.getContextPath() + "/cart";
        } else {
            backUrl = request.getContextPath() + "/pos?keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8");
        }

        int stock = pdao.getStockById(productId);

        switch (action) {
            case "add":
            case "inc": {
                int newQty = (item == null) ? 1 : item.getQty() + 1;

                if (newQty > stock) {
                    String url;
                    if ("cart".equalsIgnoreCase(from)) {
                        url = request.getContextPath()
                                + "/cart?err=not_enough_stock"
                                + "&sku=" + java.net.URLEncoder.encode(p.getSku(), "UTF-8")
                                + "&stock=" + stock;
                    } else {
                        url = request.getContextPath()
                                + "/pos?err=not_enough_stock"
                                + "&sku=" + java.net.URLEncoder.encode(p.getSku(), "UTF-8")
                                + "&stock=" + stock
                                + "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8");
                    }
                    response.sendRedirect(url);
                    return;
                }

                if (item == null) {
                    item = new CartItem();
                    item.setProductId(productId);
                    item.setSku(p.getSku());
                    item.setName(p.getName());
                    item.setPrice(p.getPrice());
                    item.setUnit(p.getUnit());
                    item.setQty(1);
                    cart.put(productId, item);
                } else {
                    item.setQty(newQty);
                }
                break;
            }

            case "dec": {
                if (item != null) {
                    int newQty = item.getQty() - 1;
                    if (newQty <= 0) {
                        cart.remove(productId);
                    } else {
                        item.setQty(newQty);
                    }
                }
                break;
            }

            case "remove": {
                cart.remove(productId);
                break;
            }

            case "set": {
                int qty = 1;
                try {
                    qty = Integer.parseInt(request.getParameter("qty"));
                } catch (Exception ignored) {
                }

                if (qty <= 0) {
                    cart.remove(productId);
                    break;
                }

                if (qty > stock) {
                    String url;
                    if ("cart".equalsIgnoreCase(from)) {
                        url = request.getContextPath()
                                + "/cart?err=not_enough_stock"
                                + "&sku=" + java.net.URLEncoder.encode(p.getSku(), "UTF-8")
                                + "&stock=" + stock;
                    } else {
                        url = request.getContextPath()
                                + "/pos?err=not_enough_stock"
                                + "&sku=" + java.net.URLEncoder.encode(p.getSku(), "UTF-8")
                                + "&stock=" + stock
                                + "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8");
                    }
                    response.sendRedirect(url);
                    return;
                }

                if (item == null) {
                    item = new CartItem();
                    item.setProductId(productId);
                    item.setSku(p.getSku());
                    item.setName(p.getName());
                    item.setPrice(p.getPrice());
                    item.setUnit(p.getUnit());
                    cart.put(productId, item);
                }
                item.setQty(qty);
                break;
            }
        }

        session.setAttribute("cart", cart);
        response.sendRedirect(backUrl);
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
