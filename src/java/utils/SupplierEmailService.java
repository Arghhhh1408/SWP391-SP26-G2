package utils;

import dao.SupplierDAO;
import dao.SupplierDebtDAO;
import dao.SupplierUpdateRequestDAO;
import dao.UserDAO;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import model.ReturnReplacementReceipt;
import model.ReturnToVendor;
import model.ReturnToVendorDetail;
import model.StockInDetail;
import model.Supplier;
import model.SupplierDebt;
import model.SupplierUpdateRequest;
import model.User;

public class SupplierEmailService {

    private static final DecimalFormat MONEY = new DecimalFormat("#,##0.##");

    public String createVerificationToken() {
        return UUID.randomUUID().toString().replace("-", "");
    }

    public boolean sendSupplierVerificationEmail(Supplier supplier, String baseUrl) {
        if (supplier == null || supplier.getEmail() == null || supplier.getEmail().trim().isEmpty()) {
            return false;
        }
        SupplierDAO supplierDAO = new SupplierDAO();
        String token = createVerificationToken();
        if (!supplierDAO.issueVerificationToken(supplier.getId(), token)) {
            return false;
        }
        String verifyUrl = baseUrl + "/supplier-email?action=confirm&token=" + token;
        String html = "<h2>Xác nhận email nhà cung cấp</h2>"
                + "<p>Xin chào <strong>" + esc(supplier.getSupplierName()) + "</strong>,</p>"
                + "<p>Vui lòng bấm nút bên dưới để xác nhận email và kích hoạt nhà cung cấp cho các nghiệp vụ trong hệ thống.</p>"
                + button(verifyUrl, "Xác nhận nhà cung cấp")
                + "<p>Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email.</p>";
        AsyncMailDispatcher.sendHtmlAsync(supplier.getEmail(), "Xác nhận email nhà cung cấp", wrap(html));
        return true;
    }

    public boolean sendSupplierUpdateApprovalEmail(Supplier currentSupplier, SupplierUpdateRequest req, String baseUrl) {
        if (currentSupplier == null || req == null) return false;
        String recipient = currentSupplier.getEmail();
        if (recipient == null || recipient.trim().isEmpty()) {
            recipient = req.getPendingEmail();
        }
        if (recipient == null || recipient.trim().isEmpty()) {
            return false;
        }
        String approveUrl = baseUrl + "/supplier-update-approval?action=approve&token=" + req.getRequestToken();
        String rejectUrl = baseUrl + "/supplier-update-approval?action=reject&token=" + req.getRequestToken();
        String html = "<h2>Yêu cầu cập nhật thông tin nhà cung cấp</h2>"
                + "<p>Hệ thống nhận được yêu cầu cập nhật thông tin cho nhà cung cấp <strong>" + esc(currentSupplier.getSupplierName()) + "</strong>.</p>"
                + "<ul>"
                + li("Tên mới", req.getPendingName())
                + li("Điện thoại mới", req.getPendingPhone())
                + li("Địa chỉ mới", req.getPendingAddress())
                + li("Email mới", req.getPendingEmail())
                + li("Trạng thái", req.isPendingIsActive() ? "Hoạt động" : "Ngừng hoạt động")
                + "</ul>"
                + button(approveUrl, "Chấp nhận cập nhật")
                + "&nbsp;"
                + button(rejectUrl, "Từ chối cập nhật")
                + "<p>Nếu bạn không yêu cầu thay đổi này, vui lòng chọn từ chối.</p>";
        AsyncMailDispatcher.sendHtmlAsync(recipient, "Xác nhận cập nhật thông tin nhà cung cấp", wrap(html));
        return true;
    }

    public SupplierUpdateRequest createSupplierUpdateRequest(int supplierId, int requestedBy,
            String name, String phone, String address, String email, boolean isActive) {
        SupplierUpdateRequestDAO dao = new SupplierUpdateRequestDAO();
        SupplierUpdateRequest req = new SupplierUpdateRequest();
        req.setSupplierID(supplierId);
        req.setRequestedBy(requestedBy);
        req.setPendingName(name);
        req.setPendingPhone(phone);
        req.setPendingAddress(address);
        req.setPendingEmail(email);
        req.setPendingIsActive(isActive);
        req.setRequestToken(createVerificationToken());
        return dao.createRequest(req) ? dao.getByToken(req.getRequestToken()) : null;
    }

    public void sendStockInCreatedEmail(Supplier supplier, int stockInId, List<StockInDetail> details, double total, double paidNow, String paymentStatus) {
        if (!canSend(supplier)) return;
        StringBuilder items = new StringBuilder();
        for (StockInDetail d : details) {
            items.append("<tr><td>").append(d.getProductId()).append("</td><td>")
                    .append(esc(d.getProductName() != null ? d.getProductName() : "SP#" + d.getProductId()))
                    .append("</td><td>").append(d.getQuantity())
                    .append("</td><td>").append(MONEY.format(d.getUnitCost()))
                    .append("</td><td>").append(MONEY.format(d.getQuantity() * d.getUnitCost())).append("</td></tr>");
        }
        String html = "<h2>Phiếu nhập hàng mới #" + stockInId + "</h2>"
                + "<p>Nhà cung cấp <strong>" + esc(supplier.getSupplierName()) + "</strong> vui lòng kiểm tra phiếu nhập hàng vừa được tạo.</p>"
                + tableHeader("Mã SP", "Tên sản phẩm", "Số lượng", "Đơn giá", "Thành tiền") + items + "</table>"
                + summary("Tổng tiền", MONEY.format(total))
                + summary("Thanh toán ban đầu", MONEY.format(paidNow))
                + summary("Trạng thái thanh toán", paymentStatus);
        AsyncMailDispatcher.sendHtmlAsync(supplier.getEmail(), "Phiếu nhập hàng mới #" + stockInId, wrap(html));
    }

    public void sendReturnApprovedEmail(Supplier supplier, ReturnToVendor rtv, List<ReturnToVendorDetail> details) {
        if (!canSend(supplier) || rtv == null) return;
        String settlement = rtv.getSettlementType() == null ? "OFFSET_DEBT" : rtv.getSettlementType();
        StringBuilder rows = new StringBuilder();
        for (ReturnToVendorDetail d : details) {
            rows.append("<tr><td>").append(esc(d.getProductName() != null ? d.getProductName() : ("SP#" + d.getProductID()))).append("</td>")
                    .append("<td>").append(d.getQuantity()).append("</td><td>").append(MONEY.format(d.getUnitCost())).append("</td>")
                    .append("<td>").append(MONEY.format(d.getLineTotal())).append("</td></tr>");
        }
        String settlementText = switch (settlement.toUpperCase()) {
            case "REPLACEMENT" -> "Đổi trả hàng lỗi";
            case "REFUND" -> "Đền bù / Refund";
            default -> "Cấn trừ công nợ";
        };
        String html = "<h2>Phiếu trả nhà cung cấp đã được duyệt</h2>"
                + summary("Mã phiếu", esc(rtv.getReturnCode()))
                + summary("Phương thức xử lý", settlementText)
                + summary("Tổng tiền", MONEY.format(rtv.getTotalAmount()))
                + tableHeader("Sản phẩm", "Số lượng", "Đơn giá", "Thành tiền") + rows + "</table>";
        AsyncMailDispatcher.sendHtmlAsync(supplier.getEmail(), "Phiếu trả NCC đã được duyệt - " + rtv.getReturnCode(), wrap(html));
    }

    public void sendSupplierDebtReminders(Collection<String> managerEmails, SupplierDebt debt, String supplierName) {
        if (managerEmails == null || managerEmails.isEmpty() || debt == null) return;
        String html = "<h2>Cảnh báo công nợ nhà cung cấp sắp đến hạn</h2>"
                + summary("Nhà cung cấp", esc(supplierName))
                + summary("Debt ID", String.valueOf(debt.getDebtID()))
                + summary("StockIn ID", String.valueOf(debt.getStockInID()))
                + summary("Số tiền còn nợ", MONEY.format(debt.getAmount()))
                + summary("Hạn thanh toán", String.valueOf(debt.getDueDate()));
        AsyncMailDispatcher.sendHtmlAsync(managerEmails, "Nhắc công nợ nhà cung cấp sắp đến hạn", wrap(html));
    }

    public void sendSupplierUpdateResultMail(Supplier supplier, boolean approved) {
        if (!canSend(supplier)) return;
        String html = approved
                ? "<h2>Thông tin nhà cung cấp đã được cập nhật</h2><p>Yêu cầu cập nhật thông tin của bạn đã được áp dụng thành công.</p>"
                : "<h2>Yêu cầu cập nhật thông tin đã bị từ chối</h2><p>Hệ thống giữ nguyên thông tin cũ của nhà cung cấp.</p>";
        AsyncMailDispatcher.sendHtmlAsync(supplier.getEmail(), approved ? "Cập nhật thông tin nhà cung cấp thành công" : "Yêu cầu cập nhật nhà cung cấp bị từ chối", wrap(html));
    }

    private boolean canSend(Supplier supplier) {
        return supplier != null && supplier.getEmail() != null && !supplier.getEmail().trim().isEmpty() && supplier.isEmailVerified();
    }

    private String wrap(String body) {
        return "<div style='font-family:Arial,sans-serif;max-width:760px;margin:auto;padding:24px'>" + body + "</div>";
    }

    private String button(String href, String label) {
        return "<p><a href='" + href + "' style='display:inline-block;padding:12px 18px;background:#2563eb;color:#fff;text-decoration:none;border-radius:8px'>" + label + "</a></p>";
    }

    private String tableHeader(String... cols) {
        StringBuilder sb = new StringBuilder("<table border='1' cellspacing='0' cellpadding='8' style='border-collapse:collapse;width:100%;margin-top:12px'><tr style='background:#f3f4f6'>");
        for (String c : cols) sb.append("<th>").append(c).append("</th>");
        sb.append("</tr>");
        return sb.toString();
    }

    private String summary(String label, String value) {
        return "<p><strong>" + label + ":</strong> " + esc(value) + "</p>";
    }

    private String li(String label, String value) {
        return "<li><strong>" + label + ":</strong> " + esc(value) + "</li>";
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
}
