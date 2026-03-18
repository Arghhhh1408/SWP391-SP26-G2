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
        <title>Chi tiết kiểm kê</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 24px;
                background: #f5f7fa;
                color: #333;
            }

            .container {
                max-width: 800px;
                margin: 0 auto;
            }

            .card {
                background: #fff;
                border-radius: 12px;
                padding: 24px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            }

            h2 {
                margin-top: 0;
                color: #0d274d;
            }

            .row {
                display: flex;
                border-bottom: 1px solid #eee;
                padding: 12px 0;
            }

            .label {
                width: 220px;
                font-weight: bold;
                color: #37506d;
            }

            .value {
                flex: 1;
            }

            .actions {
                margin-top: 20px;
            }

            .btn {
                display: inline-block;
                padding: 10px 18px;
                border-radius: 8px;
                text-decoration: none;
                margin-right: 10px;
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
        </style>
    </head>
    <body>
        <div class="container">
            <div class="card">
                <h2>Chi tiết kiểm kê</h2>

                <c:if test="${sessionScope.acc.roleID == 1}">
                    <a href="staff_dashboard">← Quay lại bảng điều khiển của nhân viên</a>
                </c:if>
                <c:if test="${sessionScope.acc.roleID == 2}">
                    <a href="category">← Quay lại bảng điều khiển của quản lý</a>
                </c:if>

                <div class="row">
                    <div class="label">Tên sản phẩm</div>
                    <div class="value">${item.productName}</div>
                </div>

                <div class="row">
                    <div class="label">SKU</div>
                    <div class="value">${item.sku}</div>
                </div>

                <div class="row">
                    <div class="label">Đơn vị tính</div>
                    <div class="value">${item.unit}</div>
                </div>

                <div class="row">
                    <div class="label">Số lượng hệ thống</div>
                    <div class="value">${item.systemQuantity}</div>
                </div>

                <div class="row">
                    <div class="label">Số lượng thực tế</div>
                    <div class="value">${item.physicalQuantity}</div>
                </div>

                <div class="row">
                    <div class="label">Chênh lệch</div>
                    <div class="value">
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
                    </div>
                </div>

                <div class="row">
                    <div class="label">Trạng thái</div>
                    <div class="value">${item.status}</div>
                </div>

                <div class="row">
                    <div class="label">Người duyệt</div>
                    <div class="value">${item.approvedBy}</div>
                </div>

                <div class="row">
                    <div class="label">Ngày kiểm kê</div>
                    <div class="value">${item.date}</div>
                </div>

                <div class="actions">
                    <a class="btn btn-back" href="inventoryCheck">← Quay lại</a>
                    <a class="btn btn-edit" href="inventoryCheck?mode=edit&id=${item.countId}">Edit</a>
                </div>
            </div>
        </div>
    </body>
</html>
