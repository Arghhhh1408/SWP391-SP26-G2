<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<c:set var="totalPrice" value="0" />

<div id="cart-list" style="max-height: 300px; overflow-y: auto; padding-right: 5px;">
    <c:forEach items="${sessionScope.cart}" var="entry">
        <c:set var="item" value="${entry.value}" />
        <c:set var="totalPrice" value="${totalPrice + (item.price * item.qty)}" />

        <div style="display:flex; justify-content:space-between; align-items:center; padding:10px 0; border-bottom:1px solid #f1f5f9;">
            <div style="flex:1;">
                <div style="font-weight:600; font-size:13px; color:#1e293b;">${item.name}</div>
                <div style="font-size:11px; color:#64748b;">
                    <fmt:formatNumber value="${item.price}" type="number"/>đ 
                </div>
            </div>

            <div style="display:flex; align-items:center; gap:5px; margin: 0 10px;">
                <button type="button" onclick="updateCartAjax('${item.productId}', 'sub')" 
                        style="width:24px; height:24px; border:1px solid #ddd; background:white; cursor:pointer; border-radius:4px;">-</button>

                <input type="number" 
                       value="${item.qty}" 
                       onchange="updateQuantityWithCheck(this, '${item.productId}', ${item.stockQuantity})"
                       style="width: 40px; text-align: center; border: 1px solid #ddd; border-radius: 4px; padding: 2px 0; font-weight: bold;">

                <button type="button" onclick="updateCartAjax('${item.productId}', 'add', ${item.stockQuantity})" 
                        style="width:24px; height:24px; border:1px solid #ddd; background:white; cursor:pointer; border-radius:4px;">+</button>
            </div>

            <div style="width:85px; text-align:right; font-weight:bold; font-size:13px; color:#3b82f6;">
                <fmt:formatNumber value="${item.price * item.qty}" type="number"/>đ
            </div>
        </div>
    </c:forEach>
</div>

<div style="margin-top:15px; border-top:2px solid #f1f5f9; padding-top:10px;">
    <c:if test="${not empty error}">
        <div style="color: #ef4444; font-size: 11px; margin-bottom: 8px; font-weight: bold; background: #fee2e2; padding: 5px; border-radius: 4px;">
            ⚠️ ${error}
        </div>
    </c:if>

    <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold; color:#64748b;">Tổng cộng:</span>
        <span style="font-size:18px; font-weight:800; color:#1e293b;" id="display-total-text">
            <fmt:formatNumber value="${totalPrice}" type="number"/>đ
        </span>
    </div>

    <div style="margin-top: 10px; border-top: 1px dashed #eee; padding-top: 10px;">
        <div id="row-debt" style="display: flex; justify-content: space-between; align-items: center;">
            <span style="font-weight: 600; color: #64748b;">Công nợ:</span>
            <span id="debt-display" style="font-size: 16px; font-weight: 800; color: #ef4444;">0 đ</span>
        </div>

        <div id="row-change" style="display: none; justify-content: space-between; align-items: center;">
            <span style="font-weight: 600; color: #64748b;">Tiền thừa:</span>
            <span id="change-display" style="font-size: 16px; font-weight: 800; color: #10b981;">0 đ</span>
        </div>
    </div>
</div>

<c:if test="${empty sessionScope.cart}">
    <p style="text-align:center; color:#94a3b8; padding:20px;">Giỏ hàng trống</p>
</c:if>

<input type="hidden" id="hidden-total-val" value="${totalPrice}">

<script>
    // Tự động gọi hàm tính nợ khi giỏ hàng được cập nhật
    if (typeof calculateDebt === "function") {
        calculateDebt();
    }

    function updateQuantityWithCheck(inputElement, productId, stockLimit) {
        let newQty = parseInt(inputElement.value);

        if (newQty > stockLimit) {
            alert("⚠️ Lỗi: Trong kho chỉ còn " + stockLimit + " sản phẩm!");
            inputElement.value = stockLimit;
            newQty = stockLimit;
        }

        if (newQty <= 0 || isNaN(newQty)) {
            inputElement.value = 1;
            newQty = 1;
        }

        // Gửi lệnh update về server
        updateCartAjax(productId, 'update&quantity=' + newQty);
    }
</script>