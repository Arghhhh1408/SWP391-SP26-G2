<%-- Document : userDetail (create / update user form) --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>
                    <c:choose>
                        <c:when test="${empty user}">Tạo tài khoản mới | IMS ADMIN</c:when>
                        <c:otherwise>Cập nhật tài khoản | IMS ADMIN</c:otherwise>
                    </c:choose>
                </title>
                <style>
                    .form-container {
                        max-width: 600px;
                        margin: 0 auto;
                    }

                    .form-grid {
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 20px;
                    }

                    @media (max-width: 600px) {
                        .form-grid {
                            grid-template-columns: 1fr;
                        }
                    }

                    .form-actions {
                        margin-top: 32px;
                        display: flex;
                        gap: 12px;
                        justify-content: flex-end;
                        border-top: 1px solid #f1f5f9;
                        padding-top: 24px;
                    }

                    .readonly-input {
                        background-color: #f8fafc !important;
                        color: #64748b !important;
                        cursor: not-allowed;
                    }
                </style>
            </head>

            <body>
                <c:set var="currentPage" value="${empty user ? 'createUser' : 'userList'}" scope="request" />
                <jsp:include page="adminSidebar.jsp" />

                <div class="admin-main">
                    <div class="admin-topbar">
                        <div>
                            <h1>
                                <c:choose>
                                    <c:when test="${empty user}">🆕 Cấp tài khoản mới</c:when>
                                    <c:otherwise>✏️ Chỉnh sửa tài khoản</c:otherwise>
                                </c:choose>
                            </h1>
                            <small>Admin &rsaquo; Quản lý người dùng &rsaquo;
                                ${empty user ? 'Tạo mới' : 'Cập nhật thông tin'}
                            </small>
                        </div>
                        <div class="user-profile">
                            <span style="font-size: 18px;">👤</span>
                            <strong>${sessionScope.acc.fullName}</strong>
                        </div>
                    </div>

                    <div class="admin-content">
                        <div class="form-container">
                            <div class="glass-card">
                                <div class="card-header">
                                    <h3>Thông tin tài khoản</h3>
                                </div>
                                <div class="card-body">
                                    <form action="${not empty user ? 'updateuser' : 'createuser'}" method="post">
                                        <c:if test="${not empty user}">
                                            <input type="hidden" name="id" value="${user.userID}">
                                        </c:if>

                                        <div class="form-grid">
                                            <c:if test="${not empty user}">
                                                <div class="form-group">
                                                    <label>User ID</label>
                                                    <input type="text" value="${user.userID}"
                                                        class="form-control readonly-input" readonly>
                                                </div>
                                                <div class="form-group">
                                                    <label>Username</label>
                                                    <input type="text" name="username" value="${user.username}"
                                                        class="form-control readonly-input" readonly>
                                                </div>
                                            </c:if>

                                            <c:if test="${empty user}">
                                                <div class="form-group">
                                                    <label>Username</label>
                                                    <input type="text" name="username" value="${param.username}"
                                                        class="form-control" placeholder="Nhập username" required>
                                                </div>
                                                <div class="form-group">
                                                    <label>Mật khẩu mặc định</label>
                                                    <input type="text" name="password" value="${param.password}"
                                                        class="form-control" placeholder="Nhập mật khẩu" required>
                                                </div>
                                            </c:if>

                                            <div class="form-group" style="grid-column: span 2;">
                                                <label>Họ và tên</label>
                                                <input type="text" name="fullname"
                                                    value="${not empty user ? user.fullName : param.fullname}"
                                                    class="form-control ${not empty user ? 'readonly-input' : ''}" 
                                                    placeholder="Nhập họ và tên đầy đủ" required
                                                    ${not empty user ? 'readonly' : ''}>
                                            </div>

                                            <div class="form-group">
                                                <label>Email liên hệ</label>
                                                <input type="email" name="email"
                                                    value="${not empty user ? user.email : param.email}"
                                                    class="form-control ${not empty user ? 'readonly-input' : ''}" 
                                                    placeholder="example@domain.com" required
                                                    ${not empty user ? 'readonly' : ''}>
                                            </div>

                                            <div class="form-group">
                                                <label>Số điện thoại</label>
                                                <input type="text" name="phone"
                                                    value="${not empty user ? user.phone : param.phone}"
                                                    class="form-control ${not empty user ? 'readonly-input' : ''}" 
                                                    placeholder="0xxxxxxxxx" required
                                                    ${not empty user ? 'readonly' : ''}>
                                            </div>

                                            <div class="form-group" style="grid-column: span 2;">
                                                <label>Vai trò hệ thống</label>
                                                <select name="role" class="form-control">
                                                    <c:forEach items="${requestScope.listOfRole}" var="r">
                                                        <option value="${r.roleID}" <c:if
                                                            test="${(not empty user and r.roleID == user.roleID) or (empty user and r.roleID == param.role)}">
                                                            selected</c:if>>
                                                            ${r.roleName}
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                        </div>

                                        <c:if test="${not empty error}">
                                            <div
                                                style="color: #ef4444; background: #fee2e2; padding: 10px 14px; border-radius: 8px; font-size: 13px; margin-top: 16px;">
                                                ⚠️ ${error}
                                            </div>
                                        </c:if>

                                        <c:if test="${not empty message}">
                                            <div
                                                style="color: #10b981; background: #dcfce7; padding: 10px 14px; border-radius: 8px; font-size: 13px; margin-top: 16px;">
                                                ✅ ${message}
                                            </div>
                                        </c:if>

                                        <div class="form-actions">
                                            <a href="userList" class="btn btn-outline">Hủy bỏ</a>
                                            <button type="submit" class="btn btn-primary">
                                                ${not empty user ? 'Cập nhật tài khoản' : 'Tạo tài khoản'}
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <div style="margin-top: 20px; text-align: center;">
                                <a href="userList"
                                    style="color: var(--text-muted); font-size: 13px; text-decoration: none;">&larr;
                                    Quay lại danh sách</a>
                            </div>
                        </div>
                    </div>
                </div>
            </body>

            </html>