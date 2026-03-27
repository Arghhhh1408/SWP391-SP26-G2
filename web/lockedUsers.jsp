<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Tài khoản bị khóa | IMS PRO</title>
</head>

<body>
    <c:set var="currentPage" value="lockedUsers" scope="request" />
    <jsp:include page="adminSidebar.jsp" />

    <div class="admin-main">
        <div class="admin-topbar">
            <div class="topbar-left">
                <h1>Tài khoản bị khóa / Vô hiệu hóa</h1>
                <p>Admin &rsaquo; Quản lý an ninh tài khoản</p>
            </div>
            <div class="user-profile">
                <span>👤 ${sessionScope.acc.fullName}</span>
            </div>
        </div>

        <div class="admin-content">
            <c:if test="${not empty sessionScope.notification or not empty sessionScope.message}">
                <div class="alert alert-success" style="margin-bottom: 20px; padding: 15px; background: #e8fff3; border: 1px solid #50cd89; color: #50cd89; border-radius: 8px;">
                    ✅ ${not empty sessionScope.notification ? sessionScope.notification : sessionScope.message}
                    <c:remove var="notification" scope="session" />
                    <c:remove var="message" scope="session" />
                    <c:remove var="status" scope="session" />
                </div>
            </c:if>

            <div class="card">
                <div class="card-header">
                    <h3>Danh sách tài khoản cần xử lý</h3>
                    <p>Bao gồm tài khoản bị khóa tự động (30p) và tài khoản bị vô hiệu hóa bởi Admin.</p>
                </div>
                <div class="card-body" style="padding: 0;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Tài khoản</th>
                                <th>Trạng thái hiện tại</th>
                                <th>Số lần nhập sai</th>
                                <th>Thời gian mở khóa dự kiến</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${lockedUsers}" var="u">
                                <tr>
                                    <td>
                                        <div style="font-weight: 600; color: #181c32;">${u.fullName}</div>
                                        <div style="font-size: 11px; color: #b5b5c3;">@${u.username} | UID: ${u.userID}</div>
                                    </td>
                                    <td>
                                        <span class="badge badge-warning">Khóa tạm thời (30p)</span>
                                    </td>
                                    <td style="text-align: center; font-weight: 700; color: #f1416c;">
                                        ${u.failedAttempts} / 5
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty u.lockoutEnd}">
                                                <div style="font-size: 12px; color: #181c32; font-weight: 600;">
                                                    <fmt:formatDate value="${u.lockoutEnd}" pattern="dd/MM HH:mm:ss" />
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #b5b5c3;">--</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div style="display: flex; gap: 8px;">
                                            <a href="unlockUser?id=${u.userID}&username=${u.username}" 
                                               class="btn btn-sm btn-success" 
                                               onclick="return confirm('Bạn có chắc chắn muốn mở khóa cho tài khoản này?')"
                                               style="text-decoration: none; padding: 6px 12px; font-size: 12px;">
                                                🔓 Mở khóa
                                            </a>
                                            
                                            <a href="deleteUser?id=${u.userID}&redirect=lockedUsers" 
                                               class="btn btn-sm btn-danger" 
                                               onclick="return confirm('Vô hiệu hóa tài khoản này sẽ đưa nó vào Thùng rác. Bạn chắc chứ?')"
                                               style="text-decoration: none; padding: 6px 12px; font-size: 12px; background-color: #f64e60; border: none; color: white; border-radius: 8px;">
                                                🚫 Vô hiệu hóa
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty lockedUsers}">
                                <tr>
                                    <td colspan="5" style="text-align: center; padding: 40px; color: #b5b5c3;">
                                        🎉 Hiện không có tài khoản nào bị khóa. Hệ thống đang an toàn!
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
