<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết đơn hàng</title>
        <style>
            .box {
                max-width: 900px;
                margin: 24px auto;
                font-family: Arial;
            }
            .head {
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                gap:16px;
            }
            .meta p {
                margin: 6px 0;
            }
            table {
                width:100%;
                border-collapse: collapse;
                margin-top: 14px;
            }
            th, td {
                border-bottom: 1px solid #eee;
                padding: 10px;
                text-align:left;
            }
            th {
                background:#fafafa;
            }
            .total {
                text-align:right;
                font-weight:700;
                margin-top: 14px;
            }
            .actions {
                margin-top: 16px;
                display:flex;
                gap:10px;
            }
            .btn {
                padding:10px 14px;
                border-radius: 8px;
                border:1px solid #ddd;
                text-decoration:none;
                color:#111;
            }
            .btn-primary {
                background:#111;
                color:#fff;
                border-color:#111;
            }
        </style>
    </head>
    <body>
        <div class="box">
            <div class="head">
                <div>
                    <h2>Chi tiết đơn #${orderHeader.stockOutId}</h2>
                    <div class="meta">
                        <p><b>Thời gian:</b> ${orderHeader.createdAt}</p>
                        <p><b>Khách hàng:</b> ${orderHeader.customerName}</p>
                        <p><b>SĐT:</b> ${orderHeader.customerPhone}</p>
                        <p><b>Sale:</b> ${orderHeader.createdBy}</p>
                        <p><b>Ghi chú:</b> ${orderHeader.note}</p>
                    </div>
                </div>

                <div class="actions" style="flex-direction:column; align-items:flex-end;">
                    <a class="btn btn-primary" target="_blank"
                       href="${pageContext.request.contextPath}/invoice?id=${orderHeader.stockOutId}">
                        In lại hóa đơn
                    </a>
                    <a class="btn" href="${pageContext.request.contextPath}/orders">Quay lại lịch sử</a>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>SKU</th>
                        <th>Tên</th>
                        <th>Giá</th>
                        <th>SL</th>
                        <th>Thành tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="it" items="${orderItems}">
                        <tr>
                            <td>${it.sku}</td>
                            <td>${it.name}</td>
                            <td>${it.price}</td>
                            <td>${it.quantity}</td>
                            <td>${it.lineTotal}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div class="total">Tổng tiền: ${orderHeader.totalAmount}</div>
        </div>
    </body>
</html>