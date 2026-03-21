<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="box">
    <div class="box-header">
        <h3>📦 Danh sách sản phẩm trong kho</h3>
    </div>
    <div class="box-body">
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="background: #f8fafc;">
                    <th>Hình ảnh</th>
                    <th>SKU</th>
                    <th>Tên sản phẩm</th>
                    <th>Giá bán</th>
                    <th>Tồn kho</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${salesProducts}" var="p">
                    <tr>
                        <td style="text-align: center;">
                            <c:if test="${not empty p.imageURL}">
                                <img src="${p.imageURL}" width="50" height="50" style="object-fit: cover; border-radius: 4px; border: 1px solid #eee;">
                            </c:if>
                            <c:if test="${empty p.imageURL}">
                                <span style="color: #ccc; font-size: 10px;">No image</span>
                            </c:if>
                        </td>
                        <td style="padding: 12px;"><code>${p.sku}</code></td>
                        <td style="padding: 12px;"><strong>${p.name}</strong></td>
                        <td style="padding: 12px;">
                            <fmt:formatNumber value="${p.price}" type="number"/> đ
                        </td>
                        <td style="padding: 12px; font-weight: bold; text-align: center; color: ${p.quantity < 5 ? 'red' : 'green'}">
                            ${p.quantity} </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>