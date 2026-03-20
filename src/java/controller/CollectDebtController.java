package controller;

import dao.CustomerDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;

@WebServlet(name = "CollectDebtController", urlPatterns = {"/collectDebt"})
public class CollectDebtController extends HttpServlet {

    // GET: Hiển thị form để nhập số tiền trả nợ
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idRaw = request.getParameter("id");
        try {
            int id = Integer.parseInt(idRaw);
            CustomerDAO dao = new CustomerDAO();
            Customer c = dao.getCustomerById(id);
            
            if (c != null) {
                request.setAttribute("customer", c);
                // Bạn cần tạo file jsp này, hoặc dùng tạm alert prompt
                request.getRequestDispatcher("/collectDebt.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/customers");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/customers");
        }
    }

    // POST: Xử lý trừ nợ trong Database
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("customerId"));
        double amountPaid = Double.parseDouble(request.getParameter("amountPaid"));

        CustomerDAO dao = new CustomerDAO();
        // Truyền số âm vào hàm updateCustomerDebt để trừ nợ
        boolean success = dao.updateCustomerDebt(id, -amountPaid);

        if (success) {
            // Sau khi thu nợ xong, quay lại trang chi tiết khách hàng
            response.sendRedirect(request.getContextPath() + "/customerDetail?id=" + id);
        } else {
            response.sendRedirect(request.getContextPath() + "/customers?err=update_failed");
        }
    }
}