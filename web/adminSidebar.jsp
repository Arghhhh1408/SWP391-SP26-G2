<%-- Document : adminSidebar (Manager Style Re-skin) --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<style>
    :root {
        --primary: #5c67f2;
        --sidebar-bg: #1e1e2d;
        --sidebar-active: #5c67f2;
        --sidebar-hover: #2b2b40;
        --sidebar-text: #a2a3b7;
        --sidebar-header: #4c4e6f;
        --content-bg: #f4f6f9;
        --topbar-bg: #ffffff;
        --card-bg: #ffffff;
        --border-color: #ebedf2;
        --text-main: #3f4254;
        --text-muted: #b5b5c3;
    }

    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
    }

    body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        background-color: var(--content-bg);
        color: var(--text-main);
        min-height: 100vh;
        display: flex;
    }

    /* ===== SIDEBAR ===== */
    .admin-sidebar {
        width: 265px;
        background-color: var(--sidebar-bg);
        color: #fff;
        height: 100vh;
        position: fixed;
        left: 0;
        top: 0;
        display: flex;
        flex-direction: column;
        z-index: 1000;
        padding: 0;
    }

    .sidebar-brand {
        padding: 30px 25px;
        display: flex;
        flex-direction: column;
        gap: 5px;
    }

    .sidebar-brand h2 {
        font-size: 20px;
        font-weight: 800;
        color: #fff;
        letter-spacing: 1px;
    }

    .sidebar-brand p {
        font-size: 11px;
        color: #5c67f2;
        text-transform: uppercase;
        font-weight: 700;
        letter-spacing: 0.5px;
    }

    .sidebar-menu {
        flex: 1;
        padding: 10px 15px;
        overflow-y: auto;
    }

    .menu-section-title {
        color: var(--sidebar-header);
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1.5px;
        padding: 25px 10px 10px 10px;
    }

    .menu-item {
        display: flex;
        align-items: center;
        padding: 12px 15px;
        color: var(--sidebar-text);
        text-decoration: none;
        font-size: 14px;
        font-weight: 500;
        transition: all 0.3s;
        border-radius: 10px;
        margin-bottom: 2px;
        gap: 12px;
    }

    .menu-item:hover {
        background-color: var(--sidebar-hover);
        color: #fff;
    }

    .menu-item.active {
        background-color: var(--sidebar-active);
        color: #fff;
        box-shadow: 0 4px 15px rgba(92, 103, 242, 0.3);
    }

    .menu-icon {
        font-size: 16px;
        width: 24px;
        text-align: center;
    }

    .sidebar-footer {
        padding: 20px;
        border-top: 1px solid rgba(255,255,255,0.05);
    }

    .btn-logout {
        display: flex;
        align-items: center;
        gap: 10px;
        color: #f64e60;
        text-decoration: none;
        font-size: 14px;
        padding: 12px 15px;
        border-radius: 10px;
        transition: background 0.3s;
    }

    .btn-logout:hover {
        background: rgba(246, 78, 96, 0.1);
    }

    /* ===== MAIN CONTENT ===== */
    .admin-main {
        margin-left: 265px;
        flex: 1;
        min-width: 0;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
    }

    .admin-topbar {
        height: 75px;
        background: var(--topbar-bg);
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 35px;
        border-bottom: 1px solid var(--border-color);
        position: sticky;
        top: 0;
        z-index: 900;
    }

    .topbar-left h1 {
        font-size: 18px;
        font-weight: 700;
        color: #181c32;
    }

    .topbar-left p {
        font-size: 12px;
        color: var(--text-muted);
    }

    .user-profile {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 8px 16px;
        background: #f3f6f9;
        border-radius: 12px;
        cursor: pointer;
    }

    .user-profile span {
        font-size: 14px;
        font-weight: 600;
        color: #3f4254;
    }

    .admin-content {
        padding: 35px;
        flex: 1;
    }

    /* ===== COMMON COMPONENTS ===== */
    .card {
        background: var(--card-bg);
        border-radius: 15px;
        border: none;
        box-shadow: 0 0 20px 0 rgba(76, 87, 125, 0.02);
        margin-bottom: 30px;
        overflow: hidden;
    }

    .card-header {
        padding: 20px 25px;
        background: transparent;
        border-bottom: 1px solid var(--border-color);
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .card-header h3 {
        font-size: 16px;
        font-weight: 700;
    }

    .card-body {
        padding: 25px;
    }

    .admin-table {
        width: 100%;
        border-collapse: collapse;
    }

    .admin-table th {
        padding: 12px 15px;
        text-align: left;
        background: #f9f9fc;
        color: #b5b5c3;
        font-size: 11px;
        text-transform: uppercase;
        font-weight: 700;
        letter-spacing: 1px;
    }

    .admin-table td {
        padding: 15px;
        border-bottom: 1px solid var(--border-color);
        font-size: 14px;
        color: #3f4254;
    }

    .admin-table tr:hover td {
        background-color: #fcfcfd;
    }

    /* Form Controls */
    .form-control {
        width: 100%;
        padding: 12px 15px;
        border-radius: 10px;
        border: 1px solid var(--border-color);
        background: #f3f6f9;
        color: #3f4254;
        font-size: 14px;
        transition: all 0.3s;
        outline: none;
    }

    .form-control:focus {
        background: #ebedf3;
        border-color: var(--primary);
    }

    .btn {
        padding: 12px 25px;
        border-radius: 10px;
        font-weight: 600;
        font-size: 14px;
        cursor: pointer;
        transition: all 0.3s;
        border: none;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
    }

    .btn-primary {
        background-color: var(--primary);
        color: #fff;
    }

    .btn-primary:hover {
        background-color: #4347d9;
    }

    .btn-outline {
        background-color: #f3f6f9;
        color: #7e8299;
    }

    .btn-outline:hover {
        background-color: #e4e6ef;
        color: var(--primary);
    }

    .badge {
        padding: 6px 12px;
        border-radius: 8px;
        font-size: 12px;
        font-weight: 700;
    }

    /* Badge Types */
    .badge-primary { background: rgba(92, 103, 242, 0.1); color: #5c67f2; }
    .badge-success { background: rgba(80, 205, 137, 0.1); color: #50cd89; }
    .badge-danger { background: rgba(246, 78, 96, 0.1); color: #f64e60; }
    .badge-warning { background: rgba(255, 173, 115, 0.1); color: #ffad73; }
</style>

<aside class="admin-sidebar">
    <div class="sidebar-brand">
        <h2>IMS PRO</h2>
        <p>Admin Terminal</p>
    </div>

    <nav class="sidebar-menu">
        <div class="menu-section-title">Tổng quan</div>
        <a href="admin" class="menu-item ${param.currentPage == 'dashboard' ? 'active' : ''}">
            <span class="menu-icon">📊</span> Dashboard
        </a>
        <a href="notifications" class="menu-item ${param.currentPage == 'notifications' ? 'active' : ''}">
            <span class="menu-icon">🔔</span> Thông báo
        </a>

        <div class="menu-section-title">Quản lý</div>
        <a href="userList" class="menu-item ${param.currentPage == 'userList' ? 'active' : ''}">
            <span class="menu-icon">👥</span> Tài khoản
        </a>
        <a href="createuser" class="menu-item ${param.currentPage == 'createUser' ? 'active' : ''}">
            <span class="menu-icon">➕</span> Cấp tài khoản
        </a>
        <a href="deletedUsers" class="menu-item ${param.currentPage == 'deletedUsers' ? 'active' : ''}">
            <span class="menu-icon">🗑️</span> Thùng rác
        </a>

        <div class="menu-section-title">Hệ thống</div>
        <a href="systemlog" class="menu-item ${param.currentPage == 'systemLog' ? 'active' : ''}">
            <span class="menu-icon">📄</span> Logs Hoạt động
        </a>
        <a href="personalProfile" class="menu-item ${param.currentPage == 'personalProfile' ? 'active' : ''}">
            <span class="menu-icon">👤</span> Hồ sơ cá nhân
        </a>
    </nav>

    <div class="sidebar-footer">
        <a href="logout" class="btn-logout">
            <span class="menu-icon">🚪</span> Đăng xuất
        </a>
    </div>
</aside>