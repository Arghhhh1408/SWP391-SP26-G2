<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Thông báo hệ thống | IMS ADMIN</title>
    <style>
        .notifications-container {
            max-width: 900px;
            margin: 0 auto;
        }

        .notif-item {
            padding: 24px;
            border-bottom: 1px solid #f1f5f9;
            transition: all 0.2s ease;
            position: relative;
        }

        .notif-item:last-child {
            border-bottom: none;
        }

        .notif-item.unread {
            background-color: #f8fafc;
            border-left: 4px solid var(--primary);
        }

        .notif-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 8px;
        }

        .notif-title {
            font-size: 16px;
            font-weight: 600;
            color: #1e293b;
            margin: 0;
        }

        .notif-time {
            font-size: 12px;
            color: var(--text-muted);
        }

        .notif-body {
            font-size: 14px;
            color: #475569;
            line-height: 1.6;
            margin: 0;
            white-space: pre-wrap;
        }

        .notif-footer {
            margin-top: 16px;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }

        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 8px;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: var(--text-muted);
        }
    </style>
</head>

<body>
    <c:set var="currentPage" value="notifications" scope="request" />
    <jsp:include page="adminSidebar.jsp" />

    <div class="admin-main">
        <div class="admin-topbar">
            <div>
                <h1>Thông báo hệ thống</h1>
                <small>Admin &rsaquo; Trung tâm thông báo</small>
            </div>
            <div class="user-profile">
                <span style="font-size: 18px;">👤</span>
                <strong>${sessionScope.acc.fullName}</strong>
            </div>
        </div>

        <div class="admin-content">
            <div class="notifications-container">
                <div class="glass-card">
                    <div class="card-header">
                        <h3>🔔 Tất cả thông báo</h3>
                        <c:if test="${not empty notifications}">
                             <span class="badge" style="background: var(--primary); color: #fff;">${notifications.size()}</span>
                        </c:if>
                    </div>
                    <div class="card-body" style="padding: 0;">
                        <c:choose>
                            <c:when test="${not empty notifications}">
                                <c:forEach var="n" items="${notifications}">
                                    <div class="notif-item ${not n.read ? 'unread' : ''}" id="notif-item-${n.notificationId}">
                                        <div class="notif-header">
                                            <h3 class="notif-title">${n.title}</h3>
                                            <span class="notif-time">
                                                <fmt:formatDate value="${n.createdAt}" pattern="dd/MM HH:mm" />
                                            </span>
                                        </div>
                                        <div class="notif-body">
                                            <c:out value="${n.message}" escapeXml="false" />
                                        </div>

                                        <div class="notif-footer">
                                            <c:if test="${n.type == 'PASSWORD_RESET_RESULT'}">
                                                <a href="personalProfile" class="btn btn-primary btn-sm">🔐 Đổi mật khẩu ngay</a>
                                            </c:if>

                                            <c:if test="${not n.read}">
                                                <div id="notif-action-${n.notificationId}" style="display: flex; gap: 8px;">
                                                    <c:choose>
                                                        <c:when test="${n.type == 'PASSWORD_RESET_REQUEST'}">
                                                            <button class="btn btn-primary btn-sm" style="background: #f59e0b;"
                                                                onclick="resetPassword(${n.notificationId})">✅ Reset</button>
                                                            <button class="btn btn-outline btn-sm" style="color: #ef4444; border-color: #fecaca;"
                                                                onclick="rejectPassword(${n.notificationId})">❌ Reject</button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button class="btn btn-outline btn-sm"
                                                                onclick="markAsRead(${n.notificationId})">Đã đọc</button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <span style="font-size: 48px; display: block; margin-bottom: 16px;">📭</span>
                                    <p>Bạn không có thông báo nào mới.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
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
                if (item) item.classList.remove('unread');
                if (actionBox) actionBox.style.display = 'none';
            })
            .catch(err => console.error(err));
        }

        function resetPassword(notifId) {
            if (confirm("Xác nhận reset mật khẩu của tài khoản này về '123'?")) {
                fetch(ctx + '/notifications', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=resetPassword&id=' + notifId
                })
                .then(res => res.json())
                .then(data => {
                    alert("Đã reset mật khẩu thành công!");
                    var item = document.getElementById('notif-item-' + notifId);
                    var actionBox = document.getElementById('notif-action-' + notifId);
                    if (item) item.classList.remove('unread');
                    if (actionBox) actionBox.style.display = 'none';
                })
                .catch(err => console.error(err));
            }
        }

        function rejectPassword(notifId) {
            if (confirm("Xác nhận từ chối yêu cầu reset mật khẩu này?")) {
                fetch(ctx + '/notifications', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=rejectPassword&id=' + notifId
                })
                .then(res => res.json())
                .then(data => {
                    var item = document.getElementById('notif-item-' + notifId);
                    var actionBox = document.getElementById('notif-action-' + notifId);
                    if (item) item.classList.remove('unread');
                    if (actionBox) actionBox.style.display = 'none';
                })
                .catch(err => console.error(err));
            }
        }
    </script>
</body>
</html>
