<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="model.User" %>
<% User acc = (User) session.getAttribute("acc"); %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>S.I.M - Bán hàng POS</title>
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
                text-align: center;
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
                text-decoration: none;
                color: #333;
            }
            .remove-btn {
                color: #ef4444;
                background: none;
                border: none;
                font-size: 20px;
                cursor: pointer;
                font-weight: bold;
            }

            /* Modal Popup */
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

            .hint-btn {
                background: #fff;
                border: 1px solid #3b82f6;
                color: #3b82f6;
                padding: 3px 10px;
                border-radius: 6px;
                cursor: pointer;
                font-size: 13px;
                font-weight: bold;
                transition: 0.2s;
            }
            .hint-btn:hover {
                background: #3b82f6;
                color: #fff;
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
                    <li><a href="products">Sản phẩm</a></li>
                    <li><a class="active" href="pos">Bán hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
                    <li><a href="customers">Khách hàng</a></li>
                    <li><a href="account">Tài khoản</a></li>
                    <li><a href="logout">Đăng xuất</a></li>
                </ul>
            </aside>

            <main class="main">
                <div class="topbar"><h2>Bán hàng POS</h2></div>
                <div class="content">
                    <c:set var="cart" value="${sessionScope.cart}" />
                    <c:set var="grandTotal" value="0" />

                    <div class="pos-grid">
                        <div class="card">
                            <h3>Danh mục Sản phẩm</h3>
                            <table>
                                <thead><tr><th>Tên / Mã</th><th>Giá</th><th>Kho</th><th></th></tr></thead>
                                <tbody>
                                    <c:forEach items="${products}" var="p">
                                        <tr>
                                            <td>${p.name} <br><small style="color:gray">${p.sku}</small></td>
                                            <td class="money"><fmt:formatNumber value="${p.price}" type="number"/> đ</td>
                                            <td>${p.quantity}</td>
                                            <td>
                                                <form method="post" action="cart">
                                                    <input type="hidden" name="action" value="add"><input type="hidden" name="productId" value="${p.id}">
                                                    <button class="btn btn-primary" type="submit">Thêm</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <div class="card">
                            <h3>Giỏ hàng</h3>
                            <c:choose>
                                <c:when test="${empty cart}">
                                    <div style="padding:30px; text-align:center; color:#999; border:1px dashed #ccc; border-radius:10px;">Giỏ hàng trống</div>
                                </c:when>
                                <c:otherwise>
                                    <table>
                                        <c:forEach items="${cart.values()}" var="it">
                                            <tr>
                                                <td><b>${it.name}</b>
                                                    <div class="qty-group">
                                                        <a href="cart?action=dec&productId=${it.productId}&from=pos" class="qty-btn">-</a>
                                                        <span>${it.qty}</span>
                                                        <a href="cart?action=inc&productId=${it.productId}&from=pos" class="qty-btn">+</a>
                                                    </div>
                                                </td>
                                                <td class="money" style="text-align:right"><fmt:formatNumber value="${it.price * it.qty}" type="number"/> đ</td>
                                                <td style="text-align:right"><a href="cart?action=remove&productId=${it.productId}&from=pos" class="remove-btn">&times;</a></td>
                                            </tr>
                                            <c:set var="grandTotal" value="${grandTotal + (it.price * it.qty)}" />
                                        </c:forEach>
                                    </table>
                                    <div style="margin-top:15px; border-top:2px solid #eee; padding-top:10px; display:flex; justify-content:space-between; font-size:20px;">
                                        <span>Tổng cộng:</span><b style="color:#3b82f6"><fmt:formatNumber value="${grandTotal}" type="number"/> đ</b>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <form id="checkoutForm" method="post" action="checkout" target="invoiceFrameName" onsubmit="document.getElementById('invoiceModal').style.display = 'block';">
                                <div class="field"><label>SĐT Khách hàng</label><input name="customerPhone" id="customerPhone" placeholder="0xxx..."></div>
                                <div class="field"><label>Tên khách hàng</label><input name="customerName" id="customerName"></div>

                                <div class="field" style="background:#fffbeb; padding:15px; border-radius:8px; border: 1px solid #fef3c7; margin-top: 15px;">
                                    <label style="color: #92400e; font-weight: bold;">Khách thực tế đưa</label>
                                    <input type="number" name="amountPaid" id="amountPaid" value="${grandTotal}" style="font-weight:bold; font-size:18px;">

                                    <div id="quickHints" style="display: flex; gap: 8px; margin-top: 8px; flex-wrap: wrap;"></div>

                                    <p id="paymentStatus" style="margin-top:10px; font-size:14px; font-weight: 600; min-height: 20px;"></p>
                                </div>
                                <button type="submit" class="btn btn-primary" style="width:100%; margin-top:15px; padding:15px; font-weight:bold;">XÁC NHẬN THANH TOÁN (F9)</button>
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

        <form id="barcodeForm" method="post" action="cart" style="display:none;">
            <input type="hidden" name="action" value="addByBarcode"><input type="hidden" name="barcode" id="barcodeHiddenInput">
        </form>

        <script>
            const amountPaidInput = document.getElementById('amountPaid');
            const quickHints = document.getElementById('quickHints');
            const statusMsg = document.getElementById('paymentStatus');
            const totalAmount = ${grandTotal != null ? grandTotal : 0};

            // 1. LOGIC TÍNH TIỀN THỐI & GỢI Ý HÀNG ĐƠN VỊ
            if (amountPaidInput) {
                amountPaidInput.oninput = function () {
                    let val = this.value;
                    let diff = val - totalAmount;
                    let fmt = new Intl.NumberFormat('vi-VN');

                    // Tạo gợi ý thông minh
                    quickHints.innerHTML = "";
                    if (val.length > 0 && val.length <= 4) {
                        let base = parseInt(val);
                        [1000, 10000, 100000, 1000000].forEach(unit => {
                            let suggest = base * unit;
                            if (suggest >= totalAmount / 10) {
                                let btn = document.createElement("span");
                                btn.className = "hint-btn";
                                btn.innerText = fmt.format(suggest);
                                btn.onclick = function () {
                                    amountPaidInput.value = suggest;
                                    amountPaidInput.oninput();
                                };
                                quickHints.appendChild(btn);
                            }
                        });
                    }

                    // Hiển thị trạng thái Thối/Nợ
                    if (diff < 0) {
                        statusMsg.style.color = "#dc2626";
                        statusMsg.innerHTML = "⚠ Khách nợ: <b>" + fmt.format(Math.abs(diff)) + " đ</b>";
                    } else if (diff > 0) {
                        statusMsg.style.color = "#059669";
                        statusMsg.innerHTML = "➡ Tiền thối lại: <b>" + fmt.format(diff) + " đ</b>";
                    } else {
                        statusMsg.style.color = "#3b82f6";
                        statusMsg.innerHTML = "✓ Khách đưa đủ tiền.";
                    }
                };
                amountPaidInput.oninput();
                amountPaidInput.onclick = function () {
                    this.select();
                };
            }

            // 2. XỬ LÝ MÁY QUÉT MÃ VẠCH (BARCODE) & PHÍM TẮT F9
            let barcodeBuffer = "";
            let lastKeyTime = Date.now();
            window.addEventListener("keydown", function (e) {
                const currentTime = Date.now();
                if (currentTime - lastKeyTime > 50)
                    barcodeBuffer = "";
                lastKeyTime = currentTime;
                if (e.key === "Enter") {
                    if (barcodeBuffer.length >= 3) {
                        e.preventDefault();
                        document.getElementById('barcodeHiddenInput').value = barcodeBuffer;
                        document.getElementById('barcodeForm').submit();
                        barcodeBuffer = "";
                    }
                } else if (e.key.length === 1) {
                    barcodeBuffer += e.key;
                }
                if (e.key === "F9") {
                    e.preventDefault();
                    document.getElementById('checkoutForm').submit();
                }
            });

            // 3. AJAX TÌM KHÁCH THEO SĐT
            document.getElementById('customerPhone')?.addEventListener('blur', function () {
                if (this.value.trim().length >= 10) {
                    fetch("customer-search?phone=" + encodeURIComponent(this.value.trim()))
                            .then(r => r.json()).then(data => {
                        if (data.name)
                            document.getElementById('customerName').value = data.name;
                    });
                }
            });

            // 4. ĐÓNG MODAL
            window.onclick = function (event) {
                if (event.target == document.getElementById('invoiceModal'))
                    location.reload();
            }
        </script>
    </body>
</html>