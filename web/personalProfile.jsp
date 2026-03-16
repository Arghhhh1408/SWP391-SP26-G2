<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib uri="jakarta.tags.core" prefix="c" %>
        <%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Hồ Sơ Cá Nhân – Admin</title>
                <style>
                    /* --- Page layout wrapper --- */
                    .profile-wrapper {
                        display: flex;
                        align-items: flex-start;
                        justify-content: center;
                        padding: 48px 32px;
                        min-height: 100vh;
                    }

                    /* --- Card --- */
                    .profile-card {
                        background: #ffffff;
                        border-radius: 16px;
                        box-shadow: 0 4px 24px rgba(26, 26, 46, 0.10);
                        padding: 40px 48px;
                        max-width: 520px;
                        width: 100%;
                    }

                    .profile-card-header {
                        display: flex;
                        align-items: center;
                        gap: 20px;
                        margin-bottom: 36px;
                    }

                    .profile-avatar {
                        width: 72px;
                        height: 72px;
                        border-radius: 50%;
                        background: linear-gradient(135deg, #1a1a2e 0%, #3a3a6e 100%);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 32px;
                        color: #ffffff;
                        flex-shrink: 0;
                    }

                    .profile-card-header h2 {
                        font-size: 22px;
                        color: #1a1a2e;
                        margin: 0 0 4px;
                    }

                    .profile-card-header span.badge {
                        display: inline-block;
                        background: #e8e8f7;
                        color: #1a1a2e;
                        border-radius: 20px;
                        padding: 2px 12px;
                        font-size: 12px;
                        font-weight: 600;
                        letter-spacing: 0.5px;
                    }

                    /* --- Info rows --- */
                    .profile-info-list {
                        list-style: none;
                        padding: 0;
                        margin: 0;
                        display: flex;
                        flex-direction: column;
                        gap: 0;
                    }

                    .profile-info-item {
                        display: flex;
                        align-items: center;
                        padding: 16px 0;
                        border-bottom: 1px solid #f0f0f5;
                    }

                    .profile-info-item:last-child {
                        border-bottom: none;
                    }

                    .profile-info-icon {
                        width: 38px;
                        height: 38px;
                        border-radius: 10px;
                        background: #f0f0fb;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 18px;
                        margin-right: 16px;
                        flex-shrink: 0;
                    }

                    .profile-info-label {
                        font-size: 11px;
                        text-transform: uppercase;
                        letter-spacing: 1px;
                        color: #999;
                        margin-bottom: 2px;
                    }

                    .profile-info-value {
                        font-size: 15px;
                        color: #1a1a2e;
                        font-weight: 500;
                    }

                    .profile-info-value.empty {
                        color: #bbb;
                        font-style: italic;
                        font-weight: 400;
                    }
                </style>
            </head>

            <body>
                <%-- Set active page for sidebar highlight --%>
                    <c:set var="currentPage" value="personalProfile" scope="request" />

                    <%-- Include the correct sidebar based on user role --%>
                        <c:choose>
                            <c:when test="${sidebarType == 'admin'}">
                                <jsp:include page="adminSidebar.jsp" />
                            </c:when>
                            <c:when test="${sidebarType == 'staff'}">
                                <jsp:include page="staffSidebar.jsp" />
                            </c:when>
                            <c:when test="${sidebarType == 'sales'}">
                                <jsp:include page="saleSidebar.jsp" />
                            </c:when>
                            <c:otherwise>
                                <jsp:include page="managerSidebar.jsp" />
                            </c:otherwise>
                        </c:choose>

                        <%-- Grab current user from session --%>
                            <c:set var="user" value="${sessionScope.acc}" />

                            <div class="admin-main">
                                <div class="admin-topbar">
                                    <div>
                                        <h1>Hồ Sơ Cá Nhân</h1>
                                        <small>Thông tin tài khoản quản trị viên</small>
                                    </div>
                                </div>

                                <div class="admin-content">
                                    <div class="profile-wrapper">
                                        <div class="profile-card">

                                            <form action="personalProfile" method="POST" id="profileForm">
                                                <input type="hidden" name="action" value="update" />

                                                <%-- Notifications --%>
                                                    <c:if test="${not empty success}">
                                                        <div
                                                            style="background: #d4edda; color: #155724; border: 1px solid #c3e6cb; border-radius: 6px; padding: 10px 16px; margin-bottom: 20px;">
                                                            &#10004; ${success}
                                                        </div>
                                                    </c:if>
                                                    <c:if test="${not empty error}">
                                                        <div
                                                            style="background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 6px; padding: 10px 16px; margin-bottom: 20px;">
                                                            &#10006; ${error}
                                                        </div>
                                                    </c:if>

                                                    <div class="profile-card-header"
                                                        style="justify-content: space-between;">
                                                        <div style="display: flex; align-items: center; gap: 20px;">
                                                            <div class="profile-avatar">&#128100;</div>
                                                            <div>
                                                                <h2 id="displayName">${not empty user.fullName ?
                                                                    user.fullName : user.username}</h2>
                                                                <span class="badge">
                                                                    <c:if test="${user.roleID == 0}">Admin</c:if>
                                                                    <c:if test="${user.roleID == 1}">Warehouse Staff
                                                                    </c:if>
                                                                    <c:if test="${user.roleID == 2}">Manager</c:if>
                                                                    <c:if test="${user.roleID == 3}">Salesperson</c:if>
                                                                </span>
                                                            </div>
                                                        </div>
                                                        <div>
                                                            <button type="button" id="editBtn" onclick="toggleEdit()"
                                                                style="background: #007bff; color: white; border: none; padding: 8px 16px; border-radius: 5px; cursor: pointer; font-size: 14px;">Chỉnh
                                                                sửa</button>
                                                            <button type="submit" id="saveBtn"
                                                                style="display: none; background: #28a745; color: white; border: none; padding: 8px 16px; border-radius: 5px; cursor: pointer; font-size: 14px; margin-right: 5px;">Lưu</button>
                                                            <button type="button" id="cancelBtn" onclick="toggleEdit()"
                                                                style="display: none; background: #dc3545; color: white; border: none; padding: 8px 16px; border-radius: 5px; cursor: pointer; font-size: 14px;">Hủy</button>
                                                        </div>
                                                    </div>

                                                    <%-- Info list --%>
                                                        <ul class="profile-info-list">

                                                            <%-- Họ và tên --%>
                                                                <li class="profile-info-item">
                                                                    <div class="profile-info-icon">&#128100;</div>
                                                                    <div style="flex: 1;">
                                                                        <div class="profile-info-label">Họ và tên</div>
                                                                        <div
                                                                            class="profile-info-value view-mode ${empty user.fullName ? 'empty' : ''}">
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${not empty user.fullName}">
                                                                                    ${user.fullName}</c:when>
                                                                                <c:otherwise>Chưa cập nhật</c:otherwise>
                                                                            </c:choose>
                                                                        </div>
                                                                        <input type="text" name="fullName"
                                                                            value="${user.fullName}" class="edit-mode"
                                                                            style="display: none; width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; font-size: 14px;" />
                                                                    </div>
                                                                </li>

                                                                <%-- Email --%>
                                                                    <li class="profile-info-item">
                                                                        <div class="profile-info-icon">&#128231;</div>
                                                                        <div style="flex: 1;">
                                                                            <div class="profile-info-label">Email</div>
                                                                            <div
                                                                                class="profile-info-value view-mode ${empty user.email ? 'empty' : ''}">
                                                                                <c:choose>
                                                                                    <c:when
                                                                                        test="${not empty user.email}">
                                                                                        ${user.email}</c:when>
                                                                                    <c:otherwise>Chưa cập nhật
                                                                                    </c:otherwise>
                                                                                </c:choose>
                                                                            </div>
                                                                            <input type="email" name="email"
                                                                                value="${user.email}" class="edit-mode"
                                                                                style="display: none; width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; font-size: 14px;" />
                                                                        </div>
                                                                    </li>

                                                                    <%-- Điện thoại --%>
                                                                        <li class="profile-info-item">
                                                                            <div class="profile-info-icon">&#128222;
                                                                            </div>
                                                                            <div style="flex: 1;">
                                                                                <div class="profile-info-label">Điện
                                                                                    thoại</div>
                                                                                <div
                                                                                    class="profile-info-value view-mode ${empty user.phone ? 'empty' : ''}">
                                                                                    <c:choose>
                                                                                        <c:when
                                                                                            test="${not empty user.phone}">
                                                                                            ${user.phone}</c:when>
                                                                                        <c:otherwise>Chưa cập nhật
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </div>
                                                                                <input type="text" name="phone"
                                                                                    value="${user.phone}"
                                                                                    class="edit-mode"
                                                                                    style="display: none; width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; font-size: 14px;" />
                                                                            </div>
                                                                        </li>

                                                                        <%-- Tên đăng nhập --%>
                                                                            <li class="profile-info-item">
                                                                                <div class="profile-info-icon">&#128272;
                                                                                </div>
                                                                                <div style="flex: 1;">
                                                                                    <div class="profile-info-label">Tên
                                                                                        đăng nhập (Không thể thay đổi)
                                                                                    </div>
                                                                                    <div class="profile-info-value">
                                                                                        ${user.username}</div>
                                                                                </div>
                                                                            </li>

                                                                            <%-- Ngày tạo tài khoản --%>
                                                                                <li class="profile-info-item">
                                                                                    <div class="profile-info-icon">
                                                                                        &#128197;</div>
                                                                                    <div style="flex: 1;">
                                                                                        <div class="profile-info-label">
                                                                                            Ngày tạo tài khoản (Không
                                                                                            thể thay đổi)</div>
                                                                                        <div
                                                                                            class="profile-info-value ${empty user.createDate ? 'empty' : ''}">
                                                                                            <c:choose>
                                                                                                <c:when
                                                                                                    test="${not empty user.createDate}">
                                                                                                    <fmt:formatDate
                                                                                                        value="${user.createDate}"
                                                                                                        pattern="dd/MM/yyyy HH:mm" />
                                                                                                </c:when>
                                                                                                <c:otherwise>Không có dữ
                                                                                                    liệu</c:otherwise>
                                                                                            </c:choose>
                                                                                        </div>
                                                                                    </div>
                                                                                </li>

                                                        </ul>
                                            </form>

                                            <script>
                                                let isEditing = false;
                                                function toggleEdit() {
                                                    isEditing = !isEditing;

                                                    // Toggle buttons
                                                    document.getElementById('editBtn').style.display = isEditing ? 'none' : 'inline-block';
                                                    document.getElementById('saveBtn').style.display = isEditing ? 'inline-block' : 'none';
                                                    document.getElementById('cancelBtn').style.display = isEditing ? 'inline-block' : 'none';

                                                    // Toggle form fields
                                                    const viewElements = document.querySelectorAll('.view-mode');
                                                    const editElements = document.querySelectorAll('.edit-mode');

                                                    viewElements.forEach(el => el.style.display = isEditing ? 'none' : 'block');
                                                    editElements.forEach(el => el.style.display = isEditing ? 'block' : 'none');

                                                    // Reset form on cancel
                                                    if (!isEditing) {
                                                        document.getElementById('profileForm').reset();
                                                    }
                                                }

                                                // If there was an error submitting, keep edit mode open
                                                var hasError = "${not empty error}";
                                                if (hasError === "true") {
                                                    window.onload = function () {
                                                        toggleEdit();
                                                    };
                                                }
                                            </script>
                                        </div>
                                    </div>
                                </div>
                            </div>

            </body>

            </html>