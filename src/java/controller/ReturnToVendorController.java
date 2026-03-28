package controller;

import dao.ReturnToVendorDAO;
import dao.StockInDAO;
import dao.SupplierDAO;
import dao.SupplierDebtDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.ReturnReplacementReceipt;
import model.ReturnToVendor;
import model.ReturnToVendorDetail;
import model.StockInDetail;
import model.Supplier;
import model.User;
import utils.SupplierEmailService;

@WebServlet(name = "ReturnToVendorController", urlPatterns = { "/return-to-vendor" })
public class ReturnToVendorController extends HttpServlet {

    private String generateReturnCode() {
        return "RTV-" + System.currentTimeMillis();
    }

    private boolean isWarehouseOrAdmin(User acc) {
        return acc != null && (acc.getRoleID() == 0 || acc.getRoleID() == 1);
    }

    private boolean isManagerOrAdmin(User acc) {
        return acc != null && (acc.getRoleID() == 0 || acc.getRoleID() == 2);
    }

    private String trimToNull(String value) {
        if (value == null)
            return null;
        String t = value.trim();
        return t.isEmpty() ? null : t;
    }

    private String valueAt(String[] values, int index) {
        return (values == null || index < 0 || index >= values.length) ? null : values[index];
    }

    private String buildDetailRedirect(HttpServletRequest request, int rtvID, String extraQuery) {
        StringBuilder url = new StringBuilder("return-to-vendor?action=detail&id=").append(rtvID);
        String from = trimToNull(request.getParameter("from"));
        if (from != null)
            url.append("&from=").append(URLEncoder.encode(from, StandardCharsets.UTF_8));
        if (extraQuery != null && !extraQuery.trim().isEmpty()) {
            if (extraQuery.charAt(0) != '&')
                url.append('&');
            url.append(extraQuery);
        }
        return url.toString();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User acc = (User) session.getAttribute("acc");
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }
        ReturnToVendorDAO dao = new ReturnToVendorDAO();
        String action = request.getParameter("action");
        try {
            if ("create".equals(action)) {
                if (!isWarehouseOrAdmin(acc)) {
                    response.sendRedirect("return-to-vendor?error=forbidden_create");
                    return;
                }
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                return;
            }
            if ("detail".equals(action)) {
                int rtvID = Integer.parseInt(request.getParameter("id"));
                ReturnToVendor rtv = dao.getById(rtvID);
                request.setAttribute("rtv", rtv);
                request.setAttribute("replacementReceipts", dao.getReplacementReceiptsByRTV(rtvID));
                request.getRequestDispatcher("returnToVendorDetail.jsp").forward(request, response);
                return;
            }
            request.setAttribute("list", dao.getAllReturns());
            request.getRequestDispatcher("returnToVendor.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Cannot load Return To Vendor page.");
            request.getRequestDispatcher("returnToVendor.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User acc = (User) session.getAttribute("acc");
        if (acc == null) {
            response.sendRedirect("login");
            return;
        }

        String action = trimToNull(request.getParameter("action"));
        String ipAddress = request.getRemoteAddr();
        ReturnToVendorDAO dao = new ReturnToVendorDAO();

        try {
            if ("create".equals(action)) {
                if (!isWarehouseOrAdmin(acc)) {
                    response.sendRedirect("return-to-vendor?error=forbidden_create");
                    return;
                }
                handleCreate(request, response, dao, acc, ipAddress);
                return;
            }
            if ("approve".equals(action)) {
                int rtvID = Integer.parseInt(request.getParameter("rtvID"));
                if (!isManagerOrAdmin(acc)) {
                    response.sendRedirect(buildDetailRedirect(request, rtvID, "error=forbidden_approve"));
                    return;
                }
                boolean ok = dao.approveReturn(rtvID, acc.getUserID(), ipAddress);
                if (ok) {
                    sendSupplierRtvApprovedEmail(rtvID);
                    // Notify Staff
                    ReturnToVendor rtv = dao.getById(rtvID);
                    if (rtv != null) {
                        dao.NotificationDAO nDAO = new dao.NotificationDAO();
                        model.Notification n = new model.Notification();
                        n.setUserId(rtv.getCreatedBy());
                        n.setTitle("✅ Trả hàng #" + rtvID + " được duyệt (Phiếu nhập #" + rtv.getStockInID() + ")");
                        String managerName = acc.getFullName() != null && !acc.getFullName().trim().isEmpty() ? acc.getFullName() : acc.getUsername();
                        n.setMessage("Quản lý \"" + managerName + "\" đã duyệt phiếu trả hàng của bạn.");
                        n.setType("RETURN_TO_VENDOR_APPROVED");
                        nDAO.insert(n);
                        websocket.NotificationEndpoint.sendToUser(rtv.getCreatedBy(), "{\"unreadCount\":" + nDAO.countUnread(rtv.getCreatedBy()) + "}");
                    }
                }
                response.sendRedirect(buildDetailRedirect(request, rtvID, ok ? "msg=approved" : "error=approve_failed_or_debt_not_enough"));
                return;
            }
            if ("reject".equals(action)) {
                int rtvID = Integer.parseInt(request.getParameter("rtvID"));
                if (!isManagerOrAdmin(acc)) {
                    response.sendRedirect(buildDetailRedirect(request, rtvID, "error=forbidden_reject"));
                    return;
                }
                String rejectNote = trimToNull(request.getParameter("rejectNote"));
                boolean ok = dao.rejectReturn(rtvID, acc.getUserID(), rejectNote, ipAddress);
                if (ok) {
                    // Notify Staff
                    ReturnToVendor rtv = dao.getById(rtvID);
                    if (rtv != null) {
                        dao.NotificationDAO nDAO = new dao.NotificationDAO();
                        model.Notification n = new model.Notification();
                        n.setUserId(rtv.getCreatedBy());
                        n.setTitle("❌ Trả hàng #" + rtvID + " bị từ chối (Phiếu nhập #" + rtv.getStockInID() + ")");
                        String managerName = acc.getFullName() != null && !acc.getFullName().trim().isEmpty() ? acc.getFullName() : acc.getUsername();
                        n.setMessage("Quản lý \"" + managerName + "\" đã từ chối phiếu trả hàng của bạn." + (rejectNote != null ? "\nLý do: " + rejectNote : ""));
                        n.setType("RETURN_TO_VENDOR_REJECTED");
                        nDAO.insert(n);
                        websocket.NotificationEndpoint.sendToUser(rtv.getCreatedBy(), "{\"unreadCount\":" + nDAO.countUnread(rtv.getCreatedBy()) + "}");
                    }
                }
                response.sendRedirect(buildDetailRedirect(request, rtvID, ok ? "msg=rejected" : "error=reject_failed"));
                return;
            }
            if ("complete".equals(action)) {
                int rtvID = Integer.parseInt(request.getParameter("rtvID"));
                if (!isWarehouseOrAdmin(acc)) {
                    response.sendRedirect(buildDetailRedirect(request, rtvID, "error=forbidden_complete"));
                    return;
                }
                boolean ok = dao.completeReturnToVendor(rtvID, acc.getUserID(), ipAddress);
                response.sendRedirect(
                        buildDetailRedirect(request, rtvID, ok ? "msg=completed" : "error=complete_failed"));
                return;
            }
            if ("addReplacementReceipt".equals(action)) {
                int rtvID = Integer.parseInt(request.getParameter("rtvID"));
                int rtvDetailID = Integer.parseInt(request.getParameter("rtvDetailID"));
                int qty = Integer.parseInt(request.getParameter("replacementQty"));
                String note = trimToNull(request.getParameter("replacementNote"));
                if (!isWarehouseOrAdmin(acc)) {
                    response.sendRedirect(buildDetailRedirect(request, rtvID, "error=forbidden_replacement_receipt"));
                    return;
                }
                boolean ok = dao.addReplacementReceipt(rtvID, rtvDetailID, qty, note, acc.getUserID(), ipAddress);
                response.sendRedirect(buildDetailRedirect(request, rtvID,
                        ok ? "msg=replacement_received" : "error=replacement_receipt_failed"));
                return;
            }
            response.sendRedirect("return-to-vendor");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("return-to-vendor?error=system_error");
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response,
            ReturnToVendorDAO dao, User acc, String ipAddress)
            throws ServletException, IOException {
        try {
            String supplierRaw = trimToNull(request.getParameter("supplierID"));
            String reason = trimToNull(request.getParameter("reason"));
            String note = trimToNull(request.getParameter("note"));
            String settlementType = trimToNull(request.getParameter("settlementType"));
            if (supplierRaw == null) {
                request.setAttribute("error", "Please select a supplier.");
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                return;
            }
            if (reason == null) {
                request.setAttribute("error", "Please enter a return reason.");
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                return;
            }
            int supplierID = Integer.parseInt(supplierRaw);
            if (settlementType == null)
                settlementType = "OFFSET_DEBT";

            String[] stockInDetailIDs = request.getParameterValues("stockInDetailID");
            String[] productIDs = request.getParameterValues("productID");
            String[] quantities = request.getParameterValues("quantity");
            String[] reasonDetails = request.getParameterValues("reasonDetail");
            String[] itemConditions = request.getParameterValues("itemCondition");
            if (stockInDetailIDs == null || stockInDetailIDs.length == 0) {
                request.setAttribute("error", "Please add at least one item.");
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                return;
            }
            ReturnToVendor rtv = new ReturnToVendor();
            rtv.setReturnCode(generateReturnCode());
            rtv.setSupplierID(supplierID);
            rtv.setCreatedBy(acc.getUserID());
            rtv.setStatus("Pending");
            rtv.setReason(reason);
            rtv.setNote(note);
            rtv.setSettlementType(settlementType);

            List<ReturnToVendorDetail> details = new ArrayList<>();
            Set<Integer> usedStockInDetailIDs = new HashSet<>();
            StockInDAO stockInDAO = new StockInDAO();
            Integer headerStockInID = null;
            double projectedTotal = 0;

            for (int i = 0; i < stockInDetailIDs.length; i++) {
                String stockInDetailRaw = trimToNull(valueAt(stockInDetailIDs, i));
                String productRaw = trimToNull(valueAt(productIDs, i));
                String quantityRaw = trimToNull(valueAt(quantities, i));
                String reasonDetail = trimToNull(valueAt(reasonDetails, i));
                String itemCondition = trimToNull(valueAt(itemConditions, i));
                boolean rowCompletelyEmpty = stockInDetailRaw == null && productRaw == null && quantityRaw == null
                        && reasonDetail == null;
                if (rowCompletelyEmpty)
                    continue;
                if (stockInDetailRaw == null || productRaw == null || quantityRaw == null) {
                    request.setAttribute("error",
                            "Please complete product, stock-in detail and quantity for every used row.");
                    request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                    return;
                }
                int stockInDetailID = Integer.parseInt(stockInDetailRaw);
                int productID = Integer.parseInt(productRaw);
                int quantity = Integer.parseInt(quantityRaw);
                if (quantity <= 0) {
                    request.setAttribute("error", "Return quantity must be greater than 0.");
                    request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                    return;
                }
                if (usedStockInDetailIDs.contains(stockInDetailID)) {
                    request.setAttribute("error", "A stock-in detail cannot be selected more than once.");
                    request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                    return;
                }
                StockInDetail sid = stockInDAO.getStockInDetailByDetailId(stockInDetailID);
                if (sid == null) {
                    request.setAttribute("error", "Selected stock-in detail does not exist.");
                    request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                    return;
                }
                if (sid.getProductId() != productID) {
                    request.setAttribute("error", "Selected stock-in detail does not belong to the selected product.");
                    request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                    return;
                }
                if (headerStockInID == null)
                    headerStockInID = sid.getStockInId();
                else if (headerStockInID != sid.getStockInId()) {
                    request.setAttribute("error",
                            "Một phiếu trả NCC chỉ được chứa chi tiết thuộc cùng một phiếu nhập hàng.");
                    request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                    return;
                }
                ReturnToVendorDetail detail = new ReturnToVendorDetail();
                detail.setStockInDetailID(stockInDetailID);
                detail.setStockInID(sid.getStockInId());
                detail.setProductID(productID);
                detail.setQuantity(quantity);
                detail.setUnitCost(sid.getUnitCost());
                detail.setLineTotal(quantity * sid.getUnitCost());
                detail.setReasonDetail(reasonDetail);
                detail.setItemCondition(itemCondition);
                projectedTotal += detail.getLineTotal();
                details.add(detail);
                usedStockInDetailIDs.add(stockInDetailID);
            }
            if (details.isEmpty()) {
                request.setAttribute("error", "Please add at least one valid return item.");
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                return;
            }
            if (headerStockInID != null)
                rtv.setStockInID(headerStockInID);
            if (dao.isOffsetDebtSettlement(settlementType)) {
                SupplierDebtDAO debtDAO = new SupplierDebtDAO();
                if (!debtDAO.hasEnoughDebtForOffset(supplierID, projectedTotal)) {
                    request.setAttribute("error",
                            "Công nợ hiện tại của nhà cung cấp nhỏ hơn tổng giá trị phiếu, không thể chọn phương thức OFFSET_DEBT.");
                    request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                    return;
                }
            }
            int rtvID = dao.createReturnWithDetails(rtv, details, ipAddress);
            if (rtvID > 0) {
                dao.NotificationDAO nDAO = new dao.NotificationDAO();
                List<Integer> managerIds = nDAO.getManagerIds();
                String staffName = acc.getFullName() != null && !acc.getFullName().trim().isEmpty() ? acc.getFullName()
                        : acc.getUsername();
                for (Integer mId : managerIds) {
                    model.Notification n = new model.Notification();
                    n.setUserId(mId);
                    n.setTitle("📦 Trả hàng NCC #" + rtvID);
                    n.setMessage("Nhân viên \"" + staffName + "\" đã tạo phiếu trả hàng cho nhà cung cấp");
                    n.setType("RETURN_TO_VENDOR_CREATED");
                    nDAO.insert(n);

                    int unread = nDAO.countUnread(mId);
                    websocket.NotificationEndpoint.sendToUser(mId, "{\"unreadCount\":" + unread + "}");
                }
                response.sendRedirect(buildDetailRedirect(request, rtvID, "msg=created"));
            } else {
                request.setAttribute("error", "Create return to vendor failed.");
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Input data contains invalid numeric values.");
            request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid input data.");
            request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
        }
    }

    private void sendSupplierRtvApprovedEmail(int rtvId) {
        try {
            ReturnToVendorDAO dao = new ReturnToVendorDAO();
            ReturnToVendor rtv = dao.getById(rtvId);
            if (rtv == null)
                return;
            Supplier supplier = new SupplierDAO().getSupplierById(rtv.getSupplierID());
            if (supplier == null)
                return;
            new SupplierEmailService().sendReturnApprovedEmail(supplier, rtv, rtv.getDetails());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public String getServletInfo() {
        return "Return To Vendor Controller";
    }
}
