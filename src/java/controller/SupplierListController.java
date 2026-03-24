/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.SupplierDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.Supplier;
import model.User;

/**
 *
 * @author dotha
 */
@WebServlet(name = "SupplierListController", urlPatterns = {"/supplierList"})
public class SupplierListController extends HttpServlet {

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
            out.println("<title>Servlet SupplierListController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet SupplierListController at " + request.getContextPath() + "</h1>");
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
        if (session == null || session.getAttribute("acc") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("acc");
        if (user == null || (user.getRoleID() != 1 && user.getRoleID() != 2)) {
            response.sendRedirect("login.jsp");
            return;
        }

        SupplierDAO supplierDAO = new SupplierDAO();

        String supplierName = request.getParameter("supplierName");
        String supplierPhone = request.getParameter("supplierPhone");
        String supplierAddress = request.getParameter("supplierAddress");
        String supplierEmail = request.getParameter("supplierEmail");
        String status = request.getParameter("status");

        boolean hasSearch
                = (supplierName != null && !supplierName.trim().isEmpty())
                || (supplierPhone != null && !supplierPhone.trim().isEmpty())
                || (supplierAddress != null && !supplierAddress.trim().isEmpty())
                || (supplierEmail != null && !supplierEmail.trim().isEmpty())
                || (status != null && !status.trim().isEmpty());

        List<Supplier> list;
        if (hasSearch) {
            list = supplierDAO.searchSupplier(
                    supplierName,
                    supplierPhone,
                    supplierAddress,
                    supplierEmail,
                    status
            );
        } else {
            list = supplierDAO.getAllSupplier();
        }

        request.setAttribute("list", list);
        request.getRequestDispatcher("/supplierList.jsp").forward(request, response);
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
        doGet(request, response);
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
