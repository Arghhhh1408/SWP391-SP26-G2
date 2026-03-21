<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="model.User" %>
<% User acc = (User) session.getAttribute("acc"); %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Dashboard - S.I.M</title>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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

            /* Stats Cards */
            .cards {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 20px;
                margin-bottom: 25px;
            }
            .card {
                background: #fff;
                border-radius: 12px;
                padding: 20px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
                border: 1px solid #e5e7eb;
            }
            .card h3 {
                font-size: 13px;
                color: #6b7280;
                margin-bottom: 10px;
                text-transform: uppercase;
                font-weight: 600;
            }
            .card p {
                font-size: 22px;
                font-weight: bold;
                color: #111827;
            }

            /* Grid Layout for Charts & Tables */
            .grid-container {
                display: grid;
                grid-template-columns: 1fr 1.5fr;
                gap: 20px;
                margin-top: 25px;
            }
            .chart-card, .table-card {
                background: #fff;
                border-radius: 12px;
                padding: 25px;
                border: 1px solid #e5e7eb;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            }
            .section-title {
                font-size: 16px;
                font-weight: 700;
                margin-bottom: 20px;
                color: #1f2937;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            /* Table Styles */
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th {
                text-align: left;
                font-size: 12px;
                color: #94a3b8;
                text-transform: uppercase;
                padding-bottom: 10px;
                border-bottom: 1px solid #f1f5f9;
            }
            td {
                padding: 12px 0;
                font-size: 14px;
                border-bottom: 1px solid #f8fafc;
            }
            .badge {
                padding: 4px 8px;
                border-radius: 6px;
                font-size: 11px;
                font-weight: bold;
            }
            .badge-danger {
                background: #fee2e2;
                color: #ef4444;
            }
        </style>
    </head>
    <body>
        <div class="layout">
            <aside class="sidebar">
                <div class="logo">S.I.M</div>
                <div class="user-box">Xin chào: <b><%= acc != null ? acc.getUsername() : "" %></b></div>
                <ul class="menu">
                    <li><a class="active"  href="${pageContext.request.contextPath}/sales_dashboard">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/sales-products">Sản phẩm</a></li>
                    <li><a  href="${pageContext.request.contextPath}/pos">Bán hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/customers">Khách hàng</a></li>
                    <li><a href="account">Tài khoản</a></li>
                    <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                </ul>
            </aside>

            <main class="main">
                <div class="topbar"><h2>Tổng quan kinh doanh</h2></div>
                <div class="content">

                    <div class="cards">
                        <div class="card" style="border-top: 4px solid #3b82f6;">
                            <h3>Doanh thu hôm nay</h3>
                            <p><fmt:formatNumber value="${revenueToday}" type="number"/> đ</p>
                        </div>
                        <div class="card" style="border-top: 4px solid #10b981;">
                            <h3>Doanh thu tuần</h3>
                            <p><fmt:formatNumber value="${revenueWeek}" type="number"/> đ</p>
                        </div>
                        <div class="card" style="border-top: 4px solid #f59e0b;">
                            <h3>Doanh thu tháng</h3>
                            <p><fmt:formatNumber value="${revenueMonth}" type="number"/> đ</p>
                        </div>
                        <div class="card" style="border-top: 4px solid #ef4444;">
                            <h3>Sắp hết hàng</h3>
                            <p style="color: #ef4444;">${lowStockCount != null ? lowStockCount : 0} mã</p>
                        </div>
                    </div>

                    <div class="grid-container">
                        <div class="chart-card">
                            <h3 class="section-title">📊 Phân bổ doanh thu</h3>
                            <div style="max-width:280px; margin: 0 auto;"><canvas id="revenuePieChart"></canvas></div>
                        </div>

                        <div class="table-card">
                            <h3 class="section-title">⚠️ Cảnh báo tồn kho (Dưới 5 món)</h3>
                            <c:choose>
                                <c:when test="${empty lowStockProducts}">
                                    <p style="color: #94a3b8; font-style: italic; text-align: center; padding: 40px 0;">Hiện tại không có hàng nào sắp hết.</p>
                                </c:when>
                                <c:otherwise>
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Sản phẩm</th>
                                                <th>Tồn kho</th>
                                                <th>Trạng thái</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${lowStockProducts}" var="p">
                                                <tr>
                                                    <td>
                                                        <b>${p.name}</b><br>
                                                        <small style="color: #94a3b8;">SKU: ${p.sku}</small>
                                                    </td>
                                                    <td style="font-weight: bold; color: #ef4444;">${p.quantity}</td>
                                                    <td><span class="badge badge-danger">CẦN NHẬP</span></td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <script>
            new Chart(document.getElementById('revenuePieChart'), {
                type: 'doughnut', /* Chuyển sang doughnut nhìn hiện đại hơn pie */
                data: {
                    labels: ['Hôm nay', 'Tuần này', 'Tháng này'],
                    datasets: [{
                            data: [${revenueToday}, ${revenueWeek}, ${revenueMonth}],
                            backgroundColor: ['#3b82f6', '#10b981', '#f59e0b'],
                            borderWidth: 0
                        }]
                },
                options: {
                    cutout: '70%',
                    plugins: {
                        legend: {position: 'bottom'}
                    }
                }
            });
        </script>
    </body>
</html>