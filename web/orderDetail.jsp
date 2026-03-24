<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết đơn hàng #${orderHeader.stockOutId}</title>
        <style>
            .detail-container {
                padding: 20px;
                max-width: 800px;
                margin: auto;
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .detail-header {
                display: flex;
                justify-content: space-between;
                border-bottom: 2px solid #eee;
                padding-bottom: 15px;
                margin-bottom: 20px;
            }
            .info-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
                margin-bottom: 30px;
            }
            .info-item label {
                color: #666;
                font-size: 13px;
                display: block;
                margin-bottom: 5px;
            }
            .info-item span {
                font-weight: bold;
                font-size: 15px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
            }
            table th {
                background: #f8fafc;
                padding: 12px;
                text-align: left;
                border-bottom: 2px solid #e2e8f0;
            }
            table td {
                padding: 12px;
                border-bottom: 1px solid #eee;
            }
            .total-section {
                margin-top: 20px;
                text-align: right;
                border-top: 2px solid #eee;
                padding-top: 15px;
            }
            .total-row {
                font-size: 18px;
                font-weight: bold;
                color: #3b82f6;
            }
            .btn-back {
                display: inline-block;
                padding: 10px 20px;
                background: #64748b;
                color: #fff;
                text-decoration: none;
                border-radius: 4px;
                margin-bottom: 20px;
            }
        </style>
    </head>
    <body>
        <div class="detail-container">
            <c:choose>
                <c:when test="${sessionScope.acc.roleID == 2}">
                    <a href="${pageContext.request.contextPath}/notifications" class="btn-back">⬅ Quay lại</a>
                </c:when>
                <c:otherwise>
                    <a href="sales_dashboard?tab=orders" class="btn-back">⬅ Quay lại danh sách</a>
                </c:otherwise>
            </c:choose>

            <div class="detail-header">
                <h2 style="margin:0;">Chi tiết đơn hàng #${orderHeader.stockOutId}</h2>
                <span style="padding: 5px 10px; background: #dcfce7; color: #166534; border-radius: 20px; font-size: 12px; font-weight: bold;">Hoàn tất</span>
            </div>

            <div class="info-grid">
                <div class="info-item">
                    <label>Khách hàng</label>
                    <span>${not empty orderHeader.customerName ? orderHeader.customerName : "Khách vãng lai"}</span>
                </div>
                <div class="info-item">
                    <label>Số điện thoại</label>
                    <span>${not empty orderHeader.customerPhone ? orderHeader.customerPhone : "---"}</span>
                </div>
                <div class="info-item">
                    <label>Ngày tạo</label>
                    <span>${orderHeader.createdAt}</span>
                </div>
                <div class="info-item">
                    <label>Người lập đơn</label>
                    <span>${orderHeader.createdBy}</span>
                </div>
            </div>

            <c:if test="${not empty orderHeader.note}">
                <div style="background: #fff9db; padding: 10px; border-radius: 4px; margin-bottom: 20px; font-style: italic;">
                    <strong>Ghi chú:</strong> ${orderHeader.note}
                </div>
            </c:if>

            <table>
                <thead>
                    <tr>
                        <th>Sản phẩm</th>
                        <th>SKU</th>
                        <th style="text-align: center;">Số lượng</th>
                        <th style="text-align: right;">Đơn giá</th>
                        <th style="text-align: right;">Thành tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${orderItems}" var="item">
                        <tr>
                            <td>${item.name}</td>
                            <td><code style="background:#f1f5f9; padding:2px 4px;">${item.sku}</code></td>
                            <td style="text-align: center;">${item.quantity}</td>
                            <td style="text-align: right;"><fmt:formatNumber value="${item.price}" type="number"/>đ</td>
                            <td style="text-align: right; font-weight: bold;">
                                <fmt:formatNumber value="${item.lineTotal}" type="number"/>đ
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div class="total-section">
                <div class="total-row">
                    Tổng cộng: <fmt:formatNumber value="${orderHeader.totalAmount}" type="number"/> VNĐ
                </div>
            </div>
        </div>
    </body>
</html>