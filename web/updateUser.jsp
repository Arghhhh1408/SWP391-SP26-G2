<%-- Document : updateUser Created on : Jan 16, 2026, 9:53:42 AM Author : minhtuan --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>JSP Page</title>
            </head>

            <body>
                <h1>Cập nhật thông tin tài khoản</h1>

                <form action="updateuser" method="POST">
                    <table>
                        <tr>
                            <td>ID:</td>
                            <td><input readonly name="id" value="${requestScope.user.getUserID()}" /></td>
                            <td>UserName:</td>
                            <td>
                                
                                <input type="text" name="username" value="${requestScope.user.getUsername()}" />
                            </td>
                            
                        </tr>
                        <tr>
                            <td>FullName:</td>
                            <td><input type="text" name="fullname" value="${requestScope.user.getFullName()}" /></td>
                            <td>Email:</td>
                            <td><input type="text" name="email" value="${requestScope.user.getEmail()}" /></td>
                        </tr>
                        <tr>
                            <td>Phone:</td>
                            <td><input type="text" name="phone" value="${requestScope.user.getPhone()}" /></td>
                            <td>Role:</td>
                            <td><select name="role">
                                    <c:forEach items="${requestScope.listOfRole}" var="i">
                                        <option value="${i.getRoleID()}" <c:if
                                            test="${i.getRoleID() == requestScope.user.getRoleID()}">
                                            selected</c:if>>${i.getRoleName()}</option>
                                    </c:forEach>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <input type="submit" value="Cập nhật" />
                            </td>
                        </tr>
                    </table>
                </form>
            </body>

            </html>