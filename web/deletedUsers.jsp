<%-- Document : deletedUsers --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Thùng rác tài khoản | IMS ADMIN</title>
    <style>
        .search-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 16px;
        }
        .role-badge {
            font-size: 11px;
            padding: 4px 10px;
            border-radius: 20px;
            font-weight: 600;
        }
        .role-admin { background: #fee2e2; color: #991b1b; }
        .role-manager { background: #dcfce7; color: #166534; }
        .role-staff { background: #dbeafe; color: #1e40af; }
        .role-sales { background: #fef9c3; color: #854d0e; }
        
        .action-link {
            font-size: 13px;
            font-weight: 600;
            color: var(--primary);
            text-decoration: none;
        }
        .action-link:hover { text-decoration: underline; }
        .restore-link { color: #10b981; }
    </style>
</head>

<body>
    <c:set var="currentPage" value="deletedUsers" scope="request" />
    <jsp:include page="adminSidebar.jsp" />

    <div class="admin-main">
        <div class="admin-topbar">
            <div>
                <h1>Thùng rác tài khoản</h1>
                <small>Admin &rsaquo; Quản lý người dùng &rsaquo; Lưu trữ đã xóa</small>
            </div>
            <div class="user-profile">
                <span style="font-size: 18px;">👤</span>
                <strong>${sessionScope.acc.fullName}</strong>
            </div>
        </div>

        <div class="admin-content">

            <!-- Search Card -->
            <div class="glass-card">
                <div class="card-header">
                    <h3>🔍 Tìm kiếm tài khoản đã xóa</h3>
                </div>
                <div class="card-body">
                    <form action="deletedUsers" method="get">
                        <div class="search-grid">
                            <div class="form-group">
                                <label>Tên / Username</label>
                                <input type="text" name="name" value="${param.name}" class="form-control" placeholder="Nhập tên...">
                            </div>
                            <div class="form-group">
                                <label>Email</label>
                                <input type="text" name="email" value="${param.email}" class="form-control" placeholder="Nhập email...">
                            </div>
                            <div class="form-group">
                                <label>Số điện thoại</label>
                                <input type="text" name="phone" value="${param.phone}" class="form-control" placeholder="Nhập SĐT...">
                            </div>
                            <div class="form-group">
                                <label>Vai trò cũ</label>
                                <select name="role" class="form-control">
                                    <option value="-1">Tất cả</option>
                                    <c:forEach items="${listOfRole}" var="r">
                                        <option value="${r.roleID}" ${param.role == r.roleID ? 'selected' : ''}>
                                            ${r.roleName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">Tìm kiếm</button>
                    </form>
                </div>
            </div>

            <!-- Table Card -->
            <div class="glass-card">
                <div class="card-header">
                    <h3>🗑️ Danh sách tài khoản đã xóa (${list.size()})</h3>
                </div>
                <div class="card-body" style="padding: 0;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tài khoản</th>
                                <th>Họ tên</th>
                                <th>Vai trò</th>
                                <th>Email</th>
                                <th>SĐT</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${requestScope.list}" var="u">
                                <tr>
                                    <td>#${u.userID}</td>
                                    <td style="font-weight: 600;">${u.username}</td>
                                    <td>${u.fullName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.roleID == 0}"><span class="role-badge role-admin">Admin</span></c:when>
                                            <c:when test="${u.roleID == 1}"><span class="role-badge role-staff">Staff</span></c:when>
                                            <c:when test="${u.roleID == 2}"><span class="role-badge role-manager">Manager</span></c:when>
                                            <c:when test="${u.roleID == 3}"><span class="role-badge role-sales">Sales</span></c:when>
                                        </c:choose>
                                    </td>
                                    <td style="font-size: 13px; color: var(--text-muted);">${u.email}</td>
                                    <td style="font-size: 13px;">${u.phone}</td>
                                    <td>
                                        <a href="restoreUser?id=${u.userID}" class="action-link restore-link" 
                                           onclick="return confirm('Bạn có chắc muốn khôi phục tài khoản này?');">
                                           🔄 Khôi phục
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty requestScope.list}">
                                <tr>
                                    <td colspan="7" style="text-align: center; padding: 40px; color: var(--text-muted);">
                                        Thùng rác đang trống.
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