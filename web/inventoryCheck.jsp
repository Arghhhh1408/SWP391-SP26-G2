<%-- 
    Document   : inventoryCheck
    Created on : 16 thg 3, 2026, 14:30:58
    Author     : dotha
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Kiểm kê kho thực tế</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 24px;
                background-color: #f5f7fa;
                color: #333;
            }

            h2 {
                margin-bottom: 10px;
            }

            a {
                text-decoration: none;
                color: #1976d2;
            }

            .top-link {
                margin-bottom: 16px;
            }

            .box {
                background: #fff;
                padding: 16px;
                border-radius: 10px;
                margin-bottom: 16px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            }

            .success {
                border-left: 4px solid #2e7d32;
                background-color: #e8f5e9;
                color: #2e7d32;
            }

            .error {
                border-left: 4px solid #c62828;
                background-color: #ffebee;
                color: #c62828;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                background: #fff;
                box-shadow: 0 2px 6px rgba(0,0,0,0.08);
            }

            th, td {
                border: 1px solid #ddd;
                padding: 10px;
                text-align: center;
            }

            th {
                background-color: #1976d2;
                color: white;
            }

            tr:nth-child(even) {
                background-color: #fafafa;
            }

            input[type="text"], input[type="number"] {
                padding: 8px;
                border: 1px solid #ccc;
                border-radius: 4px;
            }

            .search-input {
                width: 260px;
            }

            .qty-input {
                width: 100px;
                text-align: right;
            }

            .reason-input {
                width: 220px;
            }

            .actions {
                margin-top: 16px;
            }

            button {
                padding: 10px 16px;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                margin-right: 8px;
                color: white;
            }

            .btn-search {
                background-color: #1976d2;
            }

            .btn-calc {
                background-color: #f9a825;
            }

            .btn-save {
                background-color: #2e7d32;
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

            .not-input {
                color: #757575;
                font-style: italic;
            }

            ul {
                margin: 0;
                padding-left: 20px;
            }

            .session-section {
                margin-top: 36px;
            }

            .session-title {
                font-size: 20px;
                font-weight: 700;
                color: #0d274d;
                margin-bottom: 4px;
            }

            .session-subtitle {
                font-size: 14px;
                color: #5d7492;
                margin-bottom: 18px;
            }

            .session-table {
                width: 100%;
                border-collapse: separate;
                border-spacing: 0;
                background: #fff;
                border-radius: 12px;
                overflow: hidden;
                box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            }

            .session-table thead th {
                background: #f1f4f8;
                color: #37506d;
                text-align: left;
                font-size: 14px;
                font-weight: 700;
                padding: 16px;
                border: none;
                border-bottom: 1px solid #dde5ee;
            }

            .session-table tbody td {
                padding: 16px;
                vertical-align: middle;
                border: none;
                border-bottom: 1px solid #edf2f7;
                background: #fff;
                text-align: left;
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

            .empty-box {
                background: #fff;
                border-radius: 10px;
                padding: 18px;
                color: #6c7f95;
                box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            }

            .action-btn {
                display: inline-block;
                padding: 10px 18px;
                border: 1px solid #d6dde6;
                border-radius: 14px;
                background: #fff;
                color: #0d274d;
                font-weight: 700;
                margin-right: 8px;
            }

            .action-btn:hover {
                background: #f7faff;
            }

            .pagination-wrap {
                margin-top: 18px;
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                align-items: center;
            }

            .page-label {
                font-weight: bold;
                color: #37506d;
                margin-right: 8px;
            }

            .clickable-row {
                cursor: pointer;
            }

            .clickable-row:hover {
                background: #f8fbff !important;
            }
        </style>
    </head>
    <body>

        <h2>Kiểm kê kho thực tế</h2><br><br>

        <div class="top-link">
            <c:if test="${sessionScope.acc.roleID == 1}">
                <a href="staff_dashboard">← Quay lại bảng điều khiển của nhân viên</a>
            </c:if>
            <c:if test="${sessionScope.acc.roleID == 2}">
                <a href="category">← Quay lại bảng điều khiển của quản lý</a>
            </c:if>
        </div>

        <c:if test="${not empty sessionScope.message}">
            <div class="box success">
                ${sessionScope.message}
            </div>
            <c:remove var="message" scope="session"/>
        </c:if>

        <c:if test="${not empty sessionScope.error}">
            <div class="box error">
                ${sessionScope.error}
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>

        <c:if test="${not empty error}">
            <div class="box error">
                ${error}
            </div>
        </c:if>

        <c:if test="${not empty errors}">
            <div class="box error">
                <ul>
                    <c:forEach var="e" items="${errors}">
                        <li>${e}</li>
                        </c:forEach>
                </ul>
            </div>
        </c:if>

        <div class="box">
            <form action="inventoryCheck" method="get">
                <label for="keyword">Từ khóa:</label>
                <input id="keyword" class="search-input" type="text" name="keyword"
                       value="${keyword}" placeholder="Nhập tên sản phẩm hoặc SKU">
                <button type="submit" class="btn-search">Tìm kiếm</button>
            </form>
        </div>

        <form action="inventoryCheck" method="post">
            <input type="hidden" name="keyword" value="${keyword}">
            <input type="hidden" name="page" value="${page}">

            <table>
                <thead>
                    <tr>
                        <th>Product ID</th>
                        <th>SKU</th>
                        <th>Tên sản phẩm</th>
                        <th>ĐVT</th>
                        <th>Tồn hệ thống</th>
                        <th>Số lượng thực tế</th>
                        <th>Chênh lệch</th>
                        <th>Kết quả</th>
                        <th>Lý do chênh lệch</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="item" items="${items}">
                        <tr>
                            <td>
                                ${item.productId}
                                <input type="hidden" name="productId" value="${item.productId}">
                                <input type="hidden" name="systemQuantity_${item.productId}" value="${item.systemQuantity}">
                                <input type="hidden" name="sku_${item.productId}" value="${item.sku}">
                                <input type="hidden" name="productName_${item.productId}" value="${item.productName}">
                                <input type="hidden" name="unit_${item.productId}" value="${item.unit}">
                            </td>
                            <td>${item.sku}</td>
                            <td>${item.productName}</td>
                            <td>${item.unit}</td>
                            <td>${item.systemQuantity}</td>
                            <td>
                                <input
                                    class="qty-input"
                                    type="number"
                                    name="physicalQuantity_${item.productId}"
                                    min="0"
                                    value="${item.physicalQuantity != null ? item.physicalQuantity : ''}">
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${item.physicalQuantity == null}">
                                        -
                                    </c:when>
                                    <c:otherwise>
                                        ${item.variance}
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${item.physicalQuantity == null}">
                                        <span class="not-input">Chưa nhập</span>
                                    </c:when>
                                    <c:when test="${item.variance == 0}">
                                        <span class="match">Khớp</span>
                                    </c:when>
                                    <c:when test="${item.variance > 0}">
                                        <span class="excess">Dư</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="shortage">Thiếu</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <input
                                    class="reason-input"
                                    type="text"
                                    name="reason_${item.productId}"
                                    value="${item.reason != null ? item.reason : ''}"
                                    placeholder="Nhập lý do nếu lệch">
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty items}">
                        <tr>
                            <td colspan="9">Không có dữ liệu</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>

            <div class="actions">
                <button type="submit" name="action" value="calculate" class="btn-calc">Tính chênh lệch</button>
                <button type="submit" name="action" value="save" class="btn-save">Lưu kiểm kê</button>
            </div>
        </form>

        <div class="pagination-wrap">
            <span class="page-label">Trang ${page} / ${totalPages}</span>

            <c:if test="${page > 1}">
                <a class="action-btn" href="inventoryCheck?keyword=${keyword}&page=${page - 1}">← Trang trước</a>
            </c:if>

            <c:forEach begin="1" end="${totalPages}" var="i">
                <a class="action-btn"
                   style="${i == page ? 'background:#1976d2;color:white;border-color:#1976d2;' : ''}"
                   href="inventoryCheck?keyword=${keyword}&page=${i}">
                    ${i}
                </a>
            </c:forEach>

            <c:if test="${page < totalPages}">
                <a class="action-btn" href="inventoryCheck?keyword=${keyword}&page=${page + 1}">Trang sau →</a>
            </c:if>
        </div>

        <div class="session-section">
            <div class="session-title">Danh sách sản phẩm đã kiểm kê</div>
            <div class="session-subtitle">
                Hiển thị các sản phẩm đã từng được lưu kiểm kê. Bấm vào từng sản phẩm để xem lịch sử các lần kiểm kê.
            </div>

            <c:choose>
                <c:when test="${not empty checkedProducts}">
                    <table class="session-table">
                        <thead>
                            <tr>
                                <th style="width: 10%;">ID</th>
                                <th style="width: 15%;">SKU</th>
                                <th style="width: 28%;">Tên sản phẩm</th>
                                <th style="width: 10%;">ĐVT</th>
                                <th style="width: 14%;">Số lần kiểm kê</th>
                                <th style="width: 13%;">Lần gần nhất</th>
                                <th style="width: 10%;">Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${checkedProducts}">
                                <tr class="clickable-row"
                                    onclick="window.location = 'inventoryCheck?mode=history&productId=${p.productId}'">
                                    <td>${p.productId}</td>
                                    <td>${p.sku}</td>
                                    <td>${p.productName}</td>
                                    <td>${p.unit}</td>
                                    <td>${p.totalCheckTimes}</td>
                                    <td>${p.date}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.status == 'Pending'}">
                                                <span class="badge badge-pending">Pending</span>
                                            </c:when>
                                            <c:when test="${p.status == 'Approved'}">
                                                <span class="badge badge-completed">Approved</span>
                                            </c:when>
                                            <c:when test="${p.status == 'Rejected'}">
                                                <span class="badge badge-recount">Rejected</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-default">${p.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>

                <c:otherwise>
                    <div class="empty-box">
                        Chưa có sản phẩm nào được lưu kiểm kê.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </body>
</html>
