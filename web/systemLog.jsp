<%-- Document : systemLog --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Lịch sử hoạt động | IMS ADMIN</title>
</head>

<body>
    <c:if test="${sessionScope.acc == null or sessionScope.acc.roleID ne 0}">
        <c:redirect url="login" />
    </c:if>
    <c:set var="currentPage" value="systemLog" scope="request" />
    <jsp:include page="adminSidebar.jsp" />

    <div class="admin-main">
        <div class="admin-topbar">
            <div>
                <h1>Lịch sử hoạt động</h1>
                <small>Admin &rsaquo; Hệ thống &rsaquo; System Log</small>
            </div>
            <div class="user-profile">
                <span style="font-size: 18px;">👤</span>
                <strong>${sessionScope.acc.fullName}</strong>
            </div>
        </div>

        <div class="admin-content">

            <!-- Filter Card -->
            <div class="glass-card">
                <div class="card-header">
                    <h3>🔍 Lọc dữ liệu nhật ký</h3>
                </div>
                <div class="card-body">
                    <form action="systemlog" method="get">
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 16px;">
                            <div class="form-group">
                                <label>User ID</label>
                                <input type="number" name="userId" value="${userId}" class="form-control" placeholder="Nhập ID người dùng">
                            </div>
                            <div class="form-group">
                                <label>Hành động</label>
                                <input type="text" name="action" value="${action}" class="form-control" placeholder="Ví dụ: LOGIN, UPDATE...">
                            </div>
                            <div class="form-group">
                                <label>Ngày ghi nhận</label>
                                <input type="date" name="date" value="${date}" class="form-control">
                            </div>
                        </div>
                        <div style="display: flex; gap: 8px;">
                            <button type="submit" class="btn btn-primary">Áp dụng bộ lọc</button>
                            <a href="systemlog" class="btn btn-outline" style="text-decoration: none;">Làm mới</a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Table Card -->
            <div class="glass-card">
                <div class="card-header">
                    <h3>📄 Chi tiết nhật ký hệ thống</h3>
                </div>
                <div class="card-body" style="padding: 0;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Log ID</th>
                                <th>Người dùng</th>
                                <th>Hành động</th>
                                <th>Đối tượng</th>
                                <th>Mô tả</th>
                                <th>Thời gian</th>
                                <th>Địa chỉ IP</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${requestScope.logs}" var="log">
                                <tr>
                                    <td><code style="font-size: 11px; color: var(--text-muted);">#${log.logID}</code></td>
                                    <td style="font-weight: 600;">UID: ${log.userID}</td>
                                    <td>
                                        <span class="badge" style="background: rgba(99, 102, 241, 0.1); color: var(--primary);">
                                            ${log.action}
                                        </span>
                                    </td>
                                    <td style="font-size: 13px;">${log.targetObject}</td>
                                    <td style="font-size: 13px; color: var(--text-muted);">${log.description}</td>
                                    <td style="white-space:nowrap; font-size: 12px; color: var(--text-muted);">
                                        <fmt:formatDate value="${log.logDate}" pattern="dd/MM/yyyy HH:mm:ss" />
                                    </td>
                                    <td><code style="font-size: 11px;">${log.ipAddress}</code></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty requestScope.logs}">
                                <tr>
                                    <td colspan="7" style="text-align: center; padding: 40px; color: var(--text-muted);">
                                        Chưa có dữ liệu nhật ký phù hợp với bộ lọc.
                                    </td>
                                }
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</body>
</html>