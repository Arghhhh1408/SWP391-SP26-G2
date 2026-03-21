<%-- 
    Document   : inventoryCheckEdit
    Created on : 16 thg 3, 2026, 17:11:27
    Author     : dotha
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Sửa kiểm kê</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 24px;
                background: #f5f7fa;
                color: #333;
            }

            .container {
                max-width: 850px;
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

            .form-row {
                margin-bottom: 16px;
            }

            label {
                display: block;
                margin-bottom: 6px;
                font-weight: bold;
                color: #37506d;
            }

            input[type="text"],
            input[type="number"],
            select {
                width: 100%;
                padding: 10px;
                border: 1px solid #cfd8e3;
                border-radius: 8px;
                box-sizing: border-box;
            }

            .readonly {
                background: #f4f6f8;
            }

            .error-box {
                background: #ffebee;
                color: #c62828;
                border-left: 4px solid #c62828;
                padding: 12px;
                border-radius: 8px;
                margin-bottom: 16px;
            }

            .actions {
                margin-top: 20px;
            }

            .btn {
                padding: 10px 18px;
                border: none;
                border-radius: 8px;
                cursor: pointer;
                font-weight: bold;
                margin-right: 10px;
            }

            .btn-save {
                background: #2e7d32;
                color: white;
            }

            .btn-back {
                display: inline-block;
                text-decoration: none;
                background: #e3f2fd;
                color: #1565c0;
                padding: 10px 18px;
                border-radius: 8px;
            }

            .info-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 16px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="card">
                <h2>Sửa bản ghi kiểm kê</h2>

                <c:if test="${not empty error}">
                    <div class="error-box">${error}</div>
                </c:if>

                <form action="inventoryCheck" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="countId" value="${item.countId}">

                    <div class="info-grid">
                        <div class="form-row">
                            <label>Tên sản phẩm</label>
                            <input type="text" value="${item.productName}" class="readonly" readonly>
                        </div>

                        <div class="form-row">
                            <label>SKU</label>
                            <input type="text" value="${item.sku}" class="readonly" readonly>
                        </div>

                        <div class="form-row">
                            <label>Đơn vị tính</label>
                            <input type="text" value="${item.unit}" class="readonly" readonly>
                        </div>

                        <div class="form-row">
                            <label>Số lượng hệ thống</label>
                            <input type="number" name="systemQuantity" value="${item.systemQuantity}" readonly class="readonly">
                        </div>

                        <div class="form-row">
                            <label>Số lượng thực tế</label>
                            <input type="number" name="physicalQuantity" min="0" value="${item.physicalQuantity}" required>
                        </div>

                        <c:if test="${sessionScope.acc.roleID == 2}">

                            <div class="form-row">
                                <label>Trạng thái</label>
                                <select name="status">
                                    <option value="Pending" ${item.status == 'Pending' ? 'selected' : ''}>Pending</option>
                                    <option value="Approved" ${item.status == 'Approved' ? 'selected' : ''}>Approved</option>
                                    <option value="Rejected" ${item.status == 'Rejected' ? 'selected' : ''}>Rejected</option>
                                </select>
                            </div>
                        </div>
                    </c:if>
                    <div class="actions">
                        <button type="submit" class="btn btn-save">Lưu cập nhật</button>
                        <a href="inventoryCheck" class="btn-back">← Quay lại</a>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>
