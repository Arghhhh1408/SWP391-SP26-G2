<%-- Document : systemLog --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>Lịch Sử Hoạt Động</title>
            </head>

            <body>
                <c:if test="${sessionScope.acc == null or sessionScope.acc.roleID ne 0}">
                    <c:redirect url="login" />
                </c:if>
                <c:set var="currentPage" value="systemLog" scope="request" />
                <jsp:include page="adminSidebar.jsp" />

                <div class="admin-main">
                    <div class="admin-topbar">
                        <div>
                            <h1>Lịch Sử Hoạt Động</h1>
                            <small>Admin &rsaquo; Hệ thống &rsaquo; System Log</small>
                        </div>
                        <div>Xin chào, <strong>${sessionScope.acc.fullName}</strong></div>
                    </div>

                    <div class="admin-content">

                        <form action="systemlog" method="get">
                            UserID: <input type="number" name="userId" value="${userId}" placeholder="User ID">
                            Action: <input type="text" name="action" value="${action}" placeholder="Action">
                            Date: <input type="date" name="date" value="${date}">
                            <button type="submit">Lọc</button>
                        </form>
                        <br>

                        <table border="1">
                            <thead>
                                <tr>
                                    <th>Log ID</th>
                                    <th>User ID</th>
                                    <th>Action</th>
                                    <th>Target Object</th>
                                    <th>Description</th>
                                    <th>Date</th>
                                    <th>IP Address</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${requestScope.logs}" var="log">
                                    <tr>
                                        <td>${log.logID}</td>
                                        <td>${log.userID}</td>
                                        <td>${log.action}</td>
                                        <td>${log.targetObject}</td>
                                        <td>${log.description}</td>
                                        <td>${log.logDate}</td>
                                        <td>${log.ipAddress}</td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>

                    </div><!-- /admin-content -->
                </div><!-- /admin-main -->

            </body>

            </html>