<%-- Document : userList --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>Danh Sách Tài Khoản</title>
            </head>

            <body>
                <c:set var="currentPage" value="userList" scope="request" />
                <jsp:include page="adminSidebar.jsp" />

                <div class="admin-main">
                    <div class="admin-topbar">
                        <div>
                            <h1>Danh Sách Tài Khoản</h1>
                            <small>Admin &rsaquo; Quản lý người dùng &rsaquo; Danh sách tài khoản</small>
                        </div>
                        <div>Xin chào, <strong>${sessionScope.acc.fullName}</strong></div>
                    </div>

                    <div class="admin-content">

                        <h3>Tìm kiếm tài khoản</h3>
                        <form action="userList">
                            <table>
                                <tr>
                                    <td>Tên:</td>
                                    <td><input type="text" name="name" value="${param.name}"
                                            placeholder="Username or Fullname" /></td>
                                    <td>Email:</td>
                                    <td><input type="text" name="email" value="${param.email}" /></td>
                                </tr>
                                <tr>
                                    <td>Phone:</td>
                                    <td><input type="text" name="phone" value="${param.phone}" /></td>
                                    <td>Role:</td>
                                    <td>
                                        <select name="option">
                                            <option>All</option>
                                            <c:forEach items="${requestScope.listOfRole}" var="i">
                                                <option <c:if test="${i.getRoleName() eq param.option}">selected</c:if>>
                                                    ${i.getRoleName()}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </td>
                                </tr>
                            </table>
                            <input type="submit" value="Tìm Kiếm" />
                        </form>

                        <br>
                        <a href="createuser">+ Thêm Tài Khoản Mới</a>
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
                                        <td><a href="resetpassword?id=${i.getUserID()}">Reset Mật khẩu</a></td>
                                        <td>
                                            <c:if test="${i.getRoleID() != 0}">
                                                <a href="updateuser?id=${i.getUserID()}">Sửa</a>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${i.getRoleID() != 0}">
                                                <a href="deleteUser?id=${i.getUserID()}"
                                                    onclick="return confirm('Are you sure you want to delete this user?');">Xóa</a>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>

                        <h3 style="color: green">${notification}</h3>

                        <c:if test="${not empty message}">
                            <h3 style="color: ${status == 'success' ? 'green' : 'red'}">${message}</h3>
                            <a href="admin">Quay lại admin</a> |
                            <a href="deletedUsers">Xem danh sách tài khoản đã xóa</a>
                            <br><br>
                        </c:if>

                    </div><!-- /admin-content -->
                </div><!-- /admin-main -->

            </body>

            </html>