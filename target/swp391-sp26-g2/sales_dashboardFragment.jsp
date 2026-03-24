<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="dashboard-grid" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 20px;">
    <div class="stat-card card-blue" style="background: white; padding: 20px; border-radius: 8px; border-left: 5px solid #3b82f6; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
        <div class="stat-label" style="color: #64748b; font-size: 14px; font-weight: bold; text-transform: uppercase;">Doanh thu ngày</div>
        <div class="stat-value" style="font-size: 24px; font-weight: 800; margin-top: 10px;">
            <fmt:formatNumber value="${revenueToday}" type="number"/> đ
        </div>
    </div>
    <div class="stat-card card-green" style="background: white; padding: 20px; border-radius: 8px; border-left: 5px solid #10b981; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
        <div class="stat-label" style="color: #64748b; font-size: 14px; font-weight: bold; text-transform: uppercase;">Doanh thu tuần</div>
        <div class="stat-value" style="font-size: 24px; font-weight: 800; margin-top: 10px;">
            <fmt:formatNumber value="${revenueWeek}" type="number"/> đ
        </div>
    </div>
    <div class="stat-card card-purple" style="background: white; padding: 20px; border-radius: 8px; border-left: 5px solid #8b5cf6; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
        <div class="stat-label" style="color: #64748b; font-size: 14px; font-weight: bold; text-transform: uppercase;">Doanh thu tháng</div>
        <div class="stat-value" style="font-size: 24px; font-weight: 800; margin-top: 10px;">
            <fmt:formatNumber value="${revenueMonth}" type="number"/> đ
        </div>
    </div>
</div>

<div class="box" style="background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <div class="box-header" style="color:red; font-weight:bold; margin-bottom: 15px; border-bottom: 1px solid #eee; padding-bottom: 10px;">
        ⚠️ CẢNH BÁO TỒN KHO THẤP
    </div>
    <div class="box-body">
        <c:choose>
            <%-- Nếu danh sách sản phẩm sắp hết không trống --%>
            <c:when test="${not empty lowStockProducts}">
                <c:forEach items="${lowStockProducts}" var="lp">
                    <div style="display:flex; justify-content:space-between; padding:10px 0; border-bottom:1px solid #f1f5f9;">
                        <span style="font-weight: 500;">${lp.name}</span>
                        <span style="color:red; font-weight: bold;">Chỉ còn ${lp.quantity} ${lp.unit}</span>
                    </div>
                </c:forEach>
            </c:when>
            <%-- Nếu kho hàng ổn định --%>
            <c:otherwise>
                <p style="color:green; font-weight: 500; margin: 0;">✔ Kho hàng ổn định. Không có sản phẩm nào sắp hết.</p>
            </c:otherwise>
        </c:choose>
    </div>
</div>