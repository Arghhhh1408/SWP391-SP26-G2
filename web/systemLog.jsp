<%-- Document : systemLog --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Nhật ký hệ thống | IMS PRO</title>
</head>

<body>
    <c:set var="currentPage" value="systemLog" scope="request" />
    <jsp:include page="adminSidebar.jsp" />

    <div class="admin-main">
        <div class="admin-topbar">
            <div class="topbar-left">
                <h1>Nhật ký hệ thống</h1>
                <p>Admin &rsaquo; Theo dõi lịch sử hoạt động</p>
            </div>
            <div class="user-profile">
                <span>👤 ${sessionScope.acc.fullName}</span>
            </div>
        </div>

        <div class="admin-content">
            <div class="card">
                <div class="card-header">
                    <h3>🔍 Bộ lọc nhật ký</h3>
                </div>
                <div class="card-body">
                    <form action="systemlog" method="get">
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 15px; align-items: flex-end;">
                            <div class="form-group">
                                <label style="display:block; font-size:12px; font-weight:700; color:#b5b5c3; margin-bottom:8px; text-transform:uppercase;">Hành động</label>
                                <input type="text" name="action" value="${action}" class="form-control" placeholder="LOGIN, UPDATE...">
                            </div>
                            <div class="form-group">
                                <label style="display:block; font-size:12px; font-weight:700; color:#b5b5c3; margin-bottom:8px; text-transform:uppercase;">Ngày ghi nhận</label>
                                <input type="date" name="date" value="${date}" class="form-control">
                            </div>
                            <div style="display: flex; gap: 8px;">
                                <button type="submit" class="btn btn-primary" style="flex: 1;">Áp dụng</button>
                                <a href="systemlog" class="btn btn-outline">Làm mới</a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <div class="card">
                <div class="card-body" style="padding: 0;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Người thực hiện</th>
                                <th>Hành động</th>
                                <th>Đối tượng & Mô tả</th>
                                <th>Thời gian</th>
                                <th>IP Truy cập</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${requestScope.logs}" var="log">
                                <tr>
                                    <td><span style="color: #b5b5c3; font-weight: 700;">#${log.logID}</span></td>
                                    <td>
                                        <div style="font-weight: 600; color: #181c32;">${not empty log.name ? log.name : 'Hệ thống'}</div>
                                        <div style="font-size: 11px; color: #b5b5c3;">UID: ${log.userID}</div>
                                    </td>
                                    <td>
                                        <span class="badge ${log.action.contains('DELETE') || log.action.contains('REJECT') ? 'badge-danger' : 
                                                           log.action.contains('CREATE') || log.action.contains('APPROVE') ? 'badge-success' : 'badge-primary'}">
                                            ${log.action}
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty log.targetName}">
                                                <div style="font-weight: 600;">
                                                    <a href="updateuser?id=${log.targetObject.split(': ')[1]}" style="color: var(--primary); text-decoration: none;">
                                                        👤 ${log.targetName}
                                                    </a>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div style="font-weight: 600;">${log.targetObject}</div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div style="color: #475569; font-size: 12px; margin-top: 4px;">${log.description}</div>
                                    </td>
                                    <td style="color: #181c32; font-size: 12px; white-space: nowrap;">
                                        <fmt:formatDate value="${log.logDate}" pattern="dd/MM/yyyy HH:mm:ss" />
                                    </td>
                                    <td><code style="background: #f3f6f9; padding: 2px 6px; border-radius: 4px; font-size: 11px;">${log.ipAddress}</code></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>