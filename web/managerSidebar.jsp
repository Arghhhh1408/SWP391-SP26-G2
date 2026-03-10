<%-- Shared Manager Sidebar Fragment --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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

                /* Admin Table Styles */
                .admin-table {
                    width: 100%;
                    border-collapse: collapse;
                    background: #fff;
                    border: 1px solid #e0e0e0;
                    border-radius: 8px;
                    overflow: hidden;
                }

                .admin-table th {
                    background: #f8f9fa;
                    padding: 12px 18px;
                    text-align: left;
                    font-size: 13px;
                    font-weight: 600;
                    color: #555;
                    border-bottom: 2px solid #e0e0e0;
                }

                .admin-table td {
                    padding: 12px 18px;
                    font-size: 14px;
                    color: #333;
                    border-bottom: 1px solid #f0f0f0;
                }

                .admin-table tr:hover td {
                    background: #fcfcfc;
                }

                .btn {
                    display: inline-block;
                    padding: 6px 12px;
                    border-radius: 4px;
                    font-size: 12px;
                    text-decoration: none;
                    transition: all 0.2s;
                    cursor: pointer;
                    border: none;
                }

                .btn-primary {
                    background: #007bff;
                    color: #fff;
                }

                .btn-primary:hover {
                    background: #0056b3;
                }

                .btn-danger {
                    background: #dc3545;
                    color: #fff;
                }

                .btn-danger:hover {
                    background: #a71d2a;
                }

                .btn-outline {
                    border: 1px solid #ddd;
                    color: #555;
                    background: #fff;
                }

                .btn-outline:hover {
                    background: #f8f9fa;
                }
            </style>

            <aside class="admin-sidebar">
                <div class="sidebar-brand">
                    <h2>&#128230; IMS Manager</h2>
                    <small>Quản lý hệ thống</small>
                </div>

                <nav>
                    <div class="sidebar-section-title">Tổng quan</div>
                    <a href="${pageContext.request.contextPath}/category"
                        class="${currentPage == 'category' ? 'active' : ''}">
                        <span class="nav-icon">&#128230;</span> Danh sách sản phẩm
                    </a>

                    <div class="sidebar-section-title">Quản lý kho</div>
                    <a href="${pageContext.request.contextPath}/manageCategories"
                        class="${currentPage == 'manageCategories' ? 'active' : ''}">
                        <span class="nav-icon">&#128450;</span> Quản lý danh mục
                    </a>
                    <a href="${pageContext.request.contextPath}/supplierList"
                        class="${currentPage == 'supplierList' ? 'active' : ''}">
                        <span class="nav-icon">&#128230;</span> Nhà cung cấp
                    </a>
                    <a href="${pageContext.request.contextPath}/stockinList"
                        class="${currentPage == 'stockinList' ? 'active' : ''}">
                        <span class="nav-icon">&#128229;</span> Nhập kho
                    </a>

                    <div class="sidebar-section-title">Cài đặt</div>
                    <c:if test="${sessionScope.acc.roleID == 0}">
                        <a href="admin">
                            <span class="nav-icon">&#9881;</span> Quay về Admin
                        </a>
                    </c:if>
                </nav>

                <div class="sidebar-footer">
                    <span>&#9679; Phiên kết nối an toàn</span><br><br>
                    <a href="${pageContext.request.contextPath}/logout">&#8592; Đăng xuất</a>
                </div>
            </aside>