/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.NotificationDAO;
import dao.StockInDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import model.Notification;
import model.StockIn;
import model.StockInDetail;
import model.User;
import dao.SystemLogDAO;
import model.SystemLog;
import websocket.NotificationEndpoint;

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

    private void loadList(HttpServletRequest request, HttpServletResponse response, String message, String messageType)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        StockInDAO dao = new StockInDAO();
        List<StockIn> list = dao.getAllStockIn();

        if (message == null && session != null) {
            String flashMessage = (String) session.getAttribute("flashMessage");
            String flashType = (String) session.getAttribute("flashType");

            if (flashMessage != null) {
                message = flashMessage;
                messageType = flashType;
                session.removeAttribute("flashMessage");
                session.removeAttribute("flashType");
            }
        }

        request.setAttribute("stockList", list);
        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
        request.getRequestDispatcher("stockinList.jsp").forward(request, response);
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the
    // + sign on the left to edit the code.">
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

        if (action == null || action.trim().isEmpty()) {
            loadList(request, response, null, null);
            return;
        }

        switch (action) {
            case "requestCancel":
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    String reason = request.getParameter("reason");

                    if (reason == null || reason.trim().isEmpty()) {
                        loadList(request, response, "Vui lòng nhập lý do hủy phiếu.", "error");
                        return;
                    }

                    // Rule mới:
                    // Không cho hủy nếu đã nhận hàng > 0 hoặc paymentStatus khác Unpaid
                    boolean canCancel = dao.canRequestCancelStockIn(id);

                    if (!canCancel) {
                        loadList(request, response,
                                "Không thể hủy phiếu vì đã có hàng nhận vào kho hoặc đã phát sinh thanh toán.",
                                "error");
                        return;
                    }

                    boolean ok = dao.requestCancelStockIn(id, user.getUserID(), reason.trim());

                    try {
                        SystemLogDAO logDAO = new SystemLogDAO();
                        SystemLog log = new SystemLog();
                        log.setUserID(user.getUserID());
                        log.setAction("REQUEST_CANCEL_STOCKIN");
                        log.setTargetObject("StockIn");
                        log.setDescription("Yêu cầu hủy phiếu nhập | StockInID: " + id + " | Reason: " + reason.trim());
                        log.setIpAddress(request.getRemoteAddr());
                        logDAO.insertLog(log);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

                    if (ok) {
                        try {
                            sendCancelRequestNotification(user, id, reason.trim());
                        } catch (Exception notifEx) {
                            notifEx.printStackTrace();
                        }
                    }

                    loadList(request, response,
                            ok ? "Đã gửi yêu cầu hủy phiếu." : "Gửi yêu cầu hủy thất bại.",
                            ok ? "success" : "error");
                    return;

                } catch (Exception e) {
                    e.printStackTrace();
                    loadList(request, response, "Dữ liệu không hợp lệ.", "error");
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

                    loadList(request, response,
                            ok ? "Đã duyệt hủy phiếu." : "Duyệt hủy thất bại.",
                            ok ? "success" : "error");
                    return;

                } catch (Exception e) {
                    e.printStackTrace();
                    loadList(request, response, "Dữ liệu không hợp lệ.", "error");
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

                    loadList(request, response,
                            ok ? "Đã từ chối yêu cầu hủy." : "Từ chối yêu cầu hủy thất bại.",
                            ok ? "success" : "error");
                    return;

                } catch (Exception e) {
                    e.printStackTrace();
                    loadList(request, response, "Dữ liệu không hợp lệ.", "error");
                    return;
                }

            default:
                loadList(request, response, null, null);
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

                boolean validPaymentStatus = StockIn.PAYMENT_STATUS_UNPAID.equals(paymentStatus)
                        || StockIn.PAYMENT_STATUS_PARTIAL.equals(paymentStatus)
                        || StockIn.PAYMENT_STATUS_PAID.equals(paymentStatus)
                        || StockIn.PAYMENT_STATUS_CANCELLED.equals(paymentStatus);

                if (!validPaymentStatus) {
                    loadList(request, response, "Trạng thái thanh toán không hợp lệ.", "error");
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

                loadList(request, response,
                        updated ? "Cập nhật phiếu nhập thành công." : "Cập nhật phiếu nhập thất bại.",
                        updated ? "success" : "error");
                return;

            } catch (Exception e) {
                e.printStackTrace();
                loadList(request, response, "Dữ liệu cập nhật không hợp lệ.", "error");
                return;
            }
        }

        loadList(request, response, null, null);
    }

    // -----------------------------------------------------------------------
    // Notification helper — Cancel Request
    // -----------------------------------------------------------------------
    private void sendCancelRequestNotification(User staff, int stockInId, String reason) {
        StockInDAO dao = new StockInDAO();
        StockIn stockIn = dao.getStockInById(stockInId);
        if (stockIn == null) {
            return;
        }

        List<StockInDetail> details = dao.getStockInDetailsByStockInId(stockInId);

        // Timestamp (Asia/Ho_Chi_Minh)
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        String timeStr = DateTimeFormatter.ofPattern("HH:mm").format(now);
        String dateStr = DateTimeFormatter.ofPattern("dd/MM/yyyy").format(now);

        String staffName = (staff.getFullName() != null && !staff.getFullName().isEmpty())
                ? staff.getFullName()
                : staff.getUsername();

        // Payment status label
        String ps;
        switch (stockIn.getPaymentStatus() != null ? stockIn.getPaymentStatus() : "") {
            case StockIn.PAYMENT_STATUS_PAID:
                ps = "Đã thanh toán";
                break;
            case StockIn.PAYMENT_STATUS_PARTIAL:
                ps = "Thanh toán một phần";
                break;
            case StockIn.PAYMENT_STATUS_CANCELLED:
                ps = "Đã hủy";
                break;
            default:
                ps = "Chưa thanh toán";
        }

        // Build message
        StringBuilder msg = new StringBuilder();
        msg.append(timeStr).append(" ").append(dateStr).append("\n");
        msg.append("Lý do: ").append(reason).append("\n");
        msg.append("Nhà cung cấp: ").append(stockIn.getSupplierName()).append("\n");
        msg.append("Chi tiết sản phẩm:\n");

        for (StockInDetail d : details) {
            String pName = (d.getProductName() != null && !d.getProductName().isEmpty())
                    ? d.getProductName()
                    : "SP#" + d.getProductId();
            int remaining = d.getQuantity() - d.getReceivedQuantity();
            msg.append("  - ").append(pName)
                    .append(" | Số lượng: ").append(d.getQuantity())
                    .append(" | đã thêm: ").append(d.getReceivedQuantity())
                    .append(" | còn lại: ").append(remaining)
                    .append(" | Đơn giá: ").append(String.format("%,.0f đ", d.getUnitCost()))
                    .append(" | Thành tiền: ").append(String.format("%,.0f đ", d.getSubTotal()))
                    .append("\n");
        }
        msg.append("Trạng thái thanh toán: ").append(ps);

        String title = "Phiếu nhập #" + stockInId + " được yêu cầu hủy từ " + staffName;

        NotificationDAO notifDAO = new NotificationDAO();
        List<Integer> managerIds = notifDAO.getManagerIds();

        for (int managerId : managerIds) {
            Notification n = new Notification();
            n.setUserId(managerId);
            n.setTitle(title);
            n.setMessage(msg.toString());
            n.setType("STOCKIN_CANCEL_REQUEST");
            notifDAO.insert(n);

            // Push WebSocket badge update
            int unread = notifDAO.countUnread(managerId);
            NotificationEndpoint.sendToUser(managerId, "{\"unreadCount\":" + unread + "}");
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