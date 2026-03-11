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
    <title>Khách hàng</title>
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
        .card{background:#fff;border:1px solid #e6e6e6;border-radius:12px;padding:16px;box-shadow:0 2px 8px rgba(0,0,0,.04);}
        .filters{display:flex;gap:10px;margin-bottom:14px;}
        .filters input{flex:1;padding:10px;border:1px solid #d0d7de;border-radius:8px;}
        .btn{padding:10px 14px;border:none;border-radius:8px;background:#111;color:#fff;cursor:pointer;text-decoration:none;}
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
            <li><a href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
            <li><a class="active" href="${pageContext.request.contextPath}/customers">Khách hàng</a></li>
            <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
        </ul>
    </aside>

    <main class="main">
        <div class="topbar"><h2>Khách hàng</h2></div>
        <div class="content">
            <div class="card">
                <form method="get" action="${pageContext.request.contextPath}/customers" class="filters">
                    <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm theo tên hoặc số điện thoại">
                    <button class="btn" type="submit">Tìm</button>
                </form>

                <table>
                    <tr>
                        <th>ID</th>
                        <th>Tên khách</th>
                        <th>SĐT</th>
                        <th>Địa chỉ</th>
                        <th>Chi tiết</th>
                    </tr>

                    <c:forEach items="${customers}" var="c">
                        <tr>
                            <td>${c.customerId}</td>
                            <td>${c.name}</td>
                            <td>${c.phone}</td>
                            <td>${c.address}</td>
                            <td>
                                <a class="link" href="${pageContext.request.contextPath}/customerDetail?id=${c.customerId}">
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