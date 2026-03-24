/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.NotificationDAO;
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
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import model.Notification;
import model.StockIn;
import model.StockInDetail;
import model.SystemLog;
import model.User;
import websocket.NotificationEndpoint;

/**
 *
 * @author dotha
 */
@WebServlet(name = "StockInDetailController", urlPatterns = {"/stockinDetail"})
public class StockInDetailController extends HttpServlet {

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
            out.println("<title>Servlet StockInDetailController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet StockInDetailController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    private void forwardDetail(HttpServletRequest request, HttpServletResponse response,
            int stockInId, String message, String messageType)
            throws ServletException, IOException {

        StockInDAO dao = new StockInDAO();
        StockIn stockIn = dao.getStockInById(stockInId);
        List<StockInDetail> details = dao.getStockInDetailsByStockInId(stockInId);

        if (stockIn == null) {
            request.getSession().setAttribute("flashMessage", "Phiếu nhập không tồn tại.");
            request.getSession().setAttribute("flashType", "error");
            response.sendRedirect("stockinList");
            return;
        }

        request.setAttribute("stockIn", stockIn);
        request.setAttribute("details", details);
        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
        request.getRequestDispatcher("stockinDetail.jsp").forward(request, response);
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

        String idRaw = request.getParameter("id");
        if (idRaw == null || idRaw.trim().isEmpty()) {
            session.setAttribute("flashMessage", "Thiếu mã phiếu nhập.");
            session.setAttribute("flashType", "error");
            response.sendRedirect("stockinList");
            return;
        }

        try {
            int stockInId = Integer.parseInt(idRaw);
            forwardDetail(request, response, stockInId, null, null);
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flashMessage", "Mã phiếu nhập không hợp lệ.");
            session.setAttribute("flashType", "error");
            response.sendRedirect("stockinList");
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
        String stockInIdRaw = request.getParameter("stockInId");

        if (stockInIdRaw == null || stockInIdRaw.trim().isEmpty()) {
            session.setAttribute("flashMessage", "Thiếu mã phiếu nhập.");
            session.setAttribute("flashType", "error");
            response.sendRedirect("stockinList");
            return;
        }

        int stockInId;
        try {
            stockInId = Integer.parseInt(stockInIdRaw.trim());
        } catch (Exception e) {
            session.setAttribute("flashMessage", "Mã phiếu nhập không hợp lệ.");
            session.setAttribute("flashType", "error");
            response.sendRedirect("stockinList");
            return;
        }

        StockInDAO dao = new StockInDAO();
        StockIn stockIn = dao.getStockInById(stockInId);

        if (stockIn == null) {
            session.setAttribute("flashMessage", "Phiếu nhập không tồn tại.");
            session.setAttribute("flashType", "error");
            response.sendRedirect("stockinList");
            return;
        }

        if ("receive".equals(action)) {
            try {
                if (!StockIn.STOCK_STATUS_PENDING.equals(stockIn.getStockStatus())) {
                    forwardDetail(request, response, stockInId,
                            "Chỉ có thể nhận hàng khi phiếu đang ở trạng thái Pending.", "error");
                    return;
                }

                int detailId = Integer.parseInt(request.getParameter("detailId"));
                int receiveQty = Integer.parseInt(request.getParameter("receiveQty"));

                if (receiveQty <= 0) {
                    forwardDetail(request, response, stockInId,
                            "Số lượng nhận phải lớn hơn 0.", "error");
                    return;
                }

                boolean ok = dao.receiveStockInDetail(detailId, receiveQty);

                try {
                    SystemLogDAO logDAO = new SystemLogDAO();
                    SystemLog log = new SystemLog();
                    log.setUserID(user.getUserID());
                    log.setAction("RECEIVE_STOCKIN_DETAIL");
                    log.setTargetObject("StockInDetail");
                    log.setDescription("Nhận hàng cho phiếu nhập | StockInID: " + stockInId
                            + " | DetailID: " + detailId
                            + " | ReceiveQty: " + receiveQty);
                    log.setIpAddress(request.getRemoteAddr());
                    logDAO.insertLog(log);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                if (ok) {
                    // Send notification to managers
                    try {
                        sendReceiveNotification(user, stockIn, detailId, receiveQty);
                    } catch (Exception notifEx) {
                        notifEx.printStackTrace();
                    }
                    response.sendRedirect("stockinDetail?id=" + stockInId + "&success=received");
                } else {
                    forwardDetail(request, response, stockInId,
                            "Nhận hàng thất bại. Vui lòng kiểm tra số lượng còn lại.", "error");
                }
                return;

            } catch (Exception e) {
                e.printStackTrace();
                forwardDetail(request, response, stockInId,
                        "Dữ liệu nhận hàng không hợp lệ.", "error");
                return;
            }
        }

        if ("approveCancel".equals(action)) {
            if (user.getRoleID() != 2) {
                response.sendRedirect("login.jsp");
                return;
            }

            try {
                boolean ok = dao.approveCancelStockIn(stockInId, user.getUserID());

                try {
                    SystemLogDAO logDAO = new SystemLogDAO();
                    SystemLog log = new SystemLog();
                    log.setUserID(user.getUserID());
                    log.setAction("APPROVE_CANCEL_STOCKIN");
                    log.setTargetObject("StockIn");
                    log.setDescription("Duyệt hủy phiếu nhập tại trang chi tiết | StockInID: " + stockInId);
                    log.setIpAddress(request.getRemoteAddr());
                    logDAO.insertLog(log);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                if (ok) {
                    response.sendRedirect("stockinDetail?id=" + stockInId + "&success=approveCancel");
                } else {
                    forwardDetail(request, response, stockInId,
                            "Duyệt hủy phiếu thất bại.", "error");
                }
                return;

            } catch (Exception e) {
                e.printStackTrace();
                forwardDetail(request, response, stockInId,
                        "Dữ liệu không hợp lệ.", "error");
                return;
            }
        }

        if ("rejectCancel".equals(action)) {
            if (user.getRoleID() != 2) {
                response.sendRedirect("login.jsp");
                return;
            }

            try {
                boolean ok = dao.rejectCancelStockIn(stockInId);

                try {
                    SystemLogDAO logDAO = new SystemLogDAO();
                    SystemLog log = new SystemLog();
                    log.setUserID(user.getUserID());
                    log.setAction("REJECT_CANCEL_STOCKIN");
                    log.setTargetObject("StockIn");
                    log.setDescription("Từ chối hủy phiếu nhập tại trang chi tiết | StockInID: " + stockInId);
                    log.setIpAddress(request.getRemoteAddr());
                    logDAO.insertLog(log);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                if (ok) {
                    response.sendRedirect("stockinDetail?id=" + stockInId + "&success=rejectCancel");
                } else {
                    forwardDetail(request, response, stockInId,
                            "Từ chối hủy phiếu thất bại.", "error");
                }
                return;

            } catch (Exception e) {
                e.printStackTrace();
                forwardDetail(request, response, stockInId,
                        "Dữ liệu không hợp lệ.", "error");
                return;
            }
        }

        forwardDetail(request, response, stockInId, null, null);
    }

    // -----------------------------------------------------------------------
    // Notification helper
    // -----------------------------------------------------------------------
    private void sendReceiveNotification(User staff, StockIn stockIn, int updatedDetailId, int receiveQty) {
        StockInDAO dao = new StockInDAO();

        // Re-fetch StockIn to get updated status & remaining after SP ran
        StockIn updatedStockIn = dao.getStockInById(stockIn.getStockInId());
        if (updatedStockIn == null) {
            updatedStockIn = stockIn;
        }

        // Re-fetch details so receivedQuantity is up-to-date
        List<StockInDetail> details = dao.getStockInDetailsByStockInId(stockIn.getStockInId());

        // Timestamp (Asia/Ho_Chi_Minh)
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        String timeStr = DateTimeFormatter.ofPattern("HH:mm").format(now);
        String dateStr = DateTimeFormatter.ofPattern("dd/MM/yyyy").format(now);

        String staffName = (staff.getFullName() != null && !staff.getFullName().isEmpty())
                ? staff.getFullName() : staff.getUsername();

        // Payment status label (use updated stockIn)
        String ps;
        switch (updatedStockIn.getPaymentStatus() != null ? updatedStockIn.getPaymentStatus() : "") {
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

        boolean isCompleted = StockIn.STOCK_STATUS_COMPLETED.equals(updatedStockIn.getStockStatus());

        String title;
        StringBuilder msg = new StringBuilder();
        msg.append(timeStr).append(" ").append(dateStr).append("\n");
        msg.append("Nhà cung cấp: ").append(updatedStockIn.getSupplierName()).append("\n");
        msg.append("Chi tiết sản phẩm:\n");

        if (isCompleted) {
            title = "Phiếu nhập #" + updatedStockIn.getStockInId()
                    + " đã nhập đủ số lượng từ " + staffName;

            for (StockInDetail d : details) {
                String pName = (d.getProductName() != null && !d.getProductName().isEmpty())
                        ? d.getProductName() : "SP#" + d.getProductId();
                msg.append("  - ").append(pName)
                        .append(" | Số lượng: ").append(d.getQuantity())
                        .append(" | Đơn giá: ").append(String.format("%,.0f đ", d.getUnitCost()))
                        .append(" | Thành tiền: ").append(String.format("%,.0f đ", d.getSubTotal()))
                        .append("\n");
            }
        } else {
            title = "Phiếu nhập #" + updatedStockIn.getStockInId()
                    + " được cập nhật từ " + staffName;

            for (StockInDetail d : details) {
                String pName = (d.getProductName() != null && !d.getProductName().isEmpty())
                        ? d.getProductName() : "SP#" + d.getProductId();
                int remaining = d.getQuantity() - d.getReceivedQuantity();
                int added = (d.getDetailId() == updatedDetailId) ? receiveQty : 0;
                msg.append("  - ").append(pName)
                        .append(" | Số lượng: ").append(d.getQuantity())
                        .append(" | đã thêm: ").append(added)
                        .append(" | còn lại: ").append(remaining)
                        .append("\n");
            }
        }

        msg.append("Trạng thái thanh toán: ").append(ps);

        String notifType = isCompleted ? "STOCKIN_COMPLETED" : "STOCKIN_RECEIVED";

        NotificationDAO notifDAO = new NotificationDAO();
        List<Integer> managerIds = notifDAO.getManagerIds();

        for (int managerId : managerIds) {
            Notification n = new Notification();
            n.setUserId(managerId);
            n.setTitle(title);
            n.setMessage(msg.toString());
            n.setType(notifType);
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
