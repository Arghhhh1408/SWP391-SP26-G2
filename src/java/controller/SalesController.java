package controller;

import dao.OrderHistoryDAO;
import dao.ProductDAO;
import dao.ReturnDAO;
import dao.WarrantyClaimDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OrderHistory;
import model.Product;
import model.ReturnRequest;
import model.User;
import model.WarrantyClaim;

@WebServlet(name = "SalesController", urlPatterns = {"/sales_dashboard"})
public class SalesController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureSales(request, response)) {
            return;
        }
        ProductDAO pDao = new ProductDAO();
        String tab = safeTrim(request.getParameter("tab"));
        if (tab == null || tab.isEmpty()) {
            tab = "dashboard";
        }
        request.setAttribute("tab", tab);

        try {
            if ("dashboard".equals(tab)) {
                // 1. Khởi tạo các DAO cần thiết
                dao.DashboardDAO ddao = new dao.DashboardDAO();
                dao.BusinessReportDAO reportDao = new dao.BusinessReportDAO(); // Khởi tạo thêm cái này

                // 2. Lấy các con số doanh thu (Giữ nguyên của bạn)
                request.setAttribute("revenueToday", ddao.getRevenueToday());
                request.setAttribute("revenueWeek", ddao.getRevenueWeek());
                request.setAttribute("revenueMonth", ddao.getRevenueMonth());

                // 3. LẤY DỮ LIỆU TOP BÁN CHẠY (MỚI)
                // Gọi hàm từ BusinessReportDAO mà bạn vừa tạo, lấy top 5 sản phẩm
                List<model.TopProductSales> topSelling = reportDao.topProductsLast30Days(5);
                request.setAttribute("topSellingProducts", topSelling);

                // 4. Lấy sản phẩm tồn kho thấp (Giữ nguyên của bạn)
                request.setAttribute("lowStockProducts", pDao.getLowStockProducts(5));
            } else if ("pos".equals(tab)) {
                try {
                    // 1. Lấy tham số tìm kiếm và lọc từ JSP gửi lên
                    String keyword = safeTrim(request.getParameter("keyword"));
                    String sort = safeTrim(request.getParameter("sort"));
                    String range = safeTrim(request.getParameter("range"));

                    // 2. Gọi hàm tìm kiếm sản phẩm (keyword, sort, range)
                    List<Product> list = pDao.searchProducts(keyword, sort, range);

                    // 3. Gửi lại dữ liệu cho JSP hiển thị
                    request.setAttribute("products", list);
                    request.setAttribute("keyword", keyword);
                    request.setAttribute("sort", sort);
                    request.setAttribute("range", range);

                    // Lấy danh sách khách hàng để hỗ trợ JS tìm SĐT
                    dao.CustomerDAO cDao = new dao.CustomerDAO();
                    request.setAttribute("customers", cDao.getAllCustomers(""));
                } catch (Exception e) {
                    e.printStackTrace();
                }

            } else if ("products".equals(tab)) {
                // Phần xem danh sách sản phẩm (Cường/Lý dùng chung)
                request.setAttribute("salesProducts", pDao.getAllProducts());

            } else if ("warranty-lookup".equals(tab)) {
                // PHẦN CỦA CƯỜNG: Phải lấy dữ liệu claims thì bảng mới hiện
                WarrantyClaimDAO wDao = new WarrantyClaimDAO();
                String q = safeTrim(request.getParameter("q"));
                request.setAttribute("q", q);
                request.setAttribute("claims", wDao.listByCreator(getActor(request), q));

            } else if ("return-lookup".equals(tab)) {
                // PHẦN CỦA CƯỜNG: Phải lấy dữ liệu returns thì bảng mới hiện
                ReturnDAO rDao = new ReturnDAO();
                String rq = safeTrim(request.getParameter("rq"));
                request.setAttribute("rq", rq);
                request.setAttribute("returnClaims", rDao.listByCreator(getActor(request), rq));
            } else if ("orders".equals(tab)) {
                String keyword = request.getParameter("orderSearch"); // Lấy từ ô input trong JSP
                OrderHistoryDAO dao = new OrderHistoryDAO();
                List<OrderHistory> list;

                if (keyword != null && !keyword.trim().isEmpty()) {
                    // Nếu có nhập từ khóa, gọi hàm search
                    list = dao.searchOrders(keyword.trim(), "new");
                } else {
                    // Nếu không, hiện tất cả như bình thường
                    list = dao.getAllOrders("new");
                }

                request.setAttribute("orders", list);
                request.setAttribute("orderSearch", keyword); // Gửi lại keyword để hiện trên ô nhập
            } else if ("customers".equals(tab)) {
                String q = request.getParameter("orderSearch"); // Tận dụng ô search chung
                dao.CustomerDAO customerDAO = new dao.CustomerDAO();

                // Gọi hàm getAllCustomers(keyword) từ file DAO bạn vừa gửi
                List<model.Customer> customerList = customerDAO.getAllCustomers(q);

                request.setAttribute("customerList", customerList);
            }

        } catch (Exception e) {
            e.printStackTrace(); // Quan trọng: xem lỗi cụ thể ở Console nếu bị trắng trang
            request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
        }

        // LUÔN LUÔN forward về trang chính dù là tab nào
        request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ensureSales(request, response)) {
            return;
        }

        String action = safeTrim(request.getParameter("action"));
        if (action == null || action.isEmpty()) {
            action = "";
        }

        switch (action) {
            case "createWarranty" ->
                handleCreateWarranty(request, response);
            case "createReturn" ->
                handleCreateReturn(request, response);
            default ->
                response.sendRedirect("sales_dashboard");
        }
    }

    private void handleCreateWarranty(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String sku = safeTrim(request.getParameter("sku"));
        String productName = safeTrim(request.getParameter("productName"));
        String customerName = safeTrim(request.getParameter("customerName"));
        String customerPhone = safeTrim(request.getParameter("customerPhone"));
        String issue = safeTrim(request.getParameter("issueDescription"));

        request.setAttribute("tab", "warranty-create");
        request.setAttribute("sku", sku);
        request.setAttribute("productName", productName);
        request.setAttribute("customerName", customerName);
        request.setAttribute("customerPhone", customerPhone);
        request.setAttribute("issueDescription", issue);

        if (sku == null || sku.isEmpty()) {
            request.setAttribute("error", "SKU là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }
        if (customerName == null || customerName.isEmpty()) {
            request.setAttribute("error", "Tên khách hàng là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }
        if (issue == null || issue.isEmpty()) {
            request.setAttribute("error", "Mô tả lỗi là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }

        WarrantyClaimDAO dao = new WarrantyClaimDAO();
        WarrantyClaim claim = dao.create(sku, productName, customerName, customerPhone, issue, getActor(request));
        if (claim == null) {
            request.setAttribute("error", "Không thể tạo yêu cầu bảo hành, vui lòng kiểm tra dữ liệu hoặc DB.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }

        response.sendRedirect("sales_dashboard?tab=warranty-lookup&created=" + claim.getClaimCode());
    }

    private void handleCreateReturn(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String sku = safeTrim(request.getParameter("returnSku"));
        String productName = safeTrim(request.getParameter("returnProductName"));
        String customerName = safeTrim(request.getParameter("returnCustomerName"));
        String customerPhone = safeTrim(request.getParameter("returnCustomerPhone"));
        String reason = safeTrim(request.getParameter("returnReason"));
        String conditionNote = safeTrim(request.getParameter("returnConditionNote"));

        request.setAttribute("tab", "return-create");
        request.setAttribute("returnSku", sku);
        request.setAttribute("returnProductName", productName);
        request.setAttribute("returnCustomerName", customerName);
        request.setAttribute("returnCustomerPhone", customerPhone);
        request.setAttribute("returnReason", reason);
        request.setAttribute("returnConditionNote", conditionNote);

        if (sku == null || sku.isEmpty()) {
            request.setAttribute("error", "SKU là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }
        if (customerName == null || customerName.isEmpty()) {
            request.setAttribute("error", "Tên khách hàng là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }
        if (reason == null || reason.isEmpty()) {
            request.setAttribute("error", "Lý do trả hàng là bắt buộc.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }

        ReturnDAO dao = new ReturnDAO();
        ReturnRequest rr = dao.create(sku, productName, customerName, customerPhone, reason, conditionNote, getActor(request));
        if (rr == null) {
            request.setAttribute("error", "Không thể tạo yêu cầu trả hàng, vui lòng kiểm tra dữ liệu hoặc DB.");
            request.getRequestDispatcher("sales_dashboard.jsp").forward(request, response);
            return;
        }

        response.sendRedirect("sales_dashboard?tab=return-lookup&returnCreated=" + rr.getReturnCode());
    }

    private boolean ensureSales(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User u = (User) session.getAttribute("acc");
        if (u == null || u.getRoleID() != 3) {
            response.sendRedirect("login");
            return false;
        }
        return true;
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
