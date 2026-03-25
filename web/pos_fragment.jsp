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
                    <div class="product-column">
                        <div class="box">
                            <div style="padding: 15px 20px; background: #fcfcfc; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                                <h3 style="margin:0; font-size: 18px; color: #1e293b;">🛒 Danh mục Sản phẩm</h3>

                                <form action="sales_dashboard" method="get" style="display: flex; gap: 8px; flex: 1; justify-content: flex-end; min-width: 300px;">
                                    <input type="hidden" name="tab" value="pos">

                                    <select name="range" style="padding: 8px; border: 1px solid #ddd; border-radius: 6px; font-size: 13px;">
                                        <option value="all" ${range == 'all' ? 'selected' : ''}>Tất cả nhóm</option>
                                        <option value="available" ${range == 'available' ? 'selected' : ''}>Còn hàng</option>
                                    </select>

                                    <select name="sort" style="padding: 8px; border: 1px solid #ddd; border-radius: 6px; font-size: 13px;">
                                        <option value="new" ${sort == 'new' ? 'selected' : ''}>Mới nhập</option>
                                        <option value="total_desc" ${sort == 'total_desc' ? 'selected' : ''}>Giá cao nhất</option>
                                        <option value="total_asc" ${sort == 'total_asc' ? 'selected' : ''}>Giá thấp nhất</option>
                                    </select>

                                    <input type="text" name="keyword" value="${keyword}" 
                                           placeholder="Tìm tên sản phẩm, SKU..." 
                                           style="padding: 8px; border: 1px solid #ddd; border-radius: 6px; width: 180px; font-size: 13px;">

                                    <button type="submit" class="btn" style="background: #3b82f6; color: white; padding: 8px 15px; font-size: 13px;">
                                        🔍 Tìm
                                    </button>
                                </form>
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
                                        <c:if test="${empty products}">
                                            <tr>
                                                <td colspan="4" style="text-align:center; padding:30px; color:#94a3b8;">Không tìm thấy sản phẩm nào.</td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
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
                                <input type="text" name="phone" id="cusPhone" 
                                       oninput="findCustomerByPhone(this.value)" 
                                       placeholder="Bỏ trống nếu là khách lẻ"
                                       style="width:100%; padding:8px; border:1px solid #ddd; border-radius:6px;">
                            </div>

                            <div style="margin-bottom:10px;">
                                <label style="font-size:12px; font-weight:bold; color:#64748b;">Tên khách:</label>
                                <input type="text" name="customerName" id="cusName" 
                                       value="Khách lẻ"
                                       style="width:100%; padding:8px; border:1px solid #ddd; border-radius:6px;">
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
    // 1. ĐỔ DỮ LIỆU (Đã sửa fullName thành name cho khớp với model.Customer của Mạnh Lý)
    const customerList = [
        <c:forEach items="${customers}" var="c">
            { phone: "${c.phone.trim()}", name: "${c.name}" },
        </c:forEach>
    ];

    // 2. HÀM TÌM KHÁCH VÀ KHÓA TÊN
    function findCustomerByPhone(phone) {
        const phoneInput = phone.trim();
        const nameInput = document.getElementById('cusName');

        // Nếu xóa trắng SĐT -> Trở về Khách lẻ và MỞ KHÓA
        if (phoneInput === "") {
            nameInput.value = "Khách lẻ";
            nameInput.readOnly = false;
            nameInput.style.backgroundColor = "#ffffff";
            nameInput.dataset.locked = "false"; 
            return;
        }

        if (phoneInput.length >= 9) {
            const customer = customerList.find(c => c.phone === phoneInput);
            if (customer) {
                // TÌM THẤY KHÁCH QUEN -> HIỆN TÊN & KHÓA CỨNG
                nameInput.value = customer.name;
                nameInput.readOnly = true; 
                nameInput.style.backgroundColor = "#f1f5f9"; // Màu xám báo hiệu khóa
                nameInput.dataset.locked = "true"; 
                console.log("Đã khớp khách: " + customer.name);
            } else {
                // KHÁCH MỚI -> MỞ KHÓA
                nameInput.value = "";
                nameInput.readOnly = false;
                nameInput.style.backgroundColor = "#ffffff";
                nameInput.dataset.locked = "false";
                nameInput.placeholder = "Nhập tên khách mới...";
            }
        }
    }

    // 3. VÒNG KIM CÔ: Chặn gõ phím khi đã khóa
    document.addEventListener('keydown', function (e) {
        const nameInp = document.getElementById('cusName');
        if (e.target && e.target.id === 'cusName' && nameInp.dataset.locked === "true") {
            const allowedKeys = ['Tab', 'Enter', 'ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'F8', 'F9', 'Escape'];
            if (!allowedKeys.includes(e.key) && !e.ctrlKey && !e.altKey) {
                e.preventDefault();
                return false;
            }
        }
    });

    // 4. CẬP NHẬT GIỎ HÀNG AJAX
    function updateCartAjax(id, act) {
        fetch('cart?productId=' + id + '&action=' + act)
            .then(r => r.text())
            .then(h => {
                document.getElementById('cart-ajax-container').innerHTML = h;
                const totalVal = document.getElementById('hidden-total-val')?.value || 0;
                document.getElementById('amountPaid').value = totalVal; 
                calculateDebt();
            });
    }

    // 5. TÍNH TOÁN CÔNG NỢ
    function calculateDebt() {
        const total = parseInt(document.getElementById('hidden-total-val')?.value || 0);
        const paid = parseInt(document.getElementById('amountPaid').value || 0);
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

    // 6. XỬ LÝ SUBMIT (CHẶN GIỎ TRỐNG & HIỆN MODAL)
    document.getElementById('checkout-form').addEventListener('submit', function (e) {
        const totalVal = parseInt(document.getElementById('hidden-total-val')?.value || 0);
        if (totalVal <= 0) {
            e.preventDefault();
            alert("⚠️ GIỎ HÀNG ĐANG TRỐNG!");
            return;
        }

        const paidVal = parseInt(document.getElementById('amountPaid').value) || 0;
        const phoneInput = document.getElementById('cusPhone').value.trim();
        const diff = totalVal - paidVal;

        if (phoneInput === "" && paidVal < totalVal) {
            e.preventDefault();
            alert("⚠️ KHÁCH LẺ KHÔNG ĐƯỢC NỢ!");
            document.getElementById('amountPaid').value = totalVal;
            calculateDebt();
            return;
        }

        e.preventDefault(); 
        const tempOrderId = "SIM" + Date.now();
        
        document.getElementById('display-cusName').innerText = document.getElementById('cusName').value;
        document.getElementById('display-cusPhone').innerText = phoneInput || "---";
        document.getElementById('display-date').innerText = new Date().toLocaleString('vi-VN');
        document.getElementById('display-totalPrice').innerText = totalVal.toLocaleString() + " đ";
        document.getElementById('display-amountPaid').innerText = paidVal.toLocaleString() + " đ";

        const lbl = document.getElementById('label-debt-change');
        const val = document.getElementById('display-debt-change');
        lbl.innerText = diff > 0 ? "Công nợ:" : "Tiền thừa:";
        val.innerText = Math.abs(diff).toLocaleString() + " đ";
        val.style.color = diff > 0 ? "#ef4444" : "#10b981";

        let htmlItems = '';
        document.querySelectorAll('#cart-list > div').forEach(item => {
            const nameNode = item.querySelector('.item-name') || item.querySelector('div div:first-child');
            const qtyNode = item.querySelector('input[type="number"]') || item.querySelector('span');
            const priceNode = item.querySelector('div[style*="font-weight:bold"]');
            if (nameNode) {
                htmlItems += "<tr><td>" + nameNode.innerText + "</td><td align='center'>" + (qtyNode.value || qtyNode.innerText) + "</td><td align='right'>" + (priceNode ? priceNode.innerText : "0đ") + "</td></tr>";
            }
        });
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
</script>
    </body>
</html>