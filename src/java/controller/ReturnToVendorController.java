package controller;

import dao.ReturnToVendorDAO;
import dao.StockInDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import model.ReturnToVendor;
import model.ReturnToVendorDetail;
import model.StockInDetail;
import model.User;

@WebServlet(name = "ReturnToVendorController", urlPatterns = {"/return-to-vendor"})
public class ReturnToVendorController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ReturnToVendorController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ReturnToVendorController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

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
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String valueAt(String[] values, int index) {
        if (values == null || index < 0 || index >= values.length) {
            return null;
        }
        return values[index];
    }

    private String buildDetailRedirect(HttpServletRequest request, int rtvID, String extraQuery) {
        StringBuilder url = new StringBuilder("return-to-vendor?action=detail&id=").append(rtvID);
        String from = trimToNull(request.getParameter("from"));
        if (from != null) {
            url.append("&from=")
                    .append(URLEncoder.encode(from, StandardCharsets.UTF_8));
        }
        if (extraQuery != null && !extraQuery.trim().isEmpty()) {
            if (extraQuery.charAt(0) != '&') {
                url.append('&');
            }
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
                response.sendRedirect(buildDetailRedirect(request, rtvID, ok ? "msg=approved" : "error=approve_failed"));
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
                response.sendRedirect(buildDetailRedirect(request, rtvID, ok ? "msg=completed" : "error=complete_failed"));
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
            if (settlementType == null) {
                settlementType = "OFFSET_DEBT";
            }

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

            for (int i = 0; i < stockInDetailIDs.length; i++) {
                String stockInDetailRaw = trimToNull(valueAt(stockInDetailIDs, i));
                String productRaw = trimToNull(valueAt(productIDs, i));
                String quantityRaw = trimToNull(valueAt(quantities, i));
                String reasonDetail = trimToNull(valueAt(reasonDetails, i));
                String itemCondition = trimToNull(valueAt(itemConditions, i));

                boolean rowCompletelyEmpty = stockInDetailRaw == null
                        && productRaw == null
                        && quantityRaw == null
                        && reasonDetail == null;
                if (rowCompletelyEmpty) {
                    continue;
                }

                if (stockInDetailRaw == null || productRaw == null || quantityRaw == null) {
                    request.setAttribute("error", "Please complete product, stock-in detail and quantity for every used row.");
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

                if (headerStockInID == null) {
                    headerStockInID = sid.getStockInId();
                } else if (headerStockInID.intValue() != sid.getStockInId()) {
                    request.setAttribute("error", "All return items in one return-to-vendor document must belong to the same StockIn.");
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

                details.add(detail);
                usedStockInDetailIDs.add(stockInDetailID);
            }

            if (details.isEmpty()) {
                request.setAttribute("error", "Please add at least one valid return item.");
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                return;
            }

            if (headerStockInID == null) {
                request.setAttribute("error", "Cannot determine StockIn for the return items.");
                request.getRequestDispatcher("returnToVendorCreate.jsp").forward(request, response);
                return;
            }

            rtv.setStockInID(headerStockInID);

            int rtvID = dao.createReturnWithDetails(rtv, details, ipAddress);

            if (rtvID > 0) {
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

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
