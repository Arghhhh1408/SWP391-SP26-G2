<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tra cứu bảo hành</title>
    <style>
        body { font-family: 'Segoe UI', system-ui, sans-serif; background: #f1f5f9; margin: 0; }
        .wl-page-wrap { max-width: 1100px; margin: 24px auto; padding: 0 16px; }
        .wl-page-head {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 20px;
        }
        .wl-page-head h1 { margin: 0; font-size: 22px; color: #0f172a; }
        .wl-page-head a { color: #2563eb; text-decoration: none; font-size: 14px; }
        .wl-card {
            background: #fff;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }
    </style>
</head>
<body>
<div class="wl-page-wrap">
    <div class="wl-page-head">
        <h1>Tra cứu bảo hành</h1>
        <a href="${pageContext.request.contextPath}/sales_dashboard">← Về Sales</a>
    </div>
    <div class="wl-card wl-panel">
        <c:set var="warrantyUiEmbed" value="${false}" scope="request"/>
        <jsp:include page="warranty_lookup_panel.jsp"/>
    </div>
</div>
</body>
</html>
