<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="model.User" %>
<%
    User acc = (User) session.getAttribute("acc");
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Lịch sử đơn hàng - S.I.M</title>

        <style>
            /* CSS Đồng bộ hệ thống */
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

            /* Sidebar tối */
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

            /* Main Content sáng */
            .main {
                flex: 1;
                display: flex;
                flex-direction: column;
                overflow-x: hidden;
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
            .topbar h2 {
                font-size: 20px;
                font-weight: 600;
                color: #111827;
            }

            .content {
                padding: 25px;
            }

            /* Card & Filter */
            .card {
                background: #fff;
                border-radius: 12px;
                padding: 20px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
                border: 1px solid #e5e7eb;
            }

            .filters {
                display: flex;
                gap: 15px;
                flex-wrap: wrap;
                align-items: flex-end;
                margin-bottom: 20px;
                padding-bottom: 20px;
                border-bottom: 1px solid #f3f4f6;
            }
            .field {
                display: flex;
                flex-direction: column;
                gap: 5px;
            }
            .field label {
                font-size: 12px;
                font-weight: 600;
                color: #6b7280;
                text-transform: uppercase;
            }
            .field input, .field select {
                padding: 8px 12px;
                border: 1px solid #d1d5db;
                border-radius: 8px;
                font-size: 14px;
                outline: none;
                background: #fff;
            }
            .field input:focus {
                border-color: #3b82f6;
            }

            /* Button chuẩn */
            .btn {
                padding: 9px 16px;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                font-weight: 500;
                transition: 0.2s;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: 14px;
            }
            .btn-primary {
                background: #111827;
                color: #fff;
            }
            .btn-primary:hover {
                background: #374151;
            }
            .btn-ghost {
                background: #fff;
                color: #374151;
                border: 1px solid #d1d5db;
            }
            .btn-ghost:hover {
                background: #f9fafb;
            }

            /* Table đồng bộ */
            .table {
                width: 100%;
                border-collapse: collapse;
            }
            .table th {
                background: #f9fafb;
                padding: 12px 15px;
                text-align: left;
                font-size: 12px;
                font-weight: 600;
                color: #4b5563;
                text-transform: uppercase;
                border-bottom: 2px solid #e5e7eb;
            }
            .table td {
                padding: 12px 15px;
                border-bottom: 1px solid #f3f4f6;
                font-size: 14px;
            }
            .table tr:hover {
                background: #f9fafb;
            }

            .money {
                font-weight: bold;
                color: #111827;
                white-space: nowrap;
            }
            .muted {
                color: #6b7280;
                font-size: 13px;
            }
            .link {
                color: #3b82f6;
                text-decoration: none;
                font-weight: 600;
            }
            .link:hover {
                text-decoration: underline;
            }

            .empty {
                padding: 30px;
                border: 2px dashed #e5e7eb;
                border-radius: 12px;
                text-align: center;
                color: #6b7280;
                font-style: italic;
            }

            @media print {
                .sidebar, .topbar, .filters, .link {
                    display: none !important;
                }
                .main, .content, .card {
                    border: none;
                    box-shadow: none;
                    padding: 0;
                    margin: 0;
                }
                .table th {
                    background: #eee !important;
                    color: #000 !important;
                }
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
                    <li><a class="active" href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/customers">Khách hàng</a></li>
                    <li><a href="account">Tài khoản</a></li>
                    <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                </ul>
            </aside>

            <main class="main">
                <div class="topbar">
                    <h2>Lịch sử đơn hàng</h2>
                    <div class="muted">Hôm nay: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy" /></div>
                </div>

                <div class="content">
                    <div class="card">
                        <c:choose>
                            <c:when test="${empty orders}">
                                <div class="empty">Hệ thống chưa ghi nhận đơn hàng nào phù hợp.</div>
                            </c:when>

                            <c:otherwise>
                                <form method="get" action="${pageContext.request.contextPath}/orders" class="filters">
                                    <div class="field">
                                        <label>Thời gian</label>
                                        <select name="range">
                                            <option value="all"   ${param.range == 'all'   ? 'selected' : ''}>Tất cả thời gian</option>
                                            <option value="day"   ${param.range == 'day'   ? 'selected' : ''}>Hôm nay</option>
                                            <option value="week"  ${param.range == 'week'  ? 'selected' : ''}>Tuần này</option>
                                            <option value="month" ${param.range == 'month' ? 'selected' : ''}>Tháng này</option>
                                        </select>
                                    </div>

                                    <div class="field">
                                        <label>Sắp xếp</label>
                                        <select name="sort">
                                            <option value="new" ${sort == 'new' ? 'selected' : ''}>Mới nhất trước</option>
                                            <option value="old" ${sort == 'old' ? 'selected' : ''}>Cũ nhất trước</option>
                                        </select>
                                    </div>

                                    <div class="field">
                                        <label>Tìm kiếm nhanh</label>
                                        <input name="keyword" placeholder="Mã đơn hoặc SĐT..." value="${param.keyword}">
                                    </div>

                                    <button class="btn btn-primary" type="submit">Lọc dữ liệu</button>
                                    <a class="btn btn-ghost" href="${pageContext.request.contextPath}/orders">Làm mới</a>
                                </form>

                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Mã đơn</th>
                                            <th>Thời gian</th>
                                            <th>Khách hàng</th>
                                            <th>SĐT</th>
                                            <th>Tổng tiền</th>
                                            <th>Nhân viên</th>
                                            <th>Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${orders}" var="o">
                                            <tr>
                                                <td><b>#${o.stockOutId}</b></td>
                                                <td class="muted"><fmt:formatDate value="${o.date}" pattern="dd/MM/yyyy HH:mm" /></td>
                                                <td>${empty o.customerName ? 'Khách lẻ' : o.customerName}</td>
                                                <td>${o.customerPhone}</td>
                                                <td class="money"><fmt:formatNumber value="${o.totalAmount}" type="number"/> đ</td>
                                                <td class="muted">${o.createdByName}</td>
                                                <td>
                                                    <a class="link" href="${pageContext.request.contextPath}/orderdetail?id=${o.stockOutId}">Xem chi tiết</a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </main>
        </div>
    </body>
</html>