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

            /* ===== Inventory session list ===== */
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
                padding: 18px 16px;
                vertical-align: top;
                border: none;
                border-bottom: 1px solid #edf2f7;
                background: #fff;
                text-align: left;
            }

            .session-id {
                font-size: 16px;
                font-weight: 800;
                color: #0d274d;
                margin-bottom: 8px;
            }

            .product-name {
                font-size: 14px;
                color: #516b8b;
                margin-bottom: 6px;
            }

            .sub-line {
                font-size: 13px;
                color: #617992;
                margin-bottom: 4px;
            }

            .count-main {
                font-size: 15px;
                font-weight: 700;
                color: #0d274d;
                margin-bottom: 4px;
            }

            .difference-line {
                font-size: 14px;
                color: #5f7592;
                margin-bottom: 10px;
            }

            .progress-wrap {
                width: 100%;
                max-width: 250px;
                height: 11px;
                background: #e5e9ef;
                border-radius: 10px;
                overflow: hidden;
            }

            .progress-bar {
                height: 100%;
                background: linear-gradient(90deg, #69a4ff, #2f6ce5);
                border-radius: 10px;
            }

            .badge {
                display: inline-block;
                padding: 8px 14px;
                border-radius: 999px;
                font-size: 13px;
                font-weight: 700;
                margin-bottom: 10px;
                white-space: nowrap;
            }

            .badge-type {
                background: #dbe9ff;
                color: #2962e3;
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

            .evidence-line {
                font-size: 14px;
                color: #5a7090;
                margin-bottom: 6px;
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

            .empty-box {
                background: #fff;
                border-radius: 10px;
                padding: 18px;
                color: #6c7f95;
                box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            }
            .product-main-name {
                font-size: 18px;
                font-weight: 800;
                color: #0d274d;
                margin-bottom: 8px;
            }

            .progress-wrap {
                width: 100%;
                max-width: 280px;
                height: 12px;
                background: #e5e9ef;
                border-radius: 999px;
                overflow: hidden;
                margin-bottom: 8px;
            }

            .progress-bar {
                height: 100%;
                border-radius: 999px;
            }

            .bar-match {
                background: linear-gradient(90deg, #4caf50, #2e7d32);
            }

            .bar-excess {
                background: linear-gradient(90deg, #ffb74d, #ef6c00);
            }

            .bar-shortage {
                background: linear-gradient(90deg, #64b5f6, #1976d2);
            }

            .progress-note {
                font-size: 13px;
                color: #60758f;
                margin-top: 4px;
            }

            .status-note {
                margin-top: 10px;
                font-size: 13px;
                color: #617992;
                line-height: 1.5;
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
                        </tr>
                    </c:forEach>

                    <c:if test="${empty items}">
                        <tr>
                            <td colspan="8">Không có dữ liệu</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>

            <div class="actions">
                <button type="submit" name="action" value="calculate" class="btn-calc">Tính chênh lệch</button>
                <button type="submit" name="action" value="save" class="btn-save">Lưu kiểm kê</button>
            </div>
        </form>

        <!-- ===== Danh sách đã kiểm kê ===== -->
        <!-- ===== Danh sách đã kiểm kê ===== -->
        <div class="session-section">
            <div class="session-title">Danh sách sản phẩm đã kiểm kê</div>
            <div class="session-subtitle">
                Hiển thị sản phẩm đã kiểm kê, kết quả đếm thực tế, chênh lệch và trạng thái xử lý.
            </div>

            <c:choose>
                <c:when test="${not empty checkedItems}">
                    <table class="session-table">
                        <thead>
                            <tr>
                                <th style="width: 30%;">PRODUCT</th>
                                <th style="width: 30%;">COUNT RESULT</th>
                                <th style="width: 20%;">STATUS</th>
                                <th style="width: 20%;">ACTIONS</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${checkedItems}">
                                <tr>
                                    <td>
                                        <div class="product-main-name">${c.productName}</div>
                                        <div class="sub-line">SKU: ${c.sku}</div>
                                        <div class="sub-line">ĐVT: ${c.unit}</div>
                                        <div class="sub-line">Ngày kiểm kê: ${c.date}</div>
                                    </td>

                                    <td>
                                        <div class="count-main">
                                            Hệ thống: ${c.systemQuantity} / Thực tế: ${c.physicalQuantity}
                                        </div>

                                        <div class="difference-line">
                                            Chênh lệch:
                                            <c:choose>
                                                <c:when test="${c.variance > 0}">
                                                    <span class="excess">+${c.variance}</span>
                                                </c:when>
                                                <c:when test="${c.variance < 0}">
                                                    <span class="shortage">${c.variance}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="match">0</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <c:set var="progressPercent"
                                               value="${c.systemQuantity > 0 ? (c.physicalQuantity * 100 / c.systemQuantity) : 0}" />

                                        <div class="progress-wrap">
                                            <div class="progress-bar
                                                 ${c.variance == 0 ? 'bar-match' : (c.variance > 0 ? 'bar-excess' : 'bar-shortage')}"
                                                 style="width:
                                                 <c:choose>
                                                     <c:when test='${progressPercent > 100}'>100%</c:when>
                                                     <c:when test='${progressPercent < 0}'>0%</c:when>
                                                     <c:otherwise>${progressPercent}%</c:otherwise>
                                                 </c:choose>;">
                                            </div>
                                        </div>

                                        <div class="progress-note">
                                            Tỷ lệ thực tế / hệ thống:
                                            <c:choose>
                                                <c:when test="${c.systemQuantity > 0}">
                                                    ${progressPercent}%
                                                </c:when>
                                                <c:otherwise>
                                                    0%
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${c.status == 'Pending'}">
                                                <span class="badge badge-pending">Pending Review</span>
                                            </c:when>
                                            <c:when test="${c.status == 'Approved'}">
                                                <span class="badge badge-completed">Completed</span>
                                            </c:when>
                                            <c:when test="${c.status == 'Rejected'}">
                                                <span class="badge badge-recount">Recount Required</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-default">${c.status}</span>
                                            </c:otherwise>
                                        </c:choose>

                                        <div class="status-note">
                                            <c:choose>
                                                <c:when test="${c.variance == 0}">
                                                    Khớp tồn kho
                                                </c:when>
                                                <c:when test="${c.variance > 0}">
                                                    Số lượng thực tế nhiều hơn hệ thống
                                                </c:when>
                                                <c:otherwise>
                                                    Số lượng thực tế ít hơn hệ thống
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>

                                    <td>
                                        <a class="action-btn" href="inventoryCheck?mode=view&id=${c.countId}">View</a>
                                        <a class="action-btn" href="inventoryCheck?mode=edit&id=${c.countId}">Edit</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>

                <c:otherwise>
                    <div class="empty-box">
                        Chưa có dữ liệu kiểm kê đã lưu.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </body>
</html>
