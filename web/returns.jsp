<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Trả hàng &amp; hoàn tiền</title>
    </head>
    <body>
        <h1>Trả hàng &amp; hoàn tiền</h1>

        <a href="admin">← Về trang Admin</a>
        <br><br>

        <c:if test="${not empty error}">
            <p style="color: red">${error}</p>
        </c:if>

        <h2>Danh sách yêu cầu</h2>
        <table border="1" cellpadding="6" cellspacing="0">
            <tr>
                <th>ID</th>
                <th>Mã yêu cầu</th>
                <th>SKU</th>
                <th>Tên sản phẩm</th>
                <th>Khách hàng</th>
                <th>SĐT</th>
                <th>Trạng thái</th>
                <th>Cập nhật</th>
                <th>Thao tác</th>
            </tr>
            <c:forEach items="${returns}" var="r">
                <tr>
                    <td>${r.id}</td>
                    <td>${r.returnCode}</td>
                    <td>${r.sku}</td>
                    <td>${r.productName}</td>
                    <td>${r.customerName}</td>
                    <td>${r.customerPhone}</td>
                    <td>${r.status}</td>
                    <td>${r.updatedAt}</td>
                    <td><a href="return?id=${r.id}">Chi tiết</a></td>
                </tr>
            </c:forEach>
            <c:if test="${empty returns}">
                <tr>
                    <td colspan="9">Chưa có yêu cầu nào.</td>
                </tr>
            </c:if>
        </table>

        <br>

        <fieldset>
            <legend>Tạo yêu cầu mới (khung)</legend>
            <form action="returns" method="post">
                <input type="hidden" name="action" value="create" />

                <label for="sku">SKU (*):</label>
                <input id="sku" type="text" name="sku" value="${sku}" required />
                <br><br>

                <label for="productName">Tên sản phẩm (tùy chọn):</label>
                <input id="productName" type="text" name="productName" value="${productName}" size="50" />
                <br><br>

                <label for="customerName">Tên khách hàng (*):</label>
                <input id="customerName" type="text" name="customerName" value="${customerName}" required />
                <br><br>

                <label for="customerPhone">SĐT (tùy chọn):</label>
                <input id="customerPhone" type="text" name="customerPhone" value="${customerPhone}" />
                <br><br>

                <label for="reason">Lý do trả hàng (*):</label><br>
                <textarea id="reason" name="reason" rows="3" cols="80" required>${reason}</textarea>
                <br><br>

                <label for="cond">Tình trạng hàng (tùy chọn):</label><br>
                <textarea id="cond" name="conditionNote" rows="3" cols="80">${conditionNote}</textarea>
                <br><br>

                <input type="submit" value="Tạo yêu cầu" />
            </form>
        </fieldset>
    </body>
</html>

