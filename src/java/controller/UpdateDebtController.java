package controller;

import dao.CustomerDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "UpdateDebtController", urlPatterns = {"/update_debt"})
public class UpdateDebtController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // 1. Lấy dữ liệu từ form trong trang chi tiết khách hàng
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            double payAmount = Double.parseDouble(request.getParameter("payAmount"));

            // 2. Gọi DAO để trừ nợ (Số tiền khách trả nên truyền vào dạng số âm để cộng vào cột Debt)
            // Ví dụ: Nợ 500k, trả 200k -> Debt = 500 + (-200) = 300k
            CustomerDAO dao = new CustomerDAO();
            boolean success = dao.updateCustomerDebt(customerId, -payAmount);

            // 3. Quay lại trang chi tiết khách hàng sau khi cập nhật thành công
            if (success) {
                response.sendRedirect("customer_detail?id=" + customerId + "&msg=success");
            } else {
                response.sendRedirect("customer_detail?id=" + customerId + "&msg=error");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("sales_dashboard?tab=customers");
        }
    }
}