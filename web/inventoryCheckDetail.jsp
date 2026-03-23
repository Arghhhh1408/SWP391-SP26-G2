<%-- 
    Document   : inventoryCheckDetail
    Created on : 23 thg 3, 2026, 17:31:34
    Author     : dotha
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết kiểm kê kho</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 24px;
                background: #f5f7fa;
                color: #333;
            }

            .container {
                max-width: 950px;
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
                padding: 28px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            }

            h2 {
                margin-top: 0;
                margin-bottom: 20px;
                color: #0d274d;
            }

            .summary-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 16px;
                margin-bottom: 20px;
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

            .detail-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 10px;
            }

            .detail-table tr {
                border-bottom: 1px solid #edf2f7;
            }

            .detail-table td {
                padding: 14px 10px;
                vertical-align: top;
            }

            .detail-table td:first-child {
                width: 240px;
                font-weight: bold;
                color: #37506d;
                background: #fafcff;
            }

            .detail-table td:last-child {
                color: #2f3d4a;
            }

            .match {
                color: #169b45;
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
                padding: 8px 14px;
                border-radius: 999px;
                font-size: 13px;
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
                background: #f8fbff;
                border-left: 4px solid #90caf9;
                padding: 12px 14px;
                border-radius: 8px;
                line-height: 1.6;
                color: #46627f;
            }

            .empty-note {
                color: #94a3b8;
                font-style: italic;
            }

            .actions {
                margin-top: 24px;
                display: flex;
                flex-wrap: wrap;
                gap: 12px;
            }

            .btn {
                display: inline-block;
                padding: 10px 18px;
                border-radius: 8px;
                text-decoration: none;
                font-weight: bold;
            }

            .btn-back {
                background: #e3f2fd;
                color: #1565c0;
            }

            .btn-edit {
                background: #fff3e0;
                color: #ef6c00;
            }

            @media (max-width: 700px) {
                .summary-grid {
                    grid-template-columns: 1fr;
                }

                .detail-table td:first-child {
                    width: 160px;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">

            <div class="card">
                <h2>Chi tiết kiểm kê kho</h2>

                <div class="summary-grid">
                    <div class="summary-box">
                        <div class="summary-label">Count ID</div>
                        <div class="summary-value">${item.countId}</div>
                    </div>

                    <div class="summary-box">
                        <div class="summary-label">Session Code</div>
                        <div class="summary-value">${item.sessionCode}</div>
                    </div>

                    <div class="summary-box">
                        <div class="summary-label">Product ID</div>
                        <div class="summary-value">${item.productId}</div>
                    </div>

                    <div class="summary-box">
                        <div class="summary-label">SKU</div>
                        <div class="summary-value">${item.sku}</div>
                    </div>
                </div>

                <table class="detail-table">
                    <tr>
                        <td>Tên sản phẩm</td>
                        <td>${item.productName}</td>
                    </tr>

                    <tr>
                        <td>Đơn vị tính</td>
                        <td>${item.unit}</td>
                    </tr>

                    <tr>
                        <td>Số lượng hệ thống</td>
                        <td>${item.systemQuantity}</td>
                    </tr>

                    <tr>
                        <td>Số lượng thực tế</td>
                        <td>${item.physicalQuantity}</td>
                    </tr>

                    <tr>
                        <td>Chênh lệch</td>
                        <td>
                    <c:choose>
                        <c:when test="${item.variance == 0}">
                            <span class="match">${item.variance} (Khớp)</span>
                        </c:when>
                        <c:when test="${item.variance > 0}">
                            <span class="excess">+${item.variance} (Dư)</span>
                        </c:when>
                        <c:otherwise>
                            <span class="shortage">${item.variance} (Thiếu)</span>
                        </c:otherwise>
                    </c:choose>
                    </td>
                    </tr>

                    <tr>
                        <td>Lý do chênh lệch</td>
                        <td>
                    <c:choose>
                        <c:when test="${not empty item.reason}">
                            <div class="reason-box">${item.reason}</div>
                        </c:when>
                        <c:otherwise>
                            <span class="empty-note">Không có lý do được ghi nhận</span>
                        </c:otherwise>
                    </c:choose>
                    </td>
                    </tr>

                    <tr>
                        <td>Trạng thái</td>
                        <td>
                    <c:choose>
                        <c:when test="${item.status == 'Pending'}">
                            <span class="badge badge-pending">Pending</span>
                        </c:when>
                        <c:when test="${item.status == 'Approved'}">
                            <span class="badge badge-completed">Approved</span>
                        </c:when>
                        <c:when test="${item.status == 'Rejected'}">
                            <span class="badge badge-recount">Rejected</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge badge-default">${item.status}</span>
                        </c:otherwise>
                    </c:choose>
                    </td>
                    </tr>

                    <tr>
                        <td>Người tạo</td>
                        <td>
                    <c:choose>
                        <c:when test="${item.createdBy != null}">
                            ${item.createdBy}
                        </c:when>
                        <c:otherwise>
                            <span class="empty-note">Không có dữ liệu</span>
                        </c:otherwise>
                    </c:choose>
                    </td>
                    </tr>

                    <tr>
                        <td>Người duyệt</td>
                        <td>
                    <c:choose>
                        <c:when test="${item.approvedBy != null}">
                            ${item.approvedBy}
                        </c:when>
                        <c:otherwise>
                            <span class="empty-note">Chưa được duyệt</span>
                        </c:otherwise>
                    </c:choose>
                    </td>
                    </tr>

                    <tr>
                        <td>Ngày kiểm kê</td>
                        <td>${item.date}</td>
                    </tr>

                    <tr>
                        <td>Thời điểm duyệt</td>
                        <td>
                    <c:choose>
                        <c:when test="${item.approvedAt != null}">
                            ${item.approvedAt}
                        </c:when>
                        <c:otherwise>
                            <span class="empty-note">Chưa duyệt</span>
                        </c:otherwise>
                    </c:choose>
                    </td>
                    </tr>
                </table>

                <div class="actions">
                    <a class="btn btn-back" href="inventoryCheck">← Quay lại</a>
                    <a class="btn btn-edit" href="inventoryCheck?mode=edit&id=${item.countId}">Edit</a>
                </div>
            </div>
        </div>
    </body>
</html>
