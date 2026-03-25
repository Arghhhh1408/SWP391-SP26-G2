<%-- Document : userList --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Quản lý tài khoản | IMS ADMIN</title>
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
            margin-right: 12px;
        }
        .action-link:hover { text-decoration: underline; }
        .delete-link { color: #ef4444; }
    </style>
</head>

<body>
    <c:set var="currentPage" value="userList" scope="request" />
    <jsp:include page="adminSidebar.jsp" />

    <div class="admin-main">
        <div class="admin-topbar">
            <div>
                <h1>Danh sách tài khoản</h1>
                <small>Admin &rsaquo; Quản lý người dùng</small>
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
                    <h3>🔍 Tìm kiếm & Bộ lọc</h3>
                </div>
                <div class="card-body">
                    <form action="userList" method="get">
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
                                <label>Vai trò</label>
                                <select name="option" class="form-control">
                                    <option value="All">Tất cả</option>
                                    <c:forEach items="${requestScope.listOfRole}" var="r">
                                        <option value="${r.roleName}" ${r.roleName eq param.option ? 'selected' : ''}>
                                            ${r.roleName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <button type="submit" class="btn btn-primary">Tìm kiếm ngay</button>
                            <a href="createuser" class="btn btn-outline" style="text-decoration: none;">➕ Cấp tài khoản mới</a>
                        </div>
                    </form>
                </div>
            </div>

            <c:if test="${not empty notification}">
                <div style="background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; padding: 12px 16px; border-radius: 12px; margin-bottom: 24px;">
                    ✅ ${notification}
                </div>
            </c:if>

            <!-- Table Card -->
            <div class="glass-card">
                <div class="card-header">
                    <h3>👥 Danh sách hiển thị (${list.size()})</h3>
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
                                        <div style="display: flex; gap: 8px;">
                                            <a href="resetpassword?id=${u.userID}" class="action-link" title="Reset về 123">Reset</a>
                                            <c:if test="${u.roleID != 0}">
                                                <a href="updateuser?id=${u.userID}" class="action-link">Sửa</a>
                                                <a href="deleteUser?id=${u.userID}" class="action-link delete-link" 
                                                   onclick="return confirm('Bạn có chắc muốn xóa tài khoản này?');">Xóa</a>
                                            </c:if>
                                        </div>
                                    </td>
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