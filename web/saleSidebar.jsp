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

                * {
                    box-sizing: border-box;
                    margin: 0;
                    padding: 0;
                }

                body {
                    display: flex;
                    min-height: 100vh;
                    font-family: 'Segoe UI', Arial, sans-serif;
                    background: #f4f6f9;
                }

                .admin-sidebar {
                    width: 240px;
                    /* Tăng nhẹ độ rộng để menu thoải mái hơn */
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
                    text-align: center;
                }

                .sidebar-brand h2 {
                    color: #fff;
                    font-size: 18px;
                    margin-bottom: 4px;
                }

                .sidebar-brand small {
                    font-size: 11px;
                    color: #888;
                    text-transform: uppercase;
                }

                .sidebar-section-title {
                    padding: 20px 16px 8px;
                    font-size: 10px;
                    text-transform: uppercase;
                    letter-spacing: 1.2px;
                    color: #556b2f;
                    /* Màu rêu nhẹ cho tiêu đề phân đoạn */
                    font-weight: bold;
                }

                .admin-sidebar nav a {
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    padding: 12px 18px;
                    color: #bbb;
                    text-decoration: none;
                    font-size: 14px;
                    transition: all 0.2s;
                }

                .admin-sidebar nav a:hover {
                    background: #24243e;
                    color: #fff;
                    padding-left: 22px;
                }

                .admin-sidebar nav a.active {
                    background: #3b82f6;
                    color: #fff;
                    border-left: 4px solid #fff;
                }

                .admin-sidebar nav a .nav-icon {
                    width: 20px;
                    text-align: center;
                    font-size: 16px;
                }

                .sidebar-footer {
                    margin-top: auto;
                    padding: 20px 16px;
                    border-top: 1px solid #2e2e50;
                    background: #161625;
                }

                .sidebar-footer a {
                    color: #e05252;
                    text-decoration: none;
                    font-size: 13px;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }

                /* Fix cho nội dung chính không bị đè */
                .admin-main {
                    margin-left: 240px;
                    flex: 1;
                }
                .notification-badge {
                    background-color: #ef4444;
                    color: white;
                    font-size: 11px;
                    font-weight: 700;
                    padding: 2px 6px;
                    border-radius: 10px;
                    margin-left: auto;
                    float: right;
                    min-width: 18px;
                    text-align: center;
                }
            </style>

            <aside class="admin-sidebar">
                <div class="sidebar-brand">
                    <h2>&#128722; Sales Dashboard</h2>
                    <small>Salesperson</small>
                </div>

                <nav>
                    <div class="sidebar-section-title">Tổng quan</div>
                    <a href="sales_dashboard?tab=dashboard" class="${tab == 'dashboard' || empty tab ? 'active' : ''}">
                        <span class="nav-icon">📊</span> Dashboard
                    </a>
                    <a href="sales_dashboard?tab=notifications" class="${tab == 'notifications' ? 'active' : ''}">
                        <span class="nav-icon">🔔</span> Thông báo
                        <span class="notification-badge" id="notificationBadge" style="display: none;">0</span>
                    </a>

                    <%-- PHẦN 2: NGHIỆP VỤ BÁN HÀNG --%>
                        <div class="sidebar-section-title">Kinh doanh</div>
                        <a href="sales_dashboard?tab=pos" class="${tab == 'pos' ? 'active' : ''}">
                            <span class="nav-icon">🛒</span> Bán hàng (POS)
                        </a>
                        <a href="sales_dashboard?tab=orders" class="${tab == 'orders' ? 'active' : ''}">
                            <span class="nav-icon">📜</span> Lịch sử đơn hàng
                        </a>
                        <a href="sales_dashboard?tab=customers" class="${tab == 'customers' ? 'active' : ''}">
                            <span class="nav-icon">👥</span> Khách hàng
                        </a>
                        <a href="sales_dashboard?tab=warranty-create"
                            class="${currentPage == 'sales_dashboard' && tab == 'warranty-create' ? 'active' : ''}">
                            <span class="nav-icon">&#128736;</span> Tạo yêu cầu bảo hành
                        </a>
                        <a href="sales_dashboard?tab=return-create"
                            class="${currentPage == 'sales_dashboard' && tab == 'return-create' ? 'active' : ''}">
                            <span class="nav-icon">&#128260;</span> Tạo yêu cầu trả hàng
                        </a>
                        <a href="sales_dashboard?tab=warranty-lookup"
                            class="${currentPage == 'sales_dashboard' && tab == 'warranty-lookup' ? 'active' : ''}">
                            <span class="nav-icon">&#128269;</span> Tra cứu bảo hành
                        </a>
                        <a href="sales_dashboard?tab=return-lookup"
                            class="${currentPage == 'sales_dashboard' && tab == 'return-lookup' ? 'active' : ''}">
                            <span class="nav-icon">&#128270;</span> Tra cứu trả hàng
                        </a>
                        <a href="sales_dashboard?tab=products"
                            class="${currentPage == 'sales_dashboard' && tab == 'products' ? 'active' : ''}">
                            <span class="nav-icon">&#128230;</span> Xem tất cả sản phẩm
                        </a>

                        <div class="sidebar-section-title">Tài khoản</div>
                        <a href="personalProfile" class="${currentPage == 'personalProfile' ? 'active' : ''}">
                            <span class="nav-icon">&#128100;</span> Hồ sơ cá nhân
                        </a>
                </nav>

                <div class="sidebar-footer">
                    <span>&#9679; Trạng thái: Online</span><br><br>
                    <a href="logout">&#8592; Đăng xuất</a>
                </div>
            </aside>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        let port = window.location.port ? ":" + window.location.port : "";
        let wsUrl = (window.location.protocol === "https:" ? "wss://" : "ws://") + window.location.hostname + port + "${pageContext.request.contextPath}/ws/notifications/${sessionScope.acc.userID}";
        let notificationSocket = new WebSocket(wsUrl);
        let badge = document.getElementById("notificationBadge");

        notificationSocket.onmessage = function(event) {
            if (badge) {
                let currentCount = parseInt(badge.innerText || "0");
                try {
                    let data = JSON.parse(event.data);
                    if (data.unreadCount !== undefined) {
                        currentCount = data.unreadCount;
                    } else {
                        currentCount++;
                    }
                } catch(e) {
                    currentCount++;
                }

                badge.innerText = currentCount;
                if(currentCount > 0) {
                    badge.style.display = "inline-block";
                } else {
                    badge.style.display = "none";
                }
            }
        };
    });
</script>