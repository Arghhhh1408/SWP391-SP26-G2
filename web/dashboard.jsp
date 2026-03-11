<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.User" %>
<%
    User acc = (User) session.getAttribute("acc");
%>
<!DOCTYPE html>
<html>
    <head>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <meta charset="UTF-8">
        <title>Dashboard</title>
        <style>
            *{
                box-sizing:border-box;
                margin:0;
                padding:0;
                font-family:Arial, sans-serif;
            }

            body{
                background:#f4f6f9;
            }

            .layout{
                display:flex;
                min-height:100vh;
            }

            .sidebar{
                width:240px;
                background:#1f2d3d;
                color:#fff;
                display:flex;
                flex-direction:column;
            }

            .logo{
                padding:20px;
                font-size:24px;
                font-weight:bold;
                background:#1a2533;
                text-align:center;
            }

            .user-box{
                padding:18px;
                border-bottom:1px solid rgba(255,255,255,0.08);
                font-size:14px;
            }

            .menu{
                list-style:none;
                padding:10px 0;
            }

            .menu li a{
                display:block;
                padding:14px 20px;
                color:#fff;
                text-decoration:none;
                transition:0.2s;
            }

            .menu li a:hover,
            .menu li a.active{
                background:#2f4050;
            }

            .main{
                flex:1;
                display:flex;
                flex-direction:column;
            }

            .topbar{
                height:64px;
                background:#fff;
                border-bottom:1px solid #ddd;
                display:flex;
                align-items:center;
                justify-content:space-between;
                padding:0 20px;
            }

            .topbar-title{
                font-size:20px;
                font-weight:bold;
            }

            .topbar-user{
                font-size:14px;
                color:#333;
            }

            .content{
                padding:20px;
            }

            .cards{
                display:grid;
                grid-template-columns:repeat(3, 1fr);
                gap:16px;
            }

            .card{
                background:#fff;
                border-radius:12px;
                padding:20px;
                box-shadow:0 2px 8px rgba(0,0,0,0.06);
            }

            .card h3{
                margin-bottom:10px;
                font-size:16px;
                color:#555;
            }

            .card p{
                font-size:28px;
                font-weight:bold;
                color:#111;
            }

            .welcome{
                margin-top:20px;
                background:#fff;
                border-radius:12px;
                padding:20px;
                box-shadow:0 2px 8px rgba(0,0,0,0.06);
            }
            .chart-card h3{
                font-size:18px;
                margin-bottom:12px;
            }
        </style>
    </head>

    <body>

        <div class="layout">
            <aside class="sidebar">
                <div class="logo">S.I.M</div>

                <div class="user-box">
                    Xin chào: <b><%= acc != null ? acc.getUsername() : "" %></b>
                </div>

                <ul class="menu">
                    <li><a class="active" href="${pageContext.request.contextPath}/dashboard">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/products">Sản phẩm</a></li>
                    <li><a href="${pageContext.request.contextPath}/pos">Bán hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                </ul>
            </aside>

            <main class="main">
                <div class="topbar">
                    <div class="topbar-title">Dashboard</div>
                    <div class="topbar-user">Nhân viên bán hàng</div>
                </div>

                <div class="content">
                    <div class="cards">
                        <div class="card">
                            <h3>Doanh thu hôm nay</h3>
                            <p>${revenueToday}</p>
                        </div>

                        <div class="card">
                            <h3>Doanh thu tuần này</h3>
                            <p>${revenueWeek}</p>
                        </div>

                        <div class="card">
                            <h3>Doanh thu tháng này</h3>
                            <p>${revenueMonth}</p>
                        </div>
                    </div>

                    <div class="chart-card" style="margin-top:20px; background:#fff; border-radius:12px; padding:20px; box-shadow:0 2px 8px rgba(0,0,0,0.06);">
                        <h3 style="margin-bottom:16px;">Biểu đồ tròn doanh thu</h3>
                        <div style="max-width:420px;">
                            <canvas id="revenuePieChart"></canvas>
                        </div>
                    </div>
                </div>
            </main>
        </div>

    </body>
</html>
<script>
    const revenueToday = ${revenueToday};
    const revenueWeek = ${revenueWeek};
    const revenueMonth = ${revenueMonth};

    const ctx = document.getElementById('revenuePieChart').getContext('2d');

    new Chart(ctx, {
        type: 'pie',
        data: {
            labels: ['Hôm nay', 'Tuần này', 'Tháng này'],
            datasets: [{
                    data: [revenueToday, revenueWeek, revenueMonth],
                    backgroundColor: [
                        '#3b82f6',
                        '#10b981',
                        '#f59e0b'
                    ],
                    borderWidth: 1
                }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
</script>