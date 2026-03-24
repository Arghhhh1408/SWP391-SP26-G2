package controller;

import dao.ProductDAO;
import dao.SystemLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.SystemLog;
import model.User;

@WebServlet(name = "BulkProductActionController", urlPatterns = {"/bulkProductAction"})
public class BulkProductActionController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("acc");
        if (u == null || (u.getRoleID() != 1 && u.getRoleID() != 2)) {
            response.sendRedirect("login");
            return;
        }

        String action = request.getParameter("action");
        String[] selectedIdsStr = request.getParameterValues("selectedProducts");

        if (selectedIdsStr == null || selectedIdsStr.length == 0) {
            session.setAttribute("error", "Vui lòng chọn ít nhất một sản phẩm.");
            redirectToSource(request, response);
            return;
        }

        int[] ids = new int[selectedIdsStr.length];
        for (int i = 0; i < selectedIdsStr.length; i++) {
            try {
                ids[i] = Integer.parseInt(selectedIdsStr[i]);
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID sản phẩm không hợp lệ.");
                redirectToSource(request, response);
                return;
            }
        }

        ProductDAO dao = new ProductDAO();
        boolean success = false;
        String logMsg = "";

        if ("softDelete".equals(action)) {
            success = dao.bulkSoftDelete(ids);
            logMsg = "Xóa mềm " + ids.length + " sản phẩm (chuyển sang Deactivated)";
        } else if ("activate".equals(action)) {
            success = dao.bulkActivate(ids);
            logMsg = "Kích hoạt lại " + ids.length + " sản phẩm (chuyển sang Active)";
        } else if ("hardDelete".equals(action)) {
            success = dao.bulkHardDelete(ids);
            logMsg = "Xóa vĩnh viễn " + ids.length + " sản phẩm khỏi hệ thống";
        }

        if (success) {
            session.setAttribute("message", "Thực hiện thao tác hàng loạt thành công.");
            logAction(request, "BULK_ACTION_PRODUCT", logMsg);
        } else {
            session.setAttribute("error", "Có lỗi xảy ra khi thực hiện thao tác hàng loạt.");
        }

        redirectToSource(request, response);
    }

    private void redirectToSource(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect("staff_dashboard?tab=products");
        }
    }

    private void logAction(HttpServletRequest request, String action, String description) {
        try {
            HttpSession session = request.getSession(false);
            User u = (User) session.getAttribute("acc");
            SystemLog log = new SystemLog();
            log.setUserID(u != null ? u.getUserID() : 0);
            log.setAction(action);
            log.setTargetObject("Product");
            log.setDescription(description);
            log.setIpAddress(request.getRemoteAddr());
            new SystemLogDAO().insertLog(log);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
