<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Giỏ hàng</title>
        <style>
            body{
                font-family: Arial, sans-serif;
                background:#f6f8fb;
                margin:0;
                padding:24px;
                color:#111827;
            }

            .wrap{
                max-width:1000px;
                margin:0 auto;
            }

            .card{
                background:#fff;
                border:1px solid #e5e7eb;
                border-radius:16px;
                padding:20px;
                box-shadow:0 6px 24px rgba(0,0,0,.06);
            }

            h2, h3{
                margin:0 0 16px 0;
            }

            table{
                width:100%;
                border-collapse:collapse;
                margin-bottom:16px;
            }

            th, td{
                border:1px solid #e5e7eb;
                padding:10px 12px;
                text-align:left;
                vertical-align:middle;
            }

            th{
                background:#f9fafb;
                font-weight:700;
            }

            .money{
                font-weight:700;
                white-space:nowrap;
            }

            .total-row td{
                font-weight:700;
                background:#fafafa;
            }

            .qty-box{
                display:inline-flex;
                align-items:center;
                gap:6px;
            }

            .qty-btn{
                width:32px;
                height:32px;
                border:1px solid #d1d5db;
                background:#fff;
                border-radius:8px;
                cursor:pointer;
                font-size:16px;
                font-weight:700;
            }

            .qty-btn:hover{
                background:#f3f4f6;
            }

            .qty-number{
                min-width:28px;
                text-align:center;
                font-weight:700;
                display:inline-block;
            }

            .btn{
                padding:10px 14px;
                border:none;
                border-radius:10px;
                cursor:pointer;
                font-size:14px;
                text-decoration:none;
                display:inline-flex;
                align-items:center;
                justify-content:center;
            }

            .btn-primary{
                background:#2563eb;
                color:#fff;
            }

            .btn-primary:hover{
                background:#1d4ed8;
            }

            .btn-danger{
                background:#dc2626;
                color:#fff;
            }

            .btn-danger:hover{
                background:#b91c1c;
            }

            .btn-ghost{
                background:#fff;
                color:#111827;
                border:1px solid #d1d5db;
            }

            .btn-ghost:hover{
                background:#f9fafb;
            }

            .grid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:14px;
                margin-top:12px;
            }

            .field label{
                display:block;
                margin-bottom:6px;
                font-size:13px;
                color:#374151;
                font-weight:600;
            }

            .field input{
                width:100%;
                padding:10px 12px;
                border:1px solid #d1d5db;
                border-radius:10px;
                font-size:14px;
                box-sizing:border-box;
            }

            .actions{
                display:flex;
                gap:10px;
                margin-top:16px;
                flex-wrap:wrap;
            }

            .empty{
                padding:16px;
                border:1px dashed #cbd5e1;
                border-radius:12px;
                background:#f8fafc;
                color:#475569;
            }

            .top-link{
                display:inline-block;
                margin-bottom:16px;
                color:#2563eb;
                text-decoration:none;
                font-weight:600;
            }

            .top-link:hover{
                text-decoration:underline;
            }

            @media (max-width: 768px){
                .grid{
                    grid-template-columns:1fr;
                }

                table{
                    font-size:14px;
                }

                th, td{
                    padding:8px;
                }
            }
        </style>
    </head>
    <body>
        <div class="wrap">

            <a class="top-link" href="${pageContext.request.contextPath}/pos">← Quay lại POS</a>

            <div class="card">
                <h2>Giỏ hàng</h2>

                <c:set var="cart" value="${sessionScope.cart}" />

                <c:if test="${empty cart}">
                    <div class="empty">Chưa có sản phẩm trong giỏ.</div>
                </c:if>

                <c:if test="${not empty cart}">
                    <table>
                        <tr>
                            <th>SKU</th>
                            <th>Tên</th>
                            <th>Giá</th>
                            <th>SL</th>
                            <th>Thành tiền</th>
                            <th>Thao tác</th>
                        </tr>

                        <c:set var="grandTotal" value="0" />
                        <c:forEach items="${cart.values()}" var="it">
                            <tr>
                                <td>${it.sku}</td>
                                <td>${it.name}</td>
                                <td class="money">${it.price}</td>
                                <td>
                                    <div class="qty-box">
                                        <form method="post" action="${pageContext.request.contextPath}/cart" style="display:inline;">
                                            <input type="hidden" name="action" value="dec">
                                            <input type="hidden" name="from" value="cart">
                                            <input type="hidden" name="productId" value="${it.productId}">
                                            <button class="qty-btn" type="submit">-</button>
                                        </form>

                                        <span class="qty-number">${it.qty}</span>

                                        <form method="post" action="${pageContext.request.contextPath}/cart" style="display:inline;">
                                            <input type="hidden" name="action" value="inc">
                                            <input type="hidden" name="from" value="cart">
                                            <input type="hidden" name="productId" value="${it.productId}">
                                            <button class="qty-btn" type="submit">+</button>
                                        </form>
                                    </div>
                                </td>
                                <td class="money">${it.lineTotal}</td>
                                <td>
                                    <form method="post" action="${pageContext.request.contextPath}/cart" style="display:inline;">
                                        <input type="hidden" name="action" value="remove">
                                        <input type="hidden" name="from" value="cart">
                                        <input type="hidden" name="productId" value="${it.productId}">
                                        <button class="btn btn-danger" type="submit">Xóa</button>
                                    </form>
                                </td>
                            </tr>
                            <c:set var="grandTotal" value="${grandTotal + it.lineTotal}" />
                        </c:forEach>

                        <tr class="total-row">
                            <td colspan="4">Tổng</td>
                            <td colspan="2" class="money">${grandTotal}</td>
                        </tr>
                    </table>

                    <h3>Thông tin khách</h3>

                    <script>
                        function openInvoicePopup(form) {
                            const popup = window.open('', 'invoiceWindow', 'width=520,height=760');
                            form.target = 'invoiceWindow';
                            form.submit();
                        }
                    </script>

                    <form method="post"
                          action="${pageContext.request.contextPath}/checkout"
                          onsubmit="openInvoicePopup(this); return false;">

                        <div class="grid">
                            <div class="field">
                                <label for="customerName">Khách hàng</label>
                                <input id="customerName"
                                       name="customerName"
                                       value="${sessionScope.customerName}"
                                       placeholder="Tên khách">
                            </div>

                            <div class="field">
                                <label for="customerPhone">SĐT</label>
                                <input id="customerPhone"
                                       name="customerPhone"
                                       value="${sessionScope.customerPhone}"
                                       placeholder="Số điện thoại">
                            </div>
                        </div>

                        <input type="hidden" name="note" value="">

                        <div class="actions">
                            <button class="btn btn-primary" type="submit">Thanh toán</button>
                            <a class="btn btn-ghost" href="${pageContext.request.contextPath}/pos">← Quay lại POS</a>
                        </div>
                    </form>
                </c:if>
            </div>
        </div>
    </body>
</html>
<script>
document.getElementById("customerPhone").addEventListener("blur", function () {
    let phone = this.value.trim();
    if (phone.length < 5) return;

    fetch("${pageContext.request.contextPath}/customer-search?phone=" + encodeURIComponent(phone))
        .then(res => res.json())
        .then(data => {
            if (data.name) {
                document.getElementById("customerName").value = data.name;
            }
        })
        .catch(err => console.error(err));
});
</script>