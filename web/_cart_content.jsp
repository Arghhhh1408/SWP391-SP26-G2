<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<c:set var="total" value="0" />
<div id="cart-list" style="max-height: 250px; overflow-y: auto;">
    <c:forEach items="${sessionScope.cart}" var="entry">
        <c:set var="item" value="${entry.value}" />
        <c:set var="total" value="${total + item.lineTotal}" />
        <div style="display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-bottom:1px solid #f1f5f9;">
            <div style="flex:1;">
                <div style="font-weight:bold; font-size:13px;" class="item-name">${item.name}</div>
                <div style="font-size:11px; color:#64748b;">${item.price}đ</div>
            </div>
            <div style="display:flex; align-items:center; gap:5px;">
                <button type="button" onclick="updateCartAjax('${item.productId}', 'sub')" style="width:22px; cursor:pointer;">-</button>
                <span style="min-width:20px; text-align:center; font-size:13px;">${item.qty}</span>
                <button type="button" onclick="updateCartAjax('${item.productId}', 'add')" style="width:22px; cursor:pointer;">+</button>
            </div>
            <div style="width:70px; text-align:right; font-weight:bold; font-size:13px;">
                <fmt:formatNumber value="${item.lineTotal}" type="number"/>đ
            </div>
        </div>
    </c:forEach>
</div>

<div style="display:none;" id="hidden-total-val" data-total="${total}"></div>

<c:if test="${empty sessionScope.cart}">
    <p style="text-align:center; color:#999; padding:20px;">Giỏ hàng trống</p>
</c:if>

<script>
    if(window.updateAmountsAfterAjax) window.updateAmountsAfterAjax();
</script>