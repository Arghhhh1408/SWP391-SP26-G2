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
        <br>
        <br><!-- comment -->
        

        <div><h3>Tìm kiếm tài khoản</h3></div>
        <form action="deletedUsers" method="get">
            <table>
                <tr>
                    <td>Name:</td>
                    <td><input type="text" name="name" value="${param.name}" placeholder="Username or Fullname"></td>
                    <td>Email:</td>
                    <td><input type="text" name="email" value="${param.email}"></td>
                </tr>
                <tr>
                    <td>Phone:</td>
                    <td><input type="text" name="phone" value="${param.phone}"></td>
                    <td>Role:</td>
                    <td>
                        <select name="role">
                            <option value="-1">All</option>
                            <c:forEach items="${listOfRole}" var="r">
                                <option value="${r.getRoleID()}" ${param.role==r.getRoleID() ? 'selected' : '' }>
                                    ${r.getRoleName()}</option>
                                </c:forEach>
                        </select></td>
                </tr>
                
            </table>
                    <input type="submit" value="Tìm kiếm">




            
        </form>

        <br>
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