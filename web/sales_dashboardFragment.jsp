<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="dashboard-grid" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 25px;">
    <div class="stat-card" style="background: white; padding: 20px; border-radius: 12px; border-left: 5px solid #3b82f6; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
        <div style="color: #64748b; font-size: 12px; font-weight: bold; text-transform: uppercase;">Doanh thu ngày</div>
        <div style="font-size: 24px; font-weight: 800; margin-top: 10px; color: #1e293b;">
            <fmt:formatNumber value="${revenueToday}" type="number"/> đ
        </div>
    </div>
    <div class="stat-card" style="background: white; padding: 20px; border-radius: 12px; border-left: 5px solid #10b981; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
        <div style="color: #64748b; font-size: 12px; font-weight: bold; text-transform: uppercase;">Doanh thu tuần</div>
        <div style="font-size: 24px; font-weight: 800; margin-top: 10px; color: #10b981;">
            <fmt:formatNumber value="${revenueWeek}" type="number"/> đ
        </div>
    </div>
    <div class="stat-card" style="background: white; padding: 20px; border-radius: 12px; border-left: 5px solid #8b5cf6; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
        <div style="color: #64748b; font-size: 12px; font-weight: bold; text-transform: uppercase;">Doanh thu tháng</div>
        <div style="font-size: 24px; font-weight: 800; margin-top: 10px; color: #8b5cf6;">
            <fmt:formatNumber value="${revenueMonth}" type="number"/> đ
        </div>
    </div>
</div>

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
    <div class="box" style="background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
        <div style="color:#ef4444; font-weight:bold; margin-bottom: 20px; border-bottom: 2px solid #f8fafc; padding-bottom: 15px; display: flex; align-items: center; gap: 10px;">
            <span style="font-size: 18px;">⚠️</span> TỒN KHO THẤP
        </div>
        <div style="max-height: 350px; overflow-y: auto;">
            <c:choose>
                <c:when test="${not empty lowStockProducts}">
                    <c:forEach items="${lowStockProducts}" var="lp">
                        <div style="display:flex; justify-content:space-between; padding:12px 0; border-bottom:1px solid #f1f5f9;">
                            <span style="font-weight: 500; color: #334155;">${lp.name}</span>
                            <span style="color:#ef4444; font-weight: bold;">Còn ${lp.quantity}</span>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p style="color:#10b981; text-align: center; padding: 20px;">✔ Kho hàng ổn định.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="box" style="background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
        <div style="color:#3b82f6; font-weight:bold; margin-bottom: 20px; border-bottom: 2px solid #f8fafc; padding-bottom: 15px; display: flex; align-items: center; gap: 10px;">
            <span style="font-size: 18px;">🔥</span> BÁN CHẠY NHẤT THÁNG
        </div>
        <div style="max-height: 350px; overflow-y: auto;">
            <c:choose>
                <c:when test="${not empty topSellingProducts}">
                    <c:forEach items="${topSellingProducts}" var="tp" varStatus="status">
                        <div style="display:flex; align-items: center; gap: 12px; padding: 12px 0; border-bottom: 1px solid #f8fafc;">
                            <div style="width: 24px; height: 24px; background: #eff6ff; color: #3b82f6; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: bold;">
                                ${status.count}
                            </div>

                            <div style="flex: 1;">
                                <div style="font-weight: 600; font-size: 14px; color: #1e293b;">${tp.name}</div>
                                <div style="font-size: 12px; color: #94a3b8;">Số lượng: ${tp.quantity} | SKU: ${tp.sku}</div>
                            </div>

                            <div style="font-weight: bold; color: #64748b; font-size: 13px;">
                                <fmt:formatNumber value="${tp.revenue}" type="number"/> đ
                            </div>
                        </div>
                    </c:forEach>                </c:when>
                <c:otherwise>
                    <p style="text-align: center; color: #94a3b8; padding: 20px;">Chưa có dữ liệu tháng này.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>