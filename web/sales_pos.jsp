<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="model.User" %>
<% User acc = (User) session.getAttribute("acc"); %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Bán hàng POS</title>
        <style>
            /* --- GIỮ NGUYÊN CSS CŨ CỦA BẠN --- */
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
                padding: 20px;
            }
            .pos-grid {
                display: grid;
                grid-template-columns: 2fr 1.3fr;
                gap: 20px;
            }
            .card {
                background: #fff;
                border-radius: 12px;
                padding: 20px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
                border: 1px solid #e5e7eb;
                margin-bottom: 20px;
            }
            .card h3 {
                margin-bottom: 15px;
                font-size: 18px;
                color: #111827;
                border-left: 4px solid #3b82f6;
                padding-left: 10px;
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
            .money {
                font-weight: bold;
            }
            .btn {
                padding: 8px 12px;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                font-weight: 500;
                text-decoration: none;
                display: inline-block;
                transition: 0.2s;
            }
            .btn-primary {
                background: #3b82f6;
                color: #fff;
            }
            .btn-primary:hover {
                background: #2563eb;
            }
            .field {
                margin-top: 15px;
            }
            .field label {
                display: block;
                font-size: 13px;
                margin-bottom: 5px;
                font-weight: 600;
            }
            .field input {
                width: 100%;
                padding: 10px;
                border: 1px solid #d1d5db;
                border-radius: 8px;
                font-size: 15px;
            }
            .cart-item-name {
                font-weight: 600;
                color: #111827;
            }
            .cart-item-info {
                font-size: 12px;
                color: #6b7280;
            }
            .remove-btn {
                color: #ef4444;
                background: none;
                border: none;
                font-size: 18px;
                cursor: pointer;
                font-weight: bold;
            }
            .qty-group {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-top: 5px;
            }
            .qty-btn {
                width: 26px;
                height: 26px;
                border-radius: 6px;
                border: 1px solid #d1d5db;
                background: #fff;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
                transition: 0.2s;
            }
            .qty-btn:hover {
                background: #f3f4f6;
                border-color: #3b82f6;
                color: #3b82f6;
            }
            .qty-number {
                font-weight: bold;
                font-size: 14px;
                min-width: 20px;
                text-align: center;
            }

            /* --- THÊM CSS CHO MODAL TẠI ĐÂY --- */
            .modal {
                display: none;
                position: fixed;
                z-index: 9999;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.5);
                backdrop-filter: blur(2px);
            }
            .modal-content {
                background: #fff;
                margin: 2% auto;
                padding: 10px;
                border-radius: 12px;
                width: 550px;
                height: 90vh;
                position: relative;
                box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            }
            .close-modal {
                position: absolute;
                right: 15px;
                top: 10px;
                font-size: 24px;
                cursor: pointer;
                color: #666;
                z-index: 100;
            }
            iframe#invoiceFrame {
                width: 100%;
                height: 100%;
                border: none;
                border-radius: 8px;
            }
        </style>
    </head>
    <body>
        <div class="layout">
            <aside class="sidebar">
                <div class="logo">S.I.M</div>
                <div class="user-box">Xin chào: <b><%= acc != null ? acc.getUsername() : "" %></b></div>
                <ul class="menu">
                    <li><a  href="${pageContext.request.contextPath}/sales_dashboard">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/sales-products">Sản phẩm</a></li>
                    <li><a class="active" href="${pageContext.request.contextPath}/pos">Bán hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/customers">Khách hàng</a></li>
                    <li><a href="account">Tài khoản</a></li>
                    <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                </ul>
            </aside>
            <main class="main">
                <div class="topbar"><h2>Bán hàng POS</h2></div>
                <div class="content">
                    <c:set var="cart" value="${sessionScope.cart}" />
                    <c:if test="${param.err == 'not_enough_stock'}">
                        <div style="background: #fee2e2; border-left: 5px solid #ef4444; color: #b91c1c; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                            <strong>⚠ Lỗi số lượng:</strong> Sản phẩm <b>${param.sku}</b> hiện tại chỉ còn <b>${param.stock}</b> sản phẩm trong kho.
                        </div>
                    </c:if>
                    <div class="pos-grid">
                        <div class="card">
                            <h3>Danh mục Sản phẩm</h3>
                            <table>
                                <thead><tr><th>Tên sản phẩm</th><th>Đơn giá</th><th>Tồn kho</th><th></th></tr></thead>
                                <tbody>
                                    <c:forEach items="${sale_productList}" var="p">
                                        <tr>
                                            <td>${p.name}</td>
                                            <td class="money"><fmt:formatNumber value="${p.price}" type="number"/> đ</td>
                                            <td>${p.quantity}</td>
                                            <td>
                                                <form method="post" action="${pageContext.request.contextPath}/cart">
                                                    <input type="hidden" name="action" value="add">
                                                    <input type="hidden" name="productId" value="${p.id}">
                                                    <button class="btn btn-primary" type="submit">Thêm</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <div class="card">
                            <h3>Giỏ hàng hiện tại</h3>
                            <c:choose>
                                <c:when test="${empty cart}">
                                    <div style="padding:20px; border:1px dashed #ccc; text-align:center; border-radius:10px; color:#666; margin-bottom: 20px;">
                                        Giỏ hàng đang trống
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <table style="margin-bottom: 20px;">
                                        <thead>
                                            <tr>
                                                <th>Sản phẩm</th>
                                                <th style="text-align: right;">Tiền</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:set var="grandTotal" value="0" />
                                            <c:forEach items="${cart.values()}" var="it">
                                                <tr>
                                                    <td>
                                                        <div class="cart-item-name">${it.name}</div>
                                                        <div class="qty-group" style="display: flex; align-items: center; gap: 2px;">
    <form method="post" action="${pageContext.request.contextPath}/cart" style="margin:0;">
        <input type="hidden" name="action" value="dec">
        <input type="hidden" name="productId" value="${it.productId}">
        <input type="hidden" name="from" value="pos">
        <button type="submit" class="qty-btn" style="border-radius: 4px 0 0 4px;">-</button>
    </form>

    <form method="post" action="${pageContext.request.contextPath}/cart" style="margin:0;">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="productId" value="${it.productId}">
        <input type="hidden" name="from" value="pos">
        <input type="number" name="qty" value="${it.qty}" min="1"
               style="width: 45px; height: 26px; text-align: center; border: 1px solid #d1d5db; border-left: 0; border-right: 0; outline: none;"
               onchange="this.form.submit()">
    </form>

    <form method="post" action="${pageContext.request.contextPath}/cart" style="margin:0;">
        <input type="hidden" name="action" value="inc">
        <input type="hidden" name="productId" value="${it.productId}">
        <input type="hidden" name="from" value="pos">
        <button type="submit" class="qty-btn" style="border-radius: 0 4px 4px 0;">+</button>
    </form>
</div>
                                                    </td>
                                                    <td class="money" style="text-align: right;">
                                                        <fmt:formatNumber value="${it.lineTotal}" type="number"/>
                                                    </td>
                                                    <td style="text-align: right;">
                                                        <form method="post" action="${pageContext.request.contextPath}/cart" style="display:inline;">
                                                            <input type="hidden" name="action" value="remove">
                                                            <input type="hidden" name="productId" value="${it.productId}">
                                                            <input type="hidden" name="from" value="pos">
                                                            <button type="submit" class="remove-btn">×</button>
                                                        </form>
                                                    </td>
                                                </tr>
                                                <c:set var="grandTotal" value="${grandTotal + it.lineTotal}" />
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>

                            <hr style="border: 0; border-top: 1px solid #eee; margin-bottom: 15px;">

                            <p style="font-size: 18px; margin-bottom: 15px; display: flex; justify-content: space-between;">
                                <span>Tổng cộng:</span>
                                <b style="color:#3b82f6"><fmt:formatNumber value="${grandTotal}" type="number"/> đ</b>
                            </p>

                            <form method="post" action="${pageContext.request.contextPath}/checkout" 
                                  target="invoiceFrameName" onsubmit="document.getElementById('invoiceModal').style.display = 'block';">
                                <div class="field"><label>Số điện thoại</label><input name="customerPhone" id="customerPhone" placeholder="SĐT..."></div>
                                <div class="field"><label>Khách hàng</label><input name="customerName" id="customerName" placeholder="Tên khách hàng..."></div>
                                <div class="field" style="background:#fffbeb; padding:12px; border-radius:10px; border: 1px solid #fef3c7;">
                                    <label style="color: #92400e;">Số tiền khách trả</label>
                                    <input type="number" name="amountPaid" id="amountPaid" value="${grandTotal}" step="1000" style="font-weight:bold; font-size:16px;">
                                    <p id="debtMsg" style="color:#dc2626; font-size:13px; margin-top:8px; display:none; font-weight: 600;">
                                        ⚠ Khách nợ: <span id="debtVal">0</span> đ
                                    </p>
                                </div>
                                <button class="btn btn-primary" style="width:100%; margin-top:20px; padding:15px; font-size: 16px; font-weight: bold; letter-spacing: 1px;">XÁC NHẬN THANH TOÁN</button>
                            </form>
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <div id="invoiceModal" class="modal">
            <div class="modal-content">
                <span class="close-modal" onclick="location.reload();">&times;</span>
                <iframe name="invoiceFrameName" id="invoiceFrame"></iframe>
            </div>
        </div>

        <script>
            const amountPaid = document.getElementById('amountPaid');
            const grandTotal = ${grandTotal != null ? grandTotal : 0};

            if (amountPaid) {
                amountPaid.oninput = function () {
                    let debt = grandTotal - this.value;
                    if (debt > 0) {
                        document.getElementById('debtMsg').style.display = 'block';
                        document.getElementById('debtVal').innerText = new Intl.NumberFormat('vi-VN').format(debt);
                    } else {
                        document.getElementById('debtMsg').style.display = 'none';
                    }
                };
            }

            const phoneInput = document.getElementById('customerPhone');
            const nameInput = document.getElementById('customerName');
            if (phoneInput && nameInput) {
                phoneInput.onblur = function () {
                    let phone = this.value.trim();
                    if (phone.length >= 10) {
                        fetch("${pageContext.request.contextPath}/customer-search?phone=" + encodeURIComponent(phone))
                                .then(res => res.json())
                                .then(data => {
                                    if (data.name)
                                        nameInput.value = data.name;
                                });
                    }
                };
            }

            window.onclick = function (event) {
                if (event.target == document.getElementById('invoiceModal')) {
                    location.reload();
                }
            }

            window.addEventListener("DOMContentLoaded", function () {
                const params = new URLSearchParams(window.location.search);
                const err = params.get("err");
                const sku = params.get("sku");
                const stock = params.get("stock");

                if (err === "not_enough_stock") {
                    alert("❌ LỖI TỒN KHO: \nSản phẩm " + sku + " chỉ còn lại " + stock + " món trong kho.");
                    const newUrl = window.location.pathname + (params.get("keyword") ? "?keyword=" + params.get("keyword") : "");
                    window.history.replaceState({}, "", newUrl);
                }
            });
        </script>
    </body>
</html>