<%-- Shared Admin Sidebar Fragment --%>
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

                /* ===== NOTIFICATION DROPDOWN ===== */
                .notif-toggle-btn {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    padding: 10px 16px;
                    color: #bbb;
                    font-size: 14px;
                    cursor: pointer;
                    transition: background 0.2s, color 0.2s;
                    user-select: none;
                }
                .notif-toggle-btn:hover, .notif-toggle-btn.active {
                    background: #2e2e50; color: #fff;
                }
                .notif-panel {
                    display: none;
                    background: #1a1a38;
                    margin: 0 6px 6px 6px;
                    border-radius: 8px;
                    overflow: hidden;
                    max-height: 320px;
                    overflow-y: auto;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.4);
                }
                .notif-panel.open { display: block; }
                .notif-item { padding: 9px 13px; border-bottom: 1px solid #2a2a4a; font-size: 12px; line-height: 1.5; }
                .notif-item:last-child { border-bottom: none; }
                .notif-item.unread { background: rgba(100,100,200,0.1); }
                .notif-item-title { font-weight: 700; color: #e0e0ff; margin-bottom: 3px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
                .notif-item-body { color: #8888bb; white-space: pre-line; font-size: 11px; }
                .notif-item-time { color: #555577; font-size: 10px; margin-top: 3px; }
                .notif-empty { padding: 16px; text-align: center; color: #555577; font-size: 12px; }

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
            </style>

            <aside class="admin-sidebar">
                <div class="sidebar-brand">
                    <h2>&#128737; Admin Hệ Thống</h2>
                    <small>Quản trị viên</small>
                </div>

                <nav>
                    <div class="sidebar-section-title">Tổng quan</div>
                    <a href="admin" class="${currentPage == 'dashboard' ? 'active' : ''}">
                        <span class="nav-icon">&#128202;</span> Dashboard
                    </a>
                    <a href="notifications" class="${currentPage == 'notifications' ? 'active' : ''}" id="admin-notif-link">
                        <span class="nav-icon">&#128276;</span>
                        <span class="nav-link-wrap">
                            Thông báo
                            <span class="notif-badge" id="admin-notif-badge" style="display:none;">0</span>
                        </span>
                    </a>

                    <div class="sidebar-section-title">Quản lý người dùng</div>
                    <a href="userList" class="${currentPage == 'userList' ? 'active' : ''}">
                        <span class="nav-icon">&#128101;</span> Xem danh sách tài khoản
                    </a>
                    <a href="createuser" class="${currentPage == 'createUser' ? 'active' : ''}">
                        <span class="nav-icon">&#10133;</span> Cấp tài khoản mới cho User
                    </a>
                    <a href="deletedUsers" class="${currentPage == 'deletedUsers' ? 'active' : ''}">
                        <span class="nav-icon">&#128465;</span> Xem danh sách tài khoản đã xóa
                    </a>

                    <div class="sidebar-section-title">Hệ thống</div>
                    <a href="systemlog" class="${currentPage == 'systemLog' ? 'active' : ''}">
                        <span class="nav-icon">&#128196;</span> Xem lịch sử hoạt động
                    </a>
                    <a href="personalProfile" class="${currentPage == 'personalProfile' ? 'active' : ''}">
                        <span class="nav-icon">&#128100;</span> Hồ sơ cá nhân
                    </a>
                </nav>

                <div class="sidebar-footer">
                    <span>&#9679; Hệ thống hoạt động bình thường</span><br><br>
                    <a href="logout">&#8592; Đăng xuất</a>
                </div>
            </aside>

            <script>
                (function () {
                    var ctx = '${pageContext.request.contextPath}';
                    var badge = document.getElementById('admin-notif-badge');
                    var wsProtocol = location.protocol === 'https:' ? 'wss' : 'ws';
                    var ws;
                    function connect() {
                        ws = new WebSocket(wsProtocol + '://' + location.host + ctx + '/notifications');
                        ws.onmessage = function (e) {
                            try {
                                var data = JSON.parse(e.data);
                                var count = parseInt(data.unreadCount || 0);
                                if (!badge) return;
                                if (count > 0) { badge.textContent = count > 99 ? '99+' : count; badge.style.display = ''; }
                                else { badge.style.display = 'none'; }
                            } catch (ex) {}
                        };
                        ws.onclose = function () { setTimeout(connect, 5000); };
                        ws.onerror = function () { ws.close(); };
                    }
                    connect();
                })();
            </script>