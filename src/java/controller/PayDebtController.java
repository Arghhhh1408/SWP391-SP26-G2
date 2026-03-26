package controller;

import dao.CustomerDAO;
import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "PayDebtController", urlPatterns = {"/pay_debt"})
public class PayDebtController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Kiểm tra đăng nhập (Bảo mật)
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("acc");
        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        try {
            // 2. Lấy dữ liệu từ Form gửi lên
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            double amountPaid = Double.parseDouble(request.getParameter("amountPaid"));
            String note = request.getParameter("note");
            int staffId = user.getUserID(); // Lấy ID nhân viên đang đăng nhập để lưu vết

            // 3. Gọi DAO để xử lý nghiệp vụ
            CustomerDAO dao = new CustomerDAO();
            
            // Bước A: Trừ nợ trong bảng Customer
            // Bước B: Lưu lịch sử vào bảng Payment (nếu bạn có bảng này)
            boolean success = dao.updateCustomerDebt(customerId, amountPaid, staffId, note);

            if (success) {
                // 4. Thành công: Quay lại trang chi tiết khách hàng với thông báo
                response.sendRedirect("customer_detail?id=" + customerId + "&msg=success");
            } else {
                // Thất bại
                response.sendRedirect("customer_detail?id=" + customerId + "&msg=error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("sales_dashboard?tab=customers&error=system");
        }
    }
}