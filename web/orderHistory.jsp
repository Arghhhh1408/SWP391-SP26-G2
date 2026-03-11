<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="model.User" %>
<%
    User acc = (User) session.getAttribute("acc");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Lịch sử đơn hàng</title>

    <style>
        *{
            box-sizing:border-box;
            margin:0;
            padding:0;
            font-family:Arial, sans-serif;
        }

        body{
            background:#f4f6f9;
            color:#111827;
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
            letter-spacing:1px;
        }

        .user-box{
            padding:18px;
            border-bottom:1px solid rgba(255,255,255,0.08);
            font-size:14px;
            line-height:1.6;
        }

        .menu{
            list-style:none;
            padding:10px 0;
            flex:1;
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

        .content{
            padding:20px;
        }

        .card{
            background:#fff;
            border:1px solid #e6e6e6;
            border-radius:12px;
            padding:16px;
            box-shadow:0 2px 8px rgba(0,0,0,.04);
        }

        .head{
            display:flex;
            justify-content:space-between;
            align-items:center;
            gap:10px;
            flex-wrap:wrap;
            margin-bottom:14px;
        }

        h2{
            margin:0;
            font-size:22px;
        }

        .filters{
            display:flex;
            gap:10px;
            flex-wrap:wrap;
            align-items:end;
            margin:10px 0 14px;
        }

        .field label{
            display:block;
            font-size:12px;
            color:#444;
            margin-bottom:4px;
        }

        .field input,
        .field select{
            padding:8px 10px;
            border:1px solid #d0d7de;
            border-radius:8px;
            min-width:160px;
            background:#fff;
            font-size:14px;
        }

        .btn{
            padding:8px 12px;
            border-radius:10px;
            border:1px solid #111;
            background:#111;
            color:#fff;
            cursor:pointer;
            font-size:13px;
            height:38px;
            text-decoration:none;
            display:inline-flex;
            align-items:center;
            justify-content:center;
        }

        .btn.secondary{
            background:#fff;
            color:#111;
            border-color:#bbb;
        }

        .table{
            width:100%;
            border-collapse:collapse;
            background:#fff;
            overflow:hidden;
            border-radius:12px;
        }

        .table th,
        .table td{
            border-top:1px solid #eee;
            padding:10px;
            text-align:left;
            vertical-align:top;
            font-size:13px;
        }

        .table th{
            background:#f6f8fa;
            border-top:none;
            font-size:12px;
            color:#333;
            text-transform:uppercase;
            letter-spacing:.02em;
        }

        .table tr:hover{
            background:#f9fafb;
        }

        .money{
            white-space:nowrap;
            font-variant-numeric:tabular-nums;
            font-weight:700;
        }

        .muted{
            color:#666;
            font-size:12px;
        }

        .link{
            text-decoration:none;
            border-bottom:1px dotted #111;
            color:#111;
            padding:2px 0;
            font-size:13px;
        }

        .empty{
            padding:14px;
            border:1px dashed #cbd5e1;
            border-radius:12px;
            background:#f8fafc;
            color:#334155;
        }

        @media (max-width: 900px){
            .sidebar{
                width:200px;
            }

            .filters{
                flex-direction:column;
                align-items:stretch;
            }

            .field input,
            .field select{
                min-width:100%;
            }
        }

        @media print{
            .sidebar,
            .topbar,
            .filters{
                display:none !important;
            }

            body{
                background:#fff;
            }

            .layout{
                display:block;
            }

            .content{
                padding:0;
            }

            .card{
                border:none;
                box-shadow:none;
                padding:0;
            }
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
            <li><a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/products">Sản phẩm</a></li>
            <li><a href="${pageContext.request.contextPath}/pos">Bán hàng</a></li>
            <li><a href="${pageContext.request.contextPath}/cart">Giỏ hàng</a></li>
            <li><a class="active" href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
            <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
        </ul>
    </aside>

    <main class="main">
        <div class="topbar">
            <div class="topbar-title">Lịch sử đơn hàng</div>
        </div>

        <div class="content">
            <div class="card">

                <c:choose>
                    <c:when test="${empty orders}">
                        <div class="empty">Chưa có đơn hàng nào.</div>
                    </c:when>

                    <c:otherwise>
                        <form method="get" action="${pageContext.request.contextPath}/orders" class="filters">
                            <div class="field">
                                <label>Lọc</label>
                                <select name="range">
                                    <option value="all"   ${param.range == 'all'   ? 'selected' : ''}>Tất cả</option>
                                    <option value="day"   ${param.range == 'day'   ? 'selected' : ''}>Hôm nay</option>
                                    <option value="week"  ${param.range == 'week'  ? 'selected' : ''}>Tuần này</option>
                                    <option value="month" ${param.range == 'month' ? 'selected' : ''}>Tháng này</option>
                                </select>
                            </div>

                            <div class="field">
                                <label>Sắp xếp</label>
                                <select name="sort">
                                    <option value="new" ${sort == 'new' ? 'selected' : ''}>Mới nhất</option>
                                    <option value="old" ${sort == 'old' ? 'selected' : ''}>Cũ nhất</option>
                                </select>
                            </div>

                            <div class="field">
                                <label>Tìm kiếm</label>
                                <input name="keyword"
                                       placeholder="Mã đơn hoặc SĐT"
                                       value="${param.keyword}">
                            </div>

                            <button class="btn" type="submit">Áp dụng</button>
                            <a class="btn secondary" href="${pageContext.request.contextPath}/orders">Reset</a>
                        </form>

                        <table class="table">
                            <tr>
                                <th>Mã đơn</th>
                                <th>Thời gian</th>
                                <th>Khách hàng</th>
                                <th>SĐT</th>
                                <th>Tổng tiền</th>
                                <th>Sale</th>
                                <th>Ghi chú</th>
                                <th>Chi tiết</th>
                            </tr>

                            <c:forEach items="${orders}" var="o">
                                <tr>
                                    <td><b>${o.stockOutId}</b></td>
                                    <td class="muted">${o.date}</td>
                                    <td>${o.customerName}</td>
                                    <td>${o.customerPhone}</td>
                                    <td class="money">${o.totalAmount}</td>
                                    <td>${o.createdByName}</td>
                                    <td>${o.note}</td>
                                    <td>
                                        <a class="link" href="${pageContext.request.contextPath}/orderdetail?id=${o.stockOutId}">
                                            Xem
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </table>
                    </c:otherwise>
                </c:choose>

            </div>
        </div>
    </main>
</div>
</body>
</html>