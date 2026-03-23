<%-- Shared Manager Sidebar Fragment --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
      rel="stylesheet">
<style>
    :root {
        --primary: #6366f1;
        --primary-active: #4f46e5;
        --sidebar-bg: #0f172a;
        --sidebar-text: #94a3b8;
        --sidebar-hover: #1e293b;
        --text-main: #1e293b;
        --text-muted: #64748b;
    }

    body {
        margin: 0;
        padding: 0;
        display: flex;
        min-height: 100vh;
        font-family: 'Inter', sans-serif;
        background-color: #f8fafc;
    }

    .admin-sidebar {
        width: 260px;
        background: var(--sidebar-bg);
        color: var(--sidebar-text);
        display: flex;
        flex-direction: column;
        position: fixed;
        height: 100vh;
        z-index: 1000;
        box-shadow: 4px 0 10px rgba(0, 0, 0, 0.1);
    }

    .sidebar-brand {
        padding: 32px 24px;
        border-bottom: 1px solid #1e293b;
    }

    .sidebar-brand h2 {
        color: #fff;
        font-size: 22px;
        font-weight: 700;
        margin: 0;
        letter-spacing: -0.5px;
    }

    .sidebar-brand small {
        display: block;
        margin-top: 4px;
        font-size: 11px;
        text-transform: uppercase;
        color: var(--primary);
        font-weight: 700;
        letter-spacing: 1px;
    }

    .sidebar-section-title {
        padding: 24px 24px 8px;
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: 1.5px;
        color: #475569;
        font-weight: 700;
    }

    .admin-sidebar nav {
        flex: 1;
        overflow-y: auto;
    }

    .admin-sidebar nav::-webkit-scrollbar {
        width: 4px;
    }

    .admin-sidebar nav::-webkit-scrollbar-thumb {
        background: #1e293b;
        border-radius: 4px;
    }

    .admin-sidebar nav a {
        display: flex;
        align-items: center;
        padding: 12px 20px;
        color: var(--sidebar-text);
        text-decoration: none;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.2s ease;
        margin: 4px 16px;
        border-radius: 12px;
        gap: 12px;
    }

    .admin-sidebar nav a:hover {
        background: var(--sidebar-hover);
        color: #fff;
    }

    .admin-sidebar nav a.active {
        background: var(--primary);
        color: #fff;
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
    }

    .nav-icon {
        font-size: 18px;
        width: 24px;
        text-align: center;
    }

    /* ===== NOTIFICATION BADGE ===== */
    .nav-link-wrap {
        display: flex;
        align-items: center;
        justify-content: space-between;
        width: 100%;
    }

    .notif-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: #e74c3c;
        color: #fff;
        font-size: 11px;
        font-weight: 700;
        min-width: 18px;
        height: 18px;
        border-radius: 9px;
        padding: 0 5px;
        margin-left: auto;
        line-height: 1;
        animation: badgePop 0.3s ease;
    }

    @keyframes badgePop {
        0%   { transform: scale(0.5); opacity: 0; }
        70%  { transform: scale(1.2); }
        100% { transform: scale(1);   opacity: 1; }
    }

    .sidebar-footer {
        padding: 24px;
        border-top: 1px solid #1e293b;
    }

    .sidebar-footer a {
        display: flex;
        align-items: center;
        gap: 10px;
        color: #94a3b8;
        text-decoration: none;
        font-size: 14px;
        font-weight: 600;
        padding: 12px;
        border-radius: 12px;
        transition: all 0.2s;
    }

    .sidebar-footer a:hover {
        background: rgba(239, 68, 68, 0.1);
        color: #ef4444;
    }

    /* Layout helper for pages including this sidebar */
    .admin-main {
        margin-left: 260px;
        flex: 1;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
        min-width: 0;
    }

    .admin-topbar {
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

    .admin-content {
        padding: 32px;
        flex: 1;
    }

    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 8px 18px;
        border-radius: 10px;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
        border: none;
        gap: 8px;
        text-decoration: none;
    }

    .btn-primary {
        background: var(--primary);
        color: #fff !important;
    }

    .btn-primary:hover {
        background: var(--primary-active);
        box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
    }

    .btn-outline {
        border: 1px solid #e2e8f0;
        color: var(--text-main);
        background: #fff;
    }

    .btn-outline:hover {
        background: #f1f5f9;
        border-color: #cbd5e1;
    }
</style>

<aside class="admin-sidebar">
    <div class="sidebar-brand">
        <h2>IMS PRO</h2>
        <small>Manager Terminal</small>
    </div>

    <nav>
        <div class="sidebar-section-title">Operations</div>
        <a href="${pageContext.request.contextPath}/manager_dashboard"
           class="${currentPage == 'manager_dashboard' && empty param.tab ? 'active' : ''}">
            <span class="nav-icon">📊</span> Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/notifications"
           class="${currentPage == 'notifications' ? 'active' : ''}" id="mgr-notif-link">
            <span class="nav-icon">🔔</span>
            <span class="nav-link-wrap">
                Thông báo
                <span class="notif-badge" id="mgr-notif-badge" style="display:none;">0</span>
            </span>
        </a>
        <a href="${pageContext.request.contextPath}/manager_dashboard?tab=warranty"
           class="${param.tab == 'warranty' ? 'active' : ''}">
            <span class="nav-icon">🛡️</span> Bảo hành
        </a>
        <a href="${pageContext.request.contextPath}/manager_dashboard?tab=returns"
           class="${param.tab == 'returns' ? 'active' : ''}">
            <span class="nav-icon">🔄</span> Trả hàng
        </a>

        <div class="sidebar-section-title">Warehouse</div>
        <a href="${pageContext.request.contextPath}/category"
           class="${currentPage == 'category' ? 'active' : ''}">
            <span class="nav-icon">📦</span> Sản phẩm
        </a>
        <a href="${pageContext.request.contextPath}/manageCategories"
           class="${currentPage == 'manageCategories' ? 'active' : ''}">
            <span class="nav-icon">🗂️</span> Danh mục
        </a>
        <a href="${pageContext.request.contextPath}/supplierList"
           class="${currentPage == 'supplierList' ? 'active' : ''}">
            <span class="nav-icon">🤝</span> Nhà cung cấp
        </a>
        <a href="${pageContext.request.contextPath}/stockinList"
           class="${currentPage == 'stockinList' ? 'active' : ''}">
            <span class="nav-icon">📥</span> Nhập kho
        </a>
        <a href="${pageContext.request.contextPath}/inventoryCheck?mode=approval"
           class="${currentPage == 'inventoryApproval' ? 'active' : ''}">
            <span class="nav-icon">✅</span> Duyệt kiểm kho
        </a>
        <c:if test="${sessionScope.acc.roleID == 2}">
            <a href="${pageContext.request.contextPath}/productHistory"
               class="${currentPage == 'productHistory' ? 'active' : ''}">
                <span class="nav-icon">📋</span> Lịch sử sản phẩm
            </a>
        </c:if>

        <c:if test="${sessionScope.acc.roleID == 0}">
            <div class="sidebar-section-title">System</div>
            <a href="${pageContext.request.contextPath}/admin">
                <span class="nav-icon">⚙️</span> Control Panel
            </a>
        </c:if>

        <div class="sidebar-section-title">Tài khoản</div>
        <a href="${pageContext.request.contextPath}/personalProfile"
           class="${currentPage == 'personalProfile' ? 'active' : ''}">
            <span class="nav-icon">👤</span> Hồ sơ cá nhân
        </a>
    </nav>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/logout">
            <span class="nav-icon">🚪</span> Đăng xuất
        </a>
    </div>
</aside>

<script>
    (function () {
        var badge = document.getElementById('mgr-notif-badge');
        if (!badge) return;
        var wsProtocol = location.protocol === 'https:' ? 'wss' : 'ws';
        var wsUrl = wsProtocol + '://' + location.host + '${pageContext.request.contextPath}/notifications';
        var ws;
        function connect() {
            ws = new WebSocket(wsUrl);
            ws.onmessage = function (e) {
                try {
                    var data = JSON.parse(e.data);
                    var count = parseInt(data.unreadCount || data.count || 0);
                    if (count > 0) {
                        badge.textContent = count > 99 ? '99+' : count;
                        badge.style.display = '';
                    } else {
                        badge.style.display = 'none';
                    }
                } catch (ex) {}
            };
            ws.onclose = function () { setTimeout(connect, 5000); };
            ws.onerror = function () { ws.close(); };
        }
        connect();
    })();
</script>