package controller;

import dao.ProductDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;
import model.CartItem;
import model.Product;

@WebServlet(name = "CartController", urlPatterns = {"/cart"})
public class CartController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/pos");
    }

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
            backUrl = request.getContextPath() + "/pos?keyword=" + URLEncoder.encode(keyword, "UTF-8");
        }

        int productId;
        try {
            productId = Integer.parseInt(request.getParameter("productId"));
        } catch (Exception e) {
            response.sendRedirect(backUrl);
            return;
        }

        ProductDAO pdao = new ProductDAO();
        Product p = pdao.getById(productId);
        if (p == null) {
            response.sendRedirect(backUrl);
            return;
        }

        CartItem item = cart.get(productId);
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
                                + "&sku=" + URLEncoder.encode(p.getSku(), "UTF-8")
                                + "&stock=" + stock;
                    } else {
                        url = request.getContextPath()
                                + "/pos?err=not_enough_stock"
                                + "&sku=" + URLEncoder.encode(p.getSku(), "UTF-8")
                                + "&stock=" + stock
                                + "&keyword=" + URLEncoder.encode(keyword, "UTF-8");
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
                                + "&sku=" + URLEncoder.encode(p.getSku(), "UTF-8")
                                + "&stock=" + stock;
                    } else {
                        url = request.getContextPath()
                                + "/pos?err=not_enough_stock"
                                + "&sku=" + URLEncoder.encode(p.getSku(), "UTF-8")
                                + "&stock=" + stock
                                + "&keyword=" + URLEncoder.encode(keyword, "UTF-8");
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

    @Override
    public String getServletInfo() {
        return "Cart controller";
    }
}