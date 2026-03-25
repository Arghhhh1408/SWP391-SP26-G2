<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c"%>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Dashboard | Modern IMS</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6366f1;
            --primary-hover: #4f46e5;
            --bg-body: #f8fafc;
            --sidebar-bg: #0f172a;
            --sidebar-hover: #1e293b;
            --sidebar-text: #94a3b8;
            --sidebar-active: #f8fafc;
            --card-bg: rgba(255, 255, 255, 0.9);
            --text-main: #1e293b;
            --text-muted: #64748b;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --glass-border: rgba(255, 255, 255, 0.3);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            display: flex;
            min-height: 100vh;
            font-family: 'Inter', sans-serif;
            background: var(--bg-body);
            color: var(--text-main);
            overflow-x: hidden;
        }

        /* ===== SIDEBAR ===== */
        .sidebar {
            width: 260px;
            background: var(--sidebar-bg);
            color: var(--sidebar-text);
            display: flex;
            flex-direction: column;
            position: fixed;
            height: 100vh;
            transition: all 0.3s ease;
            z-index: 1000;
        }

        .sidebar-brand {
            padding: 32px 24px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .sidebar-brand h2 {
            color: #fff;
            font-size: 20px;
            font-weight: 700;
            letter-spacing: -0.5px;
        }

        .sidebar-brand small {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--primary);
            font-weight: 600;
        }

        .sidebar-section-title {
            padding: 24px 24px 8px;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: #475569;
            font-weight: 700;
        }

        .sidebar nav {
            flex: 1;
        }

        .sidebar nav a {
            display: flex;
            align-items: center;
            padding: 12px 24px;
            color: var(--sidebar-text);
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s ease;
            margin: 4px 12px;
            border-radius: 8px;
            gap: 12px;
        }

        .sidebar nav a:hover {
            background: var(--sidebar-hover);
            color: #fff;
        }

        .sidebar nav a.active {
            background: var(--primary);
            color: #fff;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
        }

        .sidebar-footer {
            padding: 20px;
            border-top: 1px solid #1e293b;
        }

        .sidebar-footer a {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #94a3b8;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            padding: 10px;
            border-radius: 8px;
            transition: all 0.2s;
        }

        .sidebar-footer a:hover {
            color: var(--danger);
            background: rgba(239, 68, 68, 0.1);
        }

        /* ===== MAIN CONTENT ===== */
        .main {
            flex: 1;
            margin-left: 260px;
            display: flex;
            flex-direction: column;
            min-width: 0;
        }

        .topbar {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(12px);
            padding: 16px 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 900;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }

        .topbar-left h1 {
            font-size: 22px;
            font-weight: 700;
            color: #0f172a;
        }

        .topbar-left small {
            font-size: 13px;
            color: var(--text-muted);
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 8px 16px;
            background: #fff;
            border-radius: 30px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            border: 1px solid #e2e8f0;
        }

        .user-profile strong {
            font-size: 14px;
            color: #334155;
        }

        .content {
            padding: 32px;
            animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* ===== DASHBOARD ELEMENTS ===== */
        .glass-card {
            background: var(--card-bg);
            backdrop-filter: blur(8px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05), 0 4px 6px -2px rgba(0, 0, 0, 0.02);
            overflow: hidden;
            margin-bottom: 24px;
        }

        .card-header {
            padding: 24px 32px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(255, 255, 255, 0.4);
        }

        .card-header h3 {
            font-size: 18px;
            font-weight: 600;
            color: #1e293b;
        }

        .card-body {
            padding: 0;
        }

        /* ===== TABLE ===== */
        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            background: rgba(248, 250, 252, 0.8);
            padding: 16px 24px;
            font-size: 11px;
            font-weight: 700;
            color: #475569;
            text-transform: uppercase;
            letter-spacing: 1px;
            text-align: left;
        }

        td {
            padding: 20px 24px;
            font-size: 14px;
            color: #334155;
            border-bottom: 1px solid #f1f5f9;
        }

        tr:last-child td {
            border-bottom: none;
        }

        tr:hover td {
            background: rgba(248, 250, 252, 0.5);
        }

        /* ===== STATS GRID ===== */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: #fff;
            padding: 28px;
            border-radius: 20px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            gap: 20px;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }

        .stat-info .value {
            display: block;
            font-size: 28px;
            font-weight: 800;
            color: #0f172a;
            line-height: 1;
        }

        .stat-info .label {
            font-size: 13px;
            color: #64748b;
            font-weight: 500;
            margin-top: 4px;
        }

        tr:hover td {
            background: rgba(99, 102, 241, 0.02);
        }

        .status-pill {
            display: inline-flex;
            align-items: center;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            gap: 6px;
        }

        .status-completed { background: #dcfce7; color: #166534; }
        .status-approved { background: #dbeafe; color: #1e40af; }
        .status-rejected { background: #fee2e2; color: #991b1b; }
        .status-new { background: #fef9c3; color: #854d0e; }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 8px 18px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            border: none;
            gap: 8px;
        }

        .btn-confirm {
            background: var(--primary);
            color: #fff;
        }

        .btn-confirm:hover {
            background: var(--primary-hover);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
        }

        .btn-reject {
            background: #fff;
            color: var(--danger);
            border: 1px solid rgba(239, 68, 68, 0.1);
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }

        .btn-reject:hover {
            background: #fee2e2;
            color: #991b1b;
            transform: translateY(-2px);
        }

        .action-group {
            display: flex;
            gap: 10px;
        }

        .empty-state {
            padding: 80px 24px;
            text-align: center;
            color: var(--text-muted);
        }

        .empty-state .icon {
            font-size: 56px;
            margin-bottom: 20px;
            display: block;
            opacity: 0.5;
        }

        .empty-state p {
            font-size: 16px;
            font-weight: 500;
        }

        /* ===== FORM FIELDS ===== */
        .form-field {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-field label {
            font-size: 13px;
            font-weight: 600;
            color: #475569;
        }

        .form-field input,
        .form-field select,
        .form-field textarea {
            padding: 10px 14px;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            font-size: 14px;
            font-family: 'Inter', sans-serif;
            color: #1e293b;
            background: #fff;
            transition: all 0.2s ease;
            outline: none;
        }

        .form-field input:focus,
        .form-field select:focus,
        .form-field textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
        }

        .form-field textarea {
            resize: vertical;
            min-height: 80px;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .sidebar { width: 80px; }
            .sidebar-brand h2, .sidebar-brand small, .sidebar-section-title, .sidebar nav a span:not(.icon) { display: none; }
            .sidebar nav a { justify-content: center; padding: 12px; }
            .main { margin-left: 80px; }
        }
    </style>
</head>
<body>
<c:set var="currentPage" value="manager_dashboard" scope="request" />
<jsp:include page="managerSidebar.jsp" />

<div class="admin-main">
    <div class="admin-topbar">
        <div class="topbar-left">
            <h1>Manager Overview</h1>
            <small>
                Operations &rsaquo;
                <c:choose>
                    <c:when test="${tab == 'overview'}">Overview</c:when>
                    <c:when test="${tab == 'returns'}">Return Requests</c:when>
                    <c:when test="${tab == 'vendorReturns'}">Vendor Return Approvals</c:when>
                    <c:when test="${tab == 'warranty'}">Warranty Claims</c:when>
                    <c:otherwise>Manager Workspace</c:otherwise>
                </c:choose>
            </small>
        </div>
        <div class="user-profile">
            <span class="avatar">👤</span>
            <strong>${sessionScope.acc.fullName}</strong>
        </div>
    </div>

    <div class="admin-content">

        <c:choose>
            <c:when test="${tab == 'overview'}">
                <%
                    java.time.LocalDate now = java.time.LocalDate.now();
                    String today = now.toString();
                    String firstDay = now.withDayOfMonth(1).toString();
                    request.setAttribute("todayDate", today);
                    request.setAttribute("firstDayDate", firstDay);
                %>
                <!-- Dashboard Overview -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon" style="background: rgba(99, 102, 241, 0.1); color: #6366f1;">🛡️</div>
                        <div class="stat-info">
                            <span class="value">${totalClaims}</span>
                            <span class="label">Tổng YC Bảo hành</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: rgba(245, 158, 11, 0.1); color: #f59e0b;">⏳</div>
                        <div class="stat-info">
                            <span class="value">${pendingClaims}</span>
                            <span class="label">Bảo hành Chờ xử lý</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: rgba(16, 185, 129, 0.1); color: #10b981;">🔄</div>
                        <div class="stat-info">
                            <span class="value">${totalReturns}</span>
                            <span class="label">Tổng YC Trả hàng</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: rgba(239, 68, 68, 0.1); color: #ef4444;">⚠️</div>
                        <div class="stat-info">
                            <span class="value">${pendingReturns}</span>
                            <span class="label">Trả hàng Chờ xử lý</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: rgba(14, 165, 233, 0.1); color: #0ea5e9;">🏭</div>
                        <div class="stat-info">
                            <span class="value">${pendingVendorReturns}</span>
                            <span class="label">Phiếu trả NCC chờ duyệt</span>
                        </div>
                    </div>
                    <div class="stat-card" style="cursor: pointer; border: 1px solid ${not empty lowStockProducts ? '#f59e0b' : '#f1f5f9'}; box-shadow: ${not empty lowStockProducts ? '0 0 10px rgba(245, 158, 11, 0.2)' : 'none'};" onclick="toggleLowStockList()">
                        <div class="stat-icon" style="background: rgba(245, 158, 11, 0.1); color: #f59e0b;">⚠️</div>
                        <div class="stat-info">
                            <span class="value">${not empty lowStockProducts ? lowStockProducts.size() : 0}</span>
                            <span class="label">Sản phẩm sắp hết</span>
                        </div>
                    </div>
                </div>

                <!-- Report Export Center -->
                <div class="glass-card" style="margin-bottom: 32px; border-top: 4px solid var(--primary);">
                    <div class="card-header">
                        <h3 style="display: flex; align-items: center; gap: 10px;">
                            <span style="font-size: 24px;">📊</span> Trung tâm Xuất báo cáo
                        </h3>
                        <span style="font-size: 12px; color: #64748b; font-weight: 500;">Tùy chọn xuất dữ liệu Excel cho Manager</span>
                    </div>
                    <div class="card-body" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; padding: 24px;">
                        
                        <!-- 1. Inventory -->
                        <div class="export-tile" style="background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%); padding: 24px; border-radius: 16px; border: 1px solid #bae6fd; display: flex; flex-direction: column; align-items: center; transition: transform 0.2s;">
                            <div style="font-size: 32px; margin-bottom: 15px;">📦</div>
                            <h4 style="margin-bottom: 8px; color: #0369a1;">Báo cáo Tồn kho</h4>
                            <p style="font-size: 11px; color: #0c4a6e; margin-bottom: 16px; text-align: center;">Thông tin tồn kho, giá trị hàng hóa và cảnh báo nhập hàng.</p>
                            <div style="margin-top: auto; width: 100%;">
                                <a href="exportManager?type=inventory" class="btn" style="width: 100%; background: #0ea5e9; border: none; padding: 10px; font-weight: 600; text-align: center; text-decoration: none; display: block;">Xuất Excel</a>
                            </div>
                        </div>

                        <!-- 2. Sales & Profit -->
                        <div class="export-tile" style="background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%); padding: 24px; border-radius: 16px; border: 1px solid #bbf7d0; display: flex; flex-direction: column; align-items: center; transition: transform 0.2s;">
                            <div style="font-size: 32px; margin-bottom: 15px;">💰</div>
                            <h4 style="margin-bottom: 8px; color: #15803d;">Doanh thu & Lợi nhuận</h4>
                            <p style="font-size: 11px; color: #166534; margin-bottom: 16px; text-align: center;">Thống kê doanh thu, giá vốn và lợi nhuận gộp theo ngày.</p>
                            <form action="exportManager" method="GET" style="width: 100%; margin-top: auto;">
                                <input type="hidden" name="type" value="sales">
                                <div style="display: flex; gap: 8px; margin-bottom: 12px;">
                                    <div style="flex: 1;">
                                        <label style="font-size: 10px; color: #166534; font-weight: 600; display: block; margin-bottom: 4px;">Từ ngày</label>
                                        <input type="date" name="fromDate" id="salesFrom" value="${firstDayDate}" max="${todayDate}" class="form-control report-date" style="font-size: 11px; width: 100%; padding: 6px; border: 1px solid #86efac;">
                                    </div>
                                    <div style="flex: 1;">
                                        <label style="font-size: 10px; color: #166534; font-weight: 600; display: block; margin-bottom: 4px;">Đến ngày</label>
                                        <input type="date" name="toDate" id="salesTo" value="${todayDate}" max="${todayDate}" class="form-control report-date" style="font-size: 11px; width: 100%; padding: 6px; border: 1px solid #86efac;">
                                    </div>
                                </div>
                                <button type="submit" class="btn" style="width: 100%; background: #22c55e; border: none; padding: 10px; font-weight: 600;">Xuất Excel</button>
                            </form>
                        </div>

                        <!-- 3. Transactions -->
                        <div class="export-tile" style="background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 100%); padding: 24px; border-radius: 16px; border: 1px solid #c7d2fe; display: flex; flex-direction: column; align-items: center; transition: transform 0.2s;">
                            <div style="font-size: 32px; margin-bottom: 15px;">📉</div>
                            <h4 style="margin-bottom: 8px; color: #4338ca;">Chi tiết Nhập/Xuất</h4>
                            <p style="font-size: 11px; color: #4338ca; margin-bottom: 16px; text-align: center;">Dữ liệu chi tiết từng dòng trong phiếu nhập hoặc hóa đơn.</p>
                            <form action="exportManager" method="GET" style="width: 100%; margin-top: auto;">
                                <select name="type" class="form-control" style="font-size: 11px; width: 100%; padding: 8px; border: 1px solid #a5b4fc; margin-bottom: 12px; background: white;">
                                    <option value="stockin_details">📦 Chi tiết Nhập kho</option>
                                    <option value="stockout_details">🤝 Chi tiết Xuất kho</option>
                                </select>
                                <div style="display: flex; gap: 8px; margin-bottom: 12px;">
                                    <div style="flex: 1;">
                                        <input type="date" name="fromDate" id="transFrom" value="${firstDayDate}" max="${todayDate}" class="form-control report-date" style="font-size: 11px; width: 100%; padding: 6px; border: 1px solid #a5b4fc;">
                                    </div>
                                    <div style="flex: 1;">
                                        <input type="date" name="toDate" id="transTo" value="${todayDate}" max="${todayDate}" class="form-control report-date" style="font-size: 11px; width: 100%; padding: 6px; border: 1px solid #a5b4fc;">
                                    </div>
                                </div>
                                <button type="submit" class="btn" style="width: 100%; background: #6366f1; border: none; padding: 10px; font-weight: 600;">Xuất Excel</button>
                            </form>
                        </div>

                        <!-- 4. Performance -->
                        <div class="export-tile" style="background: linear-gradient(135deg, #fffbeb 0%, #fef3c7 100%); padding: 24px; border-radius: 16px; border: 1px solid #fde68a; display: flex; flex-direction: column; align-items: center; transition: transform 0.2s;">
                            <div style="font-size: 32px; margin-bottom: 15px;">🏆</div>
                            <h4 style="margin-bottom: 8px; color: #b45309;">Top 20 Sản phẩm</h4>
                            <p style="font-size: 11px; color: #92400e; margin-bottom: 16px; text-align: center;">Danh sách sản phẩm bán chạy nhất theo doanh thu.</p>
                            <div style="margin-top: auto; width: 100%;">
                                <a href="exportManager?type=performance" class="btn" style="width: 100%; background: #f59e0b; border: none; padding: 10px; font-weight: 600; text-align: center; text-decoration: none; display: block;">Xuất Excel</a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Low Stock Detailed List -->
                <div id="lowStockDetails" class="glass-card" style="display: none; border: 2px solid #f59e0b; background: #fffcf0; margin-bottom: 32px;">
                    <div class="card-header" style="background: #fef3c7; border-bottom: 1px solid #fde68a;">
                        <h3 style="color: #92400e; font-weight: 700;">Danh sách sản phẩm dưới mức an tồn</h3>
                        <button onclick="toggleLowStockList()" style="background: #fef3c7; border: 1px solid #f59e0b; border-radius: 4px; padding: 2px 8px; cursor: pointer; color: #92400e;">Đóng</button>
                    </div>
                    <div class="card-body">
                        <table class="admin-table">
                            <thead>
                                <tr style="background: rgba(245, 158, 11, 0.05);">
                                    <th>Ảnh</th>
                                    <th>Tên sản phẩm</th>
                                    <th>SKU</th>
                                    <th>Số lượng</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${lowStockProducts}" var="lp">
                                    <tr>
                                        <td><img src="${lp.imageURL}" style="width: 40px; height: 40px; border-radius: 4px; object-fit: contain; background: #fff; border: 1px solid #eee;"></td>
                                        <td style="font-weight: 600;">${lp.name}</td>
                                        <td><code style="font-size: 12px; color: #64748b;">${lp.sku}</code></td>
                                        <td>
                                            <span class="stock-badge stock-low" style="font-size: 16px; background: #fee2e2; padding: 2px 8px; border-radius: 4px;">${lp.quantity}</span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="glass-card">
                    <div class="card-header">
                        <h3>Yêu cầu bảo hành gần đây</h3>
                        <a href="manager_dashboard?tab=warranty" class="btn btn-outline" style="padding: 6px 14px; font-size: 12px;">Xem tất cả</a>
                    </div>
                    <div class="card-body">
                        <table>
                            <thead>
                                <tr>
                                    <th>Mã yêu cầu</th>
                                    <th>Sản phẩm</th>
                                    <th>Khách hàng</th>
                                    <th>Trạng thái</th>
                                    <th>Cập nhật</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${recentClaims}" var="c">
                                    <tr>
                                        <td style="font-weight: 600; color: var(--primary);">${c.claimCode}</td>
                                        <td>${c.productName}</td>
                                        <td>${c.customerName}</td>
                                        <td>
                                            <span class="badge badge-${c.status.name().toLowerCase()}">
                                                ${c.status.name()}
                                            </span>
                                        </td>
                                        
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

            </c:when>

            <c:otherwise>
                <div class="glass-card">
                    <div class="card-header">
                        <c:choose>
                            <c:when test="${tab == 'returns'}">
                                <h3>Danh sách yêu cầu trả hàng</h3>
                            </c:when>
                            <c:when test="${tab == 'vendorReturns'}">
                                <h3>Danh sách phiếu trả nhà cung cấp</h3>
                            </c:when>
                            <c:otherwise>
                                <h3>Danh sách yêu cầu bảo hành</h3>
                            </c:otherwise>
                        </c:choose>
                        <div style="font-size: 12px; color: var(--text-muted); font-weight: 500;">
                            <c:choose>
                                <c:when test="${tab == 'returns'}">${returns.size()} total requests</c:when>
                                <c:when test="${tab == 'vendorReturns'}">${vendorReturns.size()} total requests</c:when>
                                <c:otherwise>${claims.size()} total requests</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${tab == 'vendorReturns'}">
                        <c:if test="${param.msg == 'approved'}">
                            <div style="background:#dcfce7; border:1px solid #86efac; color:#166534; padding:12px 16px; border-radius:8px; margin:16px;">
                                Duyệt phiếu trả NCC thành công.
                            </div>
                        </c:if>
                        <c:if test="${param.msg == 'rejected'}">
                            <div style="background:#dcfce7; border:1px solid #86efac; color:#166534; padding:12px 16px; border-radius:8px; margin:16px;">
                                Từ chối phiếu trả NCC thành công.
                            </div>
                        </c:if>
                        <c:if test="${not empty param.err}">
                            <div style="background:#fee2e2; border:1px solid #fca5a5; color:#991b1b; padding:12px 16px; border-radius:8px; margin:16px;">
                                Thao tác duyệt phiếu trả NCC thất bại. Mã lỗi: ${param.err}
                            </div>
                        </c:if>
                        <table>
                            <thead>
                                <tr>
                                    <th>Mã phiếu</th>
                                    <th>Nhà cung cấp</th>
                                    <th>Lý do</th>
                                    <th>Thanh toán</th>
                                    <th>Trạng thái</th>
                                    <th>Tổng tiền</th>
                                    <th>Ngày tạo</th>
                                    <th style="text-align: right;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${vendorReturns}" var="vr">
                                    <tr>
                                        <td><code style="background: #f1f5f9; padding: 4px 8px; border-radius: 4px; font-weight: 700; color: #334155;">${vr.returnCode}</code></td>
                                        <td>
                                            <div style="font-weight: 600; color: #0f172a;">${vr.supplierName}</div>
                                            <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">RTVID: ${vr.rtvID}</div>
                                        </td>
                                        <td>
                                            <div style="max-width: 220px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${vr.reason}">
                                                ${vr.reason}
                                            </div>
                                        </td>
                                        <td>${vr.settlementType}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${vr.status == 'Completed'}"><span class="status-pill status-completed">Completed</span></c:when>
                                                <c:when test="${vr.status == 'Approved'}"><span class="status-pill status-approved">Approved</span></c:when>
                                                <c:when test="${vr.status == 'Rejected'}"><span class="status-pill status-rejected">Rejected</span></c:when>
                                                <c:otherwise><span class="status-pill status-new">Pending</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><fmt:formatNumber value="${vr.totalAmount}" type="number" minFractionDigits="0" maxFractionDigits="2"/></td>
                                        <td>${vr.createdDate}</td>
                                        <td style="text-align: right;">
                                            <div style="display:flex; gap:8px; justify-content:flex-end; align-items:center; flex-wrap:wrap;">
                                                <a href="return-to-vendor?action=detail&id=${vr.rtvID}&from=manager" class="btn btn-reject" style="text-decoration:none;">Chi tiết</a>
                                                <c:if test="${vr.status == 'Pending'}">
                                                    <form action="manager_dashboard" method="post" style="display:inline;">
                                                        <input type="hidden" name="action" value="approveVendorReturn">
                                                        <input type="hidden" name="rtvID" value="${vr.rtvID}">
                                                        <button type="submit" class="btn btn-confirm" onclick="return confirm('Duyệt phiếu trả NCC này?');">Duyệt</button>
                                                    </form>
                                                    <form action="manager_dashboard" method="post" style="display:inline-flex; gap:8px; align-items:center; flex-wrap:wrap; justify-content:flex-end;">
                                                        <input type="hidden" name="action" value="rejectVendorReturn">
                                                        <input type="hidden" name="rtvID" value="${vr.rtvID}">
                                                        <input type="text" name="rejectNote" placeholder="Lý do từ chối" style="padding:8px 10px; border:1px solid #cbd5e1; border-radius:8px; min-width:160px;">
                                                        <button type="submit" class="btn btn-reject" onclick="return confirm('Từ chối phiếu trả NCC này?');">Từ chối</button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty vendorReturns}">
                                    <tr>
                                        <td colspan="8">
                                            <div class="empty-state">
                                                <span class="icon">📫</span>
                                                <p>Chưa có phiếu trả nhà cung cấp nào.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </c:when>
                    <c:when test="${tab == 'returns'}">
                        <table>
                            <thead>
                                <tr>
                                    <th>Mã yêu cầu</th>
                                    <th>Sản phẩm / SKU</th>
                                    <th>Khách hàng</th>
                                    <th>Lý do</th>
                                    <th>Trạng thái</th>
                                    <th style="text-align: right;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${returns}" var="r">
                                    <tr>
                                        <td><code style="background: #f1f5f9; padding: 4px 8px; border-radius: 4px; font-weight: 700; color: #334155;">#${r.returnCode}</code></td>
                                        <td>
                                            <div style="font-weight: 600; color: #0f172a;">${r.productName}</div>
                                            <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">SKU: ${r.sku}</div>
                                        </td>
                                        <td style="font-weight: 500;">${r.customerName}</td>
                                        <td>
                                            <div style="max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${r.reason}">
                                                ${r.reason}
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${r.status == 'COMPLETED'}"><span class="status-pill status-completed">Da tra hang</span></c:when>
                                                <c:when test="${r.status == 'APPROVED'}"><span class="status-pill status-approved">Da xac nhan</span></c:when>
                                                <c:when test="${r.status == 'REJECTED'}"><span class="status-pill status-rejected">Tu choi</span></c:when>
                                                <c:when test="${r.status == 'NEW'}"><span class="status-pill status-new">Dang xu ly</span></c:when>
                                                <c:when test="${r.status == 'REFUNDED'}"><span class="status-pill status-completed">Da hoan tien</span></c:when>
                                                <c:otherwise><span class="status-pill">${r.status}</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: right;">
                                            <c:choose>
                                                <c:when test="${r.status == 'NEW'}">
                                                    <form action="manager_dashboard" method="post" style="display:inline;">
                                                        <input type="hidden" name="action" value="confirmReturn">
                                                        <input type="hidden" name="id" value="${r.id}">
                                                        <button type="submit" class="btn btn-confirm" onclick="return confirm('Xác nhận yêu cầu trả hàng này?');">Xác nhận</button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--text-muted); font-size: 12px; font-style: italic;">Không có thao tác</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty returns}">
                                    <tr>
                                        <td colspan="6">
                                            <div class="empty-state">
                                                <span class="icon">📫</span>
                                                <p>Chưa có yêu cầu trả hàng nào được ghi nhận.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <c:if test="${param.err == 'warranty_expired'}">
                            <div style="background:#fef3c7; border:1px solid #f59e0b; color:#92400e; padding:12px 16px; border-radius:8px; margin-bottom:16px;">
                                Không thể xác nhận: sản phẩm đã <strong>quá thời hạn bảo hành 12 tháng</strong> kể từ ngày mua.
                            </div>
                        </c:if>
                        <table>
                            <thead>
                                <tr>
                                    <th>Mã bảo hành</th>
                                    <th>Sản phẩm / SKU</th>
                                    <th>Khách hàng</th>
                                    <th>Mô tả lỗi</th>
                                    <th>Trạng thái</th>
                                    <th>Bảo hành</th>
                                    <th style="text-align: right;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${claims}" var="c">
                                    <tr>
                                        <td><code style="background: #f1f5f9; padding: 4px 8px; border-radius: 4px; font-weight: 700; color: #334155;">#${c.claimCode}</code></td>
                                        <td>
                                            <div style="font-weight: 600; color: #0f172a;">${c.productName}</div>
                                            <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">SKU: ${c.sku}</div>
                                        </td>
                                        <td style="font-weight: 500;">${c.customerName}</td>
                                        <td>
                                            <div style="max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${c.issueDescription}">
                                                ${c.issueDescription}
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${c.status == 'COMPLETED'}"><span class="status-pill status-completed">Da bao hanh</span></c:when>
                                                <c:when test="${c.status == 'APPROVED'}"><span class="status-pill status-approved">Da xac nhan</span></c:when>
                                                <c:when test="${c.status == 'REJECTED'}"><span class="status-pill status-rejected">Tu choi</span></c:when>
                                                <c:when test="${c.status == 'NEW'}"><span class="status-pill status-new">Dang xu ly</span></c:when>
                                                <c:otherwise><span class="status-pill">${c.status}</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:set var="exp" value="${warrantyExpiredByClaimId[c.id]}"/>
                                            <c:choose>
                                                <c:when test="${exp == true}"><span style="font-size:12px;color:#b91c1c;font-weight:600;">Hết hạn (12 tháng)</span></c:when>
                                                <c:when test="${exp == false}"><span style="font-size:12px;color:#15803d;">Còn trong hạn</span></c:when>
                                                <c:otherwise><span style="font-size:12px;color:#64748b;">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: right;">
                                            <c:choose>
                                                <c:when test="${c.status == 'NEW'}">
                                                    <div class="action-group" style="justify-content: flex-end;">
                                                        <c:choose>
                                                            <c:when test="${warrantyExpiredByClaimId[c.id] == true}">
                                                                <span style="color: var(--text-muted); font-size: 12px;">Không thể xác nhận (đã hết hạn BH)</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <form action="manager_dashboard" method="post" style="display:inline;">
                                                                    <input type="hidden" name="action" value="confirmWarranty">
                                                                    <input type="hidden" name="id" value="${c.id}">
                                                                    <button type="submit" class="btn btn-confirm" onclick="return confirm('Xác nhận yêu cầu bảo hành này?');">Xác nhận</button>
                                                                </form>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--text-muted); font-size: 12px; font-style: italic;">No actions</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty claims}">
                                    <tr>
                                        <td colspan="7">
                                            <div class="empty-state">
                                                <span class="icon">🛡️</span>
                                                <p>Chưa có yêu cầu bảo hành nào cần xử lý.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </c:otherwise>
</c:choose>
        <script>
            function toggleLowStockList() {
                var details = document.getElementById('lowStockDetails');
                if (details.style.display === 'none') {
                    details.style.display = 'block';
                    details.scrollIntoView({ behavior: 'smooth', block: 'center' });
                } else {
                    details.style.display = 'none';
                }
            }

            // Logic cho việc chọn ngày xuất báo cáo
            (function() {
                const initDateControls = () => {
                    const dateInputs = document.querySelectorAll('.report-date');
                    dateInputs.forEach(input => {
                        // Validation khi thay đổi
                        input.addEventListener('change', function() {
                            const form = this.closest('form');
                            const fromInput = form.querySelector('input[name="fromDate"]');
                            const toInput = form.querySelector('input[name="toDate"]');
                            const from = fromInput.value;
                            const to = toInput.value;
                            
                            if (from && to && from > to) {
                                alert("Ngày bắt đầu không thể lớn hơn ngày kết thúc!");
                                this.value = (this.name === 'fromDate') ? to : from;
                            }
                        });
                    });
                };

                if (document.readyState === "loading") {
                    document.addEventListener("DOMContentLoaded", initDateControls);
                } else {
                    initDateControls();
                }
            })();
        </script>
    </div>
</div>
</body>
</html>
