<%-- 
    Document   : login
    Created on : Jan 15, 2026, 12:16:43 PM
    Author     : minhtuan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>LOGIN</h1>
        <h3>${requestScope.err}</h3>
        <form action="login" method="POST">
            <table>
                <tr>
                    <td>Username:</td>
                    <td><input type="text" name="username" value="${requestScope.username}" required /></td>
                </tr>
                <tr>
                    <td>Password:</td>
                    <td><input type="password" name="password" value="${requestScope.password}" required /></td>
                </tr>
                <tr>
                    <td><input type="submit" value="LOGIN" /></td>
                </tr>
            </table>
          
        </form>
    </body>
</html>
