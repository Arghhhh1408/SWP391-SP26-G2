<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.WarrantyClaim" %>
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
                <input type="text" name="q" placeholder="Tìm theo mã yêu cầu / SKU / khách hàng / SĐT"
                       value="<%= request.getAttribute("q") == null ? "" : request.getAttribute("q") %>">
                <button class="btn btn-primary" type="submit">Tìm</button>
            </form>
            <a class="btn btn-secondary" href="sales-warranty-create">Tạo yêu cầu bảo hành</a>
        </div>

        <%
            List<WarrantyClaim> claims = (List<WarrantyClaim>) request.getAttribute("claims");
            if (claims == null || claims.isEmpty()) {
        %>
            <div class="muted">Chưa có yêu cầu bảo hành nào.</div>
        <%
            } else {
        %>
            <table>
                <tr>
                    <th>Mã yêu cầu</th>
                    <th>SKU</th>
                    <th>Sản phẩm</th>
                    <th>Khách hàng</th>
                    <th>SĐT</th>
                    <th>Trạng thái</th>
                    <th>Cập nhật</th>
                </tr>
                <% for (WarrantyClaim c : claims) { %>
                    <tr>
                        <td><%= c.getClaimCode() %></td>
                        <td><%= c.getSku() == null ? "" : c.getSku() %></td>
                        <td><%= c.getProductName() == null ? "" : c.getProductName() %></td>
                        <td><%= c.getCustomerName() == null ? "" : c.getCustomerName() %></td>
                        <td><%= c.getCustomerPhone() == null ? "" : c.getCustomerPhone() %></td>
                        <td><%= c.getStatus() == null ? "" : c.getStatus().name() %></td>
                        <td><%= c.getUpdatedAt() == null ? "" : c.getUpdatedAt() %></td>
                    </tr>
                <% } %>
            </table>
        <% } %>
    </div>
</div>
</body>
</html>
