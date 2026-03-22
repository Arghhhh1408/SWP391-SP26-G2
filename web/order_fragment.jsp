
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="box">
    <div class="box-header">
        <h3>📜 Lịch sử đơn hàng</h3>
    </div>
    <div class="box-body">
        <form action="${currentPage == 'manager_dashboard' ? 'manager_dashboard' : 'sales_dashboard'}" method="get" style="margin-bottom: 20px; display: flex; gap: 10px;">
            <input type="hidden" name="tab" value="orders">
            <input type="text" name="orderSearch" value="${orderSearch}" 
                   placeholder="Nhập mã hóa đơn hoặc SĐT..." 
                   style="flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
            <button type="submit" class="btn" style="background: #3b82f6; color: white; border: none; padding: 0 20px; border-radius: 4px; cursor: pointer;">
                Tìm kiếm
            </button>
            <c:if test="${acc.roleID == 2}">
                <a href="exportManager?type=stockout_details&keyword=${orderSearch}" 
                   class="btn" 
                   style="background: #10b981; color: white; text-decoration: none; padding: 10px 20px; border-radius: 4px; font-weight: bold; display: flex; align-items: center; gap: 5px;">
                    <span>📥</span> Xuất Excel
                </a>
            </c:if>
        </form>

        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="background: #f8fafc;">
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0; text-align: left;">Mã HĐ</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0; text-align: left;">Ngày tạo</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0; text-align: left;">Khách hàng</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0; text-align: left;">Số điện thoại</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0; text-align: left;">Tổng tiền</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0; text-align: left;">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${orders}" var="o">
                    <tr>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">
                            <strong>#${o.stockOutId}</strong> </td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">
                            ${o.date} </td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">
                            ${o.customerName != null ? o.customerName : "Khách vãng lai"}
                        </td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">
                            ${o.customerPhone != null ? o.customerPhone : "---"} </td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">
                            <strong style="color: #10b981;">
                                <fmt:formatNumber value="${o.totalAmount}" type="number"/> đ
                            </strong>
                        </td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">
                            <a href="orderdetail?id=${o.stockOutId}" 
                               style="padding: 5px 10px; background: #f1f5f9; color: #333; text-decoration: none; border-radius: 4px; font-size: 12px; border: 1px solid #ddd;">
                                Chi tiết
                            </a>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty orders}">
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 30px; color: #999;">
                            Chưa có đơn hàng nào được thực hiện. (Debug: ${orders.size()} đơn)
                        </td>
                    </tr>
                </c:if>
            </tbody>        </table>
    </div>
</div>