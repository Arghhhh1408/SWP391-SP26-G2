<%-- Document : admin Created on : Jan 15, 2026, 2:43:38 PM Author : minhtuan --%>

<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Admin Dashboard</title>
</head>

<body>

    <h1>Xin chào Admin</h1>

    <!-- Quản lý user -->
    <a href="userList">Xem danh sách tài khoản</a><br>
    <a href="createuser">Cấp tài khoản mới cho User</a><br>
    <a href="deletedUsers">Tài khoản đã xóa</a><br>

    <!-- System log -->
    <a href="systemlog">Xem lịch sử hoạt động</a><br>

    <!-- Warranty System -->
    <a href="warrantyLookup">Tra cứu bảo hành</a><br>
    <a href="warrantyClaims">Xử lý yêu cầu bảo hành</a><br>
    <a href="returns">Trả hàng & hoàn tiền</a><br>
    <a href="products">Danh sách sản phẩm (CRUD)</a><br>
    <a href="dashboard">Bảng điều khiển & báo cáo</a><br>

    <!-- Logout -->
    <a href="logout">Đăng xuất</a><br>

    <br><br><br>

    <h3 style="color: green">${notification}</h3>

</body>

</html>