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
        String quantityStr = request.getParameter("quantity"); // Lấy thêm tham số quantity nếu gõ tay

        if (pIdStr != null) {
            int productId = Integer.parseInt(pIdStr);
            ProductDAO pdao = new ProductDAO();
            Product p = pdao.getById(productId);
CartItem item = cart.get(productId);

                // XỬ LÝ HÀNH ĐỘNG THÊM (ADD)
                if (p != null) {
                    

                    if ("add".equals(action)) {
                        if (item == null) {
                            // Trường hợp 1: Sản phẩm CHƯA có trong giỏ -> Tạo mới hoàn toàn
                            if (p.getQuantity() > 0) {
                                item = new CartItem();
                                item.setProductId(p.getId());
                                item.setName(p.getName());
                                item.setPrice(p.getPrice());
                                item.setQty(1);

                                // Gán các thuộc tính tồn kho và ngưỡng ở đây
                                item.setProductTotalStock(p.getQuantity());
                                item.setMinStockThreshold(p.getLowStockThreshold());
                                // Nếu bạn dùng tên biến stockQuantity thì dùng dòng dưới:
                                // item.setStockQuantity(p.getQuantity()); 

                                cart.put(productId, item);
                            } else {
                                request.setAttribute("error", "Sản phẩm đã hết hàng!");
                            }
                        } else {
                            // Trường hợp 2: Sản phẩm ĐÃ CÓ trong giỏ -> Chỉ tăng số lượng
                            // Kiểm tra ngưỡng kho trước khi cho tăng (Logic chặn của Manager)
                            if ((p.getQuantity() - (item.getQty() + 1)) >= p.getLowStockThreshold()) {
                                item.setQty(item.getQty() + 1);
                            } else {
                                request.setAttribute("error", "Đã đạt giới hạn tồn kho tối thiểu!");
                            }
                        }
                    } else if ("sub".equals(action)) {
                        if (item != null && item.getQty() > 1) {
                            item.setQty(item.getQty() - 1);
                        } else {
                            cart.remove(productId);
                        }
                    }
                } // XỬ LÝ HÀNH ĐỘNG GÕ TAY SỐ LƯỢNG (UPDATE)
                else if ("update".equals(action) && quantityStr != null) {
                    int newQty = Integer.parseInt(quantityStr);
                    if (item != null) {
                        if (newQty <= p.getQuantity()) {
                            item.setQty(newQty);
                        } else {
                            item.setQty(p.getQuantity());
                            request.setAttribute("error", "Tự động điều chỉnh về tối đa " + p.getQuantity() + " sản phẩm!");
                        }
                    }
                } // XỬ LÝ HÀNH ĐỘNG GIẢM (SUB)
                else if ("sub".equals(action)) {
                    if (item != null) {
                        if (item.getQty() > 1) {
                            item.setQty(item.getQty() - 1);
                        } else {
                            cart.remove(productId);
                        }
                    }
                } // XỬ LÝ XÓA (REMOVE)
                else if ("remove".equals(action)) {
                    cart.remove(productId);
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
