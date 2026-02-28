
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <form method="get" action="pos">
        <input name="keyword" placeholder="Tên hoặc SKU">
        <button>Tìm</button>
    </form>

    <table border="1">
        <tr>
            <th>SKU</th>
            <th>Tên</th>
            <th>Giá</th>
            <th>Tồn</th>
            <th>Đơn vị</th>
            <th>ID</th>
            <th>Action</th>
        </tr>

        <c:forEach items="${products}" var="p">
            <tr>
                <td>${p.sku}</td>
                <td>${p.name}</td>
                <td>${p.price}</td>
                <td>${p.quantity}</td>
                <td>${p.unit}</td>
                <td>${p.id}</td>
                <td>
                    <form method="post" action="cart">
                        <input type="hidden" name="productId" value="${p.id}">
                        <input type="hidden" name="keyword" value="${param.keyword}">
                        <button type="submit">Thêm</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
    </table>

    <h3>Giỏ hàng</h3>
    <c:set var="cart" value="${sessionScope.cart}" />

    <c:if test="${empty cart}">
        <p>Chưa có sản phẩm.</p>
    </c:if>

    <c:if test="${not empty cart}">
        <table border="1">
            <tr>
                <th>SKU</th>
                <th>Tên</th>
                <th>Giá</th>
                <th>SL</th>
                <th>Thành tiền</th>
            </tr>

            <c:set var="grandTotal" value="0" />
            <c:forEach items="${cart.values()}" var="it">
                <tr>
                    <td>${it.sku}</td>
                    <td>${it.name}</td>
                    <td>${it.price}</td>
                    <td>${it.qty}</td>
                    <td>${it.lineTotal}</td>
                    <td><button type="delete">Xóa</button>
</td>
                </tr>
                <c:set var="grandTotal" value="${grandTotal + it.lineTotal}" />
            </c:forEach>

            <tr>
                <td colspan="4"><b>Tổng</b></td>
                <td><b>${grandTotal}</b></td>
            </tr>
        </table>
                <form method="post" action="${pageContext.request.contextPath}/checkout">
                    <input type="hidden" name="customerId" value="1" /> <%-- tạm, sau nối customer --%>
                    <input type="hidden" name="note" value="" />
                    <button type="submit">Thanh toán</button>
                </form>
                    

    </c:if>
            <div class="no-print">
        <a href="${pageContext.request.contextPath}/orderdetail">Xem lịch sử đơn hàng</a>
    </div>

