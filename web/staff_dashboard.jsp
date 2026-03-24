<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
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
                    <div class="stats">
                        <div class="card">
                            <div class="card-label">Low stock items</div>
                            <div class="card-value">${triggeredCount}</div>
                            <span class="pill pill-orange">From LowStockAlerts</span>
                        </div>
                        <div class="card">
                            <div class="card-label">Pending supplier debt</div>
                            <div class="card-value">${pendingSupplierDebtAmount}</div>
                            <span class="pill pill-red">SupplierDebts</span>
                        </div>
                        <div class="card">
                            <div class="card-label">Open RTV cases</div>
                            <div class="card-value">${openRTVCount}</div>
                            <span class="pill pill-purple">ReturnToVendors</span>
                        </div>
                        <div class="card">
                            <div class="card-label">Unread notifications</div>
                            <div class="card-value">${unreadNotificationCount}</div>
                            <span class="pill pill-blue">Notifications</span>
                        </div>
                    </div>

                    <div class="layout-grid">
                        <section class="panel">
                            <div class="panel-header">
                                <div>
                                    <h3>Operational Alerts</h3>
                                    <p>Tổng hợp từ LowStockAlerts, SupplierDebts và hệ thống kho.</p>
                                </div>
                                <span class="pill pill-orange">Live summary</span>
                            </div>
                            <div class="panel-body">
                                <c:forEach items="${triggeredAlerts}" var="item" end="2">
                                    <div class="alert-item">
                                        <div>
                                            <h4>${item.sku} - ${item.productName}</h4>
                                            <p>Stock hiện tại ${item.stockQuantity} thấp hơn min level ${item.minStockLevel}.</p>
                                        </div>
                                        <div style="display:flex; gap:10px; align-items:center;">
                                            <span class="status-chip">Low stock</span>
                                            <form action="staff_dashboard" method="post">
                                                <input type="hidden" name="action" value="toggleLowStockNotified">
                                                <input type="hidden" name="alertId" value="${item.alertId}">
                                                <input type="hidden" name="notified" value="${item.notified}">
                                                <button type="submit" class="btn btn-light">
                                                    ${item.notified ? 'Đã thông báo' : 'Thông báo'}
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </c:forEach>

                                <c:if test="${empty triggeredAlerts}">
                                    <div class="empty-box">Hiện chưa có sản phẩm nào dưới mức tồn kho tối thiểu.</div>
                                </c:if>

                                <c:if test="${pendingSupplierDebtCount > 0}">
                                    <div class="alert-item">
                                        <div>
                                            <h4>Công nợ nhà cung cấp</h4>
                                            <p>Hiện có ${pendingSupplierDebtCount} khoản công nợ cần theo dõi.</p>
                                        </div>
                                        <span class="status-chip" style="background:#fbe1e1;color:#ef3f33;">Pending debt</span>
                                    </div>
                                </c:if>
                            </div>
                        </section>

                        <section class="panel">
                            <div class="panel-header">
                                <div>
                                    <h3>Quick Actions</h3>
                                    <p>Điều hướng nhanh theo use case của Warehouse Staff.</p>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="quick-grid">
                                    <div class="quick-card">
                                        <h4>Create Stock-In</h4>
                                        <p>Tạo StockIn và StockInDetails khi nhập hàng từ nhà cung cấp.</p>
                                        <a class="btn" href="createStockIn">Open</a>
                                    </div>
                                    <div class="quick-card">
                                        <h4>Inventory Check</h4>
                                        <p>Xem nhanh danh sách tồn kho để đối chiếu số lượng sản phẩm.</p>
                                        <a class="btn" href="staff_dashboard?tab=products">Open</a>
                                    </div>
                                    <div class="quick-card">
                                        <h4>Supplier Requests</h4>
                                        <p>Theo dõi các yêu cầu trả hàng về nhà cung cấp và các nghiệp vụ liên quan.</p>
                                        <a class="btn" href="staff_dashboard?tab=returns">Open</a>
                                    </div>
                                    <div class="quick-card">
                                        <h4>Warranty Claims</h4>
                                        <p>Kiểm tra và xử lý các yêu cầu bảo hành đang chờ xử lý.</p>
                                        <a class="btn" href="staff_dashboard?tab=warranty">Open</a>
                                    </div>
                                </div>
                            </div>
                        </section>
                    </div>

                    <div class="lower-grid">
                        <section class="panel">
                            <div class="panel-header">
                                <div>
                                    <h3>Low Stock Watchlist</h3>
                                    <p>Kết hợp Products.StockQuantity với LowStockAlerts.MinStockLevel.</p>
                                </div>
                            </div>
                            <div class="panel-body" style="padding-top:0;">
                                <table>
                                    <tr>
                                        <th>SKU</th>
                                        <th>PRODUCT</th>
                                        <th>CATEGORY</th>
                                        <th>STOCK</th>
                                        <th>MIN LEVEL</th>
                                        <th>STATUS</th>
                                    </tr>
                                    <c:forEach items="${dashboardWatchlist}" var="item">
                                        <tr>
                                            <td>${item.sku}</td>
                                            <td>${item.productName}</td>
                                            <td>${empty item.categoryName ? '-' : item.categoryName}</td>
                                            <td>${item.stockQuantity}</td>
                                            <td>${item.minStockLevel}</td>
                                            <td><span class="badge-danger">Below minimum</span></td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty dashboardWatchlist}">
                                        <tr><td colspan="6">Chưa có dữ liệu low stock alert.</td></tr>
                                    </c:if>
                                </table>
                            </div>
                        </section>

                        <section class="panel">
                            <div class="panel-header">
                                <div>
                                    <h3>Recent Warehouse Activities</h3>
                                    <p>Dữ liệu gần nhất từ SystemLog.</p>
                                </div>
                            </div>
                            <div class="panel-body">
                                <c:forEach items="${recentLogs}" var="log">
                                    <div class="activity-item">
                                        <div class="activity-date">${log.logDate}</div>
                                        <div class="activity-title">${empty log.action ? 'SYSTEM_EVENT' : log.action}</div>
                                        <div class="activity-desc">${empty log.description ? log.targetObject : log.description}</div>
                                    </div>
                                </c:forEach>
                                <c:if test="${empty recentLogs}">
                                    <div class="empty-box">Chưa có hoạt động kho gần đây.</div>
                                </c:if>
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