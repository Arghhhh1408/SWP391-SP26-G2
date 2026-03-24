<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết khách hàng - S.I.M</title>
        <style>
            body {
                margin: 0;
                padding: 0;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: #f4f6f9;
            }

            /* Container chính né Sidebar */
            .admin-main {
                margin-left: 240px; /* Khớp với độ rộng Sidebar của bạn */
                padding: 25px;
                min-height: 100vh;
                box-sizing: border-box;
            }

            /* Header Profile */
            .profile-header {
                background: #fff;
                padding: 20px 30px;
                border-radius: 12px;
                border: 1px solid #e0e0e0;
                margin-bottom: 25px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 2px 4px rgba(0,0,0,0.02);
            }

            .box {
                background: #fff;
                border-radius: 12px;
                border: 1px solid #e2e8f0;
                margin-bottom: 25px;
                overflow: hidden;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            }

            .box-header {
                padding: 18px 25px;
                border-bottom: 1px solid #f1f5f9;
                background: #fcfcfc;
                font-weight: 700;
                color: #1e293b;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .box-body {
                padding: 25px;
            }

            /* Table Styles */
            .history-table {
                width: 100%;
                border-collapse: collapse;
            }
            .history-table th {
                background: #8b5cf6;
                color: #ffffff !important;
                padding: 14px 20px;
                text-align: left;
                font-size: 13px;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }
            .history-table td {
                padding: 14px 20px;
                border-bottom: 1px solid #f1f5f9;
                color: #475569;
                font-size: 14px;
            }
            .history-table tr:hover {
                background: #f8fafc;
            }

            /* Info Card */
            .info-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 30px;
            }
            .info-item {
                display: flex;
                margin-bottom: 12px;
                align-items: center;
            }
            .info-label {
                font-weight: 600;
                color: #64748b;
                width: 140px;
                font-size: 13px;
            }
            .info-value {
                color: #1e293b;
                font-weight: 500;
            }

            /* Buttons & Inputs */
            .btn-pay {
                background: #10b981;
                color: white;
                padding: 10px 20px;
                border: none;
                border-radius: 8px;
                cursor: pointer;
                font-weight: 600;
                transition: 0.2s;
                width: 100%;
            }
            .btn-pay:hover {
                background: #059669;
                transform: translateY(-1px);
            }

            .input-pay {
                padding: 10px 15px;
                border: 1px solid #cbd5e1;
                border-radius: 8px;
                width: 100%;
                box-sizing: border-box;
                outline: none;
            }
            .input-pay:focus {
                border-color: #8b5cf6;
                ring: 2px #ddd;
            }

            /* Tab System */
            .tab-container {
                display: flex;
                gap: 12px;
                margin-bottom: 20px;
            }
            .tab-btn {
                padding: 12px 24px;
                border: none;
                border-radius: 8px;
                cursor: pointer;
                transition: 0.3s;
                font-weight: 600;
                font-size: 14px;
            }
            .tab-btn.active {
                background: #8b5cf6 !important;
                color: white !important;
                box-shadow: 0 4px 12px rgba(139, 92, 246, 0.2);
            }
            .tab-btn.inactive {
                background: #fff;
                color: #64748b;
                border: 1px solid #e2e8f0;
            }

            .status-badge {
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 11px;
                font-weight: 700;
                background: #d1fae5;
                color: #065f46;
            }
        </style>
    </head>
    <body>
        <%-- Đảm bảo bạn đã nhúng Sidebar ở đây --%>
        <c:set var="tab" value="customers" scope="request" />
        <jsp:include page="saleSidebar.jsp" />

        <div class="admin-main">
            <div class="profile-header">
                <div>
                    <h1 style="font-size: 22px; margin: 0; color: #1e293b;">Hồ sơ khách hàng: ${customer.name}</h1>
                    <a href="sales_dashboard?tab=customers" style="color: #6366f1; text-decoration: none; font-size: 14px; font-weight: 500;">
                        ← Quay lại danh sách
                    </a>
                </div>
                <div style="text-align: right;">
                    <span style="display:block; font-size: 12px; color: #94a3b8; font-weight: 600; text-transform: uppercase;">Trạng thái nợ</span>
                    <span style="font-size: 20px; font-weight: 800; color: ${customer.debt > 0 ? '#ef4444' : '#10b981'};">
                        <fmt:formatNumber value="${customer.debt}" type="number"/> VNĐ
                    </span>
                </div>
            </div>

            <div class="admin-content">
                <div class="box">
                    <div class="box-header"><span>👤</span> Chi tiết tài khoản & Thu nợ</div>
                    <div class="box-body">
                        <div style="display: flex; gap: 50px; align-items: stretch;">
                            <div style="flex: 2;">
                                <div class="info-grid">
                                    <div>
                                        <div class="info-item">
                                            <span class="info-label">Mã khách hàng:</span>
                                            <span class="info-value">#${customer.customerId}</span>
                                        </div>
                                        <div class="info-item">
                                            <span class="info-label">Số điện thoại:</span>
                                            <span class="info-value">${customer.phone}</span>
                                        </div>
                                        <div class="info-item">
                                            <span class="info-label">Địa chỉ:</span>
                                            <span class="info-value">${customer.address}</span>
                                        </div>
                                    </div>
                                    <div>
                                        <div class="info-item">
                                            <span class="info-label">Email:</span>
                                            <span class="info-value">${customer.email}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div style="flex: 1; border-left: 1px solid #f1f5f9; padding-left: 40px;">
                                <c:choose>
                                    <c:when test="${customer.debt > 0}">
                                        <h4 style="margin: 0 0 15px 0; color: #1e293b; font-size: 16px;">Thu tiền công nợ</h4>
                                        <form action="pay_debt" method="POST">
                                            <input type="hidden" name="customerId" value="${customer.customerId}">
                                            <div style="display: flex; flex-direction: column; gap: 15px;">
                                                <div>
                                                    <label style="font-size: 12px; font-weight: 700; color: #64748b; display: block; margin-bottom: 5px;">SỐ TIỀN THU (VNĐ)</label>
                                                    <input type="number" name="amountPaid" class="input-pay" required min="1000" max="${customer.debt}" placeholder="0">
                                                </div>
                                                <div>
                                                    <label style="font-size: 12px; font-weight: 700; color: #64748b; display: block; margin-bottom: 5px;">GHI CHÚ</label>
                                                    <input type="text" name="note" class="input-pay" placeholder="Ví dụ: Tiền mặt">
                                                </div>
                                                <button type="submit" class="btn-pay">Xác nhận thu nợ</button>
                                            </div>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <div style="text-align: center; padding: 20px; background: #f0fdf4; border-radius: 12px; border: 1px solid #dcfce7;">
                                            <span style="font-size: 30px;">✅</span>
                                            <p style="color: #166534; font-weight: 600; margin: 10px 0 0 0;">Khách hàng hiện không có nợ</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="tab-container">
                    <button type="button" onclick="showTab('tab-orders')" id="btn-orders" class="tab-btn active">🛒 Lịch sử mua hàng</button>
                    <button type="button" onclick="showTab('tab-payments')" id="btn-payments" class="tab-btn inactive">💰 Lịch sử trả nợ</button>
                </div>

                <div id="tab-orders" class="box tab-content">
                    <div class="box-header"><span>📜</span> Danh sách đơn hàng đã mua</div>
                    <div class="box-body" style="padding: 0;">
                        <table class="history-table">
                            <thead>
                                <tr>
                                    <th>Mã HĐ</th>
                                    <th>Ngày mua</th>
                                    <th>Người bán</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${history}" var="o">
                                    <tr>
                                        <td>#${o.stockOutId}</td>
                                        <td>${o.date}</td>
                                        <td>${o.createdByName}</td>
                                        <td><b style="color: #1e293b;"><fmt:formatNumber value="${o.totalAmount}" type="number"/> đ</b></td>
                                        <td><span class="status-badge">Hoàn thành</span></td>
                                        <td><a href="orderdetail?id=${o.stockOutId}" 
                                               style="padding: 5px 10px; background: #f1f5f9; color: #333; text-decoration: none; border-radius: 4px; font-size: 12px; border: 1px solid #ddd;">
                                                Chi tiết
                                            </a></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty history}">
                                    <tr><td colspan="6" style="text-align: center; padding: 40px; color: #94a3b8;">Chưa có dữ liệu đơn hàng.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div id="tab-payments" class="box tab-content" style="display: none;">
                    <div class="box-header"><span>💸</span> Nhật ký thu tiền nợ</div>
                    <div class="box-body" style="padding: 0;">
                        <table class="history-table">
                            <thead>
                                <tr>
                                    <th>Ngày thu</th>
                                    <th>Số tiền thu</th>
                                    <th>Người thu</th>
                                    <th>Ghi chú</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${paymentHistory}" var="p">
                                    <tr>
                                        <td>${p.paymentDate}</td>
                                        <td style="color: #10b981; font-weight: 700;">+ <fmt:formatNumber value="${p.amount}" type="number"/> đ</td>
                                        <td>${p.staffName}</td>
                                        <td>${p.note}</td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty paymentHistory}">
                                    <tr><td colspan="4" style="text-align: center; padding: 40px; color: #94a3b8;">Chưa có lịch sử thanh toán nợ.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div> </div> <script>
                function showTab(tabId) {
                    // Ẩn tất cả nội dung tab
                    document.querySelectorAll('.tab-content').forEach(tab => tab.style.display = 'none');
                    // Hiện tab được chọn
                    document.getElementById(tabId).style.display = 'block';

                    // Cập nhật trạng thái nút
                    const btnOrders = document.getElementById('btn-orders');
                    const btnPayments = document.getElementById('btn-payments');

                    if (tabId === 'tab-orders') {
                        btnOrders.className = 'tab-btn active';
                        btnPayments.className = 'tab-btn inactive';
                    } else {
                        btnOrders.className = 'tab-btn inactive';
                        btnPayments.className = 'tab-btn active';
                    }
                }
        </script>
    </body>
</html>