<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="model.User" %>
<% User acc = (User) session.getAttribute("acc"); %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Danh sách sản phẩm - S.I.M</title>
        <style>
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
            .btn {
                padding: 8px 15px;
                border-radius: 6px;
                border: none;
                cursor: pointer;
                text-decoration: none;
                font-size: 13px;
                font-weight: 600;
            }
            .btn-info {
                background: #3b82f6;
                color: #fff;
            }
            .money {
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="layout">
            <aside class="sidebar">
                <div class="logo">S.I.M</div>
                <div class="user-box">Xin chào: <b><%= acc != null ? acc.getUsername() : "" %></b></div>
                <ul class="menu">
                    <li><a href="dashboard">Trang chủ</a></li>
                    <li><a class="active" href="products">Sản phẩm</a></li>
                    <li><a href="pos">Bán hàng</a></li>
                    <li><a href="orders">Lịch sử đơn hàng</a></li>
                    <li><a href="customers">Khách hàng</a></li>
                    <li><a href="logout">Đăng xuất</a></li>
                </ul>
            </aside>
            <main class="main">
                <div class="topbar"><h2>Quản lý sản phẩm</h2></div>
                <div class="content">
                    <div class="card">
                        <div style="display:flex; justify-content: space-between; margin-bottom: 20px;">
                            <form action="products" method="get" style="display:flex; gap:10px; flex:1;">
                                <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo tên hoặc SKU..." style="padding:10px; border:1px solid #ddd; border-radius:8px; flex:0.5;">
                                <button class="btn btn-info" type="submit">Tìm kiếm</button>
                            </form>
                        </div>
                        <table>
                            <thead>
                                <tr>
                                    <th>SKU</th>
                                    <th>Tên sản phẩm</th>
                                    <th>Giá bán</th>
                                    <th>Tồn kho</th>
                                    <th>Đơn vị</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${products}" var="p">
                                    <tr>
                                        <td><b>${p.sku}</b></td>
                                        <td>${p.name}</td>
                                        <td class="money"><fmt:formatNumber value="${p.price}" type="number"/> đ</td>
                                        <td>${p.quantity}</td>
                                        <td>${p.unit}</td>
                                        <td>
                                            <a href="productDetail?id=${p.id}" class="btn btn-info">Xem chi tiết</a>
                                        </td>
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