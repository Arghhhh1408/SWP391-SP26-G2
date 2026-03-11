<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="model.User" %>
<%
    User acc = (User) session.getAttribute("acc");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>POS</title>
    <style>
        *{
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
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

        .topbar-right{
            display:flex;
            align-items:center;
            gap:14px;
        }

        .cart-icon{
            position:relative;
            font-size:22px;
            text-decoration:none;
            padding:10px 12px;
            border:1px solid #eee;
            border-radius:12px;
            background:#fff;
            color:#111;
        }

        .badge{
            position:absolute;
            top:-6px;
            right:-6px;
            background:#ef4444;
            color:#fff;
            font-size:12px;
            padding:2px 7px;
            border-radius:999px;
        }

        .content{
            padding:20px;
        }

        .card{
            border:1px solid #ddd;
            padding:16px;
            border-radius:12px;
            background:#fff;
            box-shadow:0 2px 8px rgba(0,0,0,0.04);
        }

        .card h3{
            margin-bottom:14px;
            font-size:24px;
        }

        .search{
            display:flex;
            gap:10px;
            margin-bottom:14px;
        }

        .search input{
            flex:1;
            padding:10px 12px;
            border:1px solid #ddd;
            border-radius:10px;
            font-size:14px;
        }

        .search button{
            padding:10px 14px;
            border-radius:10px;
            border:1px solid #111;
            background:#111;
            color:#fff;
            cursor:pointer;
        }

        table{
            width:100%;
            border-collapse:collapse;
        }

        th, td{
            border:1px solid #ddd;
            padding:10px;
            vertical-align:top;
        }

        th{
            background:#f5f5f5;
            text-align:left;
        }

        .btn{
            padding:8px 12px;
            cursor:pointer;
            border-radius:8px;
            border:none;
        }

        .btn-primary{
            background:#2563eb;
            color:#fff;
        }

        .btn-primary:hover{
            background:#1d4ed8;
        }

        .muted{
            color:#666;
            font-size:12px;
            margin-top:10px;
        }

        .bottom-links{
            margin-top:14px;
        }

        .bottom-links a{
            color:#2563eb;
            text-decoration:none;
        }

        .bottom-links a:hover{
            text-decoration:underline;
        }

        #errModal{
            display:none;
            position:fixed;
            inset:0;
            background:rgba(0,0,0,.4);
            z-index:9999;
        }

        .err-card{
            width:420px;
            max-width:calc(100% - 24px);
            margin:12vh auto;
            background:#fff;
            border-radius:12px;
            padding:16px 18px;
        }

        .err-card h3{
            margin-bottom:10px;
        }

        .err-actions{
            display:flex;
            justify-content:flex-end;
            margin-top:14px;
        }

        .err-actions button{
            padding:10px 14px;
            border-radius:10px;
            border:1px solid #ddd;
            background:#111;
            color:#fff;
            cursor:pointer;
        }

        @media (max-width: 900px){
            .sidebar{
                width:200px;
            }

            .topbar-title{
                font-size:18px;
            }

            .card h3{
                font-size:20px;
            }
        }
    </style>
</head>

<body>

<div id="errModal">
    <div class="err-card">
        <h3>Thông báo</h3>
        <p id="errMsg"></p>
        <div class="err-actions">
            <button type="button" id="errClose">OK</button>
        </div>
    </div>
</div>

<div class="layout">

    <aside class="sidebar">
        <div class="logo">S.I.M</div>

        <div class="user-box">
            Xin chào: <b><%= acc != null ? acc.getUsername() : "" %></b>
        </div>

        <ul class="menu">
            <li><a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/products">Sản phẩm</a></li>
            <li><a class="active" href="${pageContext.request.contextPath}/pos">Bán hàng</a></li>
            <li><a href="${pageContext.request.contextPath}/cart">Giỏ hàng</a></li>
            <li><a href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
            <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
        </ul>
    </aside>

    <main class="main">
        <div class="topbar">
            <div class="topbar-title">POS - Bán hàng</div>

            <div class="topbar-right">
                <a class="cart-icon" href="${pageContext.request.contextPath}/cart">
                    🛒
                    <span class="badge">
                        ${empty sessionScope.cart ? 0 : sessionScope.cart.size()}
                    </span>
                </a>
            </div>
        </div>

        <div class="content">
            <div class="card">
                <h3>Sản phẩm</h3>

                <form method="get" action="${pageContext.request.contextPath}/pos" class="search">
                    <input name="keyword" placeholder="Tìm theo tên hoặc SKU..." value="${param.keyword}">
                    <button type="submit">Tìm</button>
                </form>

                <table>
                    <tr>
                        <th>SKU</th>
                        <th>Tên</th>
                        <th>Giá</th>
                        <th>Tồn</th>
                        <th>Đơn vị</th>
                        <th>ID</th>
                        <th></th>
                    </tr>

                    <c:forEach items="${products}" var="p">
                        <tr>
                            <td>${p.sku}</td>
                            <td>${p.name}</td>
                            <td>${p.price}</td>
                            <td>${p.quantity}</td>
                            <td>${p.unit}</td>
                            <td>${p.id}</td>
                            <td style="white-space:nowrap;">
                                <form method="post" action="${pageContext.request.contextPath}/cart">
                                    <input type="hidden" name="productId" value="${p.id}">
                                    <input type="hidden" name="keyword" value="${param.keyword}">
                                    <input type="hidden" name="from" value="pos">
                                    <button class="btn btn-primary" type="submit">Thêm</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </table>

                <div class="muted">
                    Mẹo: dùng ô tìm kiếm để gõ nhanh SKU hoặc tên sản phẩm.
                </div>

                <div class="bottom-links">
                    <a href="${pageContext.request.contextPath}/orders">Xem lịch sử đơn hàng</a>
                    <span style="margin:0 8px;">|</span>
                    <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    (function () {
        const params = new URLSearchParams(window.location.search);
        const err = params.get("err");

        function openModal(msg) {
            document.getElementById("errMsg").textContent = msg;
            document.getElementById("errModal").style.display = "block";
        }

        function closeModal() {
            document.getElementById("errModal").style.display = "none";
        }

        document.addEventListener("click", function (e) {
            if (e.target && (e.target.id === "errClose" || e.target.id === "errModal")) {
                closeModal();
            }
        });

        if (err === "not_enough_stock") {
            openModal("❌ Số lượng tồn kho không đủ. Vui lòng giảm số lượng hoặc chọn sản phẩm khác.");

            params.delete("err");
            const newUrl = window.location.pathname + (params.toString() ? "?" + params.toString() : "");
            window.history.replaceState({}, "", newUrl);
        }
    })();
</script>

</body>
</html>