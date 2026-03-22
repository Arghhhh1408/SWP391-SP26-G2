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

        if (pIdStr != null) {
            int productId = Integer.parseInt(pIdStr);
            ProductDAO pdao = new ProductDAO();
            Product p = pdao.getById(productId); // Lấy thông tin sản phẩm từ DB

            if (p != null) {
                CartItem item = cart.get(productId);

                if ("add".equals(action)) {
                    if (item == null) {
                        // Nếu chưa có trong giỏ -> Thêm mới với số lượng là 1
                        // Nhưng vẫn phải check kho xem còn hàng không
                        if (p.getQuantity() > 0) {
                            item = new CartItem();
                            item.setProductId(productId);
                            item.setName(p.getName());
                            item.setPrice(p.getPrice());
                            item.setQty(1);
                            cart.put(productId, item);
                        } else {
                            request.setAttribute("error", "Sản phẩm đã hết hàng!");
                        }
                    } else {
                        // Đã có trong giỏ -> Check xem tăng được nữa không
                        if (item.getQty() + 1 <= p.getQuantity()) {
                            item.setQty(item.getQty() + 1);
                        } else {
                            request.setAttribute("error", "Chỉ còn " + p.getQuantity() + " sản phẩm trong kho!");
                        }
                    }
                } else if ("sub".equals(action)) {
                    if (item != null) {
                        if (item.getQty() > 1) {
                            item.setQty(item.getQty() - 1);
                        } else {
                            cart.remove(productId);
                        }
                    }
                } else if ("remove".equals(action)) {
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
