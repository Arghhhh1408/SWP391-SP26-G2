<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Notifications | Modern IMS</title>
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
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
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
            from {
                opacity: 0;
                transform: translateY(10px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
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

        .notification-unread {
            font-weight: bold;
            background: rgba(99, 102, 241, 0.05);
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
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            border: none;
            gap: 8px;
            text-decoration: none;
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
        
        .btn-primary {
            background: var(--primary);
            color: #fff !important;
        }

        .btn-primary:hover {
            background: var(--primary-hover);
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
        }
    </style>
</head>

<body>
    <c:set var="currentPage" value="manager_notification" scope="request" />
    <jsp:include page="managerSidebar.jsp" />

    <div class="main">
        <div class="topbar">
            <div class="topbar-left">
                <h1>Thông báo Quản lý</h1>
                <small>Operations &rsaquo; Notifications</small>
            </div>
            <div class="user-profile">
                <span class="avatar">👤</span>
                <strong>${sessionScope.acc.fullName}</strong>
            </div>
        </div>

        <div class="content">
            <div class="glass-card">
                <div class="card-header">
                    <h3>Danh sách thông báo</h3>
                    <div>
                        <c:if test="${unreadCount > 0}">
                            <a href="${pageContext.request.contextPath}/manager_notification?action=markAllRead" class="btn btn-primary">Đánh dấu tất cả đã đọc</a>
                        </c:if>
                    </div>
                </div>
                <div class="card-body">
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 15%">Thời gian</th>
                                <th style="width: 20%">Tiêu đề</th>
                                <th style="width: 50%">Nội dung</th>
                                <th style="width: 15%; text-align: right;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${notifications}" var="n">
                                <tr class="${!n.read ? 'notification-unread' : ''}">
                                    <td>
                                        <fmt:formatDate value="${n.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td>${n.title}</td>
                                    <td>${n.message}</td>
                                    <td style="text-align: right;">
                                        <c:choose>
                                            <c:when test="${!n.read}">
                                                <a href="${pageContext.request.contextPath}/manager_notification?action=markRead&id=${n.notificationId}" class="btn btn-outline" style="padding: 4px 10px; font-size: 11px;">Đánh dấu đã đọc</a>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: var(--text-muted); font-size: 12px; font-style: italic;">Đã đọc</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty notifications}">
                                <tr>
                                    <td colspan="4">
                                        <div class="empty-state">
                                            <span class="icon">🔕</span>
                                            <p>Chưa có thông báo nào.</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
