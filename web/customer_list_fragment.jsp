<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c" %>

<div class="box">
    <div class="box-header">
        <h3>👥 Danh sách khách hàng</h3>
    </div>
    <div class="box-body">
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="background: #f8fafc;">
                    <th>Mã KH</th>
                    <th>Tên khách hàng</th>
                    <th>Số điện thoại</th>
                    <th>Địa chỉ</th>
                    <th>Công nợ</th>
                    <th>Chi tiết</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${customerList}" var="c">
                    <tr>
                        <td>#${c.customerId}</td>
                        <td><strong>${c.name}</strong></td>
                        <td>${c.phone}</td>
                        <td>${c.address}</td>
                        <td style="color: ${c.debt > 0 ? 'red' : 'black'}; font-weight: bold;">
                <fmt:formatNumber value="${c.debt}" type="number"/> đ
                </td>
                <td>
                    <a href="customer_detail?id=${c.customerId}" class="btn" style="background:#8b5cf6; color:white; font-size:12px;">
                         Lịch sử
                    </a>
                </td>
                </tr>
            </c:forEach>
            <c:if test="${empty customerList}">
                <tr><td colspan="5" align="center">Chưa có dữ liệu khách hàng.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>