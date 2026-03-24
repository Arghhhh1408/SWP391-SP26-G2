<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Bán hàng POS - S.I.M</title>
        <style>
            #invoiceModal {
                display: none;
                position: fixed;
                z-index: 10000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.6);
                backdrop-filter: blur(3px);
            }
            .modal-content {
                background: white;
                margin: 2% auto;
                width: 450px;
                border-radius: 12px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                position: relative;
            }
            .invoice-card {
                padding: 30px;
                font-family: 'Courier New', Courier, monospace;
                color: #000;
            }
            .invoice-table {
                width: 100%;
                border-collapse: collapse;
                margin: 15px 0;
            }
            .invoice-table th {
                border-bottom: 1px solid #000;
                padding: 8px 0;
                text-align: left;
            }
            .invoice-table td {
                padding: 8px 0;
                border-bottom: 1px solid #f5f5f5;
                font-size: 14px;
            }
            .total-row {
                display: flex;
                justify-content: space-between;
                margin-bottom: 8px;
                font-weight: bold;
                font-size: 16px;
            }
            .modal-footer {
                display: flex;
                gap: 10px;
                padding: 15px 30px 25px;
                background: #f8fafc;
                border-bottom-left-radius: 12px;
                border-bottom-right-radius: 12px;
            }
            .pos-container {
                display: flex !important;
                flex-direction: row !important;
                align-items: flex-start !important;
                gap: 20px !important;
                width: 100% !important;
                margin-top: 10px;
            }
            .product-column {
                flex: 1.6 !important;
                min-width: 0;
            }
            .cart-column {
                width: 400px !important;
                position: sticky !important;
                top: 20px;
            }
            .box {
                background: white;
                border-radius: 12px;
                border: 1px solid #e2e8f0;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
            }
            .cart-box {
                background: white;
                border: 1px solid #3b82f6;
                border-radius: 12px;
                padding: 20px;
                box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
            }
            @media print {
                .no-print {
                    display: none !important;
                }
                body * {
                    visibility: hidden;
                }
                #invoice-print-area, #invoice-print-area * {
                    visibility: visible;
                }
                #invoice-print-area {
                    position: absolute;
                    left: 0;
                    top: 0;
                    width: 100%;
                }
            }
        </style>
    </head>
    <body>
        <c:set var="tab" value="pos" scope="request" />
        <jsp:include page="saleSidebar.jsp" />

        <div class="admin-main" style="margin-left: 10px; padding: 10px;">
            <div class="pos-container">
                <div class="product-column">
                    <div class="box">
                        <div style="padding: 15px 20px; background: #fcfcfc; border-bottom: 1px solid #f1f5f9;">
                            <h3 style="margin:0; font-size: 18px; color: #1e293b;">🛒 Danh mục Sản phẩm</h3>
                        </div>
                        <div style="padding: 0;">
                            <table style="width:100%; border-collapse: collapse;">
                                <thead>
                                    <tr style="background: #f8fafc;">
                                        <th style="padding:15px; text-align:left; color: #64748b; font-size: 13px;">Sản phẩm</th>
                                        <th style="padding:15px; text-align:left; color: #64748b; font-size: 13px;">Đơn giá</th>
                                        <th style="padding:15px; text-align:center; color: #64748b; font-size: 13px;">Kho</th>
                                        <th style="padding:15px; text-align:center; color: #64748b; font-size: 13px;">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${products}" var="p">
                                        <tr style="border-bottom: 1px solid #f1f5f9;">
                                            <td style="padding:15px;">
                                                <strong style="color: #1e293b;">${p.name}</strong><br>
                                                <small style="color:#94a3b8;">SKU: ${p.sku}</small>
                                            </td>
                                            <td style="padding:15px; color: #475569; font-weight: 600;">
                                                <fmt:formatNumber value="${p.price}" type="number"/>đ
                                            </td>
                                            <td style="padding:15px; text-align:center;">
                                                <span style="padding: 2px 8px; background: #f1f5f9; border-radius: 4px;">${p.quantity}</span>
                                            </td>
                                            <td style="padding:15px; text-align:center;">
                                                <button onclick="updateCartAjax('${p.id}', 'add')" style="background:#3b82f6; color:white; border:none; padding:8px 16px; border-radius:6px; cursor:pointer; font-weight: bold;">Thêm</button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="cart-column">
                    <div class="cart-box">
                        <h3 style="margin-top:0; border-bottom:2px solid #3b82f6; padding-bottom:12px; font-size: 18px; color: #1e293b;">📋 Đơn hàng</h3>
                        <div id="cart-ajax-container">
                            <jsp:include page="_cart_content.jsp" />
                        </div>
                        <form action="checkout" method="post" id="checkout-form" style="margin-top: 15px; border-top: 1px solid #eee; padding-top: 15px;">
                            <div style="margin-bottom:10px;">
                                <label style="font-size:12px; font-weight:bold; color:#64748b;">SĐT:</label>
                                <input type="text" name="phone" id="cusPhone" oninput="findCustomerByPhone(this.value)" required style="width:100%; padding:8px; border:1px solid #ddd; border-radius:6px;">
                            </div>
                            <div style="margin-bottom:10px;">
                                <label style="font-size:12px; font-weight:bold; color:#64748b;">Tên khách:</label>
                                <input type="text" name="customerName" id="cusName" style="width:100%; padding:8px; border:1px solid #ddd; border-radius:6px;">
                            </div>
                            <div style="margin-bottom:15px;">
                                <label style="font-size:12px; color:#ef4444; font-weight:bold;">Khách trả (đ):</label>
                                <input type="number" id="amountPaid" name="amountPaid" oninput="calculateDebt()" style="width:100%; padding:10px; border:2px solid #ef4444; border-radius:8px; font-size: 18px; font-weight: bold; color: #ef4444;">
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
                        <h2 style="margin:0;">HÓA ĐƠN BÁN LẺ</h2>
                        <p style="margin:5px 0;">Ngày: <span id="display-date"></span></p>
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
                        <div class="total-row"><span>Khách trả:</span><span id="display-amountPaid">0 đ</span></div>
                        <div class="total-row"><span id="label-debt-change">Công nợ:</span><span id="display-debt-change">0 đ</span></div>
                    </div>
                    <div style="display: flex; justify-content: space-around; align-items: flex-end; margin-top: 20px; border-top: 1px dashed #ddd; padding-top: 15px;">
                        <div style="text-align: center;">
                            <p style="font-size: 10px; margin-bottom: 5px; font-weight: bold;">THANH TOÁN QR</p>
                            <img id="display-qr-pay" src="" style="width: 120px; height: 120px; border: 1px solid #eee; padding: 5px;" />
                        </div>
                        <div style="text-align: center;">
                            <p style="font-size: 10px; margin-bottom: 5px; font-weight: bold;">MÃ ĐƠN HÀNG</p>
                            <img id="display-barcode" src="" style="width: 150px; height: 50px;" />
                            <p id="display-order-id" style="font-size: 10px; margin-top: 5px; letter-spacing: 2px;"></p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer no-print">
                    <button onclick="window.print()" style="flex:1; background:#10b981; color:white; padding:12px; border:none; border-radius:6px; cursor:pointer; font-weight:bold;">🖨️ IN</button>
                    <button onclick="submitFinalOrder()" style="flex:1; background:#3b82f6; color:white; padding:12px; border:none; border-radius:6px; cursor:pointer; font-weight:bold;">✅ HOÀN TẤT</button>
                </div>
            </div>
        </div>

        <script>
            // 1. Tự động tìm khách hàng theo SĐT
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

            // 2. Hàm tạo Barcode (Fix lỗi nối chuỗi)
            function generateBarcode(orderId) {
                const barcodeUrl = "https://bwipjs-api.metafloor.com/?bcid=code128&text=" + orderId + "&scale=2&rotate=N&includetext=false";
                document.getElementById('display-barcode').src = barcodeUrl;
                document.getElementById('display-order-id').innerText = orderId;
            }

            // 3. Hàm tạo QR (Nội dung chuyển khoản chuẩn)
            function generateQR(amount, orderId) {
                const qrUrl = "https://img.vietqr.io/image/MB-0338968962-compact2.jpg?amount=" + amount + "&addInfo=Thanh toan don " + orderId;
                document.getElementById('display-qr-pay').src = qrUrl;
            }

            // 4. Tính toán Công nợ / Tiền thừa
            function calculateDebt() {
                const totalEl = document.getElementById('hidden-total-val');
                const paidEl = document.getElementById('amountPaid');
                if (!totalEl || !paidEl)
                    return;

                const total = parseInt(totalEl.value) || 0;
                const paid = parseInt(paidEl.value) || 0;
                const diff = total - paid;

                const rowDebt = document.getElementById("row-debt");
                const rowChange = document.getElementById("row-change");
                const debtDisp = document.getElementById("debt-display");
                const changeDisp = document.getElementById("change-display");

                if (diff > 0) {
                    if (rowDebt)
                        rowDebt.style.display = "flex";
                    if (rowChange)
                        rowChange.style.display = "none";
                    if (debtDisp)
                        debtDisp.innerText = diff.toLocaleString() + " đ";
                } else if (diff < 0) {
                    if (rowDebt)
                        rowDebt.style.display = "none";
                    if (rowChange)
                        rowChange.style.display = "flex";
                    if (changeDisp)
                        changeDisp.innerText = Math.abs(diff).toLocaleString() + " đ";
                } else {
                    if (rowDebt)
                        rowDebt.style.display = "flex";
                    if (rowChange)
                        rowChange.style.display = "none";
                    if (debtDisp)
                        debtDisp.innerText = "0 đ";
                }
            }

            // 5. HÀM SUBMIT CHÍNH (Đã sửa lỗi không hiện hóa đơn)
            document.getElementById('checkout-form').addEventListener('submit', function (e) {
                e.preventDefault();

                const totalVal = parseInt(document.getElementById('hidden-total-val').value) || 0;
                const paidInput = document.getElementById('amountPaid').value;
                const paidVal = parseInt(paidInput) || 0;
                const diff = totalVal - paidVal;
                const tempOrderId = "SIM" + Date.now();

                // Xử lý thông tin khách lẻ
                let phoneInput = document.getElementById('cusPhone').value.trim();
                let nameInput = document.getElementById('cusName').value.trim();
                let finalPhone = (phoneInput === "") ? "---" : phoneInput;
                let finalName = (phoneInput === "") ? "Khách lẻ" : (nameInput === "" ? "Khách vãng lai" : nameInput);

                // Đổ dữ liệu lên Modal
                document.getElementById('display-cusName').innerText = finalName;
                document.getElementById('display-cusPhone').innerText = finalPhone;
                document.getElementById('display-date').innerText = new Date().toLocaleString('vi-VN');
                document.getElementById('display-totalPrice').innerText = totalVal.toLocaleString() + " đ";
                document.getElementById('display-amountPaid').innerText = paidVal.toLocaleString() + " đ";

                const lbl = document.getElementById('label-debt-change');
                const val = document.getElementById('display-debt-change');
                if (diff > 0) {
                    lbl.innerText = "Công nợ:";
                    val.innerText = diff.toLocaleString() + " đ";
                    val.style.color = "#ef4444";
                } else {
                    lbl.innerText = "Tiền thừa:";
                    val.innerText = Math.abs(diff).toLocaleString() + " đ";
                    val.style.color = "#10b981";
                }

                // Quét danh sách món hàng để hiển thị lên Bill
                let htmlItems = '';
                document.querySelectorAll('#cart-list > div').forEach(item => {
                    const name = item.querySelector('div div:first-child').innerText;
                    const qty = item.querySelector('input[type="number"]').value;
                    const price = item.querySelector('div[style*="font-weight:bold"]').innerText;
                    htmlItems += "<tr><td>" + name + "</td><td style='text-align:center'>" + qty + "</td><td style='text-align:right'>" + price + "</td></tr>";
                });
                document.getElementById('invoice-items-list').innerHTML = htmlItems;

                // Cập nhật QR Code: Nếu khách trả một phần, QR hiện đúng số tiền đó. Trả 0đ thì hiện tổng bill.
                const qrAmount = (paidVal > 0) ? paidVal : totalVal;
                generateQR(qrAmount, tempOrderId);
                generateBarcode(tempOrderId);

                // Hiển thị Modal
                document.getElementById('invoiceModal').style.display = 'block';
            });

            // 6. Các hàm bổ trợ khác
            function updateCartAjax(id, act) {
                fetch('cart?productId=' + id + '&action=' + act).then(r => r.text()).then(h => {
                    document.getElementById('cart-ajax-container').innerHTML = h;
                    const totalVal = document.getElementById('hidden-total-val').value;
                    document.getElementById('amountPaid').value = totalVal;
                    calculateDebt();
                });
            }

            function closeModal() {
                document.getElementById('invoiceModal').style.display = 'none';
            }

            function submitFinalOrder() {
                document.getElementById('checkout-form').submit();
            }

            document.addEventListener('keydown', function (e) {
                if (e.key === "F8") {
                    e.preventDefault();
                    document.getElementById('amountPaid').focus();
                }
                if (e.key === "Escape")
                    closeModal();
                if (e.key === "F9" && document.getElementById('invoiceModal').style.display === 'block') {
                    submitFinalOrder();
                }
            });
        </script>
    </body>
</html>