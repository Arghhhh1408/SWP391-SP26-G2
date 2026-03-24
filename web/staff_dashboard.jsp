<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Warehouse Staff Dashboard</title>
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            body {
                display: flex;
                min-height: 100vh;
                font-family: Arial, sans-serif;
                background: #f3f6fb;
                color: #0f172a;
            }
            a {
                text-decoration: none;
            }

            .main {
                margin-left: 326px; /* Space for the fixed sidebar */
                flex: 1;
                padding: 26px;
            }
            .page-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
            }
            .page-header h1 {
                font-size: 28px;
                color: #0b2447;
            }
            .page-header small {
                color: #64748b;
                font-size: 14px;
            }
            .layout-grid {
                display: grid;
                grid-template-columns: 1.6fr 0.9fr;
                gap: 22px;
            }
            .stats {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 18px;
                margin-bottom: 22px;
            }
            .card, .panel {
                background: #f8fafc;
                border-left: 4px solid #3b82f6;
                border: 1px solid #dbe2ec;
                border-radius: 24px;
                box-shadow: 0 4px 18px rgba(15, 23, 42, 0.05);
            }
            .card {
                padding: 24px;
            }
            .card-label {
                color: #64748b;
                font-size: 14px;
                margin-bottom: 14px;
            }
            .card-value {
                font-size: 26px;
                font-weight: 700;
                color: #082f5b;
                margin-bottom: 12px;
            }
            .pill {
                display: inline-flex;
                align-items: center;
                padding: 8px 14px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: 700;
            }
            .pill-orange {
                background: #fdebd3;
                color: #dd7a00;
            }
            .pill-red {
                background: #fbe1e1;
                color: #ef3f33;
            }
            .pill-purple {
                background: #ece5ff;
                color: #7048ff;
            }
            .pill-blue {
                background: #e1edff;
                color: #2f6fed;
            }
            .panel {
                overflow: hidden;
            }
            .panel-header {
                padding: 24px 26px 18px;
                border-bottom: 1px solid #e5edf5;
                display:flex;
                justify-content:space-between;
                align-items:center;
            }
            .panel-header h3 {
                font-size: 18px;
                color: #0b2447;
                margin-bottom: 6px;
            }
            .panel-header p {
                color: #64748b;
            }
            .panel-body {
                padding: 20px 26px 24px;
            }
            .alert-item {
                display: flex;
                justify-content: space-between;
                align-items: center;
                border: 1px solid #d8e2ef;
                border-radius: 20px;
                padding: 18px;
                margin-bottom: 14px;
            }
            .alert-item:last-child {
                margin-bottom: 0;
            }
            .alert-item h4 {
                font-size: 17px;
                margin-bottom: 8px;
                color: #0f2447;
            }
            .alert-item p {
                color: #64748b;
            }
            .status-chip {
                background: #fdebd3;
                color: #dd7a00;
                padding: 10px 16px;
                border-radius: 999px;
                font-weight: 700;
                white-space: nowrap;
            }
            .btn {
                display: inline-block;
                border: none;
                border-radius: 14px;
                background: #fff;
                color: #0b2447;
                padding: 11px 18px;
                cursor: pointer;
                font-size: 14px;
                font-weight: 700;
                border: 1px solid #cfd9e6;
            }
            .btn:hover {
                background: #2f6fed;
                border-color: #2f6fed;
                color: #fff;
            }
            .btn-light {
                background: #fff7ed;
                border-color: #fde2c1;
                color: #dd7a00;
            }
            .quick-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 18px;
            }
            .quick-card {
                border: 1px solid #d8e2ef;
                border-radius: 22px;
                padding: 22px;
            }
            .quick-card h4 {
                font-size: 16px;
                margin-bottom: 12px;
                color: #0b2447;
            }
            .quick-card p {
                color: #64748b;
                min-height: 74px;
                line-height: 1.6;
                margin-bottom: 16px;
            }
            .lower-grid {
                display: grid;
                grid-template-columns: 1.6fr 0.9fr;
                gap: 22px;
                margin-top: 22px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th, td {
                padding: 16px 8px;
                border-top: 1px solid #e5edf5;
                text-align: left;
            }
            th {
                color: #334155;
                font-size: 13px;
                letter-spacing: .4px;
            }
            td {
                color: #0f172a;
                font-size: 14px;
                vertical-align: middle;
            }
            .badge-danger {
                background: #fbe1e1;
                color: #ef3f33;
                padding: 10px 14px;
                border-radius: 999px;
                font-weight: 700;
            }
            .tag-done {
                background: #dcfce7;
                color: #166534;
                padding: 6px 10px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: 700;
            }
            .activity-item {
                padding: 18px 0;
                border-top: 1px dashed #d9e3ef;
            }
            .activity-item:first-child {
                border-top: none;
                padding-top: 0;
            }
            .activity-date {
                color: #64748b;
                font-weight: 700;
                margin-bottom: 8px;
            }
            .activity-title {
                font-size: 15px;
                font-weight: 700;
                color: #0b2447;
                margin-bottom: 6px;
            }
            .activity-desc {
                color: #64748b;
                line-height: 1.5;
            }
            .empty-box {
                padding: 24px;
                border: 1px dashed #cbd5e1;
                border-radius: 18px;
                color: #64748b;
                background: #f8fbff;
            }
            .status-tag {
                padding: 4px 10px;
                border-radius: 999px;
                font-size: 11px;
                font-weight: 700;
                text-transform: uppercase;
            }
            .status-active {
                background: #dcfce7;
                color: #166534;
            }
            .status-inactive {
                background: #f1f5f9;
                color: #64748b;
            }
            @media (max-width: 1300px) {
                .stats {
                    grid-template-columns: repeat(2, 1fr);
                }
                .layout-grid, .lower-grid {
                    grid-template-columns: 1fr;
                }
            }

            /* --- Staff dashboard overview (thống kê + feed) --- */
            .st-overview {
                margin-bottom: 28px;
            }
            .st-stat-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 20px;
                margin-bottom: 22px;
            }
            @media (max-width: 1024px) {
                .st-stat-grid { grid-template-columns: 1fr; }
            }
            .st-stat-card {
                background: linear-gradient(145deg, #ffffff 0%, #f0f9ff 100%);
                border: 1px solid #bae6fd;
                border-radius: 20px;
                padding: 22px 24px;
                box-shadow: 0 8px 24px rgba(14, 116, 144, 0.08);
                position: relative;
                overflow: hidden;
            }
            .st-stat-card::before {
                content: "";
                position: absolute;
                left: 0;
                top: 0;
                bottom: 0;
                width: 4px;
                background: linear-gradient(180deg, #0ea5e9, #0369a1);
                border-radius: 4px 0 0 4px;
            }
            .st-stat-label {
                font-size: 13px;
                font-weight: 700;
                color: #0369a1;
                text-transform: uppercase;
                letter-spacing: 0.06em;
                margin-bottom: 10px;
            }
            .st-stat-value {
                font-size: 30px;
                font-weight: 800;
                color: #0c4a6e;
                line-height: 1.15;
                word-break: break-word;
            }
            .st-stat-hint {
                margin-top: 10px;
                font-size: 12px;
                color: #64748b;
                line-height: 1.45;
            }
            .st-subbar {
                display: flex;
                flex-wrap: wrap;
                align-items: center;
                gap: 12px 20px;
                padding: 14px 18px;
                background: #fff;
                border: 1px solid #e2e8f0;
                border-radius: 14px;
                margin-bottom: 22px;
                font-size: 13px;
                color: #475569;
            }
            .st-subbar a {
                color: #0284c7;
                font-weight: 700;
            }
            .st-subbar a:hover { text-decoration: underline; }
            .st-feed-panel {
                background: #fff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                overflow: hidden;
                box-shadow: 0 4px 20px rgba(15, 23, 42, 0.06);
            }
            .st-feed-head {
                padding: 22px 24px;
                border-bottom: 1px solid #e2e8f0;
                background: linear-gradient(90deg, #f8fafc, #fff);
            }
            .st-feed-head h2 {
                font-size: 18px;
                color: #0f172a;
                margin: 0 0 6px 0;
            }
            .st-feed-head p {
                margin: 0;
                font-size: 13px;
                color: #64748b;
            }
            .st-feed-table-wrap {
                overflow-x: auto;
            }
            .st-feed-table {
                width: 100%;
                border-collapse: collapse;
                font-size: 14px;
            }
            .st-feed-table th {
                text-align: left;
                padding: 14px 18px;
                background: #f8fafc;
                color: #475569;
                font-weight: 700;
                font-size: 11px;
                text-transform: uppercase;
                letter-spacing: 0.04em;
                border-bottom: 1px solid #e2e8f0;
                white-space: nowrap;
            }
            .st-feed-table td {
                padding: 14px 18px;
                border-bottom: 1px solid #f1f5f9;
                vertical-align: middle;
                color: #334155;
            }
            .st-feed-table tr:hover td {
                background: #f8fafc;
            }
            .st-type-pill {
                display: inline-flex;
                align-items: center;
                padding: 5px 12px;
                border-radius: 999px;
                font-size: 11px;
                font-weight: 800;
                text-transform: uppercase;
                letter-spacing: 0.03em;
            }
            .st-type-warranty {
                background: #dbeafe;
                color: #1d4ed8;
            }
            .st-type-return {
                background: #ffedd5;
                color: #c2410c;
            }
            .st-code {
                font-family: ui-monospace, monospace;
                font-weight: 700;
                color: #0f172a;
                font-size: 13px;
            }
            .st-status-pill {
                display: inline-block;
                padding: 4px 10px;
                border-radius: 8px;
                font-size: 12px;
                font-weight: 700;
                background: #f1f5f9;
                color: #475569;
            }
            .st-link {
                font-size: 13px;
                font-weight: 700;
                color: #0284c7;
            }
            .st-link:hover { text-decoration: underline; }
            .st-empty-feed {
                padding: 40px 24px;
                text-align: center;
                color: #94a3b8;
                font-size: 14px;
            }
        </style>
    </head>
    <body>
        <jsp:include page="staffSidebar.jsp" />

        <main class="main">
            <div class="page-header">
                <div>
                    <h1>Warehouse Staff Dashboard</h1>
                    <small>Xin chào, <strong>${sessionScope.acc.fullName}</strong></small>
                </div>
                <div><a href="logout" class="btn">Đăng xuất</a></div>
            </div>
            <c:if test="${not empty sessionScope.error}">
                <div style="color: #ef3f33; padding: 15px; background: #fbe1e1; border-radius: 12px; margin-bottom: 20px; border: 1px solid #f5c2c2;">
                    ${sessionScope.error}
                    <c:remove var="error" scope="session"/>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${tab == 'dashboard'}">
                    <div class="st-overview">
                        <div class="st-stat-grid">
                            <div class="st-stat-card">
                                <div class="st-stat-label">Sản phẩm trong danh mục</div>
                                <div class="st-stat-value">${staffProductCatalogCount}</div>
                                <div class="st-stat-hint">Số dòng sản phẩm đang hoạt động (Active) trong hệ thống.</div>
                            </div>
                            <div class="st-stat-card">
                                <div class="st-stat-label">Tổng tiền bán hàng</div>
                                <div class="st-stat-value">${staffTotalSalesRevenueFormatted}</div>
                                <div class="st-stat-hint">Tổng giá trị các phiếu xuất kho đã hoàn thành (Completed).</div>
                            </div>
                            <div class="st-stat-card">
                                <div class="st-stat-label">Tổng số lượng đã bán</div>
                                <div class="st-stat-value"><fmt:formatNumber value="${staffTotalSoldUnits}" pattern="#,##0"/></div>
                                <div class="st-stat-hint">Cộng dồn số lượng trên tất cả dòng chi tiết phiếu xuất đã hoàn thành.</div>
                            </div>
                        </div>

                        <div class="st-subbar">
                            <span><strong>Tồn thấp:</strong> ${triggeredCount} cảnh báo</span>
                            <span>·</span>
                            <a href="createStockIn">Nhập kho</a>
                            <span>·</span>
                            <a href="staff_dashboard?tab=products">Sản phẩm &amp; tồn</a>
                            <span>·</span>
                            <a href="staff_dashboard?tab=warranty">Bảo hành</a>
                            <span>·</span>
                            <a href="staff_dashboard?tab=returns">Đổi / trả</a>
                        </div>

                        <section class="st-feed-panel">
                            <div class="st-feed-head">
                                <h2>Hoạt động gần đây — bảo hành &amp; đổi trả</h2>
                                <p>Danh sách gộp, sắp xếp theo thời gian cập nhật mới nhất trước.</p>
                            </div>
                            <div class="st-feed-table-wrap">
                                <c:choose>
                                    <c:when test="${empty staffHomeFeed}">
                                        <div class="st-empty-feed">Chưa có yêu cầu bảo hành hoặc đổi trả nào.</div>
                                    </c:when>
                                    <c:otherwise>
                                        <table class="st-feed-table">
                                            <thead>
                                                <tr>
                                                    <th>Loại</th>
                                                    <th>Mã</th>
                                                    <th>Sản phẩm</th>
                                                    <th>Khách hàng</th>
                                                    <th>Trạng thái</th>
                                                    <th>Thời gian</th>
                                                    <th></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${staffHomeFeed}" var="row">
                                                    <tr>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${row.warranty}">
                                                                    <span class="st-type-pill st-type-warranty">${row.typeLabelVi}</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="st-type-pill st-type-return">${row.typeLabelVi}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td><span class="st-code">${row.code}</span></td>
                                                        <td>${empty row.productLine ? '—' : row.productLine}</td>
                                                        <td>${empty row.customerLine ? '—' : row.customerLine}</td>
                                                        <td><span class="st-status-pill">${row.statusLabel}</span></td>
                                                        <td>${row.activityTimeVi}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${row.warranty}">
                                                                    <a class="st-link" href="staff_dashboard?tab=warranty">Mở tab</a>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <a class="st-link" href="staff_dashboard?tab=returns">Mở tab</a>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </section>
                    </div>
                </c:when>

                <c:when test="${tab == 'returns'}">
                    <section class="panel">
                        <div class="panel-header">
                            <div><h3>Danh sách yêu cầu trả hàng</h3></div>
                        </div>
                        <div class="panel-body" style="padding-top:0;">
                            <table>
                                <tr>
                                    <th>Mã yêu cầu</th>
                                    <th>SKU</th>
                                    <th>Sản phẩm</th>
                                    <th>Khách hàng</th>
                                    <th>Lý do</th>
                                    <th>Trạng thái</th>
                                    <th>Hành động</th>
                                </tr>
                                <c:forEach items="${returns}" var="r">
                                    <tr>
                                        <td>${r.returnCode}</td>
                                        <td>${r.sku}</td>
                                        <td>${r.productName}</td>
                                        <td>${r.customerName}</td>
                                        <td>${r.reason}</td>
                                        <td>${r.status}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${r.status == 'COMPLETED' || r.status == 'REJECTED' || r.status == 'REFUNDED' || r.status == 'CANCELLED'}">
                                                    <span style="color:#64748b; font-weight:600;">Đã xử lý</span>
                                                </c:when>
                                                <c:when test="${r.status == 'NEW' || r.status == 'APPROVED'}">
                                                    <form action="staff_dashboard" method="post" style="display:inline-block;">
                                                        <input type="hidden" name="action" value="completeReturn">
                                                        <input type="hidden" name="id" value="${r.id}">
                                                        <button type="submit" class="btn">Hoàn thành</button>
                                                    </form>
                                                    <form action="staff_dashboard" method="post" style="display:inline-block; margin-left:8px;">
                                                        <input type="hidden" name="action" value="rejectReturn">
                                                        <input type="hidden" name="id" value="${r.id}">
                                                        <button type="submit" class="btn btn-light">Từ chối</button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:#64748b; font-size:12px;">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </table>
                        </div>
                    </section>
                </c:when>

                <c:when test="${tab == 'products'}">
                    <section class="panel">
                        <div class="panel-header" style="display:flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                            <div><h3>Danh sách sản phẩm</h3></div>
                            <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                                <div id="bulkActions" style="display: none; gap: 10px; align-items: center; background: #f8fafc; padding: 5px 10px; border-radius: 6px; border: 1px solid #e2e8f0;">
                                    <span style="font-size: 13px; font-weight: 600; color: #64748b;">Hành động hàng loạt:</span>
                                    <button type="button" onclick="submitBulkAction('softDelete')" class="btn" style="background: #fef9c3; color: #854d0e; border-color: #fef08a; padding: 4px 8px; font-size: 12px;">Xóa mềm</button>
                                    <button type="button" onclick="submitBulkAction('hardDelete')" class="btn" style="background: #fee2e2; color: #991b1b; border-color: #fecaca; padding: 4px 8px; font-size: 12px;">Xóa cứng</button>
                                </div>
                                
                                <a href="exportProducts" class="btn" style="background: #dcfce7; color: #166534; border-color: #bbf7d0;">Export Excel</a>
                                
                                <form action="importProducts" method="post" enctype="multipart/form-data" style="display: flex; gap: 5px;">
                                    <input type="file" name="file" accept=".xlsx, .xls" style="font-size: 12px; width: 150px;" required>
                                    <button type="submit" class="btn btn-light" style="padding: 5px 10px;">Import Excel</button>
                                </form>
                            </div>
                        </div>
                        <div class="panel-body" style="padding-top:0;">
                            <form id="bulkActionForm" action="bulkProductAction" method="post">
                                <input type="hidden" name="action" id="bulkActionType" value="">
                                <table>
                                    <tr>
                                        <th style="width: 40px;"><input type="checkbox" id="selectAll" onclick="toggleSelectAll(this)"></th>
                                        <th>ID</th>
                                        <th>SKU</th>
                                        <th>Tên sản phẩm</th>
                                        <th>Tồn kho</th>
                                        <th>Đơn vị</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                    <c:forEach items="${products}" var="p">
                                        <tr>
                                            <td><input type="checkbox" name="selectedProducts" value="${p.id}" onclick="updateBulkActionsVisibility()"></td>
                                            <td>${p.id}</td>
                                            <td>${p.sku}</td>
                                            <td>${p.name}</td>
                                            <td>${p.quantity}</td>
                                            <td>${p.unit}</td>
                                            <td>
                                                <span class="status-tag ${p.status == 'Active' ? 'status-active' : 'status-inactive'}">
                                                    ${p.status}
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </table>
                            </form>
                        </div>
                    </section>
                </c:when>

                <c:otherwise>
                    <section class="panel">
                        <div class="panel-header">
                            <div><h3>Danh sách yêu cầu bảo hành</h3></div>
                        </div>
                        <div class="panel-body" style="padding-top:0;">
                            <table>
                                <tr>
                                    <th>Mã yêu cầu</th>
                                    <th>SKU</th>
                                    <th>Sản phẩm</th>
                                    <th>Khách hàng</th>
                                    <th>Mô tả lỗi</th>
                                    <th>Trạng thái</th>
                                    <th>Hành động</th>
                                </tr>
                                <c:forEach items="${claims}" var="c">
                                    <tr>
                                        <td>${c.claimCode}</td>
                                        <td>${c.sku}</td>
                                        <td>${c.productName}</td>
                                        <td>${c.customerName}</td>
                                        <td>${c.issueDescription}</td>
                                        <td>${c.status}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${c.status == 'COMPLETED' || c.status == 'REJECTED' || c.status == 'CANCELLED'}">
                                                    <span style="color:#64748b; font-weight:600;">Đã xử lý</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <form action="staff_dashboard" method="post" style="display:inline-block;">
                                                        <input type="hidden" name="action" value="completeWarranty">
                                                        <input type="hidden" name="id" value="${c.id}">
                                                        <button type="submit" class="btn">Hoàn tất</button>
                                                    </form>
                                                    <form action="staff_dashboard" method="post" style="display:inline-block; margin-left:8px;">
                                                        <input type="hidden" name="action" value="rejectWarranty">
                                                        <input type="hidden" name="id" value="${c.id}">
                                                        <button type="submit" class="btn btn-light">Từ chối</button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </table>
                        </div>
                    </section>
                </c:otherwise>
            </c:choose>
        </main>

        <script>
            function toggleSelectAll(source) {
                var checkboxes = document.getElementsByName('selectedProducts');
                for(var i=0, n=checkboxes.length;i<n;i++) {
                    checkboxes[i].checked = source.checked;
                }
                updateBulkActionsVisibility();
            }

            function updateBulkActionsVisibility() {
                var checkboxes = document.getElementsByName('selectedProducts');
                var bulkActions = document.getElementById('bulkActions');
                var anyChecked = false;
                for(var i=0; i<checkboxes.length; i++) {
                    if(checkboxes[i].checked) {
                        anyChecked = true;
                        break;
                    }
                }
                if (bulkActions) {
                    bulkActions.style.display = anyChecked ? 'flex' : 'none';
                }
                
                // Update Select All checkbox state
                var selectAll = document.getElementById('selectAll');
                if (selectAll) {
                    var allChecked = true;
                    if (checkboxes.length === 0) allChecked = false;
                    for(var i=0; i<checkboxes.length; i++) {
                        if(!checkboxes[i].checked) {
                            allChecked = false;
                            break;
                        }
                    }
                    selectAll.checked = allChecked;
                }
            }

            function submitBulkAction(action) {
                var confirmMsg = action === 'hardDelete' 
                    ? 'Bạn có chắc chắn muốn XÓA VĨNH VIỄN các sản phẩm đã chọn không? Thao tác này không thể hoàn tác!' 
                    : 'Bạn có muốn chuyển trạng thái các sản phẩm đã chọn thành Inactive không?';
                
                if (confirm(confirmMsg)) {
                    document.getElementById('bulkActionType').value = action;
                    document.getElementById('bulkActionForm').submit();
                }
            }
        </script>
    </body>
</html>