<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="model.User" %>
<% User acc = (User) session.getAttribute("acc"); %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Khách hàng - S.I.M</title>
        <style>
            /* CSS đồng bộ y hệt các trang trên */
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
            }
            .content {
                padding: 25px;
            }
            .card {
                background: #fff;
                border-radius: 12px;
                padding: 20px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
                border: 1px solid #e5e7eb;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th {
                background: #f9fafb;
                padding: 12px;
                text-align: left;
                font-size: 13px;
                border-bottom: 2px solid #e5e7eb;
            }
            td {
                padding: 12px;
                border-bottom: 1px solid #f3f4f6;
                font-size: 14px;
            }
            .debt-red {
                color: #dc2626;
                font-weight: bold;
            }
            .link {
                color: #3b82f6;
                text-decoration: none;
                font-weight: 600;
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
                    <li><a href="${pageContext.request.contextPath}/products">Sản phẩm</a></li>
                    <li><a href="${pageContext.request.contextPath}/pos">Bán hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
                    <li><a class="active" href="${pageContext.request.contextPath}/customers">Khách hàng</a></li>
                    <li><a href="account">Tài khoản</a></li>
                    <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                </ul>
            </aside>
            <main class="main">
                <div class="topbar"><h2>Quản lý Khách hàng</h2></div>
                <div class="content">
                    <div class="card">
                        <table>
                            <thead><tr><th>ID</th><th>Tên khách</th><th>SĐT</th><th>Địa chỉ</th><th>Nợ hiện tại</th><th>Hành động</th></tr></thead>
                            <tbody>
                                <c:forEach items="${customers}" var="c">
                                    <tr>
                                        <td>${c.customerId}</td>
                                        <td><b>${c.name}</b></td>
                                        <td>${c.phone}</td>
                                        <td>${c.address}</td>
                                        <td class="debt-red"><fmt:formatNumber value="${c.debt}" type="number"/> đ</td>
                                        <td><a class="link" href="${pageContext.request.contextPath}/customerDetail?id=${c.customerId}">Xem chi tiết</a></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>
    </body>
</html>