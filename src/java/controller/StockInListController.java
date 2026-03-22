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
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.StockIn;
import model.User;
import dao.SystemLogDAO;
import model.SystemLog;

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

    private void loadList(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        StockInDAO dao = new StockInDAO();
        List<StockIn> list = dao.getAllStockIn();
        request.setAttribute("stockList", list);
        request.setAttribute("message", message);
        request.getRequestDispatcher("stockinList.jsp").forward(request, response);
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
        if (user.getRoleID() != 1 && user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        StockInDAO dao = new StockInDAO();

        if (action == null || action.trim().isEmpty()) {
            loadList(request, response, null);
            return;
        }

        switch (action) {
            case "requestCancel":
                try {
                int id = Integer.parseInt(request.getParameter("id"));
                String reason = request.getParameter("reason");
                boolean ok = dao.requestCancelStockIn(id, user.getUserID(), reason);

                try {
                    SystemLogDAO logDAO = new SystemLogDAO();
                    SystemLog log = new SystemLog();
                    log.setUserID(user.getUserID());
                    log.setAction("REQUEST_CANCEL_STOCKIN");
                    log.setTargetObject("StockIn");
                    log.setDescription("Yêu cầu hủy phiếu nhập | StockInID: " + id + " | Reason: " + reason);
                    log.setIpAddress(request.getRemoteAddr());
                    logDAO.insertLog(log);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                loadList(request, response, ok ? "Đã gửi yêu cầu hủy phiếu." : "Gửi yêu cầu hủy thất bại.");
                return;
            } catch (Exception e) {
                loadList(request, response, "Dữ liệu không hợp lệ.");
                return;
            }

            case "approveCancel":
                if (user.getRoleID() != 2) {
                    response.sendRedirect("login.jsp");
                    return;
                }
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    boolean ok = dao.approveCancelStockIn(id, user.getUserID());

                    try {
                        SystemLogDAO logDAO = new SystemLogDAO();
                        SystemLog log = new SystemLog();
                        log.setUserID(user.getUserID());
                        log.setAction("APPROVE_CANCEL_STOCKIN");
                        log.setTargetObject("StockIn");
                        log.setDescription("Duyệt hủy phiếu nhập | StockInID: " + id);
                        log.setIpAddress(request.getRemoteAddr());
                        logDAO.insertLog(log);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

                    loadList(request, response, ok ? "Đã duyệt hủy phiếu." : "Duyệt hủy thất bại.");
                    return;
                } catch (Exception e) {
                    loadList(request, response, "Dữ liệu không hợp lệ.");
                    return;
                }

            case "rejectCancel":
                if (user.getRoleID() != 2) {
                    response.sendRedirect("login.jsp");
                    return;
                }
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    boolean ok = dao.rejectCancelStockIn(id);

                    try {
                        SystemLogDAO logDAO = new SystemLogDAO();
                        SystemLog log = new SystemLog();
                        log.setUserID(user.getUserID());
                        log.setAction("REJECT_CANCEL_STOCKIN");
                        log.setTargetObject("StockIn");
                        log.setDescription("Từ chối hủy phiếu nhập | StockInID: " + id);
                        log.setIpAddress(request.getRemoteAddr());
                        logDAO.insertLog(log);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

                    loadList(request, response, ok ? "Đã từ chối yêu cầu hủy." : "Từ chối yêu cầu hủy thất bại.");
                    return;
                } catch (Exception e) {
                    loadList(request, response, "Dữ liệu không hợp lệ.");
                    return;
                }

            default:
                loadList(request, response, null);
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

        String action = request.getParameter("action");
        StockInDAO dao = new StockInDAO();

        if ("update".equals(action)) {
            try {
                int stockInId = Integer.parseInt(request.getParameter("stockInId"));
                String note = request.getParameter("note");
                String paymentStatus = request.getParameter("paymentStatus");

                boolean validPaymentStatus
                        = StockIn.PAYMENT_STATUS_UNPAID.equals(paymentStatus)
                        || StockIn.PAYMENT_STATUS_PARTIAL.equals(paymentStatus)
                        || StockIn.PAYMENT_STATUS_PAID.equals(paymentStatus)
                        || StockIn.PAYMENT_STATUS_CANCELLED.equals(paymentStatus);

                if (!validPaymentStatus) {
                    loadList(request, response, "Trạng thái thanh toán không hợp lệ.");
                    return;
                }

                boolean updated = dao.updateNoteAndPaymentStatus(stockInId, note, paymentStatus);

                try {
                    SystemLogDAO logDAO = new SystemLogDAO();
                    SystemLog log = new SystemLog();
                    log.setUserID(user.getUserID());
                    log.setAction("UPDATE_STOCKIN");
                    log.setTargetObject("StockIn");
                    log.setDescription("Cập nhật phiếu nhập | StockInID: " + stockInId
                            + " | PaymentStatus: " + paymentStatus
                            + " | Note: " + note);
                    log.setIpAddress(request.getRemoteAddr());
                    logDAO.insertLog(log);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                loadList(request, response, updated ? "Cập nhật phiếu nhập thành công." : "Cập nhật phiếu nhập thất bại.");
                return;
            } catch (Exception e) {
                loadList(request, response, "Dữ liệu cập nhật không hợp lệ.");
                return;
            }
        }

        loadList(request, response, null);
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
