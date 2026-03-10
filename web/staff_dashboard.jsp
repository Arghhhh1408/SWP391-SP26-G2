<%-- 
    Document   : staff_dashboard
    Created on : 9 thg 3, 2026, 16:47:38
    Author     : dotha
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Staff Dashboard</title>
    </head>

    <body>

        <h2>STAFF DASHBOARD</h2>

        <p>
            Xin chào: <b>${sessionScope.acc.fullName}</b>
        </p>

        <hr>

        <h3>Kho</h3>
        <a href="stockinList">Danh sách phiếu nhập</a><br>
        <a href="createStockIn">Tạo phiếu nhập</a><br>
        <a href="#">Kiểm kê kho</a><br>

        <h3>Sản phẩm</h3>
        <a href="productDetail">Danh sách sản phẩm</a><br>
        <a href="#">Trả hàng cho nhà cung cấp</a><br>

        <h3>Nhà cung cấp</h3>
        <a href="supplierList">Danh sách nhà cung cấp</a><br>
        <a href="#">Quản lý công nợ nhà cung cấp</a><br>

        <hr>

        <p>
            <a href="logout">Đăng xuất</a>
        </p>

    </body>
</html>
