<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<c:choose>

    <c:when test="${empty orders}">
        Chưa có đơn hàng nào.
    </c:when>

    <c:otherwise>
        <form method="get" action="${pageContext.request.contextPath}/orders" style="margin:10px 0;">
            <label>Lọc:</label>
                <select name="range">
                    <option value="all"   ${param.range == 'all'   ? 'selected' : ''}>Tất cả</option>
                    <option value="day"   ${param.range == 'day'   ? 'selected' : ''}>Hôm nay</option>
                    <option value="week"  ${param.range == 'week'  ? 'selected' : ''}>Tuần này</option>
                    <option value="month" ${param.range == 'month' ? 'selected' : ''}>Tháng này</option>
                </select>

            <label>Sắp xếp:</label>
                <select name="sort">
                <option value="new" ${sort == 'new' ? 'selected' : ''}>Mới nhất</option>
                <option value="old" ${sort == 'old' ? 'selected' : ''}>Cũ nhất</option>
              </select>

            <button type="submit">Áp dụng</button>
        </form>
              <div>
                  <a href="${pageContext.request.contextPath}/pos">Quay Lại</a>
              </div>
        <table border="1" cellpadding="8">
            <tr>
                <th>Mã đơn</th>
                <th>Thời gian</th>
                <th>Khách hàng</th>
                <th>SĐT</th>
                <th>Tổng tiền</th>
                <th>Sale</th>
                <th>Ghi chú</th>
            </tr>

            <c:forEach items="${orders}" var="o">
                <tr>
                    <td>${o.stockOutId}</td>
                    <td>${o.date}</td>
                    <td>${o.customerName}</td>
                    <td>${o.customerPhone}</td>
                    <td>${o.totalAmount}</td>
                    <td>${o.createdByName}</td>
                    <td>${o.note}</td>
                </tr>
            </c:forEach>

        </table>

    </c:otherwise>

</c:choose>
