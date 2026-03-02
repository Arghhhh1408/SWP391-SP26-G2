package controller;

import dao.OrderHistoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "InvoiceController", urlPatterns = {"/invoice"})
public class InvoiceController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idRaw = request.getParameter("id");
        if (idRaw == null || idRaw.isBlank()) {
            // Không có id thì quay về orders
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        int stockOutId;
        try {
            stockOutId = Integer.parseInt(idRaw);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/orders");
            return;
        }

        try {
            OrderHistoryDAO dao = new OrderHistoryDAO();
            var header = dao.getOrderHeader(stockOutId);
            var items  = dao.getOrderItems(stockOutId);

            if (header == null) {
                response.sendRedirect(request.getContextPath() + "/orders");
                return;
            }

            request.setAttribute("header", header);
            request.setAttribute("items", items);

            request.getRequestDispatcher("/invoice.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/plain;charset=UTF-8");
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }
}