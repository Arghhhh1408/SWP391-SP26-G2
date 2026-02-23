<%-- 
    Document   : supplierList
    Created on : 2 thg 2, 2026, 12:50:33
    Author     : dotha
--%>

<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Danh sách nhà cung cấp</title>
    </head>

    <body>
        <h1>Danh sách nhà cung cấp</h1>
        <a href="admin">Quay lại Admin Dashboard</a>
        <br>

        <h3>Tìm kiếm nhà cung cấp</h3>
        <form action="supplierList">
            <table>
                <tr>
                    <td>Tên nhà cung cấp:</td>
                    <td><input type="text" name="supplierName" value="${param.supplierName}" placeholder="Tên nhà cung cấp"/></td>
                    <td>Số điện thoại:</td>
                    <td><input type="text" name="supplierPhone" value="${param.supplierPhone}"/></td>
                    <td>Địa chỉ:</td>
                    <td><input type="text" name="supplierAddress" value="${param.supplierAddress}"/></td>
                    <td>Email:</td>
                    <td><input type="text" name="supplierEmail" value="${param.supplierEmail}"/></td>
                </tr>

            </table>
            <input type="submit" value="Tìm Kiếm" />
        </form>

        <br><!-- comment -->
        <a href="addSupplier?action=add">Thêm nhà cung cấp mới</a>




        <table border="1">
            <thead>
                <tr>
                    <th>Mã nhà cung cấp</th>
                    <th>Tên nhà cung cấp</th>
                    <th>Số điện thoại</th>
                    <th>Địa chỉ</th>
                    <th>Email</th>
                    <th>Trạng thái</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${requestScope.list}" var="s">
                    <tr>
                        <td>${s.getId()}</td>
                        <td>${s.getSupplierName()}</td>
                        <td>${s.getPhone()}</td>
                        <td>${s.getAddress()}</td>
                        <td>${s.getEmail()}</td>
                        <td>
                            <c:choose>
                                <c:when test="${s.status}">
                                    Hoạt động
                                </c:when>
                                <c:otherwise>
                                    Ngừng hoạt động
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td>
                            <c:if test="${s.id != 0}">
                                <a href="addSupplier?action=edit&id=${s.id}">Sửa</a>
                            </c:if>
                        </td>
                        <td>
                            <c:if test="${s.id != 0}">
                                <a href="addSupplier?action=delete&id=${s.id}"
                                   onclick="return confirm('Bạn có chắc chắn muốn xóa nhà cung cấp?');">Xóa</a>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </body>

</html>