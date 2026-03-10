<%-- Document : deletedUsers --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>Tài Khoản Đã Xóa</title>
            </head>

            <body>
                <c:set var="currentPage" value="deletedUsers" scope="request" />
                <jsp:include page="adminSidebar.jsp" />

                <div class="admin-main">
                    <div class="admin-topbar">
                        <div>
                            <h1>Danh Sách Tài Khoản Đã Xóa</h1>
                            <small>Admin &rsaquo; Quản lý người dùng &rsaquo; Tài khoản đã xóa</small>
                        </div>
                        <div>Xin chào, <strong>${sessionScope.acc.fullName}</strong></div>
                    </div>

                    <div class="admin-content">

                        <h3>Tìm kiếm tài khoản</h3>
                        <form action="deletedUsers" method="get">
                            <table>
                                <tr>
                                    <td>Name:</td>
                                    <td><input type="text" name="name" value="${param.name}"
                                            placeholder="Username or Fullname"></td>
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
                                                <option value="${r.getRoleID()}" ${param.role==r.getRoleID()
                                                    ? 'selected' : '' }>
                                                    ${r.getRoleName()}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </td>
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

                    </div><!-- /admin-content -->
                </div><!-- /admin-main -->

            </body>

            </html>