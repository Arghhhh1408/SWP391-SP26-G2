<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.WarrantyLookupResult" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tra cứu bảo hành</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f4f6f9; margin: 0; }
        .wrap { max-width: 1100px; margin: 24px auto; background: #fff; border: 1px solid #ddd; border-radius: 8px; }
        .head { padding: 16px 20px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
        .content { padding: 20px; }
        .toolbar { display: flex; justify-content: space-between; gap: 12px; margin-bottom: 16px; }
        .toolbar form { display: flex; gap: 8px; flex: 1; }
        .toolbar input { flex: 1; padding: 9px 10px; border: 1px solid #ccc; border-radius: 6px; }
        .btn { padding: 9px 12px; border-radius: 6px; border: 0; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-primary { background: #1a1a2e; color: #fff; }
        .btn-secondary { background: #e9ecef; color: #111; }
        .ok { margin-bottom: 12px; color: #0f5132; background: #d1e7dd; border: 1px solid #badbcc; padding: 10px; border-radius: 6px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #e5e7eb; padding: 10px; font-size: 14px; text-align: left; }
        th { background: #f8fafc; }
        .muted { color: #666; font-size: 13px; }
    </style>
</head>
<body>
<div class="wrap">
    <div class="head">
        <h2>Tra cứu bảo hành</h2>
        <a href="sales_dashboard">Về trang Sales</a>
    </div>
    <div class="content">
        <% if (request.getAttribute("created") != null) { %>
            <div class="ok">Đã tạo yêu cầu bảo hành thành công: <strong><%= request.getAttribute("created") %></strong></div>
        <% } %>

        <div class="toolbar">
            <form action="sales-warranty-lookup" method="get">
                <input type="text" name="q" placeholder="Nhập StockOutID (mã phiếu xuất)"
                       value="<%= request.getAttribute("q") == null ? "" : request.getAttribute("q") %>">
                <button class="btn btn-primary" type="submit">Tìm</button>
            </form>
        </div>

        <%
            String error = (String) request.getAttribute("error");
            if (error != null && !error.isBlank()) {
        %>
                <div class="muted" style="color:#b42318; background:#fef3f2; border:1px solid #fecdca; padding:10px; border-radius:6px; margin-bottom:12px;">
                    <%= error %>
                </div>
        <%
            }

            List<WarrantyLookupResult> warrantyResults = (List<WarrantyLookupResult>) request.getAttribute("warrantyResults");
            Object stockOutIdObj = request.getAttribute("stockOutId");
            String stockOutIdStr = stockOutIdObj == null ? "" : String.valueOf(stockOutIdObj);

            if (warrantyResults == null || warrantyResults.isEmpty()) {
        %>
            <div class="muted">Chưa có kết quả. Vui lòng nhập StockOutID để tra cứu.</div>
        <%
            } else {
        %>
            <table>
                <tr>
                    <th>StockOutID</th>
                    <th>SKU</th>
                    <th>Sản phẩm</th>
                    <th>Khách hàng</th>
                    <th>SĐT</th>
                    <th>Ngày bán</th>
                    <th>Hết hạn</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
                <% for (WarrantyLookupResult r : warrantyResults) { %>
                    <tr>
                        <td><%= stockOutIdStr %></td>
                        <td><%= r.getProductCode() == null ? "" : r.getProductCode() %></td>
                        <td><%= r.getProductName() == null ? "" : r.getProductName() %></td>
                        <td><%= r.getCustomerName() == null ? "" : r.getCustomerName() %></td>
                        <td><%= r.getCustomerPhone() == null ? "" : r.getCustomerPhone() %></td>
                        <td><%= r.getPurchaseDate() == null ? "" : r.getPurchaseDate() %></td>
                        <td><%= r.getWarrantyEndDate() == null ? "" : r.getWarrantyEndDate() %></td>
                        <td><%= r.getStatus() == null ? "" : r.getStatus() %></td>
                        <td>
                            <% if ("Còn bảo hành".equals(r.getStatus())) { %>
                                <a class="btn btn-primary" style="padding:6px 10px; border-radius:6px;" href="sales-warranty-create?stockOutId=<%= stockOutIdStr %>&sku=<%= r.getProductCode() %>">Tạo</a>
                            <% } else { %>
                                <span style="color:#999;">Không còn</span>
                            <% } %>
                        </td>
                    </tr>
                <% } %>
            </table>
        <% } %>
    </div>
</div>
</body>
</html>
