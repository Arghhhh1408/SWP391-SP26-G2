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

@WebServlet(name="CartController", urlPatterns={"/cart"})
public class CartController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null) cart = new HashMap<>();

        // 1. Lấy thông tin từ Ajax gửi lên
        String pIdStr = request.getParameter("productId");
        String action = request.getParameter("action"); // 'add' hoặc 'sub'

        if (pIdStr != null) {
            int productId = Integer.parseInt(pIdStr);
            CartItem item = cart.get(productId);

            if ("add".equals(action)) {
                if (item == null) {
                    // Thêm mới vào giỏ
                    ProductDAO pdao = new ProductDAO();
                    Product p = pdao.getById(productId);
                    if (p != null) {
                        item = new CartItem();
                        item.setProductId(productId);
                        item.setName(p.getName()); // Đảm bảo đúng tên thuộc tính trong CartItem
                        item.setPrice(p.getPrice());
                        item.setQty(1);
                        cart.put(productId, item);
                    }
                } else {
                    // Tăng số lượng
                    item.setQty(item.getQty() + 1);
                }
            } 
            else if ("sub".equals(action)) {
                if (item != null) {
                    if (item.getQty() > 1) {
                        item.setQty(item.getQty() - 1);
                    } else {
                        cart.remove(productId);
                    }
                }
            }
        }

        session.setAttribute("cart", cart);

        // 2. PHẦN QUAN TRỌNG: Trả về file JSP con để Ajax đắp vào giao diện
        request.getRequestDispatcher("_cart_content.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Nếu có xử lý Post thì gọi sang doGet
        doGet(request, response);
    }
}