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
            model.Customer customerBefore = dao.getCustomerById(customerId);
            boolean success = dao.updateCustomerDebt(customerId, amountPaid, staffId, note);

            if (success && customerBefore != null) {
                // 4. Gửi thông báo cho Manager
                dao.NotificationDAO notifDAO = new dao.NotificationDAO();
                double oldDebt = customerBefore.getDebt();
                double newDebt = Math.max(0, oldDebt - amountPaid);
                
                String notifMessage = String.format("Cập nhật công nợ khách hàng \"%s\" | Tổng nợ: %,.0f VND | đã trả: %,.0f VND | Còn nợ: %,.0f VND",
                        customerBefore.getName(), oldDebt, amountPaid, newDebt);
                
                java.util.List<Integer> managerIds = notifDAO.getManagerIds();
                for (int mId : managerIds) {
                    model.Notification n = new model.Notification();
                    n.setUserId(mId);
                    n.setTitle("Cập nhật công nợ: " + customerBefore.getName());
                    n.setMessage(notifMessage);
                    n.setType("DEBT_UPDATE");
                    notifDAO.insert(n);
                }
                
                // --- BƯỚC 5: Ghi Log hệ thống ---
                try {
                    dao.SystemLogDAO logDAO = new dao.SystemLogDAO();
                    model.SystemLog log = new model.SystemLog();
                    log.setUserID(staffId);
                    log.setAction("DEBT_PAYMENT");
                    log.setTargetObject("Customer");
                    log.setDescription(String.format("Khách hàng %s thanh toán nợ | Đã trả: %,.0f VND | Còn nợ: %,.0f VND", 
                            customerBefore.getName(), amountPaid, newDebt));
                    log.setIpAddress(request.getRemoteAddr());
                    logDAO.insertLog(log);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                // Thành công: Quay lại trang chi tiết khách hàng với thông báo
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