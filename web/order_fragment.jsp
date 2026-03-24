
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="box">
    <div class="box-header">
        <h3>📜 Lịch sử đơn hàng</h3>
    </div>
    <div class="box-body">
        <form action="orders" method="get" style="background: #ffffff; padding: 20px; border-radius: 12px; margin-bottom: 25px; border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
            <div style="display: grid; grid-template-columns: 2fr 1.2fr 1.2fr 1fr; gap: 15px; align-items: end;">

                <div>
                    <label style="display:block; font-size: 11px; font-weight: 800; color: #64748b; margin-bottom: 8px; text-transform: uppercase;">Tìm kiếm đơn hàng</label>
                    <input type="text" name="keyword" value="${keyword}" 
                           placeholder="Mã đơn, SĐT khách..." 
                           style="width: 100%; padding: 11px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;">
                </div>

                <div>
                    <label style="display:block; font-size: 11px; font-weight: 800; color: #64748b; margin-bottom: 8px; text-transform: uppercase;">Thời gian</label>
                    <select name="range" style="width: 100%; padding: 11px; border: 1px solid #cbd5e1; border-radius: 8px; background: white; font-size: 14px;">
                        <option value="all" ${range == 'all' ? 'selected' : ''}>Tất cả thời gian</option>
                        <option value="today" ${range == 'today' ? 'selected' : ''}>Hôm nay</option>
                        <option value="yesterday" ${range == 'yesterday' ? 'selected' : ''}>Hôm qua</option>
                        <option value="this_week" ${range == 'this_week' ? 'selected' : ''}>Tuần này</option>
                        <option value="this_month" ${range == 'this_month' ? 'selected' : ''}>Tháng này</option>
                    </select>
                </div>

                <div>
                    <label style="display:block; font-size: 11px; font-weight: 800; color: #64748b; margin-bottom: 8px; text-transform: uppercase;">Sắp xếp</label>
                    <select name="sort" style="width: 100%; padding: 11px; border: 1px solid #cbd5e1; border-radius: 8px; background: white; font-size: 14px;">
                        <option value="new" ${sort == 'new' ? 'selected' : ''}>Mới nhất trước</option>
                        <option value="old" ${sort == 'old' ? 'selected' : ''}>Cũ nhất trước</option>
                        <option value="total_desc" ${sort == 'total_desc' ? 'selected' : ''}>Giá trị giảm dần</option>
                    </select>
                </div>

                <div style="display: flex; gap: 8px;">
                    <button type="submit" style="flex: 1; background: #3b82f6; color: white; border: none; padding: 11px; border-radius: 8px; cursor: pointer; font-weight: 700; transition: 0.2s;">
                        Lọc
                    </button>
                    <a href="orders" style="background: #f1f5f9; color: #475569; text-decoration: none; padding: 11px; border-radius: 8px; font-size: 13px; font-weight: 700; border: 1px solid #cbd5e1;">
                        ↻
                    </a>
                </div>
            </div>
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