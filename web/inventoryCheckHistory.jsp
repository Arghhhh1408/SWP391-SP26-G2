<%-- 
    Document   : inventoryCheckDetail
    Created on : 16 thg 3, 2026, 17:01:42
    Author     : dotha
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Lịch sử kiểm kê sản phẩm</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 24px;
                background: #f5f7fa;
                color: #333;
            }

            .container {
                max-width: 1200px;
                margin: 0 auto;
            }

            .top-link {
                margin-bottom: 18px;
            }

            .top-link a {
                text-decoration: none;
                color: #1976d2;
                font-weight: bold;
            }

            .card {
                background: #fff;
                border-radius: 14px;
                padding: 24px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            }

            h2 {
                margin-top: 0;
                margin-bottom: 10px;
                color: #0d274d;
            }

            .product-summary {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 14px;
                margin-bottom: 24px;
            }

            .summary-box {
                background: #f8fbff;
                border: 1px solid #e2ebf5;
                border-radius: 12px;
                padding: 14px 16px;
            }

            .summary-label {
                font-size: 13px;
                color: #60758f;
                margin-bottom: 6px;
            }

            .summary-value {
                font-size: 16px;
                font-weight: 700;
                color: #0d274d;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                background: #fff;
            }

            th, td {
                border: 1px solid #e2e8f0;
                padding: 10px 12px;
                text-align: center;
                vertical-align: middle;
            }

            th {
                background-color: #1976d2;
                color: white;
                font-size: 14px;
            }

            tr:nth-child(even) {
                background: #fafcff;
            }

            .match {
                color: #2e7d32;
                font-weight: bold;
            }

            .excess {
                color: #ef6c00;
                font-weight: bold;
            }

            .shortage {
                color: #c62828;
                font-weight: bold;
            }

            .badge {
                display: inline-block;
                padding: 6px 12px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: 700;
                white-space: nowrap;
            }

            .badge-pending {
                background: #ffe9cc;
                color: #d77a00;
            }

            .badge-completed {
                background: #d7f4df;
                color: #169b45;
            }

            .badge-recount {
                background: #ffdfe0;
                color: #ef3c3c;
            }

            .badge-default {
                background: #eceff3;
                color: #4a6078;
            }

            .reason-box {
                text-align: left;
                min-width: 180px;
                line-height: 1.5;
                color: #4a6078;
            }

            .action-link {
                display: inline-block;
                padding: 8px 14px;
                border-radius: 8px;
                text-decoration: none;
                font-weight: bold;
                background: #e3f2fd;
                color: #1565c0;
            }

            .empty-box {
                background: #fff;
                border-radius: 10px;
                padding: 18px;
                color: #6c7f95;
                box-shadow: 0 2px 8px rgba(0,0,0,0.05);
                margin-top: 18px;
            }

            .actions {
                margin-top: 22px;
            }

            .back-btn {
                display: inline-block;
                text-decoration: none;
                background: #e3f2fd;
                color: #1565c0;
                padding: 10px 18px;
                border-radius: 8px;
                font-weight: bold;
            }

            @media (max-width: 900px) {
                .product-summary {
                    grid-template-columns: 1fr 1fr;
                }
            }

            @media (max-width: 600px) {
                .product-summary {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">

            <div class="card">
                <h2>Lịch sử kiểm kê sản phẩm</h2>

                <c:if test="${not empty productInfo}">
                    <div class="product-summary">
                        <div class="summary-box">
                            <div class="summary-label">Product ID</div>
                            <div class="summary-value">${productInfo.productId}</div>
                        </div>

                        <div class="summary-box">
                            <div class="summary-label">SKU</div>
                            <div class="summary-value">${productInfo.sku}</div>
                        </div>

                        <div class="summary-box">
                            <div class="summary-label">Tên sản phẩm</div>
                            <div class="summary-value">${productInfo.productName}</div>
                        </div>

                        <div class="summary-box">
                            <div class="summary-label">Đơn vị tính</div>
                            <div class="summary-value">${productInfo.unit}</div>
                        </div>
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${not empty historyList}">
                        <table>
                            <thead>
                                <tr>
                                    <th>Count ID</th>
                                    <th>Session Code</th>
                                    <th>Tồn hệ thống</th>
                                    <th>Thực tế</th>
                                    <th>Chênh lệch</th>
                                    <th>Lý do</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày kiểm kê</th>
                                    <th>Người duyệt</th>
                                    <th>Chi tiết</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="h" items="${historyList}">
                                    <tr>
                                        <td>${h.countId}</td>
                                        <td>${h.sessionCode}</td>
                                        <td>${h.systemQuantity}</td>
                                        <td>${h.physicalQuantity}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${h.variance == 0}">
                                                    <span class="match">0 (Khớp)</span>
                                                </c:when>
                                                <c:when test="${h.variance > 0}">
                                                    <span class="excess">+${h.variance} (Dư)</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="shortage">${h.variance} (Thiếu)</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="reason-box">
                                            <c:choose>
                                                <c:when test="${not empty h.reason}">
                                                    ${h.reason}
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:#94a3b8;font-style:italic;">Không có</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${h.status == 'Pending'}">
                                                    <span class="badge badge-pending">Pending</span>
                                                </c:when>
                                                <c:when test="${h.status == 'Approved'}">
                                                    <span class="badge badge-completed">Approved</span>
                                                </c:when>
                                                <c:when test="${h.status == 'Rejected'}">
                                                    <span class="badge badge-recount">Rejected</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-default">${h.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${h.date}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${h.approvedBy != null}">
                                                    ${h.approvedBy}
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:#94a3b8;font-style:italic;">Chưa duyệt</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <a class="action-link" href="inventoryCheck?mode=view&id=${h.countId}">View</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>

                    <c:otherwise>
                        <div class="empty-box">
                            Không có lịch sử kiểm kê cho sản phẩm này.
                        </div>
                    </c:otherwise>
                </c:choose>

                <div class="actions">
                    <a href="inventoryCheck" class="back-btn">← Quay lại Inventory Check</a>
                </div>
            </div>
        </div>
    </body>
</html>
