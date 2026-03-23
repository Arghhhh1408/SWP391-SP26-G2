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
                    background: #f3f6fb;
                    color: #0f172a;
                }

                a {
                    text-decoration: none;
                }

                /* ===== SIDEBAR ===== */
                .admin-sidebar {
                    width: 326px;
                    background: #08142f;
                    color: #dbe6ff;
                    padding: 22px 18px;
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
                    display: flex;
                    align-items: center;
                    gap: 14px;
                    padding: 12px;
                    background: rgba(255, 255, 255, 0.05);
                    border-radius: 20px;
                    margin-bottom: 28px;
                }

                .brand-logo {
                    width: 48px;
                    height: 48px;
                    border-radius: 14px;
                    background: linear-gradient(180deg, #5ea1ff, #2b6ce6);
                    color: #fff;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 28px;
                    font-weight: 700;
                }

                .sidebar-brand h2 {
                    color: #fff;
                    font-size: 18px;
                    margin-bottom: 4px;
                }

                .sidebar-brand p {
                    color: #9fb0d0;
                    font-size: 13px;
                }

                .sidebar-section-title {
                    margin: 18px 10px 10px;
                    font-size: 12px;
                    color: #7f8fb5;
                    text-transform: uppercase;
                    letter-spacing: 1px;
                }

                .admin-sidebar nav {
                    flex: 1;
                    display: flex;
                    flex-direction: column;
                }

                .admin-sidebar nav a,
                .admin-sidebar .submenu a {
                    display: block;
                    color: #dbe6ff;
                    padding: 13px 16px;
                    border-radius: 16px;
                    margin-bottom: 6px;
                    font-size: 15px;
                }

                .admin-sidebar nav a.active,
                .admin-sidebar nav a:hover,
                .admin-sidebar .submenu a:hover {
                    background: #193066;
                }

                .admin-sidebar .submenu {
                    padding-left: 18px;
                    border-left: 1px solid rgba(255, 255, 255, 0.16);
                    margin: 8px 0 14px 16px;
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

                /* ===== MAIN CONTENT WRAPPER FOR PERSONAL PROFILE ===== */
                .admin-main {
                    margin-left: 326px;
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
            </style>

            <aside class="admin-sidebar">
                <div class="sidebar-brand">
                    <div class="brand-logo">SIM</div>
                    <div>
                        <h2>Simple Inventory</h2>
                        <p>Warehouse Staff Workspace</p>
                    </div>
                </div>

                <div class="sidebar-section-title">Warehouse Staff</div>
                <nav>
                    <a href="staff_dashboard?tab=dashboard"
                        class="${(tab == 'dashboard' || empty tab) && currentPage != 'personalProfile' ? 'active' : ''}">🏠
                        Dashboard</a>
                    <a href="notifications" class="${currentPage == 'notifications' ? 'active' : ''}" id="staff-notif-link"
                        style="display:flex; align-items:center; gap:10px;">
                        🔔
                        <span class="nav-link-wrap">
                            Thông báo
                            <span class="notif-badge" id="staff-notif-badge" style="display:none;">0</span>
                        </span>
                    </a>
                    <a href="#">📦 Stock Management</a>
                    <div class="submenu">
                        <a href="createStockIn">Create Stock-In</a>
                        <a href="stockinList">Stock-In History</a>
                    </div>
                    <a href="#">📋 Inventory</a>
                    <div class="submenu">
                        <a href="staff_dashboard?tab=products" class="${tab == 'products' ? 'active' : ''}">View
                            Inventory</a>
                        <a href="inventoryCheck">Inventory Check Item</a>
                    </div>
                    <a href="#">🚚 Supplier</a>
                    <div class="submenu">
                        <a href="supplierList">Supplier List</a>
                        <a href="staff_dashboard?tab=returns" class="${tab == 'returns' ? 'active' : ''}">Return
                            Requests</a>
                        <a href="staff_dashboard?tab=warranty" class="${tab == 'warranty' ? 'active' : ''}">Warranty
                            Claims</a>
                    </div>

                    <div class="sidebar-section-title">Tài khoản</div>
                    <a href="personalProfile" class="${currentPage == 'personalProfile' ? 'active' : ''}">👤 Hồ sơ cá
                        nhân</a>

                    <div style="margin-top:auto;">
                        <a href="logout" style="color: #fb7185; margin-top:20px;">🚪 Đăng xuất</a>
                    </div>
                </nav>
            </aside>

            <script>
                (function () {
                    var badge = document.getElementById('staff-notif-badge');
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