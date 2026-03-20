<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết đơn hàng</title>
        <style>
            body{
                margin:0;
                background:#f4f6f9;
                font-family:Arial, sans-serif;
                color:#111827;
            }

            .box{
                max-width:1000px;
                margin:24px auto;
                background:#fff;
                border:1px solid #e5e7eb;
                border-radius:16px;
                padding:24px;
                box-shadow:0 2px 8px rgba(0,0,0,0.04);
            }

            .head{
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                gap:16px;
                margin-bottom:16px;
            }

            .meta p{
                margin:8px 0;
                font-size:16px;
            }

            table{
                width:100%;
                border-collapse:collapse;
                margin-top:18px;
            }

            th, td{
                border-bottom:1px solid #e5e7eb;
                padding:12px 10px;
                text-align:left;
                vertical-align:middle;
            }

            th{
                background:#f9fafb;
                font-weight:700;
            }

            .money{
                font-weight:600;
                white-space:nowrap;
            }

            .total{
                text-align:right;
                font-weight:700;
                margin-top:16px;
                font-size:24px;
            }

            .actions{
                margin-top:16px;
                display:flex;
                gap:10px;
            }

            .btn{
                padding:10px 14px;
                border-radius:10px;
                border:1px solid #d1d5db;
                text-decoration:none;
                color:#111;
                background:#fff;
                display:inline-block;
            }

            .btn-primary{
                background:#111;
                color:#fff;
                border-color:#111;
            }

            .btn:hover{
                opacity:.95;
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
                        <p><b>Khách hàng:</b> ${empty orderHeader.customerName ? 'Khách lẻ' : orderHeader.customerName}</p>
                        <p><b>SĐT:</b> ${empty orderHeader.customerPhone ? '-' : orderHeader.customerPhone}</p>
                        <p><b>Sale:</b> ${orderHeader.createdBy}</p>
                        <p><b>Ghi chú:</b> ${empty orderHeader.note ? 'Không có' : orderHeader.note}</p>
                    </div>
                </div>

                <div class="actions" style="flex-direction:column; align-items:flex-end;">
                    <a class="btn btn-primary" target="_blank"
                       href="${pageContext.request.contextPath}/invoice?id=${orderHeader.stockOutId}">
                        In lại hóa đơn
                    </a>
                    <a class="btn" href="${pageContext.request.contextPath}/orders">
                        Quay lại lịch sử
                    </a>
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
                            <td class="money">
                                <fmt:formatNumber value="${it.price}" type="number" groupingUsed="true"/> đ
                            </td>
                            <td>${it.quantity}</td>
                            <td class="money">
                                <fmt:formatNumber value="${it.lineTotal}" type="number" groupingUsed="true"/> đ
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div class="total">
                Tổng tiền:
                <fmt:formatNumber value="${orderHeader.totalAmount}" type="number" groupingUsed="true"/> đ
            </div>
        </div>
    </body>
</html>