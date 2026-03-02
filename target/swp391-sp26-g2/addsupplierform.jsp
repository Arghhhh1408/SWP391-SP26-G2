<%-- 
    Document   : addsupplierform
    Created on : 23 thg 2, 2026, 09:45:30
    Author     : dotha
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>
            <c:if test="${empty supplier}">Thêm Nhà Cung Cấp</c:if>
            <c:if test="${not empty supplier}">Sửa Nhà Cung Cấp</c:if>
            </title>
        </head>

        <body>

            <h1>
            <c:if test="${empty supplier}">Thêm Nhà Cung Cấp</c:if>
            <c:if test="${not empty supplier}">Sửa Nhà Cung Cấp</c:if>
            </h1>

            <a href="supplierList">Quay lại Danh Sách Nhà Cung Cấp</a>

            <form action="${pageContext.request.contextPath}/addSupplier" method="post">

            <input type="hidden" name="action" 
                   value="${not empty supplier ? 'updateSupplier' : 'addSupplier'}" />

            <c:if test="${not empty supplier}">
                <input type="hidden" name="supplierID" value="${supplier.id}">
            </c:if>

            <table>

                <c:choose>

                    <%-- ================= UPDATE MODE ================= --%>
                    <c:when test="${not empty supplier}">

                        <tr>
                            <td>Supplier ID:</td>
                            <td>
                                <input type="text"
                                       value="${supplier.id}"
                                       readonly
                                       style="background-color:#e9ecef;">
                                <input type="hidden"
                                       name="supplierID"
                                       value="${supplier.id}">
                            </td>

                            <td>Tên nhà cung cấp:</td>
                            <td>
                                <input type="text"
                                       name="supplierName"
                                       value="${supplier.supplierName}"
                                       required>
                            </td>
                        </tr>

                        <tr>
                            <td>Số điện thoại:</td>
                            <td>
                                <input type="text"
                                       name="phone"
                                       value="${supplier.phone}"
                                       required>
                            </td>

                            <td>Địa chỉ:</td>
                            <td>
                                <input type="text"
                                       name="address"
                                       value="${supplier.address}">
                            </td>
                        </tr>

                        <tr>
                            <td>Email:</td>
                            <td>
                                <input type="email"
                                       name="email"
                                       value="${supplier.email}"
                                       required>
                            </td>

                            <td>Trạng thái:</td>
                            <td>
                                <input type="checkbox"
                                       name="status"
                                       <c:if test="${supplier.status}">checked</c:if>>
                                       Hoạt động
                                </td>
                            </tr>

                    </c:when>

                    <%-- ================= CREATE MODE ================= --%>
                    <c:otherwise>

                        <tr>
                            <td>Tên nhà cung cấp:</td>
                            <td>
                                <input type="text"
                                       name="supplierName"
                                       value="${param.supplierName}"
                                       required>
                            </td>

                            <td>Số điện thoại:</td>
                            <td>
                                <input type="text"
                                       name="phone"
                                       value="${param.phone}"
                                       required>
                            </td>
                        </tr>

                        <tr>
                            <td>Email:</td>
                            <td>
                                <input type="email"
                                       name="email"
                                       value="${param.email}"
                                       required>
                            </td>

                            <td>Địa chỉ:</td>
                            <td>
                                <input type="text"
                                       name="address"
                                       value="${param.address}">
                            </td>
                        </tr>

                        <tr>
                            <td>Trạng thái:</td>
                            <td>
                                <input type="checkbox"
                                       name="status"
                                       <c:if test="${param.status != null}">checked</c:if>>
                                       Hoạt động
                                </td>
                            </tr>

                    </c:otherwise>

                </c:choose>

                <tr>
                    <td>
                        <input type="submit"
                               value="${not empty supplier ? 'Cập nhật' : 'Thêm nhà cung cấp'}">
                    </td>
                </tr>

            </table>

        </form>

        <!-- Thông báo -->
        <c:if test="${not empty sessionScope.message}">
            <h3 style="color: ${sessionScope.status == 'success' ? 'green' : 'red'}">
                ${sessionScope.message}
            </h3>
        </c:if>
        <c:remove var="message" scope="session"/>
        <c:remove var="status" scope="session"/>
        <h3 style="color:red">${requestScope.error}</h3>

    </body>
</html>
