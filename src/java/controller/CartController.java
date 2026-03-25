package controller;

import dao.ProductDAO;
import java.io.IOException;
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

@WebServlet(name = "CartController", urlPatterns = {"/cart"})
public class CartController extends HttpServlet {

    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession();
    Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
    if (cart == null) {
        cart = new HashMap<>();
    }

    String pIdStr = request.getParameter("productId");
    String action = request.getParameter("action");
    // Lấy thêm tham số quantity từ Ajax (Ví dụ: update&quantity=5)
    String quantityStr = request.getParameter("quantity"); 

    if (pIdStr != null) {
        int productId = Integer.parseInt(pIdStr);
        ProductDAO pdao = new ProductDAO();
        Product p = pdao.getById(productId);
        CartItem item = cart.get(productId);

        if (p != null) {
            // --- 1. XỬ LÝ HÀNH ĐỘNG THÊM (ADD) ---
            if ("add".equals(action)) {
                if (item == null) {
                    if (p.getQuantity() > 0) {
                        item = new CartItem();
                        item.setProductId(p.getId());
                        item.setName(p.getName());
                        item.setPrice(p.getPrice());
                        item.setQty(1);
                        item.setProductTotalStock(p.getQuantity());
                        item.setMinStockThreshold(p.getLowStockThreshold());
                        cart.put(productId, item);
                    }
                } else {
                    // Kiểm tra ngưỡng kho trước khi cho cộng thêm
                    if ((p.getQuantity() - (item.getQty() + 1)) >= p.getLowStockThreshold()) {
                        item.setQty(item.getQty() + 1);
                    }
                }
            } 
            // --- 2. XỬ LÝ HÀNH ĐỘNG GÕ TAY (UPDATE) ---
            else if (action != null && action.startsWith("update")) {
                if (item != null && quantityStr != null) {
                    try {
                        int newQty = Integer.parseInt(quantityStr);
                        // Chặn gõ lố tồn kho trừ ngưỡng
                        int maxAvailable = p.getQuantity() - p.getLowStockThreshold();
                        
                        if (newQty > maxAvailable) {
                            item.setQty(maxAvailable > 0 ? maxAvailable : 1);
                        } else if (newQty < 1) {
                            item.setQty(1);
                        } else {
                            item.setQty(newQty);
                        }
                    } catch (NumberFormatException e) {
                        // Nếu gõ chữ thì giữ nguyên hoặc về 1
                    }
                }
            }
            // --- 3. XỬ LÝ HÀNH ĐỘNG GIẢM (SUB) ---
            else if ("sub".equals(action)) {
                if (item != null) {
                    if (item.getQty() > 1) {
                        item.setQty(item.getQty() - 1);
                    } else {
                        cart.remove(productId);
                    }
                }
            }
            // --- 4. XỬ LÝ XÓA (REMOVE) ---
            else if ("remove".equals(action)) {
                cart.remove(productId);
            }
        }
    }

    session.setAttribute("cart", cart);
    request.getRequestDispatcher("_cart_content.jsp").forward(request, response);
}

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Nếu có xử lý Post thì gọi sang doGet
        doGet(request, response);
    }
}
