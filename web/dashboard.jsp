<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Bảng điều khiển &amp; báo cáo</title>
    </head>
    <body>
        <h1>Bảng điều khiển &amp; báo cáo doanh nghiệp</h1>
        <a href="admin">← Về trang Admin</a>

        <br><br>

        <fieldset>
            <legend>Tổng quan (KPIs)</legend>
            <table border="1" cellpadding="6" cellspacing="0">
                <tr>
                    <th align="left">Sản phẩm (tổng / active)</th>
                    <td>${totalProducts} / ${activeProducts}</td>
                </tr>
                <tr>
                    <th align="left">Sản phẩm sắp hết hàng (Stock &lt; 5)</th>
                    <td>${lowStockProducts}</td>
                </tr>
                <tr>
                    <th align="left">Giá trị tồn kho (theo cost)</th>
                    <td><fmt:formatNumber value="${inventoryValueCost}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                </tr>
                <tr>
                    <th align="left">Giá trị tồn kho (theo price)</th>
                    <td><fmt:formatNumber value="${inventoryValuePrice}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                </tr>
                <tr>
                    <th align="left">Đơn bán hôm nay / Doanh thu hôm nay</th>
                    <td>${ordersToday} / <fmt:formatNumber value="${revenueToday}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                </tr>
                <tr>
                    <th align="left">Doanh thu tháng này</th>
                    <td><fmt:formatNumber value="${revenueThisMonth}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                </tr>
                <tr>
                    <th align="left">Nhập hàng tháng này (StockIn)</th>
                    <td><fmt:formatNumber value="${stockInThisMonth}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                </tr>
                <tr>
                    <th align="left">Hoàn tiền tháng này</th>
                    <td><fmt:formatNumber value="${refundedThisMonth}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                </tr>
            </table>
            <p>
                Ghi chú: đây là khung báo cáo; nếu bảng dữ liệu (StockOut/StockIn/ReturnRequests/WarrantyClaims) chưa có,
                các chỉ số có thể trống hoặc 0.
            </p>
        </fieldset>

        <br>

        <fieldset>
            <legend>Doanh thu 7 ngày gần nhất</legend>
            <table border="1" cellpadding="6" cellspacing="0">
                <tr>
                    <th>Ngày</th>
                    <th>Số đơn</th>
                    <th>Doanh thu</th>
                </tr>
                <c:forEach items="${sales7d}" var="d">
                    <tr>
                        <td>${d.day}</td>
                        <td>${d.orders}</td>
                        <td><fmt:formatNumber value="${d.revenue}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                    </tr>
                </c:forEach>
                <c:if test="${empty sales7d}">
                    <tr><td colspan="3">Chưa có dữ liệu.</td></tr>
                </c:if>
            </table>
        </fieldset>

        <br>

        <fieldset>
            <legend>Top sản phẩm bán chạy (30 ngày)</legend>
            <table border="1" cellpadding="6" cellspacing="0">
                <tr>
                    <th>ProductID</th>
                    <th>SKU</th>
                    <th>Tên</th>
                    <th>Số lượng bán</th>
                    <th>Doanh thu</th>
                </tr>
                <c:forEach items="${top30d}" var="t">
                    <tr>
                        <td>${t.productId}</td>
                        <td>${t.sku}</td>
                        <td>${t.name}</td>
                        <td>${t.quantity}</td>
                        <td><fmt:formatNumber value="${t.revenue}" type="number" groupingUsed="true" maxFractionDigits="0"/></td>
                    </tr>
                </c:forEach>
                <c:if test="${empty top30d}">
                    <tr><td colspan="5">Chưa có dữ liệu.</td></tr>
                </c:if>
            </table>
        </fieldset>

        <br>

        <fieldset>
            <legend>Yêu cầu bảo hành theo trạng thái</legend>
            <table border="1" cellpadding="6" cellspacing="0">
                <tr>
                    <th>Status</th>
                    <th>Count</th>
                </tr>
                <c:forEach items="${claimStatusCounts}" var="s">
                    <tr>
                        <td>${s.status}</td>
                        <td>${s.count}</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty claimStatusCounts}">
                    <tr><td colspan="2">Chưa có dữ liệu.</td></tr>
                </c:if>
            </table>
        </fieldset>

        <br>

        <fieldset>
            <legend>Trả hàng / hoàn tiền theo trạng thái</legend>
            <table border="1" cellpadding="6" cellspacing="0">
                <tr>
                    <th>Status</th>
                    <th>Count</th>
                </tr>
                <c:forEach items="${returnStatusCounts}" var="s">
                    <tr>
                        <td>${s.status}</td>
                        <td>${s.count}</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty returnStatusCounts}">
                    <tr><td colspan="2">Chưa có dữ liệu.</td></tr>
                </c:if>
            </table>
        </fieldset>
    </body>
</html>

