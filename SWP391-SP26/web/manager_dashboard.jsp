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
            <small>Operations &rsaquo; ${tab == 'returns' ? 'Return Requests' : 'Warranty Claims'}</small>
        </div>
        <div class="user-profile">
            <span class="avatar">👤</span>
            <strong>${sessionScope.acc.fullName}</strong>
        </div>
    </div>

    <div class="admin-content">
        <c:choose>
            <c:when test="${tab == 'overview'}">
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
                        <h3>${tab == 'returns' ? 'Danh sách yêu cầu trả hàng' : 'Danh sách yêu cầu bảo hành'}</h3>
                        <div style="font-size: 12px; color: var(--text-muted); font-weight: 500;">
                            ${tab == 'returns' ? returns.size() : claims.size()} total requests
                        </div>
                    </div>
            <div class="card-body">
                <c:choose>
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
                                                <c:otherwise><span class="status-pill">${r.status}</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: right;">
                                            <c:choose>
                                                <c:when test="${r.status == 'NEW'}">
                                                    <div class="action-group" style="justify-content: flex-end;">
                                                        <form action="manager_dashboard" method="post" style="display:inline;">
                                                            <input type="hidden" name="action" value="confirmReturn">
                                                            <input type="hidden" name="id" value="${r.id}">
                                                            <button type="submit" class="btn btn-confirm" onclick="return confirm('Xác nhận yêu cầu trả hàng này?');">Xác nhận</button>
                                                        </form>
                                                        <form action="manager_dashboard" method="post" style="display:inline;">
                                                            <input type="hidden" name="action" value="rejectReturn">
                                                            <input type="hidden" name="id" value="${r.id}">
                                                            <button type="submit" class="btn btn-reject" onclick="return confirm('Từ chối yêu cầu trả hàng này?');">Từ chối</button>
                                                        </form>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--text-muted); font-size: 12px; font-style: italic;">No actions</span>
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
                        <table>
                            <thead>
                                <tr>
                                    <th>Mã bảo hành</th>
                                    <th>Sản phẩm / SKU</th>
                                    <th>Khách hàng</th>
                                    <th>Mô tả lỗi</th>
                                    <th>Trạng thái</th>
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
                                        <td style="text-align: right;">
                                            <c:choose>
                                                <c:when test="${c.status == 'NEW'}">
                                                    <div class="action-group" style="justify-content: flex-end;">
                                                        <form action="manager_dashboard" method="post" style="display:inline;">
                                                            <input type="hidden" name="action" value="confirmWarranty">
                                                            <input type="hidden" name="id" value="${c.id}">
                                                            <button type="submit" class="btn btn-confirm" onclick="return confirm('Xác nhận yêu cầu bảo hành này?');">Xác nhận</button>
                                                        </form>
                                                        <form action="manager_dashboard" method="post" style="display:inline;">
                                                            <input type="hidden" name="action" value="rejectWarranty">
                                                            <input type="hidden" name="id" value="${c.id}">
                                                            <button type="submit" class="btn btn-reject" onclick="return confirm('Từ chối yêu cầu bảo hành này?');">Từ chối</button>
                                                        </form>
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
                                        <td colspan="6">
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
    </div>
</div>
</body>
</html>
