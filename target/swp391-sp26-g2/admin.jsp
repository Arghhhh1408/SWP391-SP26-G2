<%-- Document : admin Created on : Jan 15, 2026, 2:43:38 PM Author : minhtuan --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>JSP Page</title>
            </head>

            <body>
                <h1>Xin chào Admin</h1>

                <a href="userList">Xem danh sách tài khoản</a><br><!-- comment -->
                <a href="createuser">Cấp tài khoản mới cho User</a><br><!-- comment -->
                <a href="supplierList">Xem danh sách nhà cung cấp</a><br><!-- comment -->
                <a href="deletedUsers">Tài khoản đã xóa</a><br><!-- comment -->
                <a href="systemlog">Xem lịch sử hoạt động</a><br><!-- comment -->              
                <a href="warrantyLookup">Tra cứu bảo hành</a><br><!-- comment -->
                <a href="warrantyClaims">Xử lý yêu cầu bảo hành</a><br><!-- comment -->
                <a href="returns">Trả hàng &amp; hoàn tiền</a><br><!-- comment -->
                <a href="products">Danh sách sản phẩm (CRUD)</a><br><!-- comment -->
                <a href="dashboard">Bảng điều khiển &amp; báo cáo</a><br><!-- comment -->
                <a href="logout">Đăng xuất</a><br>
                
                
                <br><!-- comment -->
                <br><!-- comment -->
                <br><!-- comment -->
                <h3 style="color: green">${notification}</h3>


            </body>

            </html>