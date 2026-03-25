/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.LowStockDAO;
import dao.ReturnDAO;
import dao.StaffDashboardDAO;
import dao.SystemLogDAO;
import dao.WarrantyClaimDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.text.NumberFormat;
import java.util.Locale;
import model.Product;
import model.ReturnStatus;
import model.User;
import model.WarrantyClaimStatus;

/**
 *
 * @author dotha
 */
@WebServlet(name = "StaffController", urlPatterns = {"/staff_dashboard"})
public class StaffController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureStaff(request, response)) {
            return;
        }

        String tab = safeTrim(request.getParameter("tab"));
        if (tab == null || tab.isEmpty()) {
            tab = "dashboard";
        }
        request.setAttribute("tab", tab);

        if ("dashboard".equals(tab)) {
            loadDashboardData(request);
        } else if ("returns".equals(tab)) {
            ReturnDAO dao = new ReturnDAO();
            request.setAttribute("returns", dao.listAll());
        } else if ("products".equals(tab)) {
            try {
                CategoryDAO dao = new CategoryDAO();
                ProductDAO pDao = new ProductDAO();
                List<Product> products = pDao.getAllProducts();
                request.setAttribute("products", products);

                String editIdRaw = safeTrim(request.getParameter("editId"));
                Integer editId = tryParseInt(editIdRaw);
                if (editId != null) {
                    Product editProduct = pDao.getProductById(editId);
                    if (editProduct != null) {
                        request.setAttribute("editProduct", editProduct);
                    }
                }
                request.setAttribute("categories", dao.getHierarchicalList());
            } catch (Exception e) {
                request.setAttribute("error", "Không thể tải danh sách sản phẩm.");
            }
        } else {
            WarrantyClaimDAO dao = new WarrantyClaimDAO();
            request.setAttribute("claims", dao.listAll());
        }

        request.getRequestDispatcher("staff_dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureStaff(request, response)) {
            return;
        }

        String action = safeTrim(request.getParameter("action"));
        if ("completeWarranty".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                WarrantyClaimDAO dao = new WarrantyClaimDAO();
                var claim = dao.getById(id);
                if (claim != null
                        && claim.getStatus() != WarrantyClaimStatus.COMPLETED
                        && claim.getStatus() != WarrantyClaimStatus.REJECTED
                        && claim.getStatus() != WarrantyClaimStatus.CANCELLED) {
                    dao.updateStatus(id, WarrantyClaimStatus.COMPLETED,
                            "Staff xác nhận đã bảo hành", getActor(request));
                }
            }
            response.sendRedirect("staff_dashboard?tab=warranty");
            return;
        }

        if ("rejectWarranty".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                WarrantyClaimDAO dao = new WarrantyClaimDAO();
                var claim = dao.getById(id);
                if (claim != null
                        && claim.getStatus() != WarrantyClaimStatus.COMPLETED
                        && claim.getStatus() != WarrantyClaimStatus.REJECTED
                        && claim.getStatus() != WarrantyClaimStatus.CANCELLED) {
                    dao.updateStatus(id, WarrantyClaimStatus.REJECTED,
                            "Staff từ chối yêu cầu bảo hành", getActor(request));
                }
            }
            response.sendRedirect("staff_dashboard?tab=warranty");
            return;
        }

        if ("completeReturn".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                ReturnDAO dao = new ReturnDAO();
                var rr = dao.getById(id);
                if (rr != null
                        && rr.getStatus() != ReturnStatus.COMPLETED
                        && rr.getStatus() != ReturnStatus.REJECTED
                        && rr.getStatus() != ReturnStatus.REFUNDED
                        && rr.getStatus() != ReturnStatus.CANCELLED) {
                    String skuBefore = rr.getSku() == null ? "" : rr.getSku().trim();
                    boolean updated = dao.updateStatus(id, ReturnStatus.COMPLETED,
                            "Staff xác nhận đã trả hàng", getActor(request));

                    // Nhận hàng trả về kho: tăng StockQuantity theo SKU (1 đơn vị / yêu cầu — bảng ReturnRequests chưa có cột số lượng).
                    if (updated && !skuBefore.isEmpty()) {
                        ProductDAO productDAO = new ProductDAO();
                        productDAO.increaseQuantityBySku(skuBefore, 1);
                    }
                }
            }
            response.sendRedirect("staff_dashboard?tab=returns");
            return;
        }

        if ("toggleLowStockNotified".equals(action)) {
            Integer alertId = tryParseInt(request.getParameter("alertId"));
            boolean notified = Boolean.parseBoolean(request.getParameter("notified"));
            if (alertId != null) {
                LowStockDAO dao = new LowStockDAO();
                dao.updateNotified(alertId, !notified);
            }
            response.sendRedirect("staff_dashboard?tab=dashboard");
            return;
        }

        if ("rejectReturn".equals(action)) {
            Integer id = tryParseInt(request.getParameter("id"));
            if (id != null) {
                ReturnDAO dao = new ReturnDAO();
                var rr = dao.getById(id);
                if (rr != null
                        && rr.getStatus() != ReturnStatus.COMPLETED
                        && rr.getStatus() != ReturnStatus.REJECTED
                        && rr.getStatus() != ReturnStatus.REFUNDED
                        && rr.getStatus() != ReturnStatus.CANCELLED) {
                    dao.updateStatus(id, ReturnStatus.REJECTED,
                            "Staff từ chối yêu cầu trả hàng", getActor(request));
                }
            }
            response.sendRedirect("staff_dashboard?tab=returns");
            return;
        }

        response.sendRedirect("staff_dashboard?tab=dashboard");
    }

    private void loadDashboardData(HttpServletRequest request) {
        User user = (User) request.getSession().getAttribute("acc");
        LowStockDAO lowStockDAO = new LowStockDAO();
        StaffDashboardDAO dashboardDAO = new StaffDashboardDAO();
        SystemLogDAO systemLogDAO = new SystemLogDAO();

        int lowStockCount = lowStockDAO.countTriggeredAlerts();
        request.setAttribute("triggeredCount", lowStockCount);
        request.setAttribute("triggeredAlerts", lowStockDAO.getTriggeredAlerts());
        request.setAttribute("dashboardWatchlist", dashboardDAO.getDashboardWatchlist());
        request.setAttribute("pendingSupplierDebtCount", dashboardDAO.countPendingSupplierDebts());
        request.setAttribute("pendingSupplierDebtAmount", formatCurrencyVi(dashboardDAO.getPendingSupplierDebtAmount()));
        request.setAttribute("openRTVCount", dashboardDAO.countOpenRTVCases());
        request.setAttribute("unreadNotificationCount",
                user == null ? 0 : dashboardDAO.countUnreadNotifications(user.getUserID()));
        request.setAttribute("recentLogs", systemLogDAO.getWarehouseStaffLogs(5));

        request.setAttribute("staffProductCatalogCount", dashboardDAO.countActiveProductsInCatalog());
        request.setAttribute("staffTotalSalesRevenueFormatted",
                formatCurrencyVi(dashboardDAO.getTotalCompletedStockOutRevenue()));
        request.setAttribute("staffTotalSoldUnits", dashboardDAO.getTotalSoldUnitsFromStockOut());
        request.setAttribute("staffHomeFeed", dashboardDAO.getWarrantyAndReturnFeed(80));
    }

    private String formatCurrencyVi(double amount) {
        NumberFormat formatter = NumberFormat.getInstance(new Locale("vi", "VN"));
        formatter.setMaximumFractionDigits(0);
        return formatter.format(amount) + " đ";
    }

    private boolean ensureStaff(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 1) {
            response.sendRedirect("login");
            return false;
        }
        return true;
    }

    private Integer tryParseInt(String s) {
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
