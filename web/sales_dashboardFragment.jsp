<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="dashboard-grid">
    <div class="stat-card card-blue">
        <div class="stat-label">Doanh thu ngày</div>
        <div class="stat-value"><fmt:formatNumber value="${revenueToday}" type="number"/> đ</div>
    </div>
    <div class="stat-card card-green">
        <div class="stat-label">Doanh thu tuần</div>
        <div class="stat-value"><fmt:formatNumber value="${revenueWeek}" type="number"/> đ</div>
    </div>
    <div class="stat-card card-purple">
        <div class="stat-label">Doanh thu tháng</div>
        <div class="stat-value"><fmt:formatNumber value="${revenueMonth}" type="number"/> đ</div>
    </div>
</div>

<div class="box">
    <div class="box-header" style="color:red; font-weight:bold;">⚠️ CẢNH BÁO TỒN KHO THẤP</div>
    <div class="box-body">
        <c:choose>
            <c:when test="${not empty lowStockProducts}">
                <c:forEach items="${lowStockProducts}" var="lp">
                    <div style="display:flex; justify-content:space-between; padding:8px 0; border-bottom:1px solid #eee;">
                        <span>${lp.name}</span>
                        <span style="color:red;">Còn ${lp.quantity} ${lp.unit}</span>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise><p style="color:green;">✔ Kho hàng ổn định.</p></c:otherwise>
        </c:choose>
    </div>
</div>