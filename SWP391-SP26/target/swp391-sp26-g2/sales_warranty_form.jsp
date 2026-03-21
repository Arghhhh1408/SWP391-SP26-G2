<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tạo yêu cầu bảo hành</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f4f6f9; margin: 0; }
        .wrap { max-width: 900px; margin: 24px auto; background: #fff; border: 1px solid #ddd; border-radius: 8px; }
        .head { padding: 16px 20px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
        .content { padding: 20px; }
        .row { margin-bottom: 14px; }
        label { display: block; font-weight: 600; margin-bottom: 6px; }
        input, textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 6px; font-size: 14px; }
        textarea { min-height: 110px; resize: vertical; }
        .actions { margin-top: 16px; display: flex; gap: 10px; }
        .btn { padding: 10px 14px; border-radius: 6px; border: 0; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-primary { background: #1a1a2e; color: #fff; }
        .btn-secondary { background: #e9ecef; color: #111; }
        .error { margin-bottom: 14px; color: #b42318; background: #fef3f2; border: 1px solid #fecdca; padding: 10px; border-radius: 6px; }
    </style>
</head>
<body>
<div class="wrap">
    <div class="head">
        <h2>Tạo yêu cầu bảo hành</h2>
        <a href="sales_dashboard">Về trang Sales</a>
    </div>
    <div class="content">
        <% if (request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="sales-warranty-create" method="post">
            <div class="row">
                <label for="sku">SKU (*)</label>
                <input id="sku" name="sku" required value="<%= request.getAttribute("sku") == null ? "" : request.getAttribute("sku") %>">
            </div>

            <div class="row">
                <label for="productName">Tên sản phẩm</label>
                <input id="productName" name="productName" value="<%= request.getAttribute("productName") == null ? "" : request.getAttribute("productName") %>">
            </div>

            <div class="row">
                <label for="customerName">Tên khách hàng (*)</label>
                <input id="customerName" name="customerName" required value="<%= request.getAttribute("customerName") == null ? "" : request.getAttribute("customerName") %>">
            </div>

            <div class="row">
                <label for="customerPhone">Số điện thoại khách hàng</label>
                <input id="customerPhone" name="customerPhone" value="<%= request.getAttribute("customerPhone") == null ? "" : request.getAttribute("customerPhone") %>">
            </div>

            <div class="row">
                <label for="issueDescription">Mô tả lỗi (*)</label>
                <textarea id="issueDescription" name="issueDescription" required><%= request.getAttribute("issueDescription") == null ? "" : request.getAttribute("issueDescription") %></textarea>
            </div>

            <div class="actions">
                <button type="submit" class="btn btn-primary">Gửi yêu cầu bảo hành</button>
                <a class="btn btn-secondary" href="sales-warranty-lookup">Tra cứu bảo hành</a>
            </div>
        </form>
    </div>
</div>
</body>
</html>
