<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c"%>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Products (CRUD)</title>
    </head>
    <body>
        <h1>Danh sách sản phẩm</h1>

        <a href="admin">← Về trang Admin</a>
        <br><br>

        <a href="addProduct">+ Thêm sản phẩm</a>
        <br><br>

        <c:if test="${not empty error}">
            <p style="color: red">${error}</p>
        </c:if>

        <table border="1" cellpadding="6" cellspacing="0">
            <tr>
                <th>ID</th>
                <th>Tên</th>
                <th>SKU</th>
                <th>Cost</th>
                <th>Price</th>
                <th>Quantity</th>
                <th>Unit</th>
                <th>Warranty (months)</th>
                <th>Status</th>
                <th>CategoryID</th>
                <th>Actions</th>
            </tr>
            <c:forEach items="${products}" var="p">
                <tr>
                    <td>${p.id}</td>
                    <td>${p.name}</td>
                    <td>${p.sku}</td>
                    <td><fmt:formatNumber value="${p.cost}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                    <td><fmt:formatNumber value="${p.price}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                    <td>${p.quantity}</td>
                    <td>${p.unit}</td>
                    <td>${p.warrantyPeriod}</td>
                    <td>${p.status}</td>
                    <td>${p.categoryId}</td>
                    <td>
                        <a href="editProduct?id=${p.id}">Edit</a> |
                        <a href="deleteProduct?id=${p.id}" onclick="return confirm('Delete product?');">Delete</a>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty products}">
                <tr>
                    <td colspan="11">Chưa có sản phẩm nào.</td>
                </tr>
            </c:if>
        </table>
    </body>
</html>

