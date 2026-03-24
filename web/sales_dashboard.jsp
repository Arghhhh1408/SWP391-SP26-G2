<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <title>S.I.M - Sales Management</title>
        <style>
            /* --- CSS TỔNG THỂ --- */
            .admin-main {
                margin-left: 240px;
                padding: 20px;
                transition: all 0.3s;
            }
            .admin-topbar {
                background: #fff;
                padding: 15px 25px;
                border-bottom: 1px solid #e0e0e0;
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
                border-radius: 8px;
            }
            .box {
                background: #fff;
                border-radius: 8px;
                border: 1px solid #e0e0e0;
                margin-bottom: 20px;
                overflow: hidden;
            }
            .box-header {
                padding: 15px 20px;
                border-bottom: 1px solid #eee;
                background: #fcfcfc;
            }
            .box-body {
                padding: 20px;
            }
            .btn {
                padding: 8px 16px;
                border-radius: 4px;
                border: none;
                cursor: pointer;
                font-weight: bold;
            }

            /* Table Style cho Cường */
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 10px;
            }
            table th {
                background: #f8fafc;
                padding: 12px;
                text-align: left;
                border-bottom: 2px solid #e2e8f0;
            }
            table td {
                padding: 12px;
                border-bottom: 1px solid #e2e8f0;
            }

            /* Dashboard & POS Style */
            .dashboard-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
                gap: 20px;
                margin-bottom: 25px;
            }
            .stat-card {
                background: #fff;
                padding: 20px;
                border-radius: 12px;
                border: 1px solid #e0e0e0;
                position: relative;
                overflow: hidden;
            }
            .stat-card::before {
                content: "";
                position: absolute;
                left: 0;
                top: 0;
                height: 100%;
                width: 5px;
            }
            .card-blue::before {
                background: #3b82f6;
            }
            .card-green::before {
                background: #10b981;
            }
            .card-purple::before {
                background: #8b5cf6;
            }
            .stat-label {
                font-size: 12px;
                color: #6b7280;
                text-transform: uppercase;
                font-weight: 700;
            }
            .stat-value {
                font-size: 24px;
                font-weight: 800;
                margin-top: 8px;
                color: #1a1a2e;
            }
            .pos-wrapper {
                display: flex;
                gap: 20px;
                align-items: flex-start;
            }
            .cart-box {
                background: white;
                border-radius: 8px;
                border: 1px solid #3b82f6;
                padding: 20px;
            }
            .cart-item {
                display: flex;
                justify-content: space-between;
                padding: 8px 0;
                border-bottom: 1px dashed #eee;
                font-size: 14px;
            }
            .total-price {
                font-size: 20px;
                font-weight: bold;
                color: #3b82f6;
                text-align: right;
                margin: 15px 0;
            }
        </style>
    </head>

    <body>
        <c:set var="currentPage" value="sales_dashboard" scope="request" />
        <jsp:include page="saleSidebar.jsp" />

        <div class="admin-main">
            <div class="admin-topbar">
                <div>
                    <h1 style="font-size: 20px; margin: 0;">Trang quản lý Sales</h1>
                    <small style="color: #888;">Salesperson &rsaquo; ${tab}</small>
                </div>
                <div>Xin chào, <strong>${sessionScope.acc.fullName}</strong></div>
            </div>

            <div class="admin-content">
                <c:choose>
                    <%-- 1. BÁN HÀNG (POS) --%>
                    <c:when test="${tab == 'pos'}">
                        <jsp:include page="pos_fragment.jsp" />
                    </c:when>

                    <%-- 2. TẠO BẢO HÀNH (CỦA CƯỜNG) --%>
                    <c:when test="${tab == 'warranty-create'}">
                        <div class="box">
                            <div class="box-header"><h3>Tạo yêu cầu bảo hành</h3></div>
                            <div class="box-body">
                                <form action="sales_dashboard" method="post">
                                    <input type="hidden" name="action" value="createWarranty">
                                    <div style="margin-bottom:15px;"><label>SKU (*)</label><br><input name="sku" required value="${sku}" style="width:100%; padding:8px;"></div>
                                    <div style="margin-bottom:15px;"><label>Tên khách hàng (*)</label><br><input name="customerName" required value="${customerName}" style="width:100%; padding:8px;"></div>
                                    <div style="margin-bottom:15px;"><label>Mô tả lỗi (*)</label><br><textarea name="issueDescription" required style="width:100%; padding:8px; height:100px;">${issueDescription}</textarea></div>
                                    <button type="submit" class="btn" style="background:#1a1a2e; color:white;">Gửi yêu cầu</button>
                                </form>
                            </div>
                        </div>
                    </c:when>

                    <%-- 3. TRA CỨU BẢO HÀNH (CỦA CƯỜNG) --%>
                    <c:when test="${tab == 'warranty-lookup'}">
                        <div class="box">
                            <div class="box-header"><h3>Tra cứu bảo hành</h3></div>
                            <div class="box-body">
                                <form action="sales_dashboard" method="get" style="margin-bottom:20px; display:flex; gap:10px;">
                                    <input type="hidden" name="tab" value="warranty-lookup">
                                    <input type="text" name="q" value="${q}" placeholder="Tìm SKU, khách hàng..." style="flex:1; padding:8px;">
                                    <button type="submit" class="btn" style="background:#3b82f6; color:white;">Tìm</button>
                                </form>
                                <table>
                                    <thead><tr><th>Mã yêu cầu</th><th>SKU</th><th>Khách hàng</th><th>Trạng thái</th></tr></thead>
                                    <tbody>
                                        <c:forEach items="${claims}" var="c">
                                            <tr><td>${c.claimCode}</td><td>${c.sku}</td><td>${c.customerName}</td><td>${c.status}</td></tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:when>

                    <%-- 4. TẠO TRẢ HÀNG (CỦA CƯỜNG) --%>
                    <c:when test="${tab == 'return-create'}">
                        <div class="box">
                            <div class="box-header"><h3>Tạo yêu cầu trả hàng</h3></div>
                            <div class="box-body">
                                <form action="sales_dashboard" method="post">
                                    <input type="hidden" name="action" value="createReturn">
                                    <div style="margin-bottom:15px;"><label>SKU Trả (*)</label><br><input name="returnSku" required value="${returnSku}" style="width:100%; padding:8px;"></div>
                                    <div style="margin-bottom:15px;"><label>Lý do trả hàng (*)</label><br><textarea name="returnReason" required style="width:100%; padding:8px; height:100px;">${returnReason}</textarea></div>
                                    <button type="submit" class="btn" style="background:#1a1a2e; color:white;">Gửi yêu cầu trả</button>
                                </form>
                            </div>
                        </div>
                    </c:when>

                    <%-- 5. TRA CỨU TRẢ HÀNG (CỦA CƯỜNG) --%>
                    <c:when test="${tab == 'return-lookup'}">
                        <div class="box">
                            <div class="box-header"><h3>Tra cứu trả hàng</h3></div>
                            <div class="box-body">
                                <form action="sales_dashboard" method="get" style="margin-bottom:20px; display:flex; gap:10px;">
                                    <input type="hidden" name="tab" value="return-lookup">
                                    <input type="text" name="rq" value="${rq}" placeholder="Tìm mã trả hàng..." style="flex:1; padding:8px;">
                                    <button type="submit" class="btn" style="background:#3b82f6; color:white;">Tìm</button>
                                </form>
                                <table>
                                    <thead><tr><th>Mã trả hàng</th><th>SKU</th><th>Khách hàng</th><th>Trạng thái</th></tr></thead>
                                    <tbody>
                                        <c:forEach items="${returnClaims}" var="r">
                                            <tr><td>${r.returnCode}</td><td>${r.sku}</td><td>${r.customerName}</td><td>${r.status}</td></tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:when>
                    <%-- TAB LỊCH SỬ ĐƠN HÀNG --%>
                    <c:when test="${tab == 'orders' || activeTab == 'orders'}">
                        <jsp:include page="order_fragment.jsp" />
                    </c:when>

                    <%-- 6. QUẢN LÝ KHÁCH HÀNG --%>
                    <c:when test="${tab == 'customers'}">
                        <jsp:include page="customer_list_fragment.jsp" />
                    </c:when>

                    <%-- 7. XEM TẤT CẢ SẢN PHẨM --%>
                    <c:when test="${tab == 'products'}">
                        <jsp:include page="products_list_fragment.jsp" />
                    </c:when>
                    <%-- MẶC ĐỊNH LÀ DASHBOARD --%>
                    <c:when test="${(tab == 'dashboard' || empty tab) && activeTab != 'orders'}">
                        <jsp:include page="sales_dashboardFragment.jsp" />
                    </c:when>
                </c:choose>
            </div>
        </div>

        <script>
            // 1. Danh sách khách hàng mẫu (Để test không cần Servlet mới)
            // Sau này Mạnh Lý có thể dùng c:forEach để đổ dữ liệu thật từ DB vào mảng này
            // Đổ dữ liệu từ Java List sang JavaScript Array
            const customerList = [
            <c:forEach items="${customers}" var="c">
                {phone: "${c.phone}", name: "${c.name}"},
            </c:forEach>
            ];

            function findCustomerByPhone(phone) {
                const cusNameInput = document.getElementById('cusName');
                // Tìm khách có SĐT khớp
                const customer = customerList.find(c => c.phone.trim() === phone.trim());

                if (customer) {
                    cusNameInput.value = customer.name;
                    cusNameInput.style.background = "#e0f2fe"; // Đổi màu nền cho biết đã tìm thấy
                } else {
                    cusNameInput.value = "";
                    cusNameInput.style.background = "#fff";
                }
            }

            // 2. Hàm cập nhật giỏ hàng qua Ajax (Giữ nguyên)
            function updateCartAjax(productId, action) {
                fetch('cart?productId=' + productId + '&action=' + action)
                        .then(response => response.text())
                        .then(html => {
                            document.getElementById('cart-ajax-container').innerHTML = html;
                        });
            }

            // 3. Hàm hiển thị Popup Hóa đơn
            function showInvoice(event) {
                event.preventDefault();

                // 1. Lấy dữ liệu tổng tiền
                const totalElement = document.getElementById('hidden-total-val');
                if (!totalElement || parseFloat(totalElement.getAttribute('data-total')) <= 0) {
                    alert("Giỏ hàng đang trống!");
                    return;
                }
                const total = parseFloat(totalElement.getAttribute('data-total'));

                // TỰ ĐỘNG ĐIỀN SỐ TIỀN THANH TOÁN (Nếu ô đang trống hoặc chưa nhập)
                const paidInput = document.getElementById('amountPaid');
                if (!paidInput.value || paidInput.value == 0) {
                    paidInput.value = total; // Mặc định là khách trả đủ
                }
                const paid = parseFloat(paidInput.value) || 0;

                // 2. Lấy Ngày & Giờ hiện tại
                const now = new Date();
                const dateStr = now.toLocaleDateString('vi-VN');
                const timeStr = now.toLocaleTimeString('vi-VN', {hour: '2-digit', minute: '2-digit'});

                // 3. Thông tin Khách hàng & Thời gian
                let infoHtml = '<div style="display:flex; justify-content:space-between; font-size:12px;">' +
                        '<span>Ngày: ' + dateStr + '</span>' +
                        '<span>Giờ: ' + timeStr + '</span>' +
                        '</div>' +
                        '<p style="margin: 5px 0; text-align:left;">Khách hàng: <b>' + (document.getElementById('cusName').value || "Khách lẻ") + '</b></p>' +
                        '<p style="margin: 5px 0; text-align:left;">SĐT: ' + (document.getElementById('cusPhone').value || "N/A") + '</p>';

                document.getElementById('invoiceInfo').innerHTML = infoHtml;

                // 4. Danh sách sản phẩm (Quét từ giỏ hàng Ajax)
                let itemsHtml = '<tr style="border-bottom: 1px solid #000;">' +
                        '<th align="left">Sản phẩm</th>' +
                        '<th align="center">SL</th>' +
                        '<th align="right">T.Tiền</th>' +
                        '</tr>';

                const cartRows = document.querySelectorAll('#cart-list > div');
                cartRows.forEach(function (row) {
                    const name = row.querySelector('.item-name') ? row.querySelector('.item-name').innerText : "Sản phẩm";
                    const qty = row.querySelector('span') ? row.querySelector('span').innerText : "1";
                    const priceText = row.querySelector('div:last-child') ? row.querySelector('div:last-child').innerText : "0đ";

                    itemsHtml += '<tr>' +
                            '<td style="font-size:11px;">' + name + '</td>' +
                            '<td align="center" style="font-size:11px;">' + qty + '</td>' +
                            '<td align="right" style="font-size:11px;">' + priceText + '</td>' +
                            '</tr>';
                });
                document.getElementById('invoiceItems').innerHTML = itemsHtml;

                // 5. Tính toán tiền và nợ
                const debt = total - paid;
                let totalHtml = '<div style="margin-top:10px; border-top:1px dashed #000; padding-top:5px; font-size:14px;">' +
                        '<div style="display:flex; justify-content:space-between;">' +
                        '<span>Tổng cộng:</span><span>' + total.toLocaleString() + ' đ</span>' +
                        '</div>' +
                        '<div style="display:flex; justify-content:space-between;">' +
                        '<span>Khách thanh toán:</span><b>' + paid.toLocaleString() + ' đ</b>' +
                        '</div>';

                if (debt > 0) {
                    totalHtml += '<div style="display:flex; justify-content:space-between; color:red; font-weight:bold;">' +
                            '<span>Còn nợ:</span><span>' + debt.toLocaleString() + ' đ</span>' +
                            '</div>';
                } else if (paid > total) {
                    totalHtml += '<div style="display:flex; justify-content:space-between; color:green;">' +
                            '<span>Tiền thừa:</span><span>' + (paid - total).toLocaleString() + ' đ</span>' +
                            '</div>';
                }

                totalHtml += '</div>';
                document.getElementById('invoiceTotal').innerHTML = totalHtml;

                // 6. Hiện Popup
                document.getElementById('invoiceModal').style.display = 'flex';
            }

            function closeInvoice() {
                document.getElementById('invoiceModal').style.display = 'none';
            }

            // 4. Hàm THỰC SỰ gửi dữ liệu về CheckoutController
            function confirmCheckout() {
                document.getElementById('checkout-form').submit();
            }

            // Hàm tính nợ (Gọi mỗi khi nhập tiền)
            function calculateDebt() {
                const totalElement = document.getElementById('hidden-total-val');
                const total = totalElement ? parseFloat(totalElement.getAttribute('data-total')) : 0;
                const paid = parseFloat(document.getElementById('amountPaid').value) || 0;
                const debt = total - paid;
                document.getElementById('debt-amount').innerText = (debt > 0 ? debt : 0).toLocaleString() + " đ";
            }

            // Hàm này tự chạy sau khi Ajax update giỏ hàng
            window.updateAmountsAfterAjax = function () {
                const total = parseFloat(document.getElementById('hidden-total-val').getAttribute('data-total')) || 0;
                document.getElementById('amountPaid').value = total; // Tự điền số tiền trả đủ
                calculateDebt();
            };
        </script>
    </body>
</html>