<%-- Shared Sales Sidebar Fragment --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<style>
    /* ===== RESET & BASE ===== */
    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
    }

    body {
        display: flex;
        min-height: 100vh;
        font-family: Arial, sans-serif;
        background: #f4f6f9;
    }

    /* ===== SIDEBAR ===== */
    .admin-sidebar {
        width: 220px;
        min-height: 100vh;
        background: #1a1a2e;
        color: #ccc;
        display: flex;
        flex-direction: column;
        flex-shrink: 0;
        position: fixed;
        top: 0;
        left: 0;
        bottom: 0;
        overflow-y: auto;
        z-index: 100;
    }

    .sidebar-brand {
        padding: 20px 16px 12px;
        border-bottom: 1px solid #2e2e50;
    }

    .sidebar-brand h2 {
        color: #fff;
        font-size: 18px;
    }

    .sidebar-brand small {
        font-size: 11px;
        color: #888;
    }

    .sidebar-section-title {
        padding: 16px 16px 6px;
        font-size: 10px;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: #555;
    }

    .admin-sidebar nav a {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 16px;
        color: #bbb;
        text-decoration: none;
        font-size: 14px;
        transition: background 0.2s, color 0.2s;
    }

    .admin-sidebar nav a:hover,
    .admin-sidebar nav a.active {
        background: #2e2e50;
        color: #fff;
    }

    .admin-sidebar nav a .nav-icon {
        width: 18px;
        text-align: center;
    }

    .sidebar-footer {
        margin-top: auto;
        padding: 14px 16px;
        border-top: 1px solid #2e2e50;
        font-size: 12px;
        color: #555;
    }

    .sidebar-footer a {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        color: #e05252;
        text-decoration: none;
        font-size: 13px;
    }

    .sidebar-footer a:hover {
        text-decoration: underline;
    }

    /* ===== MAIN CONTENT WRAPPER ===== */
    .admin-main {
        margin-left: 220px;
        flex: 1;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }

    .admin-topbar {
        background: #fff;
        padding: 14px 24px;
        border-bottom: 1px solid #e0e0e0;
        display: flex;
        align-items: center;
        justify-content: space-between;
        position: sticky;
        top: 0;
        z-index: 50;
    }

    .admin-topbar h1 {
        font-size: 20px;
        color: #1a1a2e;
        margin: 0;
    }

    .admin-topbar small {
        color: #888;
        font-size: 12px;
    }

    .admin-content {
        padding: 24px;
        flex: 1;
    }

    /* ===== BOX, TABLE, FORM & BUTTONS (used by sales pages) ===== */
    .box {
        background: #fff;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        margin-bottom: 20px;
    }

    .box-header {
        padding: 14px 18px;
        border-bottom: 1px solid #e0e0e0;
    }

    .box-header h3 {
        font-size: 15px;
        color: #1a1a2e;
    }

    .box-body {
        padding: 16px 18px;
        color: #333;
        font-size: 14px;
        line-height: 1.6;
    }

    .row {
        margin-bottom: 14px;
    }

    .row label {
        display: block;
        font-weight: 600;
        margin-bottom: 6px;
    }

    .row input,
    .row textarea {
        width: 100%;
        border: 1px solid #ccc;
        border-radius: 6px;
        padding: 10px;
        font-size: 14px;
    }

    .row textarea {
        min-height: 110px;
        resize: vertical;
    }

    .btn {
        border: none;
        border-radius: 6px;
        background: #1a1a2e;
        color: #fff;
        padding: 10px 14px;
        cursor: pointer;
    }

    .ok {
        margin-bottom: 14px;
        color: #0f5132;
        background: #d1e7dd;
        border: 1px solid #badbcc;
        padding: 10px;
        border-radius: 6px;
    }

    .error {
        margin-bottom: 14px;
        color: #b42318;
        background: #fef3f2;
        border: 1px solid #fecdca;
        padding: 10px;
        border-radius: 6px;
    }

    .toolbar {
        display: flex;
        gap: 8px;
        margin-bottom: 14px;
    }

    .toolbar input {
        flex: 1;
        border: 1px solid #ccc;
        border-radius: 6px;
        padding: 10px;
    }

    table {
        width: 100%;
        border-collapse: collapse;
    }

    th,
    td {
        border: 1px solid #e5e7eb;
        padding: 10px;
        text-align: left;
        font-size: 14px;
    }

    th {
        background: #f8fafc;
    }
</style>

<aside class="admin-sidebar">
    <div class="sidebar-brand">
        <h2>S.I.M System</h2>
        <small>Sales Management</small>
    </div>

    <div class="sidebar-section-title">Menu Chính</div>

    <nav>
        <%-- Trang chủ / Dashboard --%>
        <a href="${pageContext.request.contextPath}/sales_dashboard" 
           class="${currentPage == 'sales_dashboard' ? 'active' : ''}">
            <span class="nav-icon">🏠</span> Trang chủ
        </a>

        <%-- Sản phẩm --%>
        <a href="${pageContext.request.contextPath}/sales_dashboard?tab=products"
           class="${tab == 'products' ? 'active' : ''}">
            <span class="nav-icon">📦</span> Sản phẩm
        </a>

        <%-- Bán hàng (POS) --%>
        <a href="${pageContext.request.contextPath}/pos">
            <span class="nav-icon">💰</span> Bán hàng
        </a>

        <div class="sidebar-section-title">Hỗ trợ & Khách hàng</div>

        <a href="${pageContext.request.contextPath}/customers">
            <span class="nav-icon">👥</span> Khách hàng
        </a>

        <a href="${pageContext.request.contextPath}/personalProfile">
            <span class="nav-icon">👤</span> Hồ sơ cá nhân
        </a>
    </nav>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/logout">
            <span class="nav-icon">🚪</span> Đăng xuất
        </a>
    </div>
</aside>