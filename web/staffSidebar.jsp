<%-- Shared Staff Sidebar Fragment --%>
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
        width: 240px;
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
        margin-left: 240px;
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

    /* ===== TABLE & BUTTONS (used by staff pages) ===== */
    .box {
        background: #fff;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        margin-bottom: 18px;
    }

    .box-header {
        padding: 14px 18px;
        border-bottom: 1px solid #e0e0e0;
    }

    .box-body {
        padding: 16px 18px;
        color: #333;
        line-height: 1.7;
    }

    .btn {
        border: none;
        border-radius: 6px;
        background: #38bdf8;
        color: #0c4a6e;
        padding: 7px 10px;
        cursor: pointer;
        font-size: 12px;
        font-weight: 700;
    }

    .btn:hover {
        background: #0ea5e9;
        color: #fff;
    }

    .btn-reject {
        background: #fecaca;
        color: #7f1d1d;
    }

    .btn-reject:hover {
        background: #f87171;
        color: #fff;
    }

    .action-row {
        display: flex;
        gap: 6px;
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

    .tag-done {
        background: #d1e7dd;
        color: #0f5132;
        border: 1px solid #badbcc;
        border-radius: 12px;
        padding: 2px 8px;
        font-size: 12px;
    }
</style>

<aside class="admin-sidebar">
    <div class="sidebar-brand">
        <h2>Warehouse Staff</h2>
        <small>Quản lý kho</small>
    </div>

    <nav>
        <div class="sidebar-section-title">Menu Staff</div>
        <a href="staff_dashboard?tab=warranty" class="${currentPage == 'staff_dashboard' && (tab == 'warranty' || empty tab) ? 'active' : ''}">
            <span class="nav-icon">&#128736;</span> Yêu cầu bảo hành
        </a>
        <a href="staff_dashboard?tab=returns" class="${currentPage == 'staff_dashboard' && tab == 'returns' ? 'active' : ''}">
            <span class="nav-icon">&#128260;</span> Yêu cầu trả hàng
        </a>
        <a href="staff_dashboard?tab=products" class="${currentPage == 'staff_dashboard' && tab == 'products' ? 'active' : ''}">
            <span class="nav-icon">&#128230;</span> Danh sách sản phẩm
        </a>

        <div class="sidebar-section-title">Nhà cung cấp</div>
        <a href="supplierList">
            <span class="nav-icon">&#129309;</span> Danh sách nhà cung cấp
        </a>

        <div class="sidebar-section-title">Nhập kho</div>
        <a href="stockinList">
            <span class="nav-icon">&#128229;</span> Danh sách phiếu nhập kho
        </a>
        <a href="createStockIn">
            <span class="nav-icon">&#10133;</span> Tạo phiếu nhập kho
        </a>

        <div class="sidebar-section-title">Tài khoản</div>
        <a href="personalProfile" class="${currentPage == 'personalProfile' ? 'active' : ''}">
            <span class="nav-icon">&#128100;</span> Hồ sơ cá nhân
        </a>
    </nav>

    <div class="sidebar-footer">
        <span>Trạng thái: Online</span><br><br>
        <a href="logout">&#8592; Đăng xuất</a>
    </div>
</aside>
