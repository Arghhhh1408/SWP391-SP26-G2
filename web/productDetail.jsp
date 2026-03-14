<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="model.User" %>
<% User acc = (User) session.getAttribute("acc"); %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết sản phẩm - ${product.name}</title>
        <style>
            /* CSS đồng bộ hệ thống */
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
                font-family: 'Segoe UI', Arial, sans-serif;
            }
            body {
                background: #f4f6f9;
                color: #1f2937;
            }
            .layout {
                display: flex;
                min-height: 100vh;
            }

            /* Sidebar */
            .sidebar {
                width: 240px;
                background: #1f2d3d;
                color: #fff;
                display: flex;
                flex-direction: column;
                flex-shrink: 0;
            }
            .logo {
                padding: 25px 20px;
                font-size: 24px;
                font-weight: bold;
                background: #1a2533;
                text-align: center;
                color: #3b82f6;
                letter-spacing: 2px;
            }
            .user-box {
                padding: 18px;
                border-bottom: 1px solid rgba(255,255,255,0.08);
                font-size: 14px;
                background: #263544;
            }
            .menu {
                list-style: none;
                padding: 10px 0;
                flex: 1;
            }
            .menu li a {
                display: block;
                padding: 14px 20px;
                color: #cbd5e1;
                text-decoration: none;
                transition: 0.3s;
            }
            .menu li a:hover, .menu li a.active {
                background: #374151;
                color: #fff;
                border-left: 4px solid #3b82f6;
            }

            /* Main Content */
            .main {
                flex: 1;
                display: flex;
                flex-direction: column;
            }
            .topbar {
                height: 64px;
                background: #fff;
                border-bottom: 1px solid #e5e7eb;
                display: flex;
                align-items: center;
                padding: 0 25px;
                justify-content: space-between;
            }
            .content {
                padding: 25px;
            }

            /* Product Detail Card */
            .card {
                background: #fff;
                border-radius: 12px;
                padding: 30px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
                border: 1px solid #e5e7eb;
                display: grid;
                grid-template-columns: 1fr 1.5fr;
                gap: 40px;
            }

            .product-image {
                background: #f9fafb;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                border: 1px solid #eee;
                overflow: hidden;
                min-height: 300px;
            }
            .product-image img {
                max-width: 100%;
                height: auto;
            }

            .product-info h1 {
                font-size: 28px;
                margin-bottom: 10px;
                color: #111827;
            }
            .sku-tag {
                display: inline-block;
                background: #e0e7ff;
                color: #4338ca;
                padding: 4px 10px;
                border-radius: 6px;
                font-size: 12px;
                font-weight: bold;
                margin-bottom: 20px;
            }

            .price-box {
                font-size: 32px;
                font-weight: bold;
                color: #3b82f6;
                margin-bottom: 25px;
            }

            .spec-table {
                width: 100%;
                margin-bottom: 30px;
            }
            .spec-table tr td {
                padding: 12px 0;
                border-bottom: 1px solid #f3f4f6;
            }
            .spec-label {
                color: #6b7280;
                width: 150px;
                font-weight: 500;
            }
            .spec-value {
                color: #111827;
                font-weight: 600;
            }

            .stock-status {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                font-weight: bold;
            }
            .in-stock {
                color: #10b981;
            }
            .out-of-stock {
                color: #ef4444;
            }

            .btn-group {
                display: flex;
                gap: 15px;
                margin-top: 20px;
            }
            .btn {
                padding: 12px 25px;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                font-weight: 600;
                text-decoration: none;
                font-size: 15px;
                transition: 0.2s;
            }
            .btn-primary {
                background: #3b82f6;
                color: #fff;
            }
            .btn-ghost {
                background: #f3f4f6;
                color: #374151;
            }
            .btn:hover {
                opacity: 0.9;
            }
        </style>
    </head>
    <body>
        <div class="layout">
            <aside class="sidebar">
                <div class="logo">S.I.M</div>
                <div class="user-box">Xin chào: <b><%= acc != null ? acc.getUsername() : "" %></b></div>
                <ul class="menu">
                    <li><a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a></li>
                    <li><a class="active" href="${pageContext.request.contextPath}/products">Sản phẩm</a></li>
                    <li><a href="${pageContext.request.contextPath}/pos">Bán hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/customers">Khách hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                </ul>
            </aside>

            <main class="main">
                <div class="topbar">
                    <h2>Chi tiết sản phẩm</h2>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-ghost" style="padding: 8px 15px;"> Quay lại</a>
                </div>

                <div class="content">
                    <div class="card">
                        <div class="product-image">
                            <c:choose>
                                <c:when test="${not empty product.imageURL}">
                                    <img src="${product.imageURL}" alt="${product.name}">
                                </c:when>
                                <c:otherwise>
                                    <span style="color: #9ca3af; font-size: 50px;">📦</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="product-info">
                            <span class="sku-tag">SKU: ${product.sku}</span>
                            <h1>${product.name}</h1>

                            <div class="price-box">
                                <fmt:formatNumber value="${product.price}" type="number"/> đ
                            </div>

                            <table class="spec-table">
                                <tr>
                                    <td class="spec-label">Trạng thái</td>
                                    <td class="spec-value">
                                        <c:choose>
                                            <c:when test="${product.quantity > 0}">
                                                <span class="stock-status in-stock">● Còn hàng (${product.quantity})</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="stock-status out-of-stock">● Hết hàng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="spec-label">Đơn vị tính</td>
                                    <td class="spec-value">${product.unit}</td>
                                </tr>
                                <tr>
                                    <td class="spec-label">Danh mục</td>
                                    <td class="spec-value">${product.categoryName}</td>
                                </tr>
                                <tr>
                                    <td class="spec-label">Mô tả</td>
                                    <td class="spec-value" style="font-weight: 400; line-height: 1.6;">${product.description}</td>
                                </tr>
                            </table>

                            <div class="btn-group">
                                <a href="${pageContext.request.contextPath}/pos" class="btn btn-primary">Bán mặt hàng này</a>
                                <a href="${pageContext.request.contextPath}/product/edit?id=${product.id}" class="btn btn-ghost">Chỉnh sửa thông tin</a>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </body>
</html>