<%-- 
    Document   : stockinDetail
    Created on : 23 thg 3, 2026, 14:05:05
    Author     : dotha
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết phiếu nhập</title>
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
                font-family: Arial, sans-serif;
            }
            body {
                background: #f4f6f9;
                color: #333;
                padding: 30px;
            }
            .container {
                max-width: 1300px;
                margin: 0 auto;
            }
            .page-title {
                font-size: 28px;
                font-weight: bold;
                color: #1f4e79;
                margin-bottom: 16px;
            }
            .top-bar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 12px;
                margin-bottom: 20px;
            }
            .back-link {
                text-decoration: none;
                color: #1f4e79;
                font-weight: bold;
            }
            .back-link:hover {
                text-decoration: underline;
            }
            .btn {
                border: none;
                padding: 10px 16px;
                border-radius: 8px;
                cursor: pointer;
                font-weight: bold;
                font-size: 14px;
                transition: 0.2s;
                text-decoration: none;
                display: inline-block;
            }
            .btn-primary {
                background: #1f4e79;
                color: #fff;
            }
            .btn-primary:hover {
                background: #163a59;
            }
            .btn-warning {
                background: #f59e0b;
                color: #fff;
            }
            .btn-warning:hover {
                background: #d97706;
            }
            .btn-danger {
                background: #d32f2f;
                color: #fff;
            }
            .btn-danger:hover {
                background: #b71c1c;
            }
            .card {
                background: #fff;
                border-radius: 12px;
                padding: 20px;
                margin-bottom: 20px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            }
            .message {
                margin-bottom: 16px;
                padding: 12px 16px;
                border-radius: 8px;
                border: 1px solid;
            }
            .message-success {
                background: #e8f5e9;
                color: #2e7d32;
                border-color: #c8e6c9;
            }
            .message-error {
                background: #ffebee;
                color: #c62828;
                border-color: #ef9a9a;
            }
            .summary-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 16px;
            }
            .summary-item {
                background: #f8fafc;
                border: 1px solid #dbe3eb;
                border-radius: 10px;
                padding: 12px 14px;
            }
            .summary-item strong {
                color: #1f4e79;
            }
            .table-wrapper {
                overflow-x: auto;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 12px;
                border-bottom: 1px solid #e5e7eb;
                text-align: left;
                vertical-align: middle;
            }
            th {
                background: #f1f5f9;
                color: #1f4e79;
                font-weight: bold;
                white-space: nowrap;
            }
            tr:hover td {
                background: #fafcff;
            }
            .text-center {
                text-align: center;
            }
            .money {
                font-weight: bold;
                color: #0f766e;
            }
            .badge {
                display: inline-block;
                padding: 5px 10px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: bold;
                white-space: nowrap;
            }
            .badge-stock-pending {
                background: #fff7ed;
                color: #c2410c;
            }
            .badge-stock-completed {
                background: #dcfce7;
                color: #166534;
            }
            .badge-stock-cancelled {
                background: #fee2e2;
                color: #b91c1c;
            }
            .badge-stock-cancel-requested {
                background: #fef3c7;
                color: #92400e;
            }
            .badge-payment-unpaid {
                background: #f1f5f9;
                color: #475569;
            }
            .badge-payment-partial {
                background: #fef3c7;
                color: #b45309;
            }
            .badge-payment-paid {
                background: #dbeafe;
                color: #1d4ed8;
            }
            .badge-payment-cancelled {
                background: #fee2e2;
                color: #b91c1c;
            }
            .status-stack {
                display: flex;
                flex-direction: column;
                gap: 6px;
            }
            .action-group {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }
            .receive-form {
                display: flex;
                gap: 8px;
                align-items: center;
                flex-wrap: wrap;
            }
            .receive-form input[type="number"] {
                width: 100px;
                padding: 8px;
                border-radius: 6px;
                border: 1px solid #ccc;
            }
            .empty-state {
                text-align: center;
                padding: 24px;
                color: #777;
            }
            .note-box {
                background: #fffaf0;
                border: 1px solid #fcd34d;
                color: #92400e;
                border-radius: 8px;
                padding: 12px 14px;
                margin-top: 14px;
            }
            @media (max-width: 768px) {
                body {
                    padding: 16px;
                }
                .summary-grid {
                    grid-template-columns: 1fr;
                }
                .top-bar {
                    flex-direction: column;
                    align-items: stretch;
                }
                .receive-form {
                    flex-direction: column;
                    align-items: stretch;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="page-title">Chi tiết phiếu nhập #${stockIn.stockInId}</div>

            <div class="top-bar">
                <c:choose>
                    <c:when test="${sessionScope.acc.roleID == 2}">
                        <a class="back-link" href="${pageContext.request.contextPath}/notifications">← Quay lại</a>
                    </c:when>
                    <c:otherwise>
                        <a class="back-link" href="stockinList">← Quay lại danh sách phiếu nhập</a>
                    </c:otherwise>
                </c:choose>

                <div class="action-group">
                    <c:if test="${sessionScope.acc.roleID == 2 && stockIn.stockStatus == 'CancelRequested'}">
                        <form action="stockinDetail" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="approveCancel">
                            <input type="hidden" name="stockInId" value="${stockIn.stockInId}">
                            <button type="submit" class="btn btn-danger">Duyệt hủy</button>
                        </form>

                        <form action="stockinDetail" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="rejectCancel">
                            <input type="hidden" name="stockInId" value="${stockIn.stockInId}">
                            <button type="submit" class="btn btn-warning">Từ chối hủy</button>
                        </form>
                    </c:if>
                </div>
            </div>

            <c:if test="${param.success == 'received'}">
                <div class="message message-success">Nhận hàng thành công.</div>
            </c:if>
            <c:if test="${param.success == 'approveCancel'}">
                <div class="message message-success">Duyệt hủy phiếu thành công.</div>
            </c:if>
            <c:if test="${param.success == 'rejectCancel'}">
                <div class="message message-success">Từ chối hủy phiếu thành công.</div>
            </c:if>

            <c:if test="${not empty message}">
                <div class="message ${messageType == 'error' ? 'message-error' : 'message-success'}">
                    ${message}
                </div>
            </c:if>

            <div class="card">
                <h3 style="margin-bottom:16px; color:#1f4e79;">Thông tin phiếu nhập</h3>

                <div class="summary-grid">
                    <div class="summary-item"><strong>Mã phiếu:</strong> #${stockIn.stockInId}</div>
                    <div class="summary-item"><strong>Ngày tạo:</strong> <fmt:formatDate value="${stockIn.date}" pattern="dd/MM/yyyy HH:mm"/></div>
                    <div class="summary-item"><strong>Nhà cung cấp:</strong> ${stockIn.supplierName}</div>
                    <div class="summary-item"><strong>Người tạo:</strong> ${stockIn.staffName}</div>
                    <div class="summary-item">
                        <strong>Tổng số lượng:</strong>
                        ${stockIn.totalOrderedQuantity} / ${stockIn.totalReceivedQuantity} / ${stockIn.totalRemainingQuantity}
                        <br>
                        <span style="font-size:13px; color:#666;">Đặt / Đã nhận / Còn</span>
                    </div>
                    <div class="summary-item">
                        <strong>Tổng tiền:</strong>
                        <span class="money">
                            <fmt:formatNumber value="${stockIn.totalAmountCalculated}" type="number" groupingUsed="true"/>
                        </span>
                    </div>
                    <div class="summary-item">
                        <strong>Thanh toán ban đầu:</strong>
                        <span class="money">
                            <fmt:formatNumber value="${stockIn.initialPaidAmount}" type="number" groupingUsed="true"/>
                        </span>
                    </div>

                    <div class="summary-item">
                        <strong>Công nợ phát sinh:</strong>
                        <span class="money">
                            <fmt:formatNumber value="${stockIn.totalAmountCalculated - stockIn.initialPaidAmount}" type="number" groupingUsed="true"/>
                        </span>
                    </div>
                    <div class="summary-item">
                        <strong>Trạng thái nhập:</strong>
                        <div style="margin-top:6px;">
                            <c:choose>
                                <c:when test="${stockIn.stockStatus == 'Pending'}">
                                    <span class="badge badge-stock-pending">Pending</span>
                                </c:when>
                                <c:when test="${stockIn.stockStatus == 'Completed'}">
                                    <span class="badge badge-stock-completed">Completed</span>
                                </c:when>
                                <c:when test="${stockIn.stockStatus == 'CancelRequested'}">
                                    <span class="badge badge-stock-cancel-requested">CancelRequested</span>
                                </c:when>
                                <c:when test="${stockIn.stockStatus == 'Cancelled'}">
                                    <span class="badge badge-stock-cancelled">Cancelled</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge">${stockIn.stockStatus}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="summary-item">
                        <strong>Trạng thái thanh toán:</strong>
                        <div style="margin-top:6px;">
                            <c:choose>
                                <c:when test="${stockIn.paymentStatus == 'Unpaid'}">
                                    <span class="badge badge-payment-unpaid">Unpaid</span>
                                </c:when>
                                <c:when test="${stockIn.paymentStatus == 'Partial'}">
                                    <span class="badge badge-payment-partial">Partial</span>
                                </c:when>
                                <c:when test="${stockIn.paymentStatus == 'Paid'}">
                                    <span class="badge badge-payment-paid">Paid</span>
                                </c:when>
                                <c:when test="${stockIn.paymentStatus == 'Cancelled'}">
                                    <span class="badge badge-payment-cancelled">Cancelled</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge">${stockIn.paymentStatus}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <div style="margin-top:16px;">
                    <strong style="color:#1f4e79;">Ghi chú:</strong>
                    <div style="margin-top:8px; color:#555;">
                        <c:choose>
                            <c:when test="${not empty stockIn.note}">
                                ${stockIn.note}
                            </c:when>
                            <c:otherwise>
                                <span style="color:#999;">Không có ghi chú</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <c:if test="${not empty stockIn.cancelRequestNote}">
                    <div class="note-box">
                        <strong>Lý do yêu cầu hủy:</strong> ${stockIn.cancelRequestNote}
                    </div>
                </c:if>
            </div>
            <c:if test="${sessionScope.acc.roleID == 1}">
                <div class="card">
                    <h3 style="margin-bottom:16px; color:#1f4e79;">Chi tiết hàng nhập</h3>

                    <div class="table-wrapper">
                        <table>
                            <thead>
                                <tr>
                                    <th>Detail ID</th>
                                    <th>Product ID</th>
                                    <th>Tên sản phẩm</th>
                                    <th>SKU</th>
                                    <th>ĐVT</th>
                                    <th class="text-center">Số lượng đặt</th>
                                    <th class="text-center">Đã nhận</th>
                                    <th class="text-center">Còn lại</th>
                                    <th>Giá nhập</th>
                                    <th>Thành tiền</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:if test="${empty details}">
                                    <tr>
                                        <td colspan="11" class="empty-state">Không có chi tiết phiếu nhập.</td>
                                    </tr>
                                </c:if>

                                <c:forEach var="d" items="${details}">
                                    <tr>
                                        <td>${d.detailId}</td>
                                        <td>${d.productId}</td>
                                        <td>${d.productName}</td>
                                        <td>${d.sku}</td>
                                        <td>${d.unit}</td>
                                        <td class="text-center">${d.quantity}</td>
                                        <td class="text-center">${d.receivedQuantity}</td>
                                        <td class="text-center">${d.quantity - d.receivedQuantity}</td>
                                        <td class="money">
                                            <fmt:formatNumber value="${d.unitCost}" type="number" groupingUsed="true"/>
                                        </td>
                                        <td class="money">
                                            <fmt:formatNumber value="${d.subTotal}" type="number" groupingUsed="true"/>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${stockIn.stockStatus == 'Pending' && (d.quantity - d.receivedQuantity) > 0}">
                                                    <form action="stockinDetail" method="post" class="receive-form">
                                                        <input type="hidden" name="action" value="receive">
                                                        <input type="hidden" name="stockInId" value="${stockIn.stockInId}">
                                                        <input type="hidden" name="detailId" value="${d.detailId}">

                                                        <input type="number"
                                                               name="receiveQty"
                                                               min="1"
                                                               max="${d.quantity - d.receivedQuantity}"
                                                               placeholder="SL nhận"
                                                               required>

                                                        <button type="submit" class="btn btn-primary">Nhận hàng</button>
                                                    </form>
                                                </c:when>

                                                <c:when test="${(d.quantity - d.receivedQuantity) <= 0}">
                                                    <span class="badge badge-stock-completed">Đã nhận đủ</span>
                                                </c:when>

                                                <c:otherwise>
                                                    <span style="color:#777;">Không thể thao tác</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>
        </div>
    </body>
</html>
