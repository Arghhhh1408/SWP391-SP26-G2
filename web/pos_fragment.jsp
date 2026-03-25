<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Bán hàng POS - S.I.M</title>
    <style>
        #invoiceModal { display: none; position: fixed; z-index: 10000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); backdrop-filter: blur(3px); }
        .modal-content { background: white; margin: 2% auto; width: 450px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.2); position: relative; }
        .invoice-card { padding: 30px; font-family: 'Courier New', Courier, monospace; color: #000; }
        .invoice-table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        .invoice-table th { border-bottom: 1px solid #000; padding: 8px 0; text-align: left; }
        .invoice-table td { padding: 8px 0; border-bottom: 1px solid #f5f5f5; font-size: 14px; }
        .total-row { display: flex; justify-content: space-between; margin-bottom: 8px; font-weight: bold; font-size: 16px; }
        .modal-footer { display: flex; gap: 10px; padding: 15px 30px 25px; background: #f8fafc; border-bottom-left-radius: 12px; border-bottom-right-radius: 12px; }
        .pos-container { display: flex !important; flex-direction: row !important; align-items: flex-start !important; gap: 20px !important; width: 100% !important; margin-top: 10px; }
        .product-column { flex: 1.6 !important; min-width: 0; }
        .cart-column { width: 400px !important; position: sticky !important; top: 20px; }
        .box { background: white; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); }
        .cart-box { background: white; border: 1px solid #3b82f6; border-radius: 12px; padding: 20px; }
        .stock-warning { color: #ef4444; font-weight: bold; animation: pulse 2s infinite; }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
        @media print { .no-print { display: none !important; } body * { visibility: hidden; } #invoice-print-area, #invoice-print-area * { visibility: visible; } #invoice-print-area { position: absolute; left: 0; top: 0; width: 100%; } }
    </style>
</head>
<body>
    <c:set var="tab" value="pos" scope="request" />
    <jsp:include page="saleSidebar.jsp" />

    <div class="admin-main" style="margin-left: 10px; padding: 10px;">
        <div class="pos-container">
            <div class="product-column">
                <div class="box">
                    <div style="padding: 15px 20px; background: #fcfcfc; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                        <h3 style="margin:0; font-size: 18px; color: #1e293b;">🛒 Danh mục Sản phẩm</h3>
                        <form action="sales_dashboard" method="get" style="display: flex; gap: 8px;">
                            <input type="hidden" name="tab" value="pos">
                            <input type="text" name="keyword" value="${keyword}" placeholder="Tìm sản phẩm..." style="padding: 8px; border: 1px solid #ddd; border-radius: 6px; width: 180px;">
                            <button type="submit" style="background: #3b82f6; color: white; border:none; padding: 8px 15px; border-radius: 6px; cursor:pointer;">🔍 Tìm</button>
                        </form>
                    </div>
                    <table style="width:100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: #f8fafc;">
                                <th style="padding:15px; text-align:left; color: #64748b;">Sản phẩm</th>
                                <th style="padding:15px; text-align:left; color: #64748b;">Đơn giá</th>
                                <th style="padding:15px; text-align:center; color: #64748b;">Kho (Ngưỡng)</th>
                                <th style="padding:15px; text-align:center; color: #64748b;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${products}" var="p">
                                <tr style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding:15px;">
                                        <strong style="color: #1e293b;">${p.name}</strong><br>
                                        <small style="color:#94a3b8;">SKU: ${p.sku}</small>
                                    </td>
                                    <td style="padding:15px; font-weight: 600;">
                                        <fmt:formatNumber value="${p.price}" type="number"/>đ
                                    </td>
                                    <td style="padding:15px; text-align:center;">
                                        <span class="${p.quantity <= p.lowStockThreshold ? 'stock-warning' : ''}">${p.quantity}</span>
                                        <small style="color: #94a3b8;">(${p.lowStockThreshold})</small>
                                    </td>
                                    <td style="padding:15px; text-align:center;">
                                        <c:choose>
                                            <c:when test="${p.quantity > p.lowStockThreshold}">
                                                <button onclick="updateCartAjax('${p.id}', 'add')" style="background:#3b82f6; color:white; border:none; padding:8px 16px; border-radius:6px; cursor:pointer; font-weight: bold;">Thêm</button>
                                            </c:when>
                                            <c:otherwise>
                                                <button disabled style="background:#94a3b8; color:white; border:none; padding:8px 16px; border-radius:6px; cursor:not-allowed;">Hết mức bán</button>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="cart-column">
                <div class="cart-box">
                    <h3 style="margin-top:0; border-bottom:2px solid #3b82f6; padding-bottom:12px; color: #1e293b;">📋 Đơn hàng</h3>
                    <div id="cart-ajax-container">
                        <jsp:include page="_cart_content.jsp" />
                    </div>
                    <form action="checkout" method="post" id="checkout-form" style="margin-top: 15px; border-top: 1px solid #eee; padding-top: 15px;">
                        <div style="margin-bottom:10px;">
                            <label style="font-size:12px; font-weight:bold; color:#64748b;">SĐT:</label>
                            <input type="text" name="phone" id="cusPhone" oninput="findCustomerByPhone(this.value)" placeholder="Bỏ trống nếu là khách lẻ" style="width:100%; padding:8px; border:1px solid #ddd; border-radius:6px;">
                        </div>
                        <div style="margin-bottom:10px;">
                            <label style="font-size:12px; font-weight:bold; color:#64748b;">Tên khách:</label>
                            <input type="text" name="customerName" id="cusName" value="Khách lẻ" style="width:100%; padding:8px; border:1px solid #ddd; border-radius:6px;">
                        </div>
                        <div style="margin-bottom:15px;">
                            <label style="font-size:12px; color:#ef4444; font-weight:bold;">Khách trả (đ):</label>
                            <input type="text" id="amountPaid" name="amountPaid" 
                                   oninput="this.value = Number(this.value.replace(/\D/g,'')).toLocaleString('vi-VN')" 
                                   onchange="calculateDebt()" 
                                   style="width:100%; padding:10px; border:2px solid #ef4444; border-radius:8px; font-size: 18px; font-weight: bold; color: #ef4444;">
                        </div>
                        <button type="submit" style="width:100%; background:#3b82f6; color:white; padding:15px; border:none; border-radius:10px; font-weight:bold; cursor:pointer;">XÁC NHẬN THANH TOÁN</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div id="invoiceModal">
        <div class="modal-content">
            <span onclick="closeModal()" class="no-print" style="position:absolute; right:15px; top:10px; font-size:28px; cursor:pointer;">&times;</span>
            <div class="invoice-card" id="invoice-print-area">
                <div style="text-align: center; border-bottom: 1px dashed #ddd; padding-bottom: 10px;">
                    <h2>HÓA ĐƠN BÁN LẺ</h2>
                    <p>Ngày: <span id="display-date"></span></p>
                </div>
                <div style="margin: 15px 0; font-size: 14px;">
                    <p><strong>Khách:</strong> <span id="display-cusName"></span></p>
                    <p><strong>SĐT:</strong> <span id="display-cusPhone"></span></p>
                </div>
                <table class="invoice-table">
                    <thead><tr><th>Sản phẩm</th><th style="text-align:center">SL</th><th style="text-align:right">T.Tiền</th></tr></thead>
                    <tbody id="invoice-items-list"></tbody>
                </table>
                <div style="border-top: 2px solid #000; padding-top: 10px;">
                    <div class="total-row"><span>Tổng cộng:</span><span id="display-totalPrice">0 đ</span></div>
                    <div class="total-row"><span>Khách trả:</span><span id="display-amountPaid-modal">0 đ</span></div>
                    <div class="total-row"><span id="label-debt-change">Công nợ:</span><span id="display-debt-change">0 đ</span></div>
                </div>
                <div style="display: flex; justify-content: space-around; align-items: flex-end; margin-top: 20px;">
                    <div style="text-align: center;">
                        <p style="font-size: 10px; font-weight: bold;">THANH TOÁN QR</p>
                        <img id="display-qr-pay" src="" style="width: 120px; height: 120px; border: 1px solid #eee; padding: 5px;" />
                    </div>
                    <div style="text-align: center;">
                        <p style="font-size: 10px; font-weight: bold;">MÃ ĐƠN HÀNG</p>
                        <img id="display-barcode" src="" style="width: 150px; height: 50px;" />
                    </div>
                </div>
            </div>
            <div class="modal-footer no-print">
                <button onclick="window.print()" style="flex:1; background:#10b981; color:white; padding:12px; border:none; border-radius:6px; font-weight:bold; cursor:pointer;">🖨️ IN</button>
                <button onclick="submitFinalOrder()" style="flex:1; background:#3b82f6; color:white; padding:12px; border:none; border-radius:6px; font-weight:bold; cursor:pointer;">✅ HOÀN TẤT</button>
            </div>
        </div>
    </div>

<script>
    // 1. DỮ LIỆU
    const customerList = [
        <c:forEach items="${customers}" var="c">
            { phone: "${c.phone.trim()}", name: "${c.name}" },
        </c:forEach>
    ];

    const products = [
        <c:forEach items="${products}" var="p">
            { id: "${p.id}", quantity: ${p.quantity}, minStockLevel: ${p.lowStockThreshold} },
        </c:forEach>
    ];

    // 2. TÌM KHÁCH & KHÓA TÊN
    function findCustomerByPhone(phone) {
        const phoneInput = phone.trim();
        const nameInput = document.getElementById('cusName');
        if (phoneInput === "") {
            nameInput.value = "Khách lẻ"; nameInput.readOnly = false;
            nameInput.style.backgroundColor = "#ffffff"; nameInput.dataset.locked = "false";
            return;
        }
        if (phoneInput.length >= 9) {
            const customer = customerList.find(c => c.phone.replace(/\s+/g, '') === phoneInput.replace(/\s+/g, ''));
            if (customer) {
                nameInput.value = customer.name; nameInput.readOnly = true; 
                nameInput.style.backgroundColor = "#f1f5f9"; nameInput.dataset.locked = "true";
            } else {
                nameInput.value = ""; nameInput.readOnly = false;
                nameInput.style.backgroundColor = "#ffffff"; nameInput.dataset.locked = "false";
            }
        }
    }

    // Chặn sửa tên khách quen
    document.addEventListener('keydown', function (e) {
        const nameInp = document.getElementById('cusName');
        if (e.target && e.target.id === 'cusName' && nameInp.dataset.locked === "true") {
            const allowedKeys = ['Tab', 'Enter', 'Escape'];
            if (!allowedKeys.includes(e.key)) e.preventDefault();
        }
    });

    // 3. AJAX GIỎ HÀNG & CHẶN NGƯỠNG
    function updateCartAjax(id, act) {
    const p = products.find(item => String(item.id) === String(id));
    
    if (act === 'add' && p) {
        const qtyInput = document.getElementById('qty-input-' + id);
        const currentInCart = qtyInput ? parseInt(qtyInput.value) : 0;
        
        // Chặn nếu cộng thêm 1 cái nữa mà vượt ngưỡng
        if (currentInCart + 1 > (p.quantity - p.minStockLevel)) {
            alert("⚠️ Đã đạt giới hạn bán tối đa dựa trên tồn kho và ngưỡng kho thấp!");
            return; // Dừng lại không gọi Ajax
        }
    }

    // Nếu hợp lệ hoặc là hành động khác (sub, update) thì mới fetch
    fetch('cart?productId=' + id + '&action=' + act)
        .then(r => r.text())
        .then(html => {
            document.getElementById('cart-ajax-container').innerHTML = html;
            calculateDebt();
        });
}

    // Hàm cho phép gõ tay số lượng trong file _cart_content.jsp
    function updateQtyManual(input, id) {
        let newQty = parseInt(input.value);
        const p = products.find(item => String(item.id) === String(id));
        if (!p) return;

        const maxCanSell = p.quantity - p.minStockLevel;
        if (newQty > maxCanSell) {
            alert("⚠️ Vượt ngưỡng cho phép!\nKho còn: " + p.quantity + "\nNgưỡng giữ lại: " + p.minStockLevel + "\nBạn chỉ được bán tối đa: " + maxCanSell);
            newQty = maxCanSell > 0 ? maxCanSell : 0;
            input.value = newQty;
        }
        if (newQty < 1 || isNaN(newQty)) { input.value = 1; newQty = 1; }
        updateCartAjax(id, 'update&quantity=' + newQty);
    }

    // 4. TÍNH NỢ
    function calculateDebt() {
        const total = parseInt(document.getElementById('hidden-total-val')?.value || 0);
        const paid = parseInt(document.getElementById('amountPaid').value.replace(/\./g, '')) || 0;
        const diff = total - paid;
        
        const debtDisp = document.getElementById("debt-display");
        const changeDisp = document.getElementById("change-display");
        const rowDebt = document.getElementById("row-debt");
        const rowChange = document.getElementById("row-change");

        if (diff > 0) {
            if(rowDebt) rowDebt.style.display = "flex";
            if(rowChange) rowChange.style.display = "none";
            if(debtDisp) debtDisp.innerText = diff.toLocaleString() + " đ";
        } else {
            if(rowDebt) rowDebt.style.display = "none";
            if(rowChange) rowChange.style.display = "flex";
            if(changeDisp) changeDisp.innerText = Math.abs(diff).toLocaleString() + " đ";
        }
    }

    // 5. SUBMIT & MODAL
    document.getElementById('checkout-form').addEventListener('submit', function (e) {
        const totalVal = parseInt(document.getElementById('hidden-total-val')?.value || 0);
        if (totalVal <= 0) { e.preventDefault(); alert("⚠️ GIỎ HÀNG TRỐNG!"); return; }
        
        const paidVal = parseInt(document.getElementById('amountPaid').value.replace(/\./g, '')) || 0;
        const phone = document.getElementById('cusPhone').value.trim();
        if (phone === "" && paidVal < totalVal) { e.preventDefault(); alert("⚠️ KHÁCH LẺ KHÔNG ĐƯỢC NỢ!"); return; }

        e.preventDefault(); 
        const tempOrderId = "SIM" + Date.now();
        document.getElementById('display-cusName').innerText = document.getElementById('cusName').value;
        document.getElementById('display-cusPhone').innerText = phone || "---";
        document.getElementById('display-date').innerText = new Date().toLocaleString('vi-VN');
        document.getElementById('display-totalPrice').innerText = totalVal.toLocaleString() + " đ";
        document.getElementById('display-amountPaid-modal').innerText = paidVal.toLocaleString() + " đ";

        const diff = totalVal - paidVal;
        const lbl = document.getElementById('label-debt-change');
        const val = document.getElementById('display-debt-change');
        lbl.innerText = diff > 0 ? "Công nợ:" : "Tiền thừa:";
        val.innerText = Math.abs(diff).toLocaleString() + " đ";
        val.style.color = diff > 0 ? "#ef4444" : "#10b981";

        let htmlItems = '';
let calculatedTotal = 0; // Biến tạm để tính lại tổng tiền cho chắc chắn

document.querySelectorAll('#cart-list > div').forEach(item => {
    const name = item.querySelector('.item-name')?.innerText || "Sản phẩm";
    
    // Lấy số lượng (SL) - Đảm bảo lấy đúng giá trị từ ô input số lượng
    const qtyInput = item.querySelector('input[type="number"]');
    const qty = parseInt(qtyInput ? qtyInput.value : 1);
    
    // Lấy đơn giá (Xóa chữ 'đ' và dấu chấm để tính toán)
    const priceText = item.querySelector('div[style*="font-size:11px"]')?.innerText || "0";
    const unitPrice = parseInt(priceText.replace(/\D/g, '')) || 0;
    
    const subTotal = unitPrice * qty;
    calculatedTotal += subTotal;

    // Cộng dồn dòng vào bảng hóa đơn
    htmlItems += "<tr>" +
                 "<td>" + name + "</td>" +
                 "<td align='center'>" + qty + "</td>" +
                 "<td align='right'>" + subTotal.toLocaleString('vi-VN') + "đ</td>" +
                 "</tr>";
});

// Đổ dữ liệu vào Modal
document.getElementById('invoice-items-list').innerHTML = htmlItems;

// Lấy tổng tiền thực tế từ ô ẩn (phải khớp với calculatedTotal)
const finalTotal = parseInt(document.getElementById('hidden-total-val').value) || calculatedTotal;
document.getElementById('display-totalPrice').innerText = finalTotal.toLocaleString('vi-VN') + " đ";
        document.getElementById('invoice-items-list').innerHTML = htmlItems;
        document.getElementById('display-qr-pay').src = "https://img.vietqr.io/image/MB-0338968962-compact2.jpg?amount=" + totalVal + "&addInfo=SIM" + tempOrderId;
        document.getElementById('display-barcode').src = "https://bwipjs-api.metafloor.com/?bcid=code128&text=" + tempOrderId + "&scale=2";
        document.getElementById('invoiceModal').style.display = 'block';
    });

    function closeModal() { document.getElementById('invoiceModal').style.display = 'none'; }
    function submitFinalOrder() { document.getElementById('checkout-form').submit(); }

    document.addEventListener('keydown', function (e) {
        if (e.key === "F8") { e.preventDefault(); document.getElementById('amountPaid').focus(); }
        if (e.key === "Escape") closeModal();
        if (e.key === "F9" && document.getElementById('invoiceModal').style.display === 'block') submitFinalOrder();
    });
    function updateQtyManual(input, id) {
    let newQty = parseInt(input.value);
    
    // Tìm sản phẩm trong danh sách 'products' (đã có sẵn từ lúc load trang)
    const p = products.find(item => String(item.id) === String(id));
    
    if (p) {
        // TÍNH TOÁN: Số lượng tối đa được bán = Tồn kho - Ngưỡng thấp
        const maxAvailable = p.quantity - p.minStockLevel;

        if (newQty > maxAvailable) {
            // Hiển thị thông báo lỗi ngay lập tức
            alert("⚠️ KHÔNG THỂ BÁN VƯỢT NGƯỠNG TỒN!\n" +
                  "--------------------------------\n" +
                  "📦 Tồn thực tế: " + p.quantity + "\n" +
                  "🛑 Ngưỡng tối thiểu: " + p.minStockLevel + "\n" +
                  "✅ Chỉ được bán tối đa: " + (maxAvailable > 0 ? maxAvailable : 0));

            // Ép số lượng về mức tối đa cho phép
            newQty = (maxAvailable > 0) ? maxAvailable : 1;
            input.value = newQty; 
        }
    }

    if (newQty < 1 || isNaN(newQty)) {
        input.value = 1;
        newQty = 1;
    }

    // Gọi Ajax cập nhật giỏ hàng để tổng tiền nhảy đúng
    updateCartAjax(id, 'update&quantity=' + newQty);
}
</script>
</body>
</html>