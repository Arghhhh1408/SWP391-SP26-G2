<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="box">
    <div class="box-header">
        <h3>👥 Danh sách khách hàng</h3>
    </div>
    <div class="box-body">
        <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
            <thead>
                <tr style="background: #f8fafc; text-align: left;">
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Mã KH</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Tên khách hàng</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Số điện thoại</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Địa chỉ</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Công nợ</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${customerList}" var="c">
                    <tr>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">#${c.customerId}</td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;"><strong>${c.name}</strong></td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">${c.phone}</td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">${c.address}</td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee; color: ${c.debt > 0 ? '#ef4444' : '#22c55e'}; font-weight: bold;">
                            <fmt:formatNumber value="${c.debt}" type="number"/> đ
                        </td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">
                            <a href="customer_detail?id=${c.customerId}" class="btn" 
                               style="background:#8b5cf6; color:white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-size:12px; display: inline-block;">
                                📜 Lịch sử
                            </a>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty customerList}">
                    <tr>
                        <td colspan="6" style="padding: 30px; text-align: center; color: #94a3b8;">
                            Chưa có dữ liệu khách hàng.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>