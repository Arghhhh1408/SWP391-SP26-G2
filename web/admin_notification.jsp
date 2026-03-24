<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Thông Báo Admin - IMS PRO</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
        rel="stylesheet">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-hover: #4338ca;
            --bg-color: #f1f5f9;
            --card-bg: #ffffff;
            --text-main: #1e293b;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
            --unread-bg: #f5f3ff;
            --unread-border: #818cf8;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-color);
            margin: 0;
            padding: 0;
            color: var(--text-main);
            display: flex;
            min-height: 100vh;
        }

        .main-content {
            flex: 1;
            padding: 40px;
            max-width: 1000px;
            margin: 0 auto;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .page-title {
            font-size: 28px;
            font-weight: 700;
            color: var(--text-main);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 16px;
            background: white;
            color: var(--text-main);
            text-decoration: none;
            border-radius: 8px;
            font-weight: 500;
            font-size: 14px;
            border: 1px solid var(--border-color);
            transition: all 0.2s ease;
        }

        .back-btn:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }

        .notifications-container {
            background: var(--card-bg);
            border-radius: 16px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
            overflow: hidden;
        }

        .notif-item {
            padding: 24px;
            border-bottom: 1px solid var(--border-color);
            transition: background-color 0.2s ease;
            position: relative;
        }

        .notif-item:last-child {
            border-bottom: none;
        }

        .notif-item.unread {
            background-color: var(--unread-bg);
        }

        .notif-item.unread::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            background-color: var(--primary);
        }

        .notif-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
        }

        .notif-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--text-main);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .notif-time {
            font-size: 13px;
            color: var(--text-muted);
            white-space: nowrap;
        }

        .notif-body {
            font-size: 14px;
            color: #475569;
            line-height: 1.6;
            margin: 0;
            white-space: pre-wrap;
        }

        .notif-actions {
            position: absolute;
            right: 24px;
            top: 24px;
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .btn-mark-read {
            background: #fff;
            border: 1px solid #cbd5e1;
            color: #4f46e5;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn-mark-read:hover {
            background: #f1f5f9;
            border-color: #94a3b8;
        }

        .notif-empty {
            padding: 60px 40px;
            text-align: center;
        }

        .notif-empty-icon {
            font-size: 48px;
            color: #cbd5e1;
            margin-bottom: 16px;
        }

        .notif-empty-text {
            font-size: 16px;
            color: var(--text-muted);
            margin: 0;
        }
    </style>
</head>

<body>
    <div class="main-content">
        <div class="page-header">
            <h1 class="page-title">
                <span style="font-size: 32px;">🔔</span>
                Thông báo Quản trị viên
            </h1>
            <a href="javascript:history.back()" class="back-btn">
                <span>&larr;</span> Quay lại
            </a>
        </div>

        <div class="notifications-container">
            <c:choose>
                <c:when test="${not empty notifications}">
                    <c:forEach var="n" items="${notifications}">
                        <div class="notif-item ${not n.read ? 'unread' : ''}"
                            id="notif-item-${n.notificationId}">
                            <div class="notif-header">
                                <h3 class="notif-title">${n.title}</h3>
                            </div>
                            <div class="notif-body">
                                <c:out value="${n.message}" escapeXml="false" />
                            </div>

                            <c:if test="${not n.read}">
                                <div class="notif-actions" id="notif-action-${n.notificationId}">
                                    <button class="btn-mark-read"
                                        onclick="markAsRead(${n.notificationId})">Đã đọc</button>
                                </div>
                            </c:if>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="notif-empty">
                        <div class="notif-empty-icon">📭</div>
                        <h3 style="margin: 0 0 8px 0; color: var(--text-main);">Không có thông báo nào</h3>
                        <p class="notif-empty-text">Bạn đã xem tất cả các thông báo.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <script>
        var ctx = "${pageContext.request.contextPath}";

        function markAsRead(notifId) {
            fetch(ctx + '/notifications', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=markRead&id=' + notifId
            })
                .then(res => res.json())
                .then(data => {
                    var item = document.getElementById('notif-item-' + notifId);
                    var actionBox = document.getElementById('notif-action-' + notifId);
                    if (item) {
                        item.classList.remove('unread');
                    }
                    if (actionBox) {
                        actionBox.style.display = 'none';
                    }
                })
                .catch(err => console.error(err));
        }
    </script>
</body>

</html>
