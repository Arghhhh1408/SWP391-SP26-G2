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
                                                                                                        pattern="dd/MM/yyyy" />
                                                                                                </c:when>
                                                                                                <c:otherwise>Không có dữ
                                                                                                    liệu</c:otherwise>
                                                                                            </c:choose>
                                                                                        </div>
                                                                                    </div>
                                                                                </li>

                                                        </ul>
                                            </form>

                                            <%-- ===== Change Password Section ===== --%>
                                            <div style="margin-top: 32px; border-top: 2px solid #f0f0f5; padding-top: 28px;">
                                                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;">
                                                    <div style="display: flex; align-items: center; gap: 10px;">
                                                        <div class="profile-info-icon">&#128274;</div>
                                                        <h3 style="margin: 0; font-size: 18px; color: #1a1a2e;">Đổi mật khẩu</h3>
                                                    </div>
                                                    <button type="button" id="togglePasswordBtn" onclick="togglePasswordSection()"
                                                        style="background: #6c757d; color: white; border: none; padding: 8px 16px; border-radius: 5px; cursor: pointer; font-size: 14px;">
                                                        Đổi mật khẩu
                                                    </button>
                                                </div>

                                                <%-- Password change notifications --%>
                                                <c:if test="${not empty passwordSuccess}">
                                                    <div style="background: #d4edda; color: #155724; border: 1px solid #c3e6cb; border-radius: 6px; padding: 10px 16px; margin-bottom: 16px;">
                                                        &#10004; ${passwordSuccess}
                                                    </div>
                                                </c:if>
                                                <c:if test="${not empty passwordError}">
                                                    <div style="background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 6px; padding: 10px 16px; margin-bottom: 16px;">
                                                        &#10006; ${passwordError}
                                                    </div>
                                                </c:if>

                                                <form action="personalProfile" method="POST" id="passwordForm" 
                                                    style="display: none;" onsubmit="return validatePasswordForm()">
                                                    <input type="hidden" name="action" value="changePassword" />

                                                    <div style="margin-bottom: 16px;">
                                                        <label style="display: block; font-size: 13px; color: #555; margin-bottom: 6px; font-weight: 500;">
                                                            Mật khẩu hiện tại <span style="color: #dc3545;">*</span>
                                                        </label>
                                                        <input type="password" name="currentPassword" id="currentPassword" required
                                                            style="width: 100%; padding: 10px 12px; border: 1px solid #ccc; border-radius: 6px; font-size: 14px; box-sizing: border-box; transition: border-color 0.2s;"
                                                            onfocus="this.style.borderColor='#007bff'" onblur="this.style.borderColor='#ccc'"
                                                            placeholder="Nhập mật khẩu hiện tại" />
                                                    </div>

                                                    <div style="margin-bottom: 16px;">
                                                        <label style="display: block; font-size: 13px; color: #555; margin-bottom: 6px; font-weight: 500;">
                                                            Mật khẩu mới <span style="color: #dc3545;">*</span>
                                                        </label>
                                                        <input type="password" name="newPassword" id="newPassword" required
                                                            style="width: 100%; padding: 10px 12px; border: 1px solid #ccc; border-radius: 6px; font-size: 14px; box-sizing: border-box; transition: border-color 0.2s;"
                                                            onfocus="this.style.borderColor='#007bff'" onblur="this.style.borderColor='#ccc'"
                                                            placeholder="Nhập mật khẩu mới" />
                                                    </div>

                                                    <div style="margin-bottom: 20px;">
                                                        <label style="display: block; font-size: 13px; color: #555; margin-bottom: 6px; font-weight: 500;">
                                                            Xác nhận mật khẩu mới <span style="color: #dc3545;">*</span>
                                                        </label>
                                                        <input type="password" name="confirmPassword" id="confirmPassword" required
                                                            style="width: 100%; padding: 10px 12px; border: 1px solid #ccc; border-radius: 6px; font-size: 14px; box-sizing: border-box; transition: border-color 0.2s;"
                                                            onfocus="this.style.borderColor='#007bff'" onblur="this.style.borderColor='#ccc'"
                                                            placeholder="Nhập lại mật khẩu mới" />
                                                    </div>

                                                    <div id="passwordValidationError" 
                                                        style="display: none; background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 6px; padding: 10px 16px; margin-bottom: 16px;">
                                                    </div>

                                                    <div style="display: flex; gap: 10px;">
                                                        <button type="submit"
                                                            style="background: #28a745; color: white; border: none; padding: 10px 24px; border-radius: 5px; cursor: pointer; font-size: 14px; font-weight: 500;">
                                                            Xác nhận đổi mật khẩu
                                                        </button>
                                                        <button type="button" onclick="togglePasswordSection()"
                                                            style="background: #dc3545; color: white; border: none; padding: 10px 24px; border-radius: 5px; cursor: pointer; font-size: 14px; font-weight: 500;">
                                                            Hủy
                                                        </button>
                                                    </div>
                                                </form>
                                            </div>

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

                                                // --- Change Password Section ---
                                                let isPasswordOpen = false;
                                                function togglePasswordSection() {
                                                    isPasswordOpen = !isPasswordOpen;
                                                    document.getElementById('passwordForm').style.display = isPasswordOpen ? 'block' : 'none';
                                                    document.getElementById('togglePasswordBtn').style.display = isPasswordOpen ? 'none' : 'inline-block';
                                                    if (!isPasswordOpen) {
                                                        document.getElementById('passwordForm').reset();
                                                        document.getElementById('passwordValidationError').style.display = 'none';
                                                    }
                                                }

                                                function validatePasswordForm() {
                                                    var newPass = document.getElementById('newPassword').value;
                                                    var confirmPass = document.getElementById('confirmPassword').value;
                                                    var errorDiv = document.getElementById('passwordValidationError');


                                                    if (newPass !== confirmPass) {
                                                        errorDiv.innerHTML = '&#10006; Mật khẩu xác nhận không khớp!';
                                                        errorDiv.style.display = 'block';
                                                        return false;
                                                    }
                                                    errorDiv.style.display = 'none';
                                                    return true;
                                                }

                                                // If there was an error submitting, keep edit mode open
                                                var hasError = "${not empty error}";
                                                if (hasError === "true") {
                                                    window.onload = function () {
                                                        toggleEdit();
                                                    };
                                                }

                                                // If there was a password error, keep password section open
                                                var hasPasswordError = "${not empty passwordError}";
                                                if (hasPasswordError === "true") {
                                                    window.onload = function () {
                                                        togglePasswordSection();
                                                    };
                                                }
                                            </script>
                                        </div>
                                    </div>
                                </div>
                            </div>

            </body>

            </html>