<%@ page import="model.ReturnToVendor" %>
<%@ page import="model.ReturnToVendorDetail" %>
<%@ page import="model.ReturnReplacementReceipt" %>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Return To Vendor Detail</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 24px; background: #f4f6f9; }
        .container { max-width: 1250px; margin: auto; }
        .card { border: 1px solid #ddd; background: #fff; border-radius: 14px; padding: 18px; margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; background: white; }
        table, th, td { border: 1px solid #ddd; }
        th, td { padding: 10px; text-align: center; }
        .btn { padding: 10px 14px; border: none; cursor: pointer; border-radius: 10px; color: white; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 8px; }
        .approve { background: #16a34a; }
        .reject { background: #dc2626; }
        .complete { background: #2563eb; }
        .receive { background: #7c3aed; }
        .back { background: #6b7280; color: white; text-decoration: none; padding: 10px 14px; border-radius: 10px; display: inline-block; margin-bottom: 20px; }
        .msg { color: #166534; background: #dcfce7; border: 1px solid #86efac; padding: 12px 14px; border-radius: 10px; margin-bottom: 12px; }
        .error { color: #991b1b; background: #fee2e2; border: 1px solid #fca5a5; padding: 12px 14px; border-radius: 10px; margin-bottom: 12px; }
        textarea, input[type=text], input[type=number] { padding: 10px; border-radius: 8px; border: 1px solid #d1d5db; }
        textarea { width: 320px; height: 80px; margin-right: 8px; }
        .actions { display: flex; gap: 12px; flex-wrap: wrap; align-items: flex-start; }
        .muted { color: #6b7280; font-size: 14px; }
        .section-title { margin: 10px 0 12px; color: #1d4ed8; }
        .form-inline { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
    </style>
</head>
<body>
<div class="container">
<%
    ReturnToVendor rtv = (ReturnToVendor) request.getAttribute("rtv");
    List<ReturnReplacementReceipt> receipts = (List<ReturnReplacementReceipt>) request.getAttribute("replacementReceipts");
    User acc = (User) session.getAttribute("acc");
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
    String from = request.getParameter("from");
    boolean isManager = acc != null && (acc.getRoleID() == 0 || acc.getRoleID() == 2);
    boolean isWarehouse = acc != null && (acc.getRoleID() == 0 || acc.getRoleID() == 1);
    String backUrl = "return-to-vendor";
    String backLabel = "Back to list";
    if ("manager".equalsIgnoreCase(from) || (acc != null && acc.getRoleID() == 2)) {
        backUrl = "manager_dashboard?tab=vendorReturns";
        backLabel = "Back to manager approvals";
    }
%>
<a class="back" href="<%= backUrl %>"><%= backLabel %></a>
<% if (msg != null) { %><div class="msg">Success: <%= msg %></div><% } %>
<% if (error != null) { %><div class="error">Error: <%= error %></div><% } %>
<% if (rtv != null) { %>
<div class="card">
    <h2>Return To Vendor Detail</h2>
    <p><strong>RTVID:</strong> <%= rtv.getRtvID() %></p>
    <p><strong>Return Code:</strong> <%= rtv.getReturnCode() %></p>
    <p><strong>Supplier:</strong> <%= rtv.getSupplierName() != null ? rtv.getSupplierName() : rtv.getSupplierID() %></p>
    <p><strong>StockIn ID:</strong> <%= rtv.getStockInID() %></p>
    <p><strong>Status:</strong> <%= rtv.getStatus() %></p>
    <p><strong>Reason:</strong> <%= rtv.getReason() %></p>
    <p><strong>Note:</strong> <%= rtv.getNote() %></p>
    <p><strong>Settlement Type:</strong> <%= rtv.getSettlementType() %></p>
    <% if ("REPLACEMENT".equalsIgnoreCase(rtv.getSettlementType())) { %>
    <p><strong>Inventory Flow:</strong> Approved =&gt; trừ tồn kho lỗi ngay. Khi nhập lại hàng thay thế theo từng đợt, tồn kho sẽ được cộng lại tương ứng. Chỉ hoàn tất khi đã nhận đủ hàng thay thế.</p>
    <% } else if ("OFFSET_DEBT".equalsIgnoreCase(rtv.getSettlementType())) { %>
    <p><strong>Inventory Flow:</strong> Completed =&gt; trừ tồn kho và cấn trừ công nợ.</p>
    <% } else { %>
    <p><strong>Inventory Flow:</strong> Completed =&gt; trừ tồn kho, không phát sinh công nợ mới.</p>
    <% } %>
    <p><strong>Total Amount:</strong> <%= String.format("%,.2f", rtv.getTotalAmount()) %></p>
    <p><strong>Created Date:</strong> <%= rtv.getCreatedDate() %></p>
    <p><strong>Approved Date:</strong> <%= rtv.getApprovedDate() != null ? rtv.getApprovedDate() : "-" %></p>
    <p><strong>Completed Date:</strong> <%= rtv.getCompletedDate() != null ? rtv.getCompletedDate() : "-" %></p>
</div>

<table>
    <thead>
    <tr>
        <th>RTV Detail ID</th>
        <th>StockIn Detail ID</th>
        <th>StockIn ID</th>
        <th>Product</th>
        <th>Quantity</th>
        <th>UnitCost</th>
        <th>Line Total</th>
        <th>Reason Detail</th>
        <th>Condition</th>
        <% if ("REPLACEMENT".equalsIgnoreCase(rtv.getSettlementType())) { %>
        <th>Đã nhận thay thế</th>
        <th>Còn thiếu</th>
        <% } %>
    </tr>
    </thead>
    <tbody>
    <%
        List<ReturnToVendorDetail> details = rtv.getDetails();
        if (details != null && !details.isEmpty()) {
            for (ReturnToVendorDetail d : details) {
    %>
    <tr>
        <td><%= d.getRtvDetailID() %></td>
        <td><%= d.getStockInDetailID() %></td>
        <td><%= d.getStockInID() %></td>
        <td><%= d.getProductName() != null ? d.getProductName() : d.getProductID() %></td>
        <td><%= d.getQuantity() %></td>
        <td><%= String.format("%,.2f", d.getUnitCost()) %></td>
        <td><%= String.format("%,.2f", d.getLineTotal()) %></td>
        <td><%= d.getReasonDetail() != null ? d.getReasonDetail() : "-" %></td>
        <td><%= d.getItemCondition() != null ? d.getItemCondition() : "-" %></td>
        <% if ("REPLACEMENT".equalsIgnoreCase(rtv.getSettlementType())) { %>
        <td><%= d.getReplacementReceivedQuantity() %></td>
        <td><%= d.getReplacementRemainingQuantity() %></td>
        <% } %>
    </tr>
    <%      }
        } else { %>
    <tr><td colspan="11">No detail found.</td></tr>
    <% } %>
    </tbody>
</table>

<% if ("REPLACEMENT".equalsIgnoreCase(rtv.getSettlementType())) { %>
<div class="card">
    <h3 class="section-title">Theo dõi nhập hàng thay thế theo đợt</h3>
    <table>
        <thead>
        <tr>
            <th>RTV Detail ID</th>
            <th>Sản phẩm</th>
            <th>Số lượng cần thay</th>
            <th>Đã nhập lại</th>
            <th>Còn lại</th>
            <th>Thao tác</th>
        </tr>
        </thead>
        <tbody>
        <% if (details != null) {
            for (ReturnToVendorDetail d : details) { %>
            <tr>
                <td><%= d.getRtvDetailID() %></td>
                <td><%= d.getProductName() %></td>
                <td><%= d.getQuantity() %></td>
                <td><%= d.getReplacementReceivedQuantity() %></td>
                <td><%= d.getReplacementRemainingQuantity() %></td>
                <td>
                    <% if (isWarehouse && "Approved".equalsIgnoreCase(rtv.getStatus()) && d.getReplacementRemainingQuantity() > 0) { %>
                    <form action="return-to-vendor" method="post" class="form-inline">
                        <input type="hidden" name="action" value="addReplacementReceipt"/>
                        <input type="hidden" name="rtvID" value="<%= rtv.getRtvID() %>"/>
                        <input type="hidden" name="rtvDetailID" value="<%= d.getRtvDetailID() %>"/>
                        <% if (from != null) { %><input type="hidden" name="from" value="<%= from %>"/><% } %>
                        <input type="number" name="replacementQty" min="1" max="<%= d.getReplacementRemainingQuantity() %>" placeholder="SL nhập lại" required/>
                        <input type="text" name="replacementNote" placeholder="Ghi chú"/>
                        <button type="submit" class="btn receive">Nhập hàng thay thế</button>
                    </form>
                    <% } else if (d.getReplacementRemainingQuantity() <= 0) { %>
                    <span class="muted">Đã nhận đủ hàng thay thế</span>
                    <% } else { %>
                    <span class="muted">Không thể thao tác</span>
                    <% } %>
                </td>
            </tr>
        <% }} %>
        </tbody>
    </table>
</div>

<div class="card">
    <h3 class="section-title">Lịch sử nhập lại hàng thay thế</h3>
    <table>
        <thead><tr><th>Receipt ID</th><th>RTV Detail ID</th><th>Sản phẩm</th><th>Số lượng</th><th>Ghi chú</th><th>Người nhận</th><th>Thời gian</th></tr></thead>
        <tbody>
        <% if (receipts != null && !receipts.isEmpty()) {
            for (ReturnReplacementReceipt rr : receipts) { %>
            <tr>
                <td><%= rr.getReceiptID() %></td>
                <td><%= rr.getRtvDetailID() %></td>
                <td><%= rr.getProductName() %></td>
                <td><%= rr.getQuantity() %></td>
                <td><%= rr.getNote() != null ? rr.getNote() : "-" %></td>
                <td><%= rr.getReceivedByName() != null ? rr.getReceivedByName() : rr.getReceivedBy() %></td>
                <td><%= rr.getReceivedAt() %></td>
            </tr>
        <% }} else { %>
            <tr><td colspan="7">Chưa có đợt nhập lại nào.</td></tr>
        <% } %>
        </tbody>
    </table>
</div>
<% } %>

<br/>
<div class="actions">
    <% if (isManager && "Pending".equalsIgnoreCase(rtv.getStatus())) { %>
    <form action="return-to-vendor" method="post" style="display:inline;">
        <input type="hidden" name="action" value="approve"/>
        <input type="hidden" name="rtvID" value="<%= rtv.getRtvID() %>"/>
        <% if (from != null) { %><input type="hidden" name="from" value="<%= from %>"/><% } %>
        <button type="submit" class="btn approve">Approve</button>
    </form>
    <form action="return-to-vendor" method="post" style="display:inline-flex; align-items:flex-start; gap:8px; flex-wrap:wrap;">
        <input type="hidden" name="action" value="reject"/>
        <input type="hidden" name="rtvID" value="<%= rtv.getRtvID() %>"/>
        <% if (from != null) { %><input type="hidden" name="from" value="<%= from %>"/><% } %>
        <textarea name="rejectNote" placeholder="Enter reject reason" required></textarea>
        <button type="submit" class="btn reject">Reject</button>
    </form>
    <% } %>

    <% if (isWarehouse && "Approved".equalsIgnoreCase(rtv.getStatus())) { %>
    <form action="return-to-vendor" method="post" style="display:inline;">
        <input type="hidden" name="action" value="complete"/>
        <input type="hidden" name="rtvID" value="<%= rtv.getRtvID() %>"/>
        <% if (from != null) { %><input type="hidden" name="from" value="<%= from %>"/><% } %>
        <button type="submit" class="btn complete">Complete Return</button>
    </form>
    <% } %>

    <% if (!(isManager && "Pending".equalsIgnoreCase(rtv.getStatus())) && !(isWarehouse && "Approved".equalsIgnoreCase(rtv.getStatus()))) { %>
    <span class="muted">No available action for your role or current status.</span>
    <% } %>
</div>

<% } else { %>
<div class="error">Return record not found.</div>
<% } %>
</div>
</body>
</html>
