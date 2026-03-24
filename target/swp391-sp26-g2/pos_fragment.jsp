<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<style>
    /* 1. Giao diện nền Modal */
    #invoiceModal {
        display: none;
        position: fixed;
        z-index: 10000;
        left: 0; top: 0;
        width: 100%; height: 100%;
        background: rgba(0,0,0,0.6);
        backdrop-filter: blur(3px);
    }

    /* 2. Khung trắng hóa đơn */
    .modal-content {
        background: white;
        margin: 2% auto;
        padding: 0;
        width: 450px;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.2);
        position: relative;
    }

    /* 3. Thân hóa đơn */
    .invoice-card {
        padding: 30px;
        font-family: 'Courier New', Courier, monospace;
        color: #000;
        line-height: 1.4;
        background: white;
    }

    .invoice-header { text-align: center; margin-bottom: 20px; border-bottom: 1px dashed #ddd; padding-bottom: 10px; }
    .invoice-header h2 { margin: 5px 0; font-size: 22px; }

    .invoice-table { width: 100%; border-collapse: collapse; margin: 15px 0; }
    .invoice-table th { border-bottom: 1px solid #000; padding: 8px 0; text-align: left; }
    .invoice-table td { padding: 8px 0; vertical-align: top; border-bottom: 1px solid #f5f5f5; font-size: 14px; }

    .total-section { margin-top: 15px; border-top: 2px solid #000; padding-top: 10px; }
    .total-row { display: flex; justify-content: space-between; margin-bottom: 8px; font-weight: bold; font-size: 16px; }

    .modal-footer { display: flex; gap: 10px; padding: 15px 30px 25px; background: #f8fafc; border-bottom-left-radius: 12px; border-bottom-right-radius: 12px; }

    /* FIX LỖI IN TRANG TRẮNG */
    @media print {
        body * { visibility: hidden !important; }
        #invoice-print-area, #invoice-print-area * { visibility: visible !important; }
        #invoice-print-area { 
            position: absolute; 
            left: 0; top: 0; 
            width: 100%; 
            margin: 0; padding: 0;
            background: white;
        }
        .no-print { display: none !important; }
    }
</style>

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

<div id="invoiceModal">
    <div class="modal-content">
        <span onclick="closeModal()" class="no-print" style="position:absolute; right:15px; top:10px; font-size:28px; cursor:pointer; color:#999;">&times;</span>

        <div class="invoice-card" id="invoice-print-area">
            <div class="invoice-header">
                <h2>HÓA ĐƠN BÁN LẺ</h2>
                <p style="margin:0; font-size:13px;">Ngày: <span id="display-date"></span></p>
            </div>

            <div class="invoice-info" style="font-size: 14px;">
                <p><strong>Khách hàng:</strong> <span id="display-cusName"></span></p>
                <p><strong>Số ĐT:</strong> <span id="display-cusPhone"></span></p>
                <p id="display-note-wrapper"><strong>Ghi chú:</strong> <span id="display-note"></span></p>
            </div>

            <table class="invoice-table">
                <thead>
                    <tr>
                        <th style="width:55%">Sản phẩm</th>
                        <th style="text-align:center">SL</th>
                        <th style="text-align:right">T.Tiền</th>
                    </tr>
                </thead>
                <tbody id="invoice-items-list">
                    </tbody>
            </table>

            <div class="total-section">
                <div class="total-row">
                    <span>Tổng cộng:</span>
                    <span id="display-totalPrice">0 đ</span>
                </div>
                <div class="total-row">
                    <span>Khách trả:</span>
                    <span id="display-amountPaid">0 đ</span>
                </div>
                <div class="total-row">
                    <span style="color: #ef4444;">Công nợ:</span>
                    <span id="display-debt" style="color: #ef4444;">0 đ</span>
                </div>
            </div>
            <p style="text-align: center; margin-top: 25px; font-style: italic; font-size: 12px;">Cảm ơn quý khách!</p>
        </div>

        <div class="modal-footer no-print">
            <button onclick="window.print()" style="flex:1; background:#10b981; color:white; border:none; padding:12px; border-radius:6px; font-weight:bold; cursor:pointer;">🖨️ IN HÓA ĐƠN</button>
            <button onclick="submitFinalOrder()" style="flex:1; background:#3b82f6; color:white; border:none; padding:12px; border-radius:6px; font-weight:bold; cursor:pointer;">✅ HOÀN TẤT & LƯU</button>
        </div>
    </div>
</div>

<script>
    // 1. Chặn submit để hiện Modal
    document.getElementById('checkout-form').addEventListener('submit', function (e) {
        e.preventDefault();
        showInvoiceModal();
    });

    function showInvoiceModal() {
        try {
            // LẤY DỮ LIỆU & FIX LỖI SỐ THẬP PHÂN (.0)
            const cusName = document.getElementById('cusName').value || "Khách lẻ";
            const cusPhone = document.getElementById('cusPhone').value || "Chưa có";
            const note = document.getElementsByName('note')[0].value;
            
            // Ép kiểu số nguyên để không bị lỗi hiển thị .0
            const totalRaw = document.getElementById('hidden-total-val').value;
            const totalVal = parseInt(totalRaw) || 0;
            
            const paidRaw = document.getElementById('amountPaid').value || "0";
            const paidVal = parseInt(paidRaw) || 0;
            
            const debtVal = totalVal - paidVal;
            const displayDebt = debtVal > 0 ? debtVal : 0;

            // Đổ vào Modal
            document.getElementById('display-cusName').innerText = cusName;
            document.getElementById('display-cusPhone').innerText = cusPhone;
            document.getElementById('display-totalPrice').innerText = totalVal.toLocaleString('vi-VN') + " đ";
            document.getElementById('display-amountPaid').innerText = paidVal.toLocaleString('vi-VN') + " đ";
            document.getElementById('display-debt').innerText = displayDebt.toLocaleString('vi-VN') + " đ";
            document.getElementById('display-date').innerText = new Date().toLocaleString('vi-VN');

            // Xử lý Ghi chú
            const noteWrapper = document.getElementById('display-note-wrapper');
            if (note && note.trim() !== "") {
                noteWrapper.style.display = 'block';
                document.getElementById('display-note').innerText = note;
            } else {
                noteWrapper.style.display = 'none';
            }

            // QUÉT SẢN PHẨM TỪ CẤU TRÚC DIV CỦA BẠN (QUAN TRỌNG)
            const cartItems = document.querySelectorAll('#cart-list > div');
            let htmlItems = '';

            cartItems.forEach((item) => {
                const name = item.querySelector('div:first-child div:first-child').innerText.trim();
                const qty = item.querySelector('input[type="number"]').value;
                const priceText = item.querySelector('div:last-child').innerText.trim();

                htmlItems += `
                    <tr>
                        <td style="padding: 8px 0; border-bottom: 1px solid #f5f5f5;">\${name}</td>
                        <td style="text-align:center; padding: 8px 0; border-bottom: 1px solid #f5f5f5;">\${qty}</td>
                        <td style="text-align:right; padding: 8px 0; border-bottom: 1px solid #f5f5f5;">\${priceText}</td>
                    </tr>`;
            });

            document.getElementById('invoice-items-list').innerHTML = htmlItems || '<tr><td colspan="3" style="text-align:center">Trống</td></tr>';

            // Hiện Modal
            document.getElementById('invoiceModal').style.display = 'block';
        } catch (err) {
            console.error(err);
        }
    }

    function closeModal() { document.getElementById('invoiceModal').style.display = 'none'; }
    function submitFinalOrder() { document.getElementById('checkout-form').submit(); }

    // AJAX & TÍNH TOÁN CÔNG NỢ MÀN HÌNH CHÍNH
    function autoFillAmount() {
        setTimeout(() => {
            const hiddenTotal = document.getElementById('hidden-total-val');
            const amountPaidInput = document.getElementById('amountPaid');
            if (hiddenTotal && amountPaidInput) {
                const rawValue = hiddenTotal.value.replace(/[^0-9]/g, '');
                if (rawValue && rawValue !== "0") {
                    amountPaidInput.value = rawValue;
                    calculateDebt();
                }
            }
        }, 100);
    }

    function updateCartAjax(productId, action) {
        fetch('cart?productId=' + productId + '&action=' + action)
            .then(res => res.text())
            .then(html => {
                document.getElementById('cart-ajax-container').innerHTML = html;
                autoFillAmount();
            });
    }

    function updateCartQuantityAjax(productId, qty) {
        if (qty < 1) { updateCartAjax(productId, 'sub'); return; }
        fetch('cart?productId=' + productId + '&action=update&qty=' + qty)
            .then(res => res.text())
            .then(html => {
                document.getElementById('cart-ajax-container').innerHTML = html;
                autoFillAmount();
            });
    }

    function calculateDebt() {
        const totalInput = document.getElementById('hidden-total-val');
        const paidInput = document.getElementById('amountPaid');
        if (totalInput && paidInput) {
            const total = parseInt(totalInput.value.replace(/[^0-9]/g, '')) || 0;
            const paid = parseInt(paidInput.value) || 0;
            const debt = total - paid;
            document.getElementById('debt-amount').innerText = (debt > 0 ? debt : 0).toLocaleString() + " đ";
        }
    }

    function findCustomerByPhone(phone) {
        const input = phone.trim();
        if (input.length < 9) return;
        if (typeof customerList !== 'undefined') {
            const customer = customerList.find(c => c.phone === input);
            if (customer) {
                document.getElementById('cusName').value = customer.name;
                document.getElementById('cusName').style.backgroundColor = "#dcfce7";
            }
        }
    }

    document.addEventListener("DOMContentLoaded", autoFillAmount);
</script>