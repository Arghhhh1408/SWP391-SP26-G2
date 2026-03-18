<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.User" %>
<% User acc = (User) session.getAttribute("acc"); %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Tài khoản - S.I.M</title>
        <style>
            /* --- GIỮ NGUYÊN CSS CŨ CỦA BẠN --- */
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
                font-family: 'Segoe UI', Arial, sans-serif;
            }
            body {
                background: #f4f6f9;
                color: #1f2937;
            }
            .layout {
                display: flex;
                min-height: 100vh;
            }
            .sidebar {
                width: 240px;
                background: #1f2d3d;
                color: #fff;
                display: flex;
                flex-direction: column;
                flex-shrink: 0;
            }
            .logo {
                padding: 25px 20px;
                font-size: 24px;
                font-weight: bold;
                background: #1a2533;
                text-align: center;
                color: #3b82f6;
                letter-spacing: 2px;
            }
            .menu {
                list-style: none;
                padding: 10px 0;
                flex: 1;
            }
            .menu li a {
                display: block;
                padding: 14px 20px;
                color: #cbd5e1;
                text-decoration: none;
            }
            .menu li a.active {
                background: #374151;
                color: #fff;
                border-left: 4px solid #3b82f6;
            }
            .main {
                flex: 1;
                display: flex;
                flex-direction: column;
            }
            .content {
                padding: 30px;
                display: flex;
                justify-content: center;
            }

            /* Cấu trúc Card Profile */
            .card {
                background: #fff;
                border-radius: 12px;
                padding: 30px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
                border: 1px solid #e5e7eb;
                width: 100%;
                max-width: 550px;
            }
            .profile-header {
                text-align: center;
                margin-bottom: 30px;
            }
            .avatar {
                width: 80px;
                height: 80px;
                background: #3b82f6;
                color: #fff;
                border-radius: 50%;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: 32px;
                font-weight: bold;
                margin-bottom: 10px;
            }

            .info-item {
                margin-bottom: 15px;
            }
            .info-item label {
                display: block;
                font-size: 12px;
                color: #6b7280;
                font-weight: 700;
                margin-bottom: 5px;
                text-transform: uppercase;
            }
            .info-box {
                padding: 12px;
                background: #f9fafb;
                border: 1px solid #e5e7eb;
                border-radius: 8px;
                font-size: 15px;
            }
            .edit-input {
                display: none;
                width: 100%;
                padding: 10px;
                border: 2px solid #3b82f6;
                border-radius: 8px;
                font-size: 15px;
                outline: none;
            }

            .btn {
                padding: 12px;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                font-weight: 600;
                width: 100%;
                margin-top: 10px;
                transition: 0.2s;
            }
            .btn-edit {
                background: #f3f4f6;
                color: #1f2937;
                border: 1px solid #d1d5db;
            }
            .btn-save {
                background: #3b82f6;
                color: #fff;
                display: none;
            }
            .btn-cancel {
                background: #fee2e2;
                color: #dc2626;
                display: none;
                margin-top: 5px;
                font-size: 13px;
            }
            .user-box {
                padding: 18px;
                border-bottom: 1px solid rgba(255,255,255,0.08);
                font-size: 14px;
                background: #263544;
            }
        </style>
    </head>
    <body>
        <div class="layout">
            <aside class="sidebar">
                <div class="logo">S.I.M</div>
                <div class="user-box">Xin chào: <b><%= acc != null ? acc.getUsername() : "" %></b></div>
                <ul class="menu">
                    <li><a  href="${pageContext.request.contextPath}/dashboard">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/products">Sản phẩm</a></li>
                    <li><a href="${pageContext.request.contextPath}/pos">Bán hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/orders">Lịch sử đơn hàng</a></li>
                    <li><a href="${pageContext.request.contextPath}/customers">Khách hàng</a></li>
                    <li><a class="active" href="account">Tài khoản</a></li>
                    <li><a href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                </ul>
            </aside>

            <main class="main">
                <div class="content">
                    <div class="card">
                        <div class="profile-header">
                            <div class="avatar"><%= acc != null ? acc.getUsername().substring(0, 1).toUpperCase() : "U" %></div>
                            <h2><%= acc != null ? acc.getUsername() : "User" %></h2>
                            <p style="color: #6b7280;">Nhân viên siêu thị S.I.M</p>
                        </div>

                        <form id="profileForm" action="update-account" method="POST">
                            <div class="info-item">
                                <label>Tên đăng nhập</label>
                                <div class="info-box"><%= acc != null ? acc.getUsername() : "" %></div>
                            </div>

                            <div class="info-item">
                                <label>Số điện thoại</label>
                                <div class="info-box view-mode">098xxxxxxx</div> <input type="text" name="phone" class="edit-input" value="098xxxxxxx">
                            </div>

                            <div class="info-item">
                                <label>Địa chỉ công tác</label>
                                <div class="info-box view-mode">Sơn Tây, Hà Nội</div> <input type="text" name="address" class="edit-input" value="Sơn Tây, Hà Nội">
                            </div>

                            <button type="button" id="editBtn" class="btn btn-edit">CHỈNH SỬA THÔNG TIN</button>
                            <button type="submit" id="saveBtn" class="btn btn-save">LƯU THAY ĐỔI</button>
                            <button type="button" id="cancelBtn" class="btn btn-cancel">HỦY BỎ</button>
                        </form>

                        <a href="change-password" style="display:block; text-align:center; margin-top:20px; font-size:14px; color:#3b82f6; text-decoration:none;">Đổi mật khẩu?</a>
                    </div>
                </div>
            </main>
        </div>

        <script>
            const editBtn = document.getElementById('editBtn');
            const saveBtn = document.getElementById('saveBtn');
            const cancelBtn = document.getElementById('cancelBtn');
            const viewModes = document.querySelectorAll('.view-mode');
            const editInputs = document.querySelectorAll('.edit-input');

            editBtn.onclick = function () {
                viewModes.forEach(el => el.style.display = 'none');
                editInputs.forEach(el => el.style.display = 'block');
                editBtn.style.display = 'none';
                saveBtn.style.display = 'block';
                cancelBtn.style.display = 'block';
            };

            cancelBtn.onclick = function () {
                viewModes.forEach(el => el.style.display = 'block');
                editInputs.forEach(el => el.style.display = 'none');
                editBtn.style.display = 'block';
                saveBtn.style.display = 'none';
                cancelBtn.style.display = 'none';
            };
        </script>
    </body>
</html>