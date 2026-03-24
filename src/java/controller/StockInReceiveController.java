/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.StockInDAO;
import dao.SystemLogDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.SystemLog;
import model.User;

/**
 *
 * @author dotha
 */
@WebServlet(name = "StockInReceiveController", urlPatterns = {"/stockinReceive"})
public class StockInReceiveController extends HttpServlet {

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
            out.println("<title>Servlet StockInReceiveController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet StockInReceiveController at " + request.getContextPath() + "</h1>");
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
        processRequest(request, response);
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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("acc") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("acc");
        if (user.getRoleID() != 1 && user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int detailId = Integer.parseInt(request.getParameter("detailId"));
            int stockInId = Integer.parseInt(request.getParameter("stockInId"));
            int receiveQty = Integer.parseInt(request.getParameter("receiveQty"));

            StockInDAO dao = new StockInDAO();
            boolean ok = dao.receiveStockInDetail(detailId, receiveQty);

            try {
                SystemLogDAO logDAO = new SystemLogDAO();
                SystemLog log = new SystemLog();
                log.setUserID(user.getUserID());
                log.setAction("RECEIVE_STOCKIN_PARTIAL");
                log.setTargetObject("StockInDetail");
                log.setDescription("Nhập kho từng phần | StockInID: " + stockInId
                        + " | DetailID: " + detailId
                        + " | ReceiveQty: " + receiveQty);
                log.setIpAddress(request.getRemoteAddr());
                logDAO.insertLog(log);
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            response.sendRedirect("stockinList?msg=" + (ok ? "receive_success" : "receive_fail"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("stockinList?msg=receive_fail");
        }
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
