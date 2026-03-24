<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="box">
    <div class="box-header">
        <h3>📜 Lịch sử đơn hàng</h3>
    </div>
    <div class="box-body">
        <form action="orders" method="get" 
              style="margin-bottom: 20px; display: flex; flex-wrap: wrap; gap: 10px; align-items: center;">

            <input type="hidden" name="tab" value="orders">

            <select name="range" style="padding: 10px; border: 1px solid #ddd; border-radius: 4px; background: white;">
                <option value="all" ${range == 'all' ? 'selected' : ''}>Tất cả thời gian</option>
                <option value="today" ${range == 'today' ? 'selected' : ''}>Hôm nay</option>
                <option value="yesterday" ${range == 'yesterday' ? 'selected' : ''}>Hôm qua</option>
                <option value="7days" ${range == '7days' ? 'selected' : ''}>7 ngày qua</option>
            </select>

            <select name="sort" style="padding: 10px; border: 1px solid #ddd; border-radius: 4px; background: white;">
                <option value="new" ${sort == 'new' ? 'selected' : ''}>Mới nhất</option>
                <option value="old" ${sort == 'old' ? 'selected' : ''}>Cũ nhất</option>

                <option value="total_desc" ${sort == 'total_desc' ? 'selected' : ''}>Giá cao nhất</option>
                <option value="total_asc" ${sort == 'total_asc' ? 'selected' : ''}>Giá thấp nhất</option>
            </select>
            <input type="text" name="keyword" value="${keyword}" 
                   placeholder="Mã HĐ hoặc SĐT..." 
                   style="flex: 1; min-width: 200px; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">

            <button type="submit" class="btn" style="background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-weight: bold;">
                🔍 Lọc dữ liệu
            </button>

            <c:if test="${acc.roleID == 2}">
                <a href="exportManager?type=stockout_details&keyword=${orderSearch}&range=${range}&sort=${sort}" 
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
                        <td style="padding: 12px; border-bottom: 1px solid #eee;"><strong>#${o.stockOutId}</strong></td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">${o.date}</td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">${o.customerName != null ? o.customerName : "Khách vãng lai"}</td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">${o.customerPhone != null ? o.customerPhone : "---"}</td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">
                            <strong style="color: #10b981;"><fmt:formatNumber value="${o.totalAmount}" type="number"/> đ</strong>
                        </td>
                        <td style="padding: 12px; border-bottom: 1px solid #eee;">
                            <a href="orderdetail?id=${o.stockOutId}" style="padding: 5px 10px; background: #f1f5f9; color: #333; text-decoration: none; border-radius: 4px; font-size: 12px; border: 1px solid #ddd;">Chi tiết</a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty orders}">
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 30px; color: #999;">Không tìm thấy đơn hàng phù hợp.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>