package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.ReturnDAO;
import dao.ReturnToVendorDAO;
import dao.WarrantyClaimDAO;
import dao.WarrantyLookupDAO;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.ReturnStatus;
import model.User;
import model.WarrantyClaim;
import model.WarrantyClaimStatus;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "ManagerController", urlPatterns = {"/manager_dashboard"})
public class ManagerController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureManager(request, response)) {
            return;
        }

        String tab = safeTrim(request.getParameter("tab"));
        if (tab == null || tab.isEmpty()) {
            tab = "overview";
        }
        request.setAttribute("tab", tab);

        if ("returns".equals(tab)) {
            ReturnDAO dao = new ReturnDAO();
            request.setAttribute("returns", dao.listAll());
        } else if ("vendorReturns".equals(tab)) {
            ReturnToVendorDAO dao = new ReturnToVendorDAO();
            request.setAttribute("vendorReturns", dao.getAllReturns());
        } else if ("warranty".equals(tab)) {
            WarrantyClaimDAO wcDao = new WarrantyClaimDAO();
            List<WarrantyClaim> claims = wcDao.listAll();
            request.setAttribute("claims", claims);
            WarrantyLookupDAO wlDao = new WarrantyLookupDAO();
            Map<Integer, Boolean> warrantyExpiredByClaimId = new HashMap<>();
            for (WarrantyClaim c : claims) {
                boolean expired = wlDao.isWarrantyExpiredBySkuAndPhone(c.getSku(), c.getCustomerPhone());
                warrantyExpiredByClaimId.put(c.getId(), expired);
            }
            request.setAttribute("warrantyExpiredByClaimId", warrantyExpiredByClaimId);
        } else if ("orders".equals(tab)) {
            String keyword = request.getParameter("orderSearch");
            dao.OrderHistoryDAO oDao = new dao.OrderHistoryDAO();
            List<model.OrderHistory> list;
            if (keyword != null && !keyword.trim().isEmpty()) {
                list = oDao.searchOrders(keyword.trim(), "new");
            } else {
                list = oDao.getAllOrders("new");
            }
            request.setAttribute("orders", list);
            request.setAttribute("orderSearch", keyword);
        } else {
            WarrantyClaimDAO wDao = new WarrantyClaimDAO();
            ReturnDAO rDao = new ReturnDAO();
            ReturnToVendorDAO rtvDao = new ReturnToVendorDAO();
            CategoryDAO cDao = new CategoryDAO();
            ProductDAO pDao = new ProductDAO();

            var claims = wDao.listAll();
            var returns = rDao.listAll();
            var vendorReturns = rtvDao.getAllReturns();

            request.setAttribute("totalClaims", claims.size());
            request.setAttribute("pendingClaims", claims.stream().filter(c -> "NEW".equals(c.getStatus().name())).count());

            request.setAttribute("totalReturns", returns.size());
            request.setAttribute("pendingReturns", returns.stream().filter(r -> "NEW".equals(r.getStatus().name())).count());

            request.setAttribute("totalVendorReturns", vendorReturns.size());
            request.setAttribute("pendingVendorReturns", vendorReturns.stream().filter(r -> "Pending".equalsIgnoreCase(r.getStatus())).count());

            request.setAttribute("recentClaims", claims.size() > 5 ? claims.subList(0, 5) : claims);

            try {
                request.setAttribute("categories", cDao.getHierarchicalList());
                request.setAttribute("lowStockProducts", pDao.getLowStockProducts(10));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.getRequestDispatcher("manager_dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureManager(request, response)) {
            return;
        }

        String action = safeTrim(request.getParameter("action"));
        if (action == null || action.isEmpty()) {
            response.sendRedirect("manager_dashboard");
            return;
        }

        String actor = getActor(request);
        User currentUser = (User) request.getSession().getAttribute("acc");
        String ipAddress = request.getRemoteAddr();

        if ("confirmWarranty".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                WarrantyClaimDAO dao = new WarrantyClaimDAO();
                WarrantyClaim claim = dao.getById(id);
                if (claim != null) {
                    WarrantyLookupDAO wlDao = new WarrantyLookupDAO();
                    if (wlDao.isWarrantyExpiredBySkuAndPhone(claim.getSku(), claim.getCustomerPhone())) {
                        response.sendRedirect("manager_dashboard?tab=warranty&err=warranty_expired");
                        return;
                    }
                    dao.updateStatus(id, WarrantyClaimStatus.APPROVED, "Manager xác nhận yêu cầu", actor);
                }
            }
            response.sendRedirect("manager_dashboard?tab=warranty");
            return;
        }

        if ("confirmReturn".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                ReturnDAO dao = new ReturnDAO();
                dao.updateStatus(id, ReturnStatus.APPROVED, "Manager xác nhận yêu cầu", actor);
            }
            response.sendRedirect("manager_dashboard?tab=returns");
            return;
        }

        if ("approveVendorReturn".equals(action)) {
            Integer rtvID = tryParseInt(request.getParameter("rtvID"));
            if (rtvID == null) {
                response.sendRedirect("manager_dashboard?tab=vendorReturns&err=invalid_id");
                return;
            }
            ReturnToVendorDAO dao = new ReturnToVendorDAO();
            boolean ok = dao.approveReturn(rtvID, currentUser.getUserID(), ipAddress);
            response.sendRedirect("manager_dashboard?tab=vendorReturns" + (ok ? "&msg=approved" : "&err=approve_failed"));
            return;
        }

        if ("rejectVendorReturn".equals(action)) {
            Integer rtvID = tryParseInt(request.getParameter("rtvID"));
            if (rtvID == null) {
                response.sendRedirect("manager_dashboard?tab=vendorReturns&err=invalid_id");
                return;
            }
            String rejectNote = safeTrim(request.getParameter("rejectNote"));
            if (rejectNote == null || rejectNote.isEmpty()) {
                rejectNote = "Manager rejected return to vendor request.";
            }
            ReturnToVendorDAO dao = new ReturnToVendorDAO();
            boolean ok = dao.rejectReturn(rtvID, currentUser.getUserID(), rejectNote, ipAddress);
            response.sendRedirect("manager_dashboard?tab=vendorReturns" + (ok ? "&msg=rejected" : "&err=reject_failed"));
            return;
        }

        response.sendRedirect("manager_dashboard");
    }

    private boolean ensureManager(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 2) {
            response.sendRedirect("login");
            return false;
        }
        return true;
    }

    private Integer tryParseInt(String s) {
        if (s == null || s.isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return null;
        }
    }

    private String getActor(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object acc = session.getAttribute("acc");

        if (acc instanceof User) {
            User u = (User) acc;
            if (u.getUsername() != null && !u.getUsername().isBlank()) {
                return u.getUsername();
            }
            return "user#" + u.getUserID();
        }

        return "unknown";
    }

    private String safeTrim(String s) {
        return s == null ? null : s.trim();
    }
}
