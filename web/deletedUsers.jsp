<%-- Document : deletedUsers Created on : Jan 16, 2026, 10:43:38 PM Author : minhtuan --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>Deleted Users</title>
            </head>

            <body>
                <h1>Danh sách tài khoản đã xóa</h1>
                <a href="admin">Quay lại Admin Dashboard</a>
                <br><br>
                <table border="1">
                    <thead>
                        <tr>
                            <th>UserID</th>
                            <th>UserName</th>
                            <th>FullName</th>
                            <th>Role</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>CreateDate</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${requestScope.list}" var="i">
                            <tr>
                                <td>${i.getUserID()}</td>
                                <td>${i.getUsername()}</td>
                                <td>${i.getFullName()}</td>
                                <td>
                                    <c:if test="${i.getRoleID() == 0}">Admin</c:if>
                                    <c:if test="${i.getRoleID() == 1}">Staff</c:if>
                                    <c:if test="${i.getRoleID() == 2}">Manager</c:if>
                                    <c:if test="${i.getRoleID() == 3}">Sales</c:if>
                                </td>
                                <td>${i.getEmail()}</td>
                                <td>${i.getPhone()}</td>
                                <td>${i.getCreateDate()}</td>
                                <td>
                                    <a href="restoreUser?id=${i.getUserID()}"
                                        onclick="return confirm('Bạn có chắc muốn khôi phục tài khoản này?');">Khôi
                                        phục</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </body>

            </html>