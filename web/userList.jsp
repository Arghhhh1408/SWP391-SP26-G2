<%-- Document : userList --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Danh sách người dùng | IMS PRO</title>
</head>

<body>
    <c:set var="currentPage" value="userList" scope="request" />
    <jsp:include page="adminSidebar.jsp" />

    <div class="admin-main">
        <div class="admin-topbar">
            <div class="topbar-left">
                <h1>Quản lý người dùng</h1>
                <p>Admin &rsaquo; Danh sách tất cả tài khoản</p>
            </div>
            <div class="user-profile">
                <span>👤 ${sessionScope.acc.fullName}</span>
            </div>
        </div>

        <div class="admin-content">
            <c:if test="${not empty sessionScope.message}">
                <div class="alert alert-${sessionScope.status eq 'success' ? 'success' : 'danger'}" 
                     style="margin-bottom: 20px; padding: 15px; border-radius: 8px; 
                            background: ${sessionScope.status eq 'success' ? '#e8fff3' : '#fff5f8'}; 
                            color: ${sessionScope.status eq 'success' ? '#50cd89' : '#f1416c'}; 
                            border: 1px solid ${sessionScope.status eq 'success' ? '#50cd89' : '#f1416c'};">
                    ${sessionScope.status eq 'success' ? '✅' : '⚠️'} ${sessionScope.message}
                    <c:remove var="message" scope="session" />
                    <c:remove var="status" scope="session" />
                </div>
            </c:if>
            <div class="card">
                <div class="card-header">
                    <h3>🔍 Bộ lọc tìm kiếm</h3>
                    <a href="createuser" class="btn btn-primary" style="padding: 8px 15px; font-size: 13px;">+ Thêm mới</a>
                </div>
                <div class="card-body">
                    <form action="userList" method="get">
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; align-items: flex-end;">
                            <div class="form-group">
                                <label style="display:block; font-size:12px; font-weight:700; color:#b5b5c3; margin-bottom:8px; text-transform:uppercase;">Tìm tên / Username</label>
                                <input type="text" name="name" value="${param.name}" class="form-control" placeholder="Từ khóa...">
                            </div>
                            <div class="form-group">
                                <label style="display:block; font-size:12px; font-weight:700; color:#b5b5c3; margin-bottom:8px; text-transform:uppercase;">Vai trò</label>
                                <select name="option" class="form-control">
                                    <option value="All">Tất cả vai trò</option>
                                    <c:forEach items="${requestScope.listOfRole}" var="r">
                                        <option value="${r.roleName}" ${r.roleName eq param.option ? 'selected' : ''}>${r.roleName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-outline">Tìm kiếm</button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="card">
                <div class="card-body" style="padding: 0;">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>#ID</th>
                                <th>Tài khoản</th>
                                <th>Họ tên</th>
                                <th>Email/SĐT</th>
                                <th>Vai trò</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${requestScope.list}" var="u">
                                <tr>
                                    <td><span style="color: #b5b5c3; font-weight: 700;">#${u.userID}</span></td>
                                    <td style="font-weight: 700; color: #181c32;">${u.username}</td>
                                    <td>${u.fullName}</td>
                                    <td>
                                        <div style="font-size: 13px;">${u.email}</div>
                                        <div style="color: #b5b5c3; font-size: 11px;">${u.phone}</div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.roleID == 0}"><span class="badge badge-danger">Admin</span></c:when>
                                            <c:when test="${u.roleID == 1}"><span class="badge badge-primary">Staff</span></c:when>
                                            <c:when test="${u.roleID == 2}"><span class="badge badge-success">Manager</span></c:when>
                                            <c:when test="${u.roleID == 3}"><span class="badge badge-warning">Sales</span></c:when>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div style="display: flex; gap: 10px;">
                                            <a href="updateuser?id=${u.userID}" class="btn btn-outline" style="padding: 5px 12px; font-size: 11px;">Sửa</a>
                                            <c:if test="${u.roleID != 0}">
                                                <a href="deleteUser?id=${u.userID}" class="btn btn-outline" style="color: #f64e60; padding: 5px 12px; font-size: 11px;" onclick="return confirm('Xác nhận xóa tài khoản?');">Xóa</a>
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