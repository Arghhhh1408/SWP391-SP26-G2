<%-- Document : createAccount Created on : Jan 16, 2026, 10:04:42 AM Author : minhtuan --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>JSP Page</title>
            </head>

            <body>
                <h1>
                    <c:if test="${empty user}">Tạo tài khoản</c:if>
                    <c:if test="${not empty user}">Sửa tài khoản</c:if>
                </h1>
                <a href="admin">Quay lại Admin Dashboard</a>
                <form action="${not empty user ? 'updateuser' : 'createuser'}" method="post">
                    <c:if test="${not empty user}">
                        <input type="hidden" name="id" value="${user.userID}">
                    </c:if>
                    <table>
                        <c:choose>
                            <c:when test="${not empty user}">
                                <%-- UPDATE MODE --%>
                                    <tr>
                                        <td>User ID:</td>
                                        <td><input type="text" value="${user.userID}" readonly
                                                style="background-color: #e9ecef;"></td>
                                        <td>Username:</td>
                                        <td><input type="text" name="username" value="${user.username}" readonly
                                                style="background-color: #e9ecef;"></td>
                                    </tr>
                                    <tr>
                                        <td>Họ tên:</td>
                                        <td><input type="text" name="fullname" value="${user.fullName}" required></td>
                                        <td>Số điện thoại:</td>
                                        <td><input type="text" name="phone" value="${user.phone}" required></td>
                                    </tr>
                                    <tr>
                                        <td>Email:</td>
                                        <td><input type="email" name="email" value="${user.email}" required></td>
                                        <td>Vai trò: </td>
                                        <td>
                                            <select name="role">
                                                <c:forEach items="${requestScope.listOfRole}" var="i">
                                                    <option value="${i.getRoleID()}" <c:if
                                                        test="${i.getRoleID() == user.roleID}">
                                                        selected</c:if>>${i.getRoleName()}</option>
                                                </c:forEach>
                                            </select>
                                        </td>
                                    </tr>
                            </c:when>
                            <c:otherwise>
                                <%-- CREATE MODE --%>
                                    <tr>
                                        <td>Họ tên:</td>
                                        <td><input type="text" name="fullname" value="${param.fullname}" required></td>
                                        <td>Số điện thoại:</td>
                                        <td><input type="text" name="phone" value="${param.phone}" required></td>
                                    </tr>
                                    <tr>
                                        <td>Email:</td>
                                        <td><input type="email" name="email" value="${param.email}" required></td>
                                        <td>Username:</td>
                                        <td><input type="text" name="username" value="${param.username}" required></td>
                                    </tr>
                                    <tr>
                                        <td>Password:</td>
                                        <td><input type="text" name="password" value="${param.password}" required> </td>
                                        <td>Vai trò: </td>
                                        <td>
                                            <select name="role">
                                                <c:forEach items="${requestScope.listOfRole}" var="i">
                                                    <option value="${i.getRoleID()}" <c:if
                                                        test="${i.getRoleID() == param.role}">
                                                        selected</c:if>>${i.getRoleName()}</option>
                                                </c:forEach>
                                            </select>
                                        </td>
                                    </tr>
                            </c:otherwise>
                        </c:choose>

                        <tr>
                            <td><input type="submit" value="${not empty user ? 'Cập nhật' : 'Tạo tài khoản'}"></td>
                        </tr>
                    </table>
                </form>
                <c:if test="${not empty message}">
                    <h3 style="color: ${status == 'success' ? 'green' : 'red'}">${message}</h3>
                    <a href="admin">Quay lại admin</a> |
                    <a href="userList">Xem danh sách tài khoản</a>
                    <c:if test="${empty user}"> | <a href="createuser">Tiếp tục thêm tài khoản</a></c:if>
                    <br><br>
                </c:if>
                <c:if test="${empty message}">

                </c:if>
                <h3 style="color: red">${requestScope.error}</h3>
            </body>

            </html>