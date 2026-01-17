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


                <a href="createuser">Cấp tài khoản mới cho User</a><br><!-- comment -->
                <a href="deletedUsers">Tài khoản đã xóa</a><br><!-- comment -->             
                <a href="logout">Đăng xuất</a>



                <br><!-- comment -->
                <br><!-- comment -->
                <br><!-- comment -->

                <h3>Danh Sách Tài Khoản</h3>
                <br><!-- comment -->



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
                                <td> <a href="#">Xem chi tiết</a> </td>
                                <td> <a href="#">Sửa</a> </td>
                                <td> <a href="deleteUser?id=${i.getUserID()}"
                                        onclick="return confirm('Are you sure you want to delete this user?');">Xóa</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <br><!-- comment -->
                <h3>Lọc tài khoản</h3>
                <form action="admin">
                    <table>
                        <tr>
                            <td>Tên:</td>
                            <td><input type="text" name="name" value="${param.name}" /></td>
                        </tr>
                        <tr>
                            <td>Email:</td>
                            <td><input type="text" name="email" value="${param.email}" /></td>
                        </tr>
                        <tr>
                            <td>Phone:</td>
                            <td><input type="text" name="phone" value="${param.phone}" /></td>
                        </tr>
                        <tr>
                            <td><select name="option">
                                    <option>All</option>
                                    <c:forEach items="${requestScope.listOfRole}" var="i">
                                        <option <c:if test="${i.getRoleName() eq param.option}">selected</c:if>
                                            >${i.getRoleName()}
                                        </option>
                                    </c:forEach>
                                </select></td>
                        </tr>
                    </table>
                    <input type="submit" value="LỌC" />
                </form>
                <h3>${notification}</h3>

            </body>

            </html>