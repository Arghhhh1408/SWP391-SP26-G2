package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import dao.ProductDAO;
import model.Product;
import model.User;

@WebServlet(name = "SalesProductListController", urlPatterns = {"/sales-products"})
public class SalesProductListController extends HttpServlet {

    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    // 1. Lấy từ khóa tìm kiếm (nếu có)
    String keyword = request.getParameter("keyword");
    if (keyword == null) {
        keyword = "";
    }
    keyword = keyword.trim();

    // 2. Kiểm tra quyền (Chỉ Role 3 - Sale hoặc Role 0 - Admin mới được vào)
    HttpSession session = request.getSession();
    model.User user = (model.User) session.getAttribute("acc");
    
    if (user == null || (user.getRoleID() != 3 && user.getRoleID() != 0)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // 3. Xử lý lấy dữ liệu từ DAO
    dao.ProductDAO pDao = new dao.ProductDAO();
    try {
        java.util.List<model.Product> list;
        
        if (!keyword.isEmpty()) {
            // Nếu có từ khóa -> Gọi hàm tìm kiếm
            list = pDao.search(keyword); 
        } else {
            // Nếu không có từ khóa -> Lấy tất cả sản phẩm cho Sale xem
            list = pDao.getAllProducts();
        }

        // 4. Đẩy dữ liệu sang trang JSP dành riêng cho Sale
        // LƯU Ý: Tên "sale_productList" phải khớp với items="${sale_productList}" trong JSP
        request.setAttribute("sale_productList", list);
        request.getRequestDispatcher("/sales_productList.jsp").forward(request, response);

    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Lỗi: " + e.getMessage());
        request.getRequestDispatcher("/error.jsp").forward(request, response);
    }
}
}