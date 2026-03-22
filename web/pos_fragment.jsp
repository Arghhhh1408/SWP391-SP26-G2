<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="pos-wrapper" style="display: flex; gap: 20px; align-items: flex-start;">
    <%-- Danh sách sản phẩm bên trái --%>
    <div style="flex: 2;">
        <div class="box">
            <div class="box-header"><h3>🛒 Danh mục Sản phẩm</h3></div>
            <div class="box-body">
                <table style="width:100%; border-collapse: collapse;">
                    <thead>
                        <tr style="background: #f8fafc;">
                            <th style="padding:12px; border-bottom:2px solid #e2e8f0; text-align:left;">Sản phẩm</th>
                            <th style="padding:12px; border-bottom:2px solid #e2e8f0; text-align:left;">Đơn giá</th>
                            <th style="padding:12px; border-bottom:2px solid #e2e8f0; text-align:left;">Kho</th>
                            <th style="padding:12px; border-bottom:2px solid #e2e8f0; text-align:left;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${products}" var="p">
                            <tr>
                                <td style="padding:12px; border-bottom:1px solid #eee;">
                                    <strong>${p.name}</strong><br><small style="color:#888;">SKU: ${p.sku}</small>
                                </td>
                                <td style="padding:12px; border-bottom:1px solid #eee;">
                                    <fmt:formatNumber value="${p.price}" type="number"/>đ
                                </td>
                                <td style="padding:12px; border-bottom:1px solid #eee;">${p.quantity}</td>
                                <td style="padding:12px; border-bottom:1px solid #eee;">
                                    <button class="btn" style="background:#3b82f6; color:white; border:none; padding:5px 12px; border-radius:4px; cursor:pointer;" 
                                            onclick="updateCartAjax('${p.id}', 'add')">Thêm</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <%-- Đơn hàng bên phải --%>
    <div style="flex: 1; position: sticky; top: 20px;">
        <div class="cart-box" style="background:white; border:1px solid #3b82f6; border-radius:8px; padding:20px; box-shadow:0 4px 6px rgba(0,0,0,0.1);">
            <h3 style="margin-top:0; border-bottom:2px solid #3b82f6; padding-bottom:10px;">📋 Đơn hàng</h3>

            <div id="cart-ajax-container">
                <jsp:include page="_cart_content.jsp" />
            </div>

            <div style="background: #f8fafc; padding: 15px; border-radius: 8px; margin-top:15px;">
                <form action="checkout" method="post" id="checkout-form">
                    <div style="margin-bottom:10px;">
                        <label style="font-size:12px; font-weight:bold;">Số điện thoại:</label>
                        <input type="text" name="phone" id="cusPhone" oninput="findCustomerByPhone(this.value)" placeholder="Nhập SĐT..." required style="width:100%; padding:8px; border:1px solid #ddd; border-radius:4px;">
                    </div>
                    <div style="margin-bottom:10px;">
                        <label style="font-size:12px; font-weight:bold;">Tên khách:</label>
                        <input type="text" name="customerName" id="cusName" placeholder="Tên khách..." style="width:100%; padding:8px; border:1px solid #ddd; border-radius:4px;">
                    </div>
                    <div style="margin-bottom:10px;">
                        <label style="font-size:12px; font-weight:bold;">Ghi chú:</label>
                        <textarea name="note" style="width:100%; padding:8px; height:50px; border:1px solid #ddd; border-radius:4px;"></textarea>
                    </div>
                    <div style="margin-bottom:15px; border-top:1px solid #ddd; padding-top:10px;">
                        <label style="font-size:12px; color:#ef4444; font-weight:bold;">Khách trả (đ):</label>
                        <input type="number" id="amountPaid" name="amountPaid" oninput="calculateDebt()" 
                               style="width:100%; padding:8px; border:1px solid #ef4444; font-weight:bold; outline:none; border-radius:4px;">
                    </div>
                    <div style="display:flex; justify-content:space-between; margin-bottom:15px;">
                        <span>Công nợ:</span>
                        <span id="debt-amount" style="color:#ef4444; font-weight:bold;">0 đ</span>
                    </div>
                    <button type="submit" style="width:100%; background:#3b82f6; color:white; padding:12px; border:none; border-radius:6px; font-weight:bold; cursor:pointer;">XÁC NHẬN THANH TOÁN</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    // 1. Hàm CỐT LÕI: Tự động lấy tiền từ giỏ hàng điền vào ô "Khách trả"
    function autoFillAmount() {
        // Đợi 100ms để chắc chắn Ajax đã nạp xong HTML vào giỏ hàng
        setTimeout(() => {
            const hiddenTotal = document.getElementById('hidden-total-val');
            const amountPaidInput = document.getElementById('amountPaid');

            if (hiddenTotal && amountPaidInput) {
                // Lấy giá trị tổng tiền, xóa bỏ dấu chấm, phẩy nếu có để ra số nguyên
                const rawValue = hiddenTotal.value.replace(/[^0-9]/g, '');

                if (rawValue && rawValue !== "0") {
                    amountPaidInput.value = rawValue; // Đổ số vào ô nhập
                    console.log("Đã tự động điền tiền: " + rawValue);

                    // Gọi hàm tính nợ để cập nhật dòng "Công nợ: 0 đ"
                    calculateDebt();
                }
            }
        }, 100);
    }

    // 2. Hàm Ajax khi nhấn Thêm/Cộng/Trừ
    function updateCartAjax(productId, action) {
        fetch('cart?productId=' + productId + '&action=' + action)
                .then(res => res.text())
                .then(html => {
                    document.getElementById('cart-ajax-container').innerHTML = html;
                    autoFillAmount(); // Cứ nạp giỏ hàng xong là tự điền tiền
                });
    }

    // 3. Hàm Ajax khi gõ số lượng trực tiếp vào ô Input
    function updateCartQuantityAjax(productId, qty) {
        if (qty < 1) {
            updateCartAjax(productId, 'sub');
            return;
        }

        fetch('cart?productId=' + productId + '&action=update&qty=' + qty)
                .then(res => res.text())
                .then(html => {
                    document.getElementById('cart-ajax-container').innerHTML = html;
                    autoFillAmount(); // Cập nhật lại tiền sau khi đổi số lượng
                });
    }

    // 4. Hàm tính nợ (Dùng khi khách trả thiếu và bạn tự sửa ô Khách trả)
    function calculateDebt() {
        const totalInput = document.getElementById('hidden-total-val');
        const paidInput = document.getElementById('amountPaid');

        if (totalInput && paidInput) {
            const total = parseFloat(totalInput.value.replace(/[^0-9]/g, '')) || 0;
            const paid = parseFloat(paidInput.value) || 0;
            const debt = total - paid;

            document.getElementById('debt-amount').innerText =
                    (debt > 0 ? debt : 0).toLocaleString() + " đ";
        }
    }

    // 5. Tìm khách theo SĐT
    function findCustomerByPhone(phone) {
        const input = phone.trim();
        if (input.length < 9)
            return;
        if (typeof customerList !== 'undefined') {
            const customer = customerList.find(c => c.phone === input);
            if (customer) {
                document.getElementById('cusName').value = customer.name;
                document.getElementById('cusName').style.backgroundColor = "#dcfce7";
            }
        }
    }

    // Khi vừa load trang POS, nếu giỏ có hàng sẵn thì điền luôn
    document.addEventListener("DOMContentLoaded", autoFillAmount);
</script>