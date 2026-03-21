/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.StockInDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.StockIn;

/**
 *
 * @author dotha
 */
@WebServlet(name = "StockInListController", urlPatterns = {"/stockinList"})
public class StockInListController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet StockInListController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet StockInListController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        StockInDAO dao = new StockInDAO();

        if (action == null) {
            List<StockIn> list = dao.getAllStockIn();
            request.setAttribute("stockList", list);
            request.getRequestDispatcher("stockinList.jsp").forward(request, response);
            return;
        }

        switch (action) {
            case "edit":
                try {
                int id = Integer.parseInt(request.getParameter("id"));
                StockIn stockIn = dao.getStockInById(id);

                if (stockIn != null) {
                    request.setAttribute("stockIn", stockIn);
                    request.getRequestDispatcher("editStockIn.jsp").forward(request, response);
                } else {
                    request.setAttribute("message", "Không tìm thấy phiếu nhập");
                    List<StockIn> list = dao.getAllStockIn();
                    request.setAttribute("stockList", list);
                    request.getRequestDispatcher("stockinList.jsp").forward(request, response);
                }
            } catch (Exception e) {
                request.setAttribute("message", "Dữ liệu không hợp lệ");
                List<StockIn> list = dao.getAllStockIn();
                request.setAttribute("stockList", list);
                request.getRequestDispatcher("stockinList.jsp").forward(request, response);
            }
            break;

            case "delete":
                try {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean deleted = dao.deleteStockIn(id);

                if (deleted) {
                    request.setAttribute("message", "Xóa phiếu nhập thành công");
                } else {
                    request.setAttribute("message", "Xóa phiếu nhập thất bại");
                }
            } catch (Exception e) {
                request.setAttribute("message", "Dữ liệu không hợp lệ");
            }

            List<StockIn> list = dao.getAllStockIn();
            request.setAttribute("stockList", list);
            request.getRequestDispatcher("stockinList.jsp").forward(request, response);
            break;

            default:
                List<StockIn> defaultList = dao.getAllStockIn();
                request.setAttribute("stockList", defaultList);
                request.getRequestDispatcher("stockinList.jsp").forward(request, response);
                break;
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        StockInDAO dao = new StockInDAO();

        if ("update".equals(action)) {
            try {
                int stockInId = Integer.parseInt(request.getParameter("stockInId"));
                String stockStatus = request.getParameter("stockStatus");
                String paymentStatus = request.getParameter("paymentStatus");
                String note = request.getParameter("note");

                StockIn s = new StockIn();
                s.setStockInId(stockInId);
                s.setStockStatus(stockStatus);
                s.setPaymentStatus(paymentStatus);
                s.setNote(note);

                boolean updated = dao.updateStockIn(s);

                if (updated) {
                    request.setAttribute("message", "Cập nhật phiếu nhập thành công");
                } else {
                    request.setAttribute("message", "Cập nhật phiếu nhập thất bại");
                }

            } catch (Exception e) {
                request.setAttribute("message", "Dữ liệu cập nhật không hợp lệ");
            }
        }

        List<StockIn> list = dao.getAllStockIn();
        request.setAttribute("stockList", list);
        request.getRequestDispatcher("stockinList.jsp").forward(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
