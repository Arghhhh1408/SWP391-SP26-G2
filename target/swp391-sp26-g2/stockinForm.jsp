<%-- 
    Document   : stockinForm
    Created on : 26 thg 2, 2026, 15:51:39
    Author     : dotha
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Tạo Phiếu Nhập Kho</title>
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
                max-width: 1200px;
                margin: 0 auto;
            }
            .page-title {
                font-size: 28px;
                font-weight: bold;
                margin-bottom: 20px;
                color: #1f4e79;
            }
            .back-link {
                display: inline-block;
                margin-bottom: 20px;
                text-decoration: none;
                color: #1f4e79;
                font-weight: bold;
            }
            .back-link:hover {
                text-decoration: underline;
            }
            .message {
                margin-bottom: 20px;
                padding: 12px 16px;
                border-radius: 8px;
                background: #e8f5e9;
                color: #2e7d32;
                border: 1px solid #c8e6c9;
            }
            .card {
                background: #fff;
                border-radius: 12px;
                padding: 20px;
                margin-bottom: 20px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            }
            .card h3 {
                margin-bottom: 16px;
                color: #1f4e79;
                border-bottom: 2px solid #eef2f7;
                padding-bottom: 10px;
            }
            .form-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 16px;
            }
            .form-group {
                display: flex;
                flex-direction: column;
            }
            .form-group.full-width {
                grid-column: 1 / -1;
            }
            label {
                margin-bottom: 6px;
                font-weight: bold;
                color: #444;
            }
            input[type="text"], input[type="number"], textarea, select {
                width: 100%;
                padding: 10px 12px;
                border: 1px solid #ccc;
                border-radius: 8px;
                outline: none;
                font-size: 14px;
            }
            input:focus, textarea:focus, select:focus {
                border-color: #1f4e79;
                box-shadow: 0 0 0 3px rgba(31, 78, 121, 0.12);
            }
            textarea {
                resize: vertical;
                min-height: 90px;
            }
            .readonly-box {
                padding: 10px 12px;
                background: #f8fafc;
                border: 1px solid #dbe3eb;
                border-radius: 8px;
            }
            .section-actions {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 12px;
                flex-wrap: wrap;
                margin-bottom: 14px;
            }
            .search-wrapper {
                position: relative;
                width: 100%;
                max-width: 560px;
            }
            .search-row {
                display: flex;
                gap: 10px;
                align-items: center;
            }
            .search-row input[type="text"] {
                flex: 1;
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
            .btn-danger {
                background: #d32f2f;
                color: #fff;
            }
            .btn-danger:hover {
                background: #b71c1c;
            }
            .btn:disabled,
            .btn[disabled] {
                opacity: 0.6;
                cursor: not-allowed;
            }
            .dropdown-results {
                position: absolute;
                top: calc(100% + 6px);
                left: 0;
                right: 0;
                background: #fff;
                border: 1px solid #d9e2ec;
                border-radius: 10px;
                box-shadow: 0 8px 20px rgba(0,0,0,0.12);
                max-height: 320px;
                overflow-y: auto;
                z-index: 999;
            }
            .dropdown-item {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 12px;
                padding: 12px 14px;
                border-bottom: 1px solid #eef2f7;
            }
            .dropdown-item:last-child {
                border-bottom: none;
            }
            .dropdown-item:hover {
                background: #f8fbff;
            }
            .dropdown-info {
                display: flex;
                flex-direction: column;
                gap: 4px;
            }
            .dropdown-name {
                font-weight: bold;
                color: #1f2937;
            }
            .dropdown-meta {
                font-size: 13px;
                color: #6b7280;
            }
            .table-wrapper {
                overflow-x: auto;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                background: #fff;
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
            }
            tr:hover td {
                background: #fafcff;
            }
            .empty-state {
                text-align: center;
                color: #777;
                padding: 20px;
            }
            .summary-box {
                background: #f8fafc;
                border: 1px solid #dbe3eb;
                border-radius: 10px;
                padding: 14px 16px;
                margin-bottom: 16px;
            }
            .summary-box p {
                margin: 6px 0;
            }
            .submit-row {
                text-align: right;
                margin-top: 20px;
            }
            .badge {
                display: inline-block;
                padding: 4px 10px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: bold;
                background: #e3f2fd;
                color: #1565c0;
            }
            .helper-text {
                margin-top: 8px;
                font-size: 13px;
                color: #64748b;
            }
            @media (max-width: 768px) {
                .form-grid {
                    grid-template-columns: 1fr;
                }
                .search-row {
                    flex-direction: column;
                    align-items: stretch;
                }
                .submit-row {
                    text-align: center;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="page-title">Tạo Phiếu Nhập Kho</div>

            <c:if test="${sessionScope.acc.roleID == 1}">
                <a class="back-link" href="staff_dashboard?action=clear&redirect=1">← Quay lại bảng điều khiển của nhân viên</a>
            </c:if>
            <c:if test="${sessionScope.acc.roleID == 2}">
                <a class="back-link" href="category?action=clear&redirect=1">← Quay lại bảng điều khiển của quản lý</a>
            </c:if>

            <c:if test="${not empty message}">
                <div class="message">${message}</div>
            </c:if>

            <form action="createStockIn" method="get" id="searchForm">
                <div class="card">
                    <h3>Thông tin phiếu nhập</h3>

                    <div class="form-grid">
                        <div class="form-group">
                            <label>Nhà cung cấp</label>
                            <select name="supplierId" onchange="document.getElementById('searchForm').submit()" required>
                                <option value="">-- Chọn nhà cung cấp --</option>
                                <c:forEach var="sup" items="${supplierList}">
                                    <option value="${sup.id}"
                                            <c:if test="${supplierIdDraft == sup.id}">selected="selected"</c:if>>
                                        ${sup.supplierName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Người tạo</label>
                            <div class="readonly-box">${sessionScope.acc.username}</div>
                        </div>

                        <div class="form-group">
                            <label>Trạng thái nhập hàng</label>
                            <div class="readonly-box">Pending</div>
                        </div>

                        <div class="form-group">
                            <label>Trạng thái thanh toán dự kiến</label>
                            <div class="readonly-box">
                                <c:choose>
                                    <c:when test="${empty paidNowDraft or paidNowDraft == '0' or paidNowDraft == '0.0' or paidNowDraft == '0.00'}">
                                        Unpaid
                                    </c:when>
                                    <c:otherwise>
                                        Tự động tính khi tạo phiếu
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Thanh toán ban đầu</label>
                            <input type="number" name="paidNow" min="0" step="0.01" value="${paidNowDraft}">
                        </div>

                        <div class="form-group full-width">
                            <label>Ghi chú</label>
                            <textarea name="note">${noteDraft}</textarea>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <h3>Tìm và thêm sản phẩm</h3>

                    <div class="section-actions">
                        <div class="search-wrapper">
                            <div class="search-row">
                                <input type="text"
                                       name="keyword"
                                       id="keywordInput"
                                       value="${keyword}"
                                       placeholder="Nhập tên hoặc SKU sản phẩm..."
                                       ${empty supplierIdDraft ? 'disabled' : ''}>

                                <button type="submit" class="btn btn-primary" ${empty supplierIdDraft ? 'disabled' : ''}>
                                    Tìm
                                </button>

                                <a href="createStockIn?action=clear" class="btn btn-danger">Xóa danh sách</a>
                            </div>

                            <c:if test="${not empty productList}">
                                <div class="dropdown-results">
                                    <c:forEach var="p" items="${productList}">
                                        <div class="dropdown-item">
                                            <div class="dropdown-info">
                                                <div class="dropdown-name">${p.name}</div>
                                                <div class="dropdown-meta">
                                                    ID: ${p.id} | SKU: ${p.sku} | ĐVT: ${p.unit} | Tồn: ${p.quantity}
                                                </div>
                                                <div class="dropdown-meta">
                                                    Giá nhập gợi ý:
                                                    <fmt:formatNumber value="${p.cost}" type="number" groupingUsed="true"/>
                                                </div>
                                            </div>
                                            <button type="submit" name="addPid" value="${p.id}" class="btn btn-primary">
                                                Chọn
                                            </button>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <c:if test="${empty supplierIdDraft}">
                        <div class="empty-state">Vui lòng chọn nhà cung cấp trước khi tìm sản phẩm.</div>
                    </c:if>

                    <c:if test="${not empty supplierIdDraft and not empty keyword and empty productList}">
                        <div class="empty-state">Không tìm thấy sản phẩm phù hợp với nhà cung cấp đã chọn.</div>
                    </c:if>

                    <div class="helper-text">
                        Chỉ hiển thị các sản phẩm đang được cung cấp bởi nhà cung cấp đã chọn.
                    </div>
                </div>
            </form>

            <form action="createStockIn" method="post">
                <input type="hidden" name="keyword" value="${keyword}">
                <input type="hidden" name="supplierId" value="${supplierIdDraft}">
                <input type="hidden" name="note" value="${noteDraft}">
                <input type="hidden" name="paidNow" value="${paidNowDraft}">

                <div class="card">
                    <h3>Chi tiết phiếu nhập</h3>

                    <div class="summary-box">
                        <p><strong>Nhà cung cấp:</strong>
                            <c:forEach var="sup" items="${supplierList}">
                                <c:if test="${supplierIdDraft == sup.id}">
                                    ${sup.supplierName}
                                </c:if>
                            </c:forEach>
                        </p>
                        <p><strong>Người tạo:</strong> ${sessionScope.acc.username}</p>
                        <p><strong>Trạng thái nhập hàng:</strong> <span class="badge">Pending</span></p>
                        <p><strong>Thanh toán ban đầu:</strong>
                            <span class="badge">
                                <fmt:formatNumber value="${empty paidNowDraft ? 0 : paidNowDraft}" type="number" groupingUsed="true"/>
                            </span>
                        </p>
                        <p><strong>Ghi chú:</strong> ${noteDraft}</p>
                    </div>

                    <div class="table-wrapper">
                        <table>
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên</th>
                                    <th>SKU</th>
                                    <th>ĐVT</th>
                                    <th>Số lượng nhập</th>
                                    <th>Giá nhập</th>
                                    <th>Xóa</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:if test="${empty cart}">
                                    <tr>
                                        <td colspan="7" class="empty-state">Chưa có sản phẩm nào được chọn</td>
                                    </tr>
                                </c:if>

                                <c:if test="${not empty cart}">
                                    <c:forEach var="entry" items="${cart}">
                                        <c:set var="p" value="${entry.value}" />
                                        <tr>
                                            <td>${p.id}</td>
                                            <td>${p.name}</td>
                                            <td>${p.sku}</td>
                                            <td>${p.unit}</td>
                                            <td>
                                                <input type="number" name="qty_${p.id}" min="1" value="1" required style="width: 100px;">
                                            </td>
                                            <td>
                                                <input type="number" name="cost_${p.id}" min="0" step="0.01" value="${p.cost}" required style="width: 140px;">
                                            </td>
                                            <td>
                                                <a href="createStockIn?removePid=${p.id}&supplierId=${supplierIdDraft}&note=${noteDraft}&paidNow=${paidNowDraft}&keyword=${keyword}"
                                                   class="btn btn-danger">
                                                    Xóa
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <div class="submit-row">
                        <button type="submit" class="btn btn-primary">Tạo phiếu nhập</button>
                    </div>
                </div>
            </form>
        </div>
    </body>
</html>