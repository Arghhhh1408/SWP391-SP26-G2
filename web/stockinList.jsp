<%-- 
    Document   : stockinList
    Created on : 26 thg 2, 2026, 15:51:39
    Author     : dotha
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Danh sách phiếu nhập hàng</title>
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
            .note-cell {
                max-width: 240px;
                white-space: normal;
                color: #555;
            }
            .action-group {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
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
            .empty-state {
                text-align: center;
                padding: 24px;
                color: #777;
            }
            .summary-bar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 10px;
                margin-bottom: 16px;
            }
            .summary-item {
                background: #f8fafc;
                border: 1px solid #dbe3eb;
                border-radius: 10px;
                padding: 10px 14px;
                font-size: 14px;
            }
            .inline-form {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
                align-items: center;
            }
            .inline-form input[type="text"] {
                padding: 8px 10px;
                border-radius: 6px;
                border: 1px solid #ccc;
                min-width: 180px;
            }
            @media (max-width: 768px) {
                body {
                    padding: 16px;
                }
                .top-bar, .summary-bar {
                    flex-direction: column;
                    align-items: stretch;
                }
                .action-group {
                    flex-direction: column;
                }
                .inline-form {
                    flex-direction: column;
                    align-items: stretch;
                }
                .inline-form input[type="text"] {
                    min-width: 100%;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="page-title">Danh sách phiếu nhập hàng</div>

            <div class="top-bar">
                <div>
                    <c:if test="${sessionScope.acc.roleID == 1}">
                        <a class="back-link" href="staff_dashboard?action=clear&redirect=1">← Quay lại bảng điều khiển của nhân viên</a>
                    </c:if>
                    <c:if test="${sessionScope.acc.roleID == 2}">
                        <a class="back-link" href="category?action=clear&redirect=1">← Quay lại bảng điều khiển của quản lý</a>
                    </c:if>
                </div>

                <div>
                    <a href="createStockIn" class="btn btn-primary">+ Tạo phiếu nhập hàng</a>
                </div>
            </div>

            <c:if test="${not empty message}">
                <div class="message ${messageType == 'error' ? 'message-error' : 'message-success'}">
                    ${message}
                </div>
            </c:if>

            <div class="card">
                <div class="summary-bar">
                    <div class="summary-item">
                        <strong>Tổng số phiếu:</strong>
                        <c:choose>
                            <c:when test="${not empty stockList}">${stockList.size()}</c:when>
                            <c:otherwise>0</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="summary-item">
                        Theo dõi tình trạng nhập kho, công nợ và yêu cầu hủy của từng phiếu nhập.
                    </div>
                </div>

                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Mã phiếu</th>
                                <th>Ngày tạo</th>
                                <th>Nhà cung cấp</th>
                                <th>Nhân viên tạo</th>
                                <th class="text-center">Đặt / Đã nhận / Còn</th>
                                <th>Thanh toán ban đầu</th>
                                <th>Giá trị phiếu</th>
                                <th>Trạng thái</th>
                                <th>Ghi chú</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>

                        <tbody>
                            <c:if test="${empty stockList}">
                                <tr>
                                    <td colspan="9" class="empty-state">Không có phiếu nhập hàng nào</td>
                                </tr>
                            </c:if>

                            <c:if test="${not empty stockList}">
                                <c:forEach var="s" items="${stockList}">
                                    <tr>
                                        <td><strong>#${s.stockInId}</strong></td>

                                        <td>
                                            <fmt:formatDate value="${s.date}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>

                                        <td>${s.supplierName}</td>
                                        <td>${s.staffName}</td>

                                        <td class="text-center">
                                            ${s.totalOrderedQuantity} / ${s.totalReceivedQuantity} / ${s.totalRemainingQuantity}
                                        </td>

                                        <td class="money">
                                            <fmt:formatNumber value="${s.initialPaidAmount}" type="number" groupingUsed="true"/>
                                        </td>

                                        <td class="money">
                                            <fmt:formatNumber value="${s.totalAmountCalculated}" type="number" groupingUsed="true"/>
                                        </td>

                                        <td>
                                            <div class="status-stack">
                                                <c:choose>
                                                    <c:when test="${s.stockStatus == 'Pending'}">
                                                        <span class="badge badge-stock-pending">Nhập hàng: Pending</span>
                                                    </c:when>
                                                    <c:when test="${s.stockStatus == 'Completed'}">
                                                        <span class="badge badge-stock-completed">Nhập hàng: Completed</span>
                                                    </c:when>
                                                    <c:when test="${s.stockStatus == 'CancelRequested'}">
                                                        <span class="badge badge-stock-cancel-requested">Nhập hàng: Chờ duyệt hủy</span>
                                                    </c:when>
                                                    <c:when test="${s.stockStatus == 'Cancelled'}">
                                                        <span class="badge badge-stock-cancelled">Nhập hàng: Cancelled</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge">${s.stockStatus}</span>
                                                    </c:otherwise>
                                                </c:choose>

                                                <c:choose>
                                                    <c:when test="${s.paymentStatus == 'Unpaid'}">
                                                        <span class="badge badge-payment-unpaid">Thanh toán: Unpaid</span>
                                                    </c:when>
                                                    <c:when test="${s.paymentStatus == 'Partial'}">
                                                        <span class="badge badge-payment-partial">Thanh toán: Partial</span>
                                                    </c:when>
                                                    <c:when test="${s.paymentStatus == 'Paid'}">
                                                        <span class="badge badge-payment-paid">Thanh toán: Paid</span>
                                                    </c:when>
                                                    <c:when test="${s.paymentStatus == 'Cancelled'}">
                                                        <span class="badge badge-payment-cancelled">Thanh toán: Cancelled</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge">${s.paymentStatus}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>

                                        <td class="note-cell">
                                            <c:choose>
                                                <c:when test="${not empty s.note}">
                                                    ${s.note}
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:#999;">Không có ghi chú</span>
                                                </c:otherwise>
                                            </c:choose>

                                            <c:if test="${not empty s.cancelRequestNote}">
                                                <div style="margin-top:6px; color:#b45309;">
                                                    <strong>Lý do hủy:</strong> ${s.cancelRequestNote}
                                                </div>
                                            </c:if>
                                        </td>

                                        <td>
                                            <div class="action-group">
                                                <a href="stockinDetail?id=${s.stockInId}" class="btn btn-primary">
                                                    Chi tiết
                                                </a>

                                                <c:if test="${sessionScope.acc.roleID == 1 
                                                              && s.stockStatus == 'Pending'
                                                              && s.totalReceivedQuantity == 0
                                                              && s.paymentStatus == 'Unpaid'}">
                                                      <form action="stockinList" method="get" class="inline-form">
                                                          <input type="hidden" name="action" value="requestCancel">
                                                          <input type="hidden" name="id" value="${s.stockInId}">
                                                          <input type="text" name="reason" placeholder="Nhập lý do hủy" required>
                                                          <button type="submit" class="btn btn-danger">Yêu cầu hủy</button>
                                                      </form>
                                                </c:if>

                                                <c:if test="${sessionScope.acc.roleID == 2 && s.stockStatus == 'CancelRequested'}">
                                                    <a href="stockinList?action=approveCancel&id=${s.stockInId}" class="btn btn-danger">
                                                        Duyệt hủy
                                                    </a>
                                                    <a href="stockinList?action=rejectCancel&id=${s.stockInId}" class="btn btn-warning">
                                                        Từ chối hủy
                                                    </a>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </body>
</html>