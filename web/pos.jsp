<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>POS</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 16px;
            }
            .container {
                display: grid;
                grid-template-columns: 1.2fr 0.8fr;
                gap: 16px;
                align-items: start;
            }
            .card {
                border: 1px solid #ddd;
                padding: 12px;
                border-radius: 8px;
                background: #fff;
            }
            .card h3 {
                margin: 0 0 10px 0;
            }

            .searchbar {
                display: flex;
                gap: 8px;
                margin-bottom: 10px;
            }
            .searchbar input {
                flex: 1;
                padding: 8px;
            }
            .searchbar button {
                padding: 8px 12px;
                cursor: pointer;
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                border: 1px solid #ddd;
                padding: 8px;
                vertical-align: top;
            }
            th {
                background: #f5f5f5;
                text-align: left;
            }

            .btn {
                padding: 6px 10px;
                cursor: pointer;
            }
            .btn-primary {
                border: 1px solid #1f6feb;
                background: #1f6feb;
                color: white;
            }
            .btn-danger {
                border: 1px solid #d1242f;
                background: #d1242f;
                color: white;
            }
            .btn-ghost {
                border: 1px solid #bbb;
                background: #fff;
                color: #222;
            }

            .muted {
                color: #666;
                font-size: 12px;
            }
            .row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 10px;
            }
            .field label {
                display: block;
                font-size: 12px;
                color: #444;
                margin-bottom: 4px;
            }
            .field input {
                width: 100%;
                padding: 8px;
            }

            .total {
                display: flex;
                justify-content: space-between;
                margin-top: 10px;
                font-weight: bold;
            }
            .actions {
                display: flex;
                gap: 10px;
                margin-top: 10px;
                align-items: center;
                flex-wrap: wrap;
            }

            .link {
                display: inline-block;
                margin-top: 8px;
            }
        </style>
    </head>
    <div id="errModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,.4); z-index:9999;">
        <div style="width:420px; max-width:calc(100% - 24px); margin:12vh auto; background:#fff; border-radius:12px; padding:16px 18px;">
            <h3 style="margin:0 0 10px;">Thông báo</h3>
            <p id="errMsg" style="margin:0 0 14px; line-height:1.4;"></p>
            <div style="display:flex; justify-content:flex-end; gap:10px;">
                <button type="button" id="errClose"
                        style="padding:10px 14px; border-radius:10px; border:1px solid #ddd; background:#111; color:#fff; cursor:pointer;">
                    OK
                </button>
            </div>
        </div>
    </div>
    <body>

        <div class="container">

            <!-- LEFT: PRODUCTS -->
            <div class="card">
                <h3>Sản phẩm</h3>

                <form method="get" action="pos" class="searchbar">
                    <input name="keyword" value="${param.keyword}" placeholder="Tìm theo tên hoặc SKU..." />
                    <button class="btn btn-ghost" type="submit">Tìm</button>
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
                                <form method="post" action="cart">
                                    <input type="hidden" name="productId" value="${p.id}">
                                    <input type="hidden" name="keyword" value="${param.keyword}">
                                    <button class="btn btn-primary" type="submit">Thêm</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </table>

                <div class="muted" style="margin-top:8px;">
                    Mẹo: dùng ô tìm kiếm để gõ nhanh SKU hoặc tên sản phẩm.
                </div>
            </div>
            <div style="margin-top:12px;">
                <a class="link" href="${pageContext.request.contextPath}/orders">Xem lịch sử đơn hàng</a>
                <span style="margin:0 8px;">|</span>
                <a class="link" href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
            </div>

            <!-- RIGHT: CART + CHECKOUT -->
            <div class="card">
                <h3>Giỏ hàng</h3>

                <c:set var="cart" value="${sessionScope.cart}" />

                <c:if test="${empty cart}">
                    <p class="muted">Chưa có sản phẩm trong giỏ.</p>
                </c:if>

                <c:if test="${not empty cart}">
                    <table>
                        <tr>
                            <th>SKU</th>
                            <th>Tên</th>
                            <th>SL</th>
                            <th>Thành tiền</th>
                            <th></th>
                        </tr>

                        <c:set var="grandTotal" value="0" />
                        <c:forEach items="${cart.values()}" var="it">
                            <tr>
                                <td>${it.sku}</td>
                                <td>${it.name}</td>
                                <td>${it.qty}</td>
                                <td>${it.lineTotal}</td>

                                <!-- Cột hành động: nút - / + -->
                                <td style="white-space:nowrap;">
                                    <form action="${pageContext.request.contextPath}/cart" method="post"
                                          style="display:inline-flex; gap:6px; align-items:center;">
                                        <input type="hidden" name="keyword" value="${param.keyword}"/>
                                        <!-- ✅ SỬA Ở ĐÂY: item -> it -->
                                        <input type="hidden" name="productId" value="${it.productId}"/>

                                        <button type="submit" name="action" value="dec"
                                                style="width:32px;height:32px;border:1px solid #ddd;border-radius:8px;cursor:pointer;">-</button>

                                        <!-- ✅ SỬA Ở ĐÂY: item -> it -->
                                        <span style="min-width:24px; text-align:center; display:inline-block;">${it.qty}</span>

                                        <button type="submit" name="action" value="inc"
                                                style="width:32px;height:32px;border:1px solid #ddd;border-radius:8px;cursor:pointer;">+</button>
                                    </form>
                                </td>
                            </tr>
                            <c:set var="grandTotal" value="${grandTotal + it.lineTotal}" />
                        </c:forEach>
                    </table>

                    <div class="total">
                        <span>Tổng</span>
                        <span>${grandTotal}</span>
                    </div>

                    <form method="post" action="${pageContext.request.contextPath}/checkout" style="margin-top:12px;">
                        <div class="row">
                            <div class="field">
                                <label>Khách hàng</label>
                                <input name="customerName" value="${sessionScope.customerName}" placeholder="Tên khách" />
                            </div>
                            <div class="field">
                                <label>SĐT</label>
                                <input name="customerPhone" value="${sessionScope.customerPhone}" placeholder="Số điện thoại" />
                            </div>
                        </div>

                        <input type="hidden" name="note" value="" />

                        <div class="actions">
                            <button class="btn btn-primary" type="submit">Thanh toán</button>
                        </div>
                    </form>
                </c:if>


            </div>
        </div>

    </body>
</html>
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

            // Xoá err khỏi URL để refresh không bị popup lại
            params.delete("err");
            const newUrl = window.location.pathname + (params.toString() ? "?" + params.toString() : "");
            window.history.replaceState({}, "", newUrl);
        }
    })();
</script>