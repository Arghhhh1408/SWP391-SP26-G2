/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.SupplierDebtDAO;
import dao.SystemLogDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Date;
import java.util.List;
import model.SupplierDebt;
import model.SystemLog;
import model.User;

/**
 *
 * @author dotha
 */
@WebServlet(name = "SupplierDebtController", urlPatterns = {"/supplierDebt"})
public class SupplierDebtController extends HttpServlet {

    private SupplierDebtDAO debtDAO;

    @Override
    public void init() {
        debtDAO = new SupplierDebtDAO();
    }

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
            out.println("<title>Servlet SupplierDebtController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet SupplierDebtController at " + request.getContextPath() + "</h1>");
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

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("acc") : null;

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (user.getRoleID() != 1 && user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        String supplierIdRaw = request.getParameter("supplierId");
        String status = request.getParameter("status");
        String fromDateRaw = request.getParameter("fromDate");
        String toDateRaw = request.getParameter("toDate");

        Integer supplierId = null;
        Date fromDate = null;
        Date toDate = null;

        try {
            if (supplierIdRaw != null && !supplierIdRaw.trim().isEmpty()) {
                supplierId = Integer.parseInt(supplierIdRaw);
            }
            if (fromDateRaw != null && !fromDateRaw.trim().isEmpty()) {
                fromDate = Date.valueOf(fromDateRaw);
            }
            if (toDateRaw != null && !toDateRaw.trim().isEmpty()) {
                toDate = Date.valueOf(toDateRaw);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Dữ liệu tìm kiếm không hợp lệ!");
        }

        List<SupplierDebt> list = debtDAO.searchDebts(supplierId, status, fromDate, toDate);

        // Ghi log xem / tìm kiếm công nợ NCC
        try {
            SystemLogDAO logDao = new SystemLogDAO();
            SystemLog log = new SystemLog();
            log.setUserID(user.getUserID());
            log.setAction("VIEW_SUPPLIER_DEBT");
            log.setTargetObject("SupplierDebt");
            log.setDescription("Viewed supplier debt list"
                    + (supplierId != null ? " | supplierId=" + supplierId : "")
                    + (status != null && !status.trim().isEmpty() ? " | status=" + status : "")
                    + (fromDate != null ? " | fromDate=" + fromDate : "")
                    + (toDate != null ? " | toDate=" + toDate : ""));
            log.setIpAddress(request.getRemoteAddr());
            logDao.insertLog(log);
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("debtList", list);
        request.getRequestDispatcher("supplierDebtList.jsp").forward(request, response);
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
        response.sendRedirect("supplierDebt");
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
