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
        <meta charset="UTF-8">
        <title>Chi tiết khách hàng - S.I.M</title>
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
            .topbar h2 {
                font-size: 20px;
                font-weight: 600;
            }

            .content {
                padding: 25px;
            }

            /* Card thiết kế chuẩn */
            .card {
                background: #fff;
                border-radius: 12px;
                padding: 25px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
                border: 1px solid #e5e7eb;
                margin-bottom: 25px;
            }
            .card h3 {
                font-size: 18px;
                margin-bottom: 20px;
                color: #111827;
                border-left: 4px solid #3b82f6;
                padding-left: 12px;
            }

            /* Thông tin khách */
            .info-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 15px;
            }
            .info-item {
                font-size: 15px;
                margin-bottom: 8px;
            }
            .info-item b {
                color: #4b5563;
                min-width: 100px;
                display: inline-block;
            }

            /* Box Công nợ nổi bật */
            .debt-container {
                margin-top: 15px;
                padding: 20px;
                background: #fffaf0;
                border: 1px solid #feebc8;
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: space-between;
            }
            .debt-label {
                font-size: 14px;
                color: #744210;
                font-weight: 600;
            }
            .debt-value {
                font-size: 24px;
                color: #c53030;
                font-weight: 800;
            }

            /* Table đồng bộ */
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th {
                background: #f9fafb;
                padding: 12px 15px;
                text-align: left;
                font-size: 13px;
                font-weight: 600;
                color: #4b5563;
                border-bottom: 2px solid #e5e7eb;
            }
            td {
                padding: 12px 15px;
                border-bottom: 1px solid #f3f4f6;
                font-size: 14px;
            }
            tr:hover {
                background: #f9fafb;
            }

            /* Button */
            .btn {
                padding: 10px 18px;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                font-weight: 600;
                text-decoration: none;
                transition: 0.2s;
                font-size: 14px;
                display: inline-block;
            }
            .btn-pay {
                background: #10b981;
                color: white;
            }
            .btn-pay:hover {
                background: #059669;
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);
            }
            .btn-ghost {
                background: #f3f4f6;
                color: #374151;
                margin-left: 10px;
            }
            .link {
                color: #3b82f6;
                text-decoration: none;
                font-weight: 600;
            }
            .link:hover {
                text-decoration: underline;
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
                    <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                </ul>
            </aside>

            <main class="main">
                <div class="topbar">
                    <h2>Hồ sơ khách hàng</h2>
                    <a href="${pageContext.request.contextPath}/customers" class="btn btn-ghost">Quay lại danh sách</a>
                </div>

                <div class="content">
                    <div class="card">
                        <h3>Thông tin cơ bản</h3>
                        <div class="info-grid">
                            <div class="info-item"><b>Mã khách:</b> #${customer.customerId}</div>
                            <div class="info-item"><b>Họ và tên:</b> ${customer.name}</div>
                            <div class="info-item"><b>Điện thoại:</b> ${customer.phone}</div>
                            <div class="info-item"><b>Địa chỉ:</b> ${customer.address}</div>
                        </div>

                        <div class="debt-container">
                            <div>
                                <div class="debt-label">TỔNG NỢ CẦN THU</div>
                                <div class="debt-value">
                                    <fmt:formatNumber value="${customer.debt}" type="number"/> VNĐ
                                </div>
                            </div>
                            <c:if test="${customer.debt > 0}">
                                <a href="${pageContext.request.contextPath}/collectDebt?id=${customer.customerId}" class="btn btn-pay">
                                    💳 Ghi nhận thu nợ
                                </a>
                            </c:if>
                        </div>
                    </div>

                    <div class="card">
                        <h3>Lịch sử giao dịch</h3>
                        <c:choose>
                            <c:when test="${empty orders}">
                                <p style="color: #6b7280; font-style: italic; text-align: center; padding: 20px;">Khách hàng này chưa có đơn hàng nào.</p>
                            </c:when>
                            <c:otherwise>
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Mã đơn</th>
                                            <th>Ngày giao dịch</th>
                                            <th>Tổng thanh toán</th>
                                            <th>Nhân viên bán</th>
                                            <th>Ghi chú</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${orders}" var="o">
                                            <tr>
                                                <td><b>#${o.stockOutId}</b></td>
                                                <td style="color: #6b7280;">${o.date}</td>
                                                <td>
                                                    <b style="color: #111827;"><fmt:formatNumber value="${o.totalAmount}" type="number"/> đ</b>
                                                </td>
                                                <td>${o.createdByName}</td>
                                                <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                    ${empty o.note ? '-' : o.note}
                                                </td>
                                                <td>
                                                    <a class="link" href="${pageContext.request.contextPath}/orderdetail?id=${o.stockOutId}">
                                                        Xem đơn
                                                    </a>
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