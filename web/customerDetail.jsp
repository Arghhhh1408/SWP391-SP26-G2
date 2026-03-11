<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="model.User" %>
<%
    User acc = (User) session.getAttribute("acc");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chi tiết khách hàng</title>
    <style>
        *{box-sizing:border-box;margin:0;padding:0;font-family:Arial,sans-serif;}
        body{background:#f4f6f9;}
        .layout{display:flex;min-height:100vh;}
        .sidebar{width:240px;background:#1f2d3d;color:#fff;}
        .logo{padding:20px;text-align:center;font-size:24px;font-weight:bold;background:#1a2533;}
        .user-box{padding:18px;border-bottom:1px solid rgba(255,255,255,.08);}
        .menu{list-style:none;padding:10px 0;}
        .menu li a{display:block;padding:14px 20px;color:#fff;text-decoration:none;}
        .menu li a:hover,.menu li a.active{background:#2f4050;}
        .main{flex:1;}
        .topbar{height:64px;background:#fff;border-bottom:1px solid #ddd;display:flex;align-items:center;padding:0 20px;}
        .content{padding:20px;}
        .card{background:#fff;border:1px solid #e6e6e6;border-radius:12px;padding:16px;box-shadow:0 2px 8px rgba(0,0,0,.04);margin-bottom:16px;}
        table{width:100%;border-collapse:collapse;}
        th,td{border:1px solid #eee;padding:10px;text-align:left;}
        th{background:#f6f8fa;}
        .link{color:#2563eb;text-decoration:none;}
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
            <li><a href="${pageContext.request.contextPath}/cart">Giỏ hàng</a></li>
            <li><a href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
            <li><a class="active" href="${pageContext.request.contextPath}/customers">Khách hàng</a></li>
            <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
        </ul>
    </aside>

    <main class="main">
        <div class="topbar"><h2>Chi tiết khách hàng</h2></div>

        <div class="content">
            <div class="card">
                <h3>Thông tin khách</h3>
                <p><b>ID:</b> ${customer.customerId}</p>
                <p><b>Tên:</b> ${customer.name}</p>
                <p><b>SĐT:</b> ${customer.phone}</p>
                <p><b>Địa chỉ:</b> ${customer.address}</p>
            </div>

            <div class="card">
                <h3>Lịch sử mua hàng</h3>
                <table>
                    <tr>
                        <th>Mã đơn</th>
                        <th>Ngày</th>
                        <th>Tổng tiền</th>
                        <th>Sale</th>
                        <th>Ghi chú</th>
                        <th>Chi tiết</th>
                    </tr>

                    <c:forEach items="${orders}" var="o">
                        <tr>
                            <td>${o.stockOutId}</td>
                            <td>${o.date}</td>
                            <td>${o.totalAmount}</td>
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
            </div>
        </div>
    </main>
</div>
</body>
</html>