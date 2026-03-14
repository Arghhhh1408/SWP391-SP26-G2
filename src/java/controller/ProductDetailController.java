package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;

@WebServlet(name = "ProductDetailController", urlPatterns = { "/productDetail" })
public class ProductDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
    ProductDAO dao = new ProductDAO();
    
    // Lấy 1 đối tượng duy nhất
    Product p = dao.getProductById(id); 
    
    // Đặt tên là "product" (số ít) để khớp với ${product.name} trong JSP
    request.setAttribute("product", p); 
    
    // Chuyển sang trang chi tiết
    request.getRequestDispatcher("/productDetail.jsp").forward(request, response);
    }
}
