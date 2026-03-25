/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.InventoryCheckDAO;
import dao.SystemLogDAO;
import model.SystemLog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.sql.Date;
import java.util.List;
import model.InventoryCheckItem;
import model.User;
import dao.NotificationDAO;
import model.Notification;
import websocket.NotificationEndpoint;

/**
 *
 * @author dotha
 */
@WebServlet(name = "InventoryCheckController", urlPatterns = {"/inventoryCheck"})
public class InventoryCheckController extends HttpServlet {

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
            out.println("<title>Servlet InventoryCheckController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet InventoryCheckController at " + request.getContextPath() + "</h1>");
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

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("acc") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("acc");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (user.getRoleID() != 1 && user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        String mode = request.getParameter("mode");

        if ("view".equals(mode)) {
            handleView(request, response);
            return;
        }

        if ("edit".equals(mode)) {
            handleEditForm(request, response);
            return;
        }

        if ("history".equals(mode)) {
            handleProductHistory(request, response);
            return;
        }

        if (user.getRoleID() == 2 && "approval".equals(mode)) {
            handleApprovalList(request, response);
            return;
        }

        if (user.getRoleID() == 2 && "approvalDetail".equals(mode)) {
            handleApprovalDetail(request, response);
            return;
        }

        loadInventoryCheckPage(request, response, null, null, null);
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
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if (user.getRoleID() != 1 && user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("update".equals(action)) {
            handleUpdate(request, response);
            return;
        }

        if ("approveSession".equals(action)) {
            handleApproveSession(request, response);
            return;
        }

        if ("rejectSession".equals(action)) {
            handleRejectSession(request, response);
            return;
        }

        String keyword = request.getParameter("keyword");
        String[] productIds = request.getParameterValues("productId");

        List<InventoryCheckItem> items = new ArrayList<>();
        List<String> errors = new ArrayList<>();

        if (productIds != null) {
            for (String pidRaw : productIds) {
                try {
                    int productId = Integer.parseInt(pidRaw);
                    int systemQuantity = Integer.parseInt(request.getParameter("systemQuantity_" + productId));

                    String physicalRaw = request.getParameter("physicalQuantity_" + productId);
                    String reason = request.getParameter("reason_" + productId);

                    Integer physicalQuantity = null;

                    if (physicalRaw != null && !physicalRaw.trim().isEmpty()) {
                        physicalQuantity = Integer.parseInt(physicalRaw.trim());

                        if (physicalQuantity < 0) {
                            errors.add("Số lượng thực tế không được âm ở sản phẩm ID " + productId);
                            continue;
                        }

                        if (physicalQuantity != systemQuantity
                                && (reason == null || reason.trim().isEmpty())) {
                            errors.add("Sản phẩm ID " + productId + " có chênh lệch nên phải nhập lý do.");
                        }
                    }

                    InventoryCheckItem item = new InventoryCheckItem();
                    item.setProductId(productId);
                    item.setSku(request.getParameter("sku_" + productId));
                    item.setProductName(request.getParameter("productName_" + productId));
                    item.setUnit(request.getParameter("unit_" + productId));
                    item.setSystemQuantity(systemQuantity);
                    item.setPhysicalQuantity(physicalQuantity);
                    item.setReason(reason);
                    item.setStatus("Pending");

                    int variance = 0;
                    if (physicalQuantity != null) {
                        variance = physicalQuantity - systemQuantity;
                    }
                    item.setVariance(variance);

                    items.add(item);

                } catch (NumberFormatException e) {
                    errors.add("Dữ liệu nhập không hợp lệ.");
                } catch (Exception e) {
                    errors.add("Có lỗi xảy ra khi xử lý dữ liệu.");
                }
            }
        }

        if ("calculate".equals(action)) {
            loadInventoryCheckPage(request, response, items, errors, null);
            return;
        }

        if ("save".equals(action)) {
            boolean hasAtLeastOneInput = false;

            for (InventoryCheckItem item : items) {
                if (item.getPhysicalQuantity() != null) {
                    hasAtLeastOneInput = true;
                    break;
                }
            }

            if (!errors.isEmpty()) {
                loadInventoryCheckPage(request, response, items, errors, null);
                return;
            }

            if (!hasAtLeastOneInput) {
                loadInventoryCheckPage(request, response, items, null,
                        "Bạn chưa nhập số lượng thực tế cho sản phẩm nào.");
                return;
            }

            InventoryCheckDAO dao = new InventoryCheckDAO();
            boolean ok = dao.saveInventoryCounts(items, user.getUserID());

            if (ok) {
                session.setAttribute("message", "Lưu kiểm kê thành công.");
                
                String senderName = "Unknown User";
                if (user != null) {
                    if (user.getFullName() != null && !user.getFullName().trim().isEmpty()) {
                        senderName = user.getFullName().trim();
                    } else if (user.getUsername() != null && !user.getUsername().trim().isEmpty()) {
                        senderName = user.getUsername().trim();
                    }
                }
                
                // 1. Add System Log (Do this first and independent of notifications)
                try {
                    SystemLogDAO logDao = new SystemLogDAO();
                    SystemLog logEntry = new SystemLog();
                    logEntry.setUserID(user != null ? user.getUserID() : 0);
                    logEntry.setAction("INVENTORY_CHECK_SAVE");
                    logEntry.setTargetObject("InventoryCheck");
                    logEntry.setDescription("Staff " + senderName + " has saved a new inventory check session.");
                    logEntry.setIpAddress(request.getRemoteAddr());
                    logDao.insertLog(logEntry);
                } catch (Exception logEx) {
                    logEx.printStackTrace();
                }

                // 2. Send notification to all managers
                try {
                    NotificationDAO nDao = new NotificationDAO();
                    List<Integer> managerIds = nDao.getManagerIds();
                    
                    for (Integer managerId : managerIds) {
                        Notification n = new Notification();
                        n.setUserId(managerId);
                        n.setTitle("Kiểm kê kho mới");
                        n.setMessage(senderName + " đã lưu kiểm kê, hãy kiểm tra");
                        n.setType("INVENTORY_CHECK_SAVED");
                        nDao.insert(n);
                        
                        // Push WebSocket real-time update
                        int unread = nDao.countUnread(managerId);
                        NotificationEndpoint.sendToUser(managerId, "{\"unreadCount\":" + unread + "}");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    // Log error but don't block the main flow
                }
            } else {
                session.setAttribute("error", "Lưu kiểm kê thất bại.");
            }

            String encodedKeyword = keyword == null ? "" : URLEncoder.encode(keyword, "UTF-8");
            String pageParam = request.getParameter("page");
            if (pageParam == null || pageParam.trim().isEmpty()) {
                pageParam = "1";
            }

            response.sendRedirect("inventoryCheck?keyword=" + encodedKeyword + "&page=" + pageParam);
            return;
        }

        response.sendRedirect("inventoryCheck");
    }

    private void loadInventoryCheckPage(HttpServletRequest request, HttpServletResponse response,
            List<InventoryCheckItem> overrideItems,
            List<String> errors,
            String singleError)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        int page = 1;
        int pageSize = 10;

        try {
            String pageRaw = request.getParameter("page");
            if (pageRaw != null && !pageRaw.trim().isEmpty()) {
                page = Integer.parseInt(pageRaw);
                if (page < 1) {
                    page = 1;
                }
            }
        } catch (Exception e) {
            page = 1;
        }

        InventoryCheckDAO daoCount = new InventoryCheckDAO();
        int totalProducts = daoCount.countProductsForCounting(keyword);
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        if (totalPages == 0) {
            totalPages = 1;
        }
        if (page > totalPages) {
            page = totalPages;
        }

        List<InventoryCheckItem> items;
        if (overrideItems != null) {
            items = overrideItems;
        } else {
            InventoryCheckDAO daoItems = new InventoryCheckDAO();
            items = daoItems.searchProductsForCounting(keyword, page, pageSize);
        }

        InventoryCheckDAO daoChecked = new InventoryCheckDAO();
        List<InventoryCheckItem> checkedProducts = daoChecked.getCheckedProductSummaries();

        request.setAttribute("keyword", keyword);
        request.setAttribute("items", items);
        request.setAttribute("checkedProducts", checkedProducts);
        request.setAttribute("page", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);

        if (errors != null && !errors.isEmpty()) {
            request.setAttribute("errors", errors);
        }

        if (singleError != null && !singleError.trim().isEmpty()) {
            request.setAttribute("error", singleError);
        }

        request.getRequestDispatcher("inventoryCheck.jsp").forward(request, response);
    }

    private void handleView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idRaw = request.getParameter("id");

        try {
            int countId = Integer.parseInt(idRaw);

            InventoryCheckDAO dao = new InventoryCheckDAO();
            InventoryCheckItem item = dao.getInventoryCountById(countId);

            if (item == null) {
                request.getSession().setAttribute("error", "Không tìm thấy bản ghi kiểm kê.");
                response.sendRedirect("inventoryCheck");
                return;
            }

            request.setAttribute("item", item);
            request.getRequestDispatcher("inventoryCheckDetail.jsp").forward(request, response);

        } catch (Exception e) {
            request.getSession().setAttribute("error", "Dữ liệu không hợp lệ.");
            response.sendRedirect("inventoryCheck");
        }
    }

    private void handleEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idRaw = request.getParameter("id");

        try {
            int countId = Integer.parseInt(idRaw);

            InventoryCheckDAO dao = new InventoryCheckDAO();
            InventoryCheckItem item = dao.getInventoryCountById(countId);

            if (item == null) {
                request.getSession().setAttribute("error", "Không tìm thấy bản ghi cần sửa.");
                response.sendRedirect("inventoryCheck");
                return;
            }

            request.setAttribute("item", item);
            request.getRequestDispatcher("inventoryCheckEdit.jsp").forward(request, response);

        } catch (Exception e) {
            request.getSession().setAttribute("error", "Dữ liệu không hợp lệ.");
            response.sendRedirect("inventoryCheck");
        }
    }

    private void handleProductHistory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productIdRaw = request.getParameter("productId");

        try {
            int productId = Integer.parseInt(productIdRaw);

            InventoryCheckDAO dao = new InventoryCheckDAO();
            List<InventoryCheckItem> historyList = dao.getInventoryHistoryByProductId(productId);

            if (historyList == null || historyList.isEmpty()) {
                request.getSession().setAttribute("error", "Không tìm thấy lịch sử kiểm kê của sản phẩm.");
                response.sendRedirect("inventoryCheck");
                return;
            }

            request.setAttribute("historyList", historyList);
            request.setAttribute("productInfo", historyList.get(0));
            request.getRequestDispatcher("inventoryCheckHistory.jsp").forward(request, response);

        } catch (Exception e) {
            request.getSession().setAttribute("error", "Dữ liệu sản phẩm không hợp lệ.");
            response.sendRedirect("inventoryCheck");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("acc");

        try {
            int countId = Integer.parseInt(request.getParameter("countId"));
            int systemQuantity = Integer.parseInt(request.getParameter("systemQuantity"));
            int physicalQuantity = Integer.parseInt(request.getParameter("physicalQuantity"));
            String status = request.getParameter("status");
            String reason = request.getParameter("reason");

            if (physicalQuantity == systemQuantity) {
                reason = null;
            }

            InventoryCheckDAO daoCheck = new InventoryCheckDAO();
            InventoryCheckItem oldItem = daoCheck.getInventoryCountById(countId);

            if (oldItem == null) {
                request.getSession().setAttribute("error", "Không tìm thấy bản ghi cần cập nhật.");
                response.sendRedirect("inventoryCheck");
                return;
            }

            if (physicalQuantity < 0) {
                request.setAttribute("error", "Số lượng thực tế không được âm.");
                request.setAttribute("item", oldItem);
                request.getRequestDispatcher("inventoryCheckEdit.jsp").forward(request, response);
                return;
            }

            if (physicalQuantity != systemQuantity && (reason == null || reason.trim().isEmpty())) {
                request.setAttribute("error", "Nếu số lượng thực tế chênh lệch, bạn phải nhập lý do.");
                request.setAttribute("item", oldItem);
                request.getRequestDispatcher("inventoryCheckEdit.jsp").forward(request, response);
                return;
            }

            InventoryCheckItem item = new InventoryCheckItem();
            item.setCountId(countId);
            item.setSystemQuantity(systemQuantity);
            item.setPhysicalQuantity(physicalQuantity);
            item.setStatus(status);
            item.setReason(reason);
            item.setDate(new Date(System.currentTimeMillis()));

            InventoryCheckDAO daoUpdate = new InventoryCheckDAO();
            boolean ok = daoUpdate.updateInventoryCount(item);

            if (ok) {
                request.getSession().setAttribute("message", "Cập nhật kiểm kê thành công.");

                // Add System Log for individual update
                try {
                    String senderName = (user.getFullName() != null && !user.getFullName().trim().isEmpty())
                            ? user.getFullName() : user.getUsername();
                    SystemLogDAO logDao = new SystemLogDAO();
                    SystemLog logEntry = new SystemLog();
                    logEntry.setUserID(user.getUserID());
                    logEntry.setAction("INVENTORY_CHECK_UPDATE");
                    logEntry.setTargetObject("InventoryCheck");
                    logEntry.setDescription("Staff " + senderName + " updated an inventory check record (ID: " + countId + ").");
                    logEntry.setIpAddress(request.getRemoteAddr());
                    logDao.insertLog(logEntry);
                } catch (Exception logEx) {
                    logEx.printStackTrace();
                }
            } else {
                request.getSession().setAttribute("error", "Cập nhật kiểm kê thất bại.");
            }

            response.sendRedirect("inventoryCheck");

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Dữ liệu cập nhật không hợp lệ.");
            response.sendRedirect("inventoryCheck");
        }
    }

    private void handleApprovalList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("acc");

        if (user == null || user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        InventoryCheckDAO dao = new InventoryCheckDAO();
        List<InventoryCheckItem> approvalSessions = dao.getPendingApprovalSessions();

        request.setAttribute("currentPage", "inventoryApproval");
        request.setAttribute("approvalSessions", approvalSessions);
        request.getRequestDispatcher("inventoryApproval.jsp").forward(request, response);
    }

    private void handleApprovalDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("acc");

        if (user == null || user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sessionCode = request.getParameter("sessionCode");
        if (sessionCode == null || sessionCode.trim().isEmpty()) {
            request.getSession().setAttribute("error", "Session code không hợp lệ.");
            response.sendRedirect("inventoryCheck?mode=approval");
            return;
        }

        InventoryCheckDAO dao1 = new InventoryCheckDAO();
        List<InventoryCheckItem> approvalSessions = dao1.getPendingApprovalSessions();

        InventoryCheckDAO dao2 = new InventoryCheckDAO();
        List<InventoryCheckItem> sessionItems = dao2.getInventoryCountsBySessionCode(sessionCode);

        if (sessionItems == null || sessionItems.isEmpty()) {
            request.getSession().setAttribute("error", "Không tìm thấy phiếu kiểm kho.");
            response.sendRedirect("inventoryCheck?mode=approval");
            return;
        }

        InventoryCheckItem first = sessionItems.get(0);

        request.setAttribute("currentPage", "inventoryApproval");
        request.setAttribute("approvalSessions", approvalSessions);
        request.setAttribute("selectedSessionCode", sessionCode);
        request.setAttribute("selectedSessionDate", first.getDate());
        request.setAttribute("selectedSessionCreatedBy", first.getCreatedByName());
        request.setAttribute("selectedSessionSize", sessionItems.size());
        request.setAttribute("selectedSessionItems", sessionItems);

        request.getRequestDispatcher("inventoryApproval.jsp").forward(request, response);
    }

    private void handleApproveSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("acc");

        if (user == null || user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sessionCode = request.getParameter("sessionCode");

        if (sessionCode == null || sessionCode.trim().isEmpty()) {
            session.setAttribute("error", "Session code không hợp lệ.");
            response.sendRedirect("inventoryCheck?mode=approval");
            return;
        }

        InventoryCheckDAO dao = new InventoryCheckDAO();
        boolean ok = dao.approveInventorySession(sessionCode, user.getUserID());

        if (ok) {
            session.setAttribute("message", "Approve phiếu kiểm kho thành công.");
            
            // Log this action
            try {
                String managerName = (user.getFullName() != null && !user.getFullName().trim().isEmpty())
                                    ? user.getFullName() : user.getUsername();
                SystemLogDAO logDao = new SystemLogDAO();
                SystemLog logEntry = new SystemLog();
                logEntry.setUserID(user.getUserID());
                logEntry.setAction("INVENTORY_CHECK_APPROVE");
                logEntry.setTargetObject("InventoryCheck");
                logEntry.setDescription("Manager " + managerName + " approved inventory session: " + sessionCode);
                logEntry.setIpAddress(request.getRemoteAddr());
                logDao.insertLog(logEntry);
            } catch (Exception logEx) {
                logEx.printStackTrace();
            }

            // Notify staff
            InventoryCheckDAO daoNotify = new InventoryCheckDAO();
            Integer creatorId = daoNotify.getCreatorIdBySessionCode(sessionCode);
            if (creatorId != null) {
                try {
                    String managerName = (user.getFullName() != null && !user.getFullName().trim().isEmpty())
                                        ? user.getFullName() : user.getUsername();
                    Notification n = new Notification();
                    n.setUserId(creatorId);
                    n.setTitle("Phiếu kiểm kho đã được duyệt");
                    n.setMessage("manager " + managerName + " đã Duyệt phiếu kiểm kê của bạn.");
                    n.setType("INVENTORY_CHECK_APPROVED");
                    
                    NotificationDAO nDao = new NotificationDAO();
                    if (nDao.insert(n)) {
                        int unread = nDao.countUnread(creatorId);
                        websocket.NotificationEndpoint.sendToUser(creatorId, "{\"unreadCount\":" + unread + "}");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } else {
            session.setAttribute("error", "Approve phiếu kiểm kho thất bại.");
        }

        response.sendRedirect("inventoryCheck?mode=approval");
    }

    private void handleRejectSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("acc");

        if (user == null || user.getRoleID() != 2) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sessionCode = request.getParameter("sessionCode");
        String rejectReason = request.getParameter("rejectReason");

        if (sessionCode == null || sessionCode.trim().isEmpty()) {
            session.setAttribute("error", "Session code không hợp lệ.");
            response.sendRedirect("inventoryCheck?mode=approval");
            return;
        }

        if (rejectReason == null || rejectReason.trim().isEmpty()) {
            session.setAttribute("error", "Bạn phải nhập lý do reject.");
            response.sendRedirect("inventoryCheck?mode=approvalDetail&sessionCode=" + sessionCode);
            return;
        }

        InventoryCheckDAO dao = new InventoryCheckDAO();
        boolean ok = dao.rejectInventorySession(sessionCode, user.getUserID(), rejectReason.trim());

        if (ok) {
            session.setAttribute("message", "Reject phiếu kiểm kho thành công.");
            
            // Log this action
            try {
                String managerName = (user.getFullName() != null && !user.getFullName().trim().isEmpty())
                                    ? user.getFullName() : user.getUsername();
                SystemLogDAO logDao = new SystemLogDAO();
                SystemLog logEntry = new SystemLog();
                logEntry.setUserID(user.getUserID());
                logEntry.setAction("INVENTORY_CHECK_REJECT");
                logEntry.setTargetObject("InventoryCheck");
                logEntry.setDescription("Manager " + managerName + " rejected inventory session: " + sessionCode + ". Reason: " + rejectReason);
                logEntry.setIpAddress(request.getRemoteAddr());
                logDao.insertLog(logEntry);
            } catch (Exception logEx) {
                logEx.printStackTrace();
            }

            // Notify staff
            InventoryCheckDAO daoNotify = new InventoryCheckDAO();
            Integer creatorId = daoNotify.getCreatorIdBySessionCode(sessionCode);
            if (creatorId != null) {
                try {
                    String managerName = (user.getFullName() != null && !user.getFullName().trim().isEmpty())
                                        ? user.getFullName() : user.getUsername();
                    Notification n = new Notification();
                    n.setUserId(creatorId);
                    n.setTitle("Phiếu kiểm kho bị từ chối");
                    n.setMessage("manager " + managerName + " đã Từ chối phiếu kiểm kê của bạn. Lý do: " + rejectReason);
                    n.setType("INVENTORY_CHECK_REJECTED");
                    
                    NotificationDAO nDao = new NotificationDAO();
                    if (nDao.insert(n)) {
                        int unread = nDao.countUnread(creatorId);
                        websocket.NotificationEndpoint.sendToUser(creatorId, "{\"unreadCount\":" + unread + "}");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } else {
            session.setAttribute("error", "Reject phiếu kiểm kho thất bại.");
        }

        response.sendRedirect("inventoryCheck?mode=approval");
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
