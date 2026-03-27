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
                        // FIX: Chỉ chặn khi vượt quá tồn kho thực tế (p.getQuantity())
                        // Không trừ p.getLowStockThreshold() ở đây nữa
                        if (item.getQty() + 1 <= p.getQuantity()) {
                            item.setQty(item.getQty() + 1);
                        }
                    }
                } 
                // --- 2. XỬ LÝ HÀNH ĐỘNG CẬP NHẬT/GÕ TAY (UPDATE) ---
                else if (action != null && action.startsWith("update")) {
                    if (item != null && quantityStr != null) {
                        try {
                            int newQty = Integer.parseInt(quantityStr);
                            // FIX: Cho phép cập nhật tối đa bằng đúng kho thực tế
                            int maxAvailable = p.getQuantity(); 
                            
                            if (newQty > maxAvailable) {
                                item.setQty(maxAvailable > 0 ? maxAvailable : 1);
                            } else if (newQty < 1) {
                                item.setQty(1);
                            } else {
                                item.setQty(newQty);
                            }
                        } catch (NumberFormatException e) {
                            // Giữ nguyên số lượng cũ nếu gõ sai định dạng
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
        doGet(request, response);
    }
}