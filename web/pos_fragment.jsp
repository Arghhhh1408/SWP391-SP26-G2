<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<div class="pos-wrapper" style="display: flex; gap: 20px; align-items: flex-start;">
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

    <div style="flex: 1; position: sticky; top: 20px;">
        <div class="cart-box" style="background:white; border:1px solid #3b82f6; border-radius:8px; padding:20px; box-shadow:0 4px 6px rgba(0,0,0,0.1);">
            <h3 style="margin-top:0; border-bottom:2px solid #3b82f6; padding-bottom:10px;">📋 Đơn hàng</h3>

            <div id="cart-ajax-container">
                <%-- File _cart_content.jsp sẽ được load vào đây --%>
                <jsp:include page="_cart_content.jsp" />
            </div>

            <div style="background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0; margin-top:15px;">
                <form action="checkout" method="post" id="checkout-form" onsubmit="showInvoice(event)">
                    <div style="margin-bottom:10px;">
                        <label style="font-size:12px; font-weight:bold;">Số điện thoại:</label>
                        <input type="text" name="phone" id="cusPhone" oninput="findCustomerByPhone(this.value)" 
                               placeholder="Nhập SĐT khách..." required 
                               style="width:100%; padding:8px; border:1px solid #ddd; border-radius:4px;">
                    </div>

                    <div style="margin-bottom:10px;">
                        <label style="font-size:12px; font-weight:bold;">Tên Khách hàng:</label>
                        <input type="text" name="customerName" id="cusName" 
                               placeholder="Tên khách sẽ tự hiện..." 
                               style="width:100%; padding:8px; border:1px solid #ddd; border-radius:4px; background-color: #f9f9f9;">
                    </div>

                    <div style="margin-bottom:10px;">
                        <label style="font-size:12px; font-weight:bold;">Ghi chú:</label>
                        <textarea name="note" id="orderNote" placeholder="Ghi chú đơn hàng..." style="width:100%; padding:8px; border:1px solid #ddd; border-radius:4px; height:60px;"></textarea>
                    </div>

                    <div style="margin-bottom:15px; padding-top:10px; border-top:1px solid #ddd;">
                        <label style="font-size:12px; color:#ef4444; font-weight:bold;">Khách thanh toán (đ):</label>
                        <input type="number" id="amountPaid" name="amountPaid" oninput="calculateDebt()" style="width:100%; padding:8px; border:1px solid #ef4444; border-radius:4px; font-weight:bold;">
                    </div>

                    <div style="display:flex; justify-content:space-between; font-size:14px; margin-bottom:15px; color:#64748b;">
                        <span>Công nợ:</span>
                        <span id="debt-amount" style="color:#ef4444; font-weight:bold;">0 đ</span>
                    </div>

                    <button type="submit" style="width:100%; background:#3b82f6; color:white; padding:12px; border:none; border-radius:6px; font-weight:bold; cursor:pointer;">XÁC NHẬN THANH TOÁN</button>
                </form>
            </div>
        </div>
    </div>
</div>

<div id="invoiceModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; justify-content:center; align-items:center;">
    <div style="background:white; width:380px; padding:25px; border-radius:8px; box-shadow:0 10px 25px rgba(0,0,0,0.2);">
        <div id="printArea" style="text-align:center; font-family:monospace;">
            <h2 style="margin:0;">S.I.M MARKET</h2>
            <p style="font-size:12px;">Hóa đơn bán lẻ</p>
            <hr>
            <div id="invoiceInfo" style="text-align:left; font-size:13px; margin:10px 0;"></div>
            <hr>
            <table id="invoiceItems" style="width:100%; font-size:13px; border:none;"></table>
            <hr>
            <div id="invoiceTotal" style="text-align:right; font-weight:bold; font-size:15px;"></div>
        </div>
        <div style="margin-top:20px; display:flex; gap:8px;">
            <button type="button" onclick="printInvoice()" style="flex:1; padding:10px; background:#10b981; color:white; border:none; border-radius:4px; cursor:pointer; font-weight:bold;">
                🖨️ In
            </button>

            <button type="button" onclick="confirmCheckout()" style="flex:1.5; padding:10px; background:#3b82f6; color:white; border:none; border-radius:4px; cursor:pointer; font-weight:bold;">
                ✅ Hoàn tất
            </button>

            <button type="button" onclick="cancelInvoice()" style="flex:1; padding:10px; background:#64748b; color:white; border:none; border-radius:4px; cursor:pointer;">
                ⬅️ Quay lại
            </button>
        </div>
    </div>
</div>
            <script>
                // 1. Hàm IN: Chỉ in vùng hóa đơn, không lưu dữ liệu
function printInvoice() {
    const printArea = document.getElementById('printArea');
    if (!printArea) {
        alert("Không tìm thấy vùng dữ liệu để in!");
        return;
    }
    const printContents = printArea.innerHTML;

    // Tạo cửa sổ tạm
    const printWindow = window.open('', '', 'height=600,width=800');

    printWindow.document.write('<html><head><title>HÓA ĐƠN BÁN LẺ</title>');
    // Thêm CSS để hóa đơn trông giống biên lai thật
    printWindow.document.write('<style>' +
        'body { font-family: "Courier New", Courier, monospace; padding: 20px; color: #000; }' +
        'table { width: 100%; border-collapse: collapse; margin-top: 10px; }' +
        'th, td { text-align: left; padding: 5px; }' +
        '.text-right { text-align: right; }' +
        'hr { border: none; border-top: 1px dashed #000; margin: 10px 0; }' +
        '.header { text-align: center; font-weight: bold; font-size: 1.2em; }' +
        '</style>');
    printWindow.document.write('</head><body>');
    printWindow.document.write(printContents); // Đổ nội dung từ printArea vào đây
    printWindow.document.write('</body></html>');

    printWindow.document.close(); // Quan trọng: Đóng luồng ghi dữ liệu

    // Đợi 500ms để trình duyệt render xong rồi mới in
    setTimeout(function() {
        printWindow.focus();
        printWindow.print();
        printWindow.close();
    }, 500);
}

// 2. Hàm HOÀN TẤT: Đẩy dữ liệu về CheckoutController để trừ kho & xóa giỏ
function confirmCheckout() {
    // Hiện loading nhẹ để tránh bấm liên tiếp
    const btn = event.target;
    btn.innerText = "Đang xử lý...";
    btn.disabled = true;

    // Gửi form đi - CheckoutController sẽ lo việc lưu DB, trừ kho và xóa Session Cart
    document.getElementById('checkout-form').submit();
}

// 3. Hàm QUAY LẠI: Cần xác nhận trước khi đóng popup
function cancelInvoice() {
    if (confirm("Bạn có chắc chắn muốn quay lại chỉnh sửa đơn hàng không?")) {
        document.getElementById('invoiceModal').style.display = 'none';
    }
}
            </script>           