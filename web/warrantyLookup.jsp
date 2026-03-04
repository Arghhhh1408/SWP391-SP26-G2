<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Warranty Lookup Tool</title>
    </head>
    <body>
        <h1>Warranty Lookup Tool</h1>

        <a href="admin">← Về trang Admin</a>
        <br><br>

        <form action="warrantyLookup" method="post">
            <fieldset>
                <legend>Tra cứu bảo hành</legend>

                <label for="lookupType">Tra cứu theo:</label>
                <select id="lookupType" name="lookupType">
                    <option value="sku" ${lookupType == 'sku' ? 'selected' : ''}>Mã SKU</option>
                    <option value="productName" ${lookupType == 'productName' ? 'selected' : ''}>Tên sản phẩm</option>
                </select>

                <br><br>

                <label for="query">Giá trị:</label>
                <input id="query" type="text" name="query" value="${query}" size="40" required />
                <input type="submit" value="Tra cứu" />

                <c:if test="${not empty error}">
                    <p style="color: red">${error}</p>
                </c:if>

                <c:if test="${not empty message}">
                    <p style="color: green">${message}</p>
                </c:if>
            </fieldset>
        </form>

        <br>

        <c:if test="${not empty products}">
            <h2>Kết quả tra cứu</h2>
            <table border="1" cellpadding="6" cellspacing="0">
                <tr>
                    <th>ProductID</th>
                    <th>Tên sản phẩm</th>
                    <th>SKU</th>
                    <th>Bảo hành (tháng)</th>
                    <th>Trạng thái</th>
                </tr>
                <c:forEach items="${products}" var="p">
                    <tr>
                        <td>${p.id}</td>
                        <td>${p.name}</td>
                        <td>${p.sku}</td>
                        <td>${p.warrantyPeriod}</td>
                        <td>${p.status}</td>
                    </tr>
                </c:forEach>
            </table>
        </c:if>
    </body>
</html>

