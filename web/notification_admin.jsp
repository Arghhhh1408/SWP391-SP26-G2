<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Trung tâm thông báo | IMS PRO</title>
</head>

<body>
    <c:set var="currentPage" value="notifications" scope="request" />
    <jsp:include page="adminSidebar.jsp" />

    <div class="admin-main">
        <div class="admin-topbar">
            <div class="topbar-left">
                <h1>Thông báo hệ thống</h1>
                <p>Quản lý các yêu cầu và cảnh báo từ người dùng</p>
            </div>
            <div class="user-profile">
                <span>👤 ${sessionScope.acc.fullName}</span>
            </div>
        </div>

        <div class="admin-content">
            <div style="max-width: 900px; margin: 0 auto;">
                <div class="card">
                    <div class="card-header">
                        <h3>🔔 Danh sách thông báo mới</h3>
                        <span class="badge badge-primary">${notifications.size()}</span>
                    </div>
                    <div class="card-body" style="padding: 0;">
                        <c:choose>
                            <c:when test="${not empty notifications}">
                                <c:forEach var="n" items="${notifications}">
                                    <div id="notif-card-${n.notificationId}" style="padding: 25px; border-bottom: 1px solid var(--border-color); ${not n.read ? 'background:#fbfbff; border-left:4px solid var(--primary);' : ''}">
                                        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 10px;">
                                            <h4 style="font-size: 16px; font-weight: 700; color: #181c32;">${n.title}</h4>
                                            <span style="font-size: 12px; color: #b5b5c3;">
                                                <fmt:formatDate value="${n.createdAt}" pattern="dd/MM HH:mm" />
                                            </span>
                                        </div>
                                        <p style="font-size: 14px; color: #3f4254; line-height: 1.6; margin-bottom: 15px;">
                                            <c:out value="${n.message}" escapeXml="false" />
                                        </p>
                                        <div style="display: flex; justify-content: flex-end; gap: 10px; align-items: center;">
                                            <!-- Persistent Action Buttons (Always Visible) -->
                                            <c:if test="${n.type == 'ACCOUNT_LOCKOUT'}">
                                                <a href="lockedUsers" class="btn btn-primary" 
                                                   style="padding: 6px 15px; font-size: 12px; text-decoration: none; background: #009ef7; border: none; color: white; border-radius: 6px;"
                                                   onclick="markAsReadSilent(${n.notificationId})">
                                                    🔎 Xem danh sách tài khoản bị khóa
                                                </a>
                                            </c:if>
                                            
                                            <!-- Transient Action Buttons (Hide on Read) -->
                                            <c:if test="${not n.read}">
                                                <div id="notif-action-${n.notificationId}" style="display: flex; gap: 10px;">
                                                    <c:choose>
                                                        <c:when test="${n.type == 'PASSWORD_RESET_REQUEST'}">
                                                            <button class="btn btn-primary" style="background:#ffad73; padding: 6px 15px; font-size: 12px; border: none;"
                                                                onclick="resetPassword(${n.notificationId})">Chấp nhận Reset</button>
                                                            <button class="btn btn-outline" style="color:#f64e60; padding: 6px 15px; font-size: 12px;"
                                                                onclick="rejectPassword(${n.notificationId})">Từ chối</button>
                                                        </c:when>
                                                    </c:choose>
                                                    <button class="btn btn-outline" style="padding: 6px 15px; font-size: 12px; border-radius: 6px;"
                                                        onclick="markAsReadDynamic(${n.notificationId}, this)">Đã đọc</button>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div style="padding: 60px; text-align: center; color: #b5b5c3;">
                                    <div style="font-size: 40px; margin-bottom: 15px;">📭</div>
                                    <p>Hộp thư thông báo đang trống</p>
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
        function markAsRead(id) {
            fetch(ctx + '/notifications', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=markRead&id=' + id
            }).then(() => location.reload());
        }
        function markAsReadDynamic(id, btn) {
            // Update the UI to "read" state without hiding
            var card = document.getElementById('notif-card-' + id);
            var actionArea = document.getElementById('notif-action-' + id);
            
            if (card) {
                card.style.background = 'transparent';
                card.style.borderLeft = 'none';
            }
            if (actionArea) {
                actionArea.style.display = 'none';
            }
            
            // Send request to server
            fetch(ctx + '/notifications', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=markRead&id=' + id
            });
            // The sidebar badge will update automatically via WebSocket from the server
        }
        function markAsReadSilent(id) {
            fetch(ctx + '/notifications', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=markRead&id=' + id
            });
        }
        function resetPassword(id) {
            if(confirm("Xác nhận reset mật khẩu người dùng này về 123?")) {
                fetch(ctx + '/notifications', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=resetPassword&id=' + id
                }).then(() => location.reload());
            }
        }
        function rejectPassword(id) {
            fetch(ctx + '/notifications', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=rejectPassword&id=' + id
            }).then(() => location.reload());
        }
    </script>
</body>
</html>