<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết đơn hàng #${orderHeader.stockOutId}</title>
        <style>
            .detail-container {
                padding: 20px;
                max-width: 800px;
                margin: auto;
                background: #fff;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .detail-header {
                display: flex;
                justify-content: space-between;
                border-bottom: 2px solid #eee;
                padding-bottom: 15px;
                margin-bottom: 20px;
            }
            .info-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
                margin-bottom: 30px;
            }
            .info-item label {
                color: #666;
                font-size: 13px;
                display: block;
                margin-bottom: 5px;
            }
            .info-item span {
                font-weight: bold;
                font-size: 15px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
            }
            table th {
                background: #f8fafc;
                padding: 12px;
                text-align: left;
                border-bottom: 2px solid #e2e8f0;
            }
            table td {
                padding: 12px;
                border-bottom: 1px solid #eee;
            }
            .total-section {
                margin-top: 20px;
                text-align: right;
                border-top: 2px solid #eee;
                padding-top: 15px;
            }
            .total-row {
                font-size: 18px;
                font-weight: bold;
                color: #3b82f6;
            }
            .btn-back {
                display: inline-block;
                padding: 10px 20px;
                background: #64748b;
                color: #fff;
                text-decoration: none;
                border-radius: 4px;
                margin-bottom: 20px;
            }
            #invoiceModal {
                display: none; /* Mặc định ẩn */
                position: fixed;
                z-index: 10000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.6);
                backdrop-filter: blur(3px);
                align-items: center;
                justify-content: center;
            }
            .modal-content {
                background: white;
                width: 450px;
                border-radius: 12px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                position: relative;
                font-family: 'Courier New', Courier, monospace;
            }
            @media print {
    /* 1. Ẩn mọi thứ không liên quan */
    .no-print, .admin-sidebar, .admin-topbar, .btn-back { 
        display: none !important; 
    }

    /* 2. Ép nội dung in ra giữa trang */
    body {
        visibility: hidden;
        margin: 0;
        padding: 0;
        display: flex;
        justify-content: center; /* Căn giữa theo chiều ngang */
    }

    /* 3. Chỉ hiển thị vùng hóa đơn và định dạng lại độ rộng */
    #invoice-print-area {
        visibility: visible;
        position: absolute;
        top: 0;
        width: 300px; /* Độ rộng chuẩn cho máy in nhiệt K80 */
        left: 50%;
        transform: translateX(-50%); /* Kỹ thuật căn giữa tuyệt đối */
        border: none;
    }

    /* 4. Xóa Header/Footer mặc định của trình duyệt (Ngày tháng, URL ở góc) */
    @page {
        margin: 0;
    }
}
        </style>
    </head>
    <div id="invoiceModal">
        <div class="modal-content">
            <span onclick="closeModal()" class="no-print" style="position:absolute; right:15px; top:10px; font-size:28px; cursor:pointer;">&times;</span>

            <div class="invoice-card" id="invoice-print-area" style="padding: 30px; color: #000;">
                <div style="text-align: center; border-bottom: 1px dashed #ddd; padding-bottom: 10px;">
                    <h2 style="margin:0;">S.I.M MARKET</h2>
                    <p style="margin:5px 0;">Ngày: ${orderHeader.createdAt}</p>
                </div>

                <div style="margin: 15px 0; font-size: 14px;">
                    <p><strong>Khách:</strong> ${not empty orderHeader.customerName ? orderHeader.customerName : "Khách lẻ"}</p>
                    <p><strong>SĐT:</strong> ${not empty orderHeader.customerPhone ? orderHeader.customerPhone : "---"}</p>
                </div>

                <table style="width: 100%; border-collapse: collapse; margin: 15px 0;">
                    <thead>
                        <tr style="border-bottom: 1px solid #000;">
                            <th align="left">Sản phẩm</th>
                            <th style="text-align:center">SL</th>
                            <th style="text-align:right">T.Tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${orderItems}" var="item">
                            <tr style="border-bottom: 1px solid #f5f5f5;">
                                <td style="font-size: 13px;">${item.name}</td>
                                <td align="center">${item.quantity}</td>
                                <td align="right"><fmt:formatNumber value="${item.lineTotal}" type="number"/>đ</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <div style="border-top: 2px solid #000; padding-top: 10px;">
                    <div style="display: flex; justify-content: space-between; font-weight: bold; font-size: 16px;">
                        <span>Tổng cộng:</span>
                        <span><fmt:formatNumber value="${orderHeader.totalAmount}" type="number"/> đ</span>
                    </div>
                </div>
            </div>

            <div style="display: flex; gap: 10px; padding: 15px 30px 25px; background: #f8fafc; border-bottom-left-radius: 12px; border-bottom-right-radius: 12px;" class="no-print">
                <button onclick="window.print()" style="flex:1; background:#10b981; color:white; padding:12px; border:none; border-radius:6px; cursor:pointer; font-weight:bold;">🖨️ IN</button>
            </div>
        </div>
    </div>
    <body>

        <div class="detail-container">
            <c:choose>
                <c:when test="${sessionScope.acc.roleID == 2}">
                    <a href="${pageContext.request.contextPath}/notifications" class="btn-back">⬅ Quay lại</a>
                </c:when>
                <c:otherwise>
                    <a href="sales_dashboard?tab=orders" class="btn-back">⬅ Quay lại danh sách</a>
                </c:otherwise>
            </c:choose>


            <div class="detail-header">
                <h2 style="margin:0;">Chi tiết đơn hàng #${orderHeader.stockOutId}</h2>
                <span style="padding: 5px 10px; background: #dcfce7; color: #166534; border-radius: 20px; font-size: 12px; font-weight: bold;">Hoàn tất</span>
                <button onclick="printBill()" style="padding: 6px 12px; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer;">
                    <span>🖨️</span> In lại hóa đơn
                </button>
            </div>

            <div class="info-grid">
                <div class="info-item">
                    <label>Khách hàng</label>
                    <span>${not empty orderHeader.customerName ? orderHeader.customerName : "Khách vãng lai"}</span>
                </div>
                <div class="info-item">
                    <label>Số điện thoại</label>
                    <span>${not empty orderHeader.customerPhone ? orderHeader.customerPhone : "---"}</span>
                </div>
                <div class="info-item">
                    <label>Ngày tạo</label>
                    <span>${orderHeader.createdAt}</span>
                </div>
                <div class="info-item">
                    <label>Người lập đơn</label>
                    <span>${orderHeader.createdBy}</span>
                </div>
            </div>

            <c:if test="${not empty orderHeader.note}">
                <div style="background: #fff9db; padding: 10px; border-radius: 4px; margin-bottom: 20px; font-style: italic;">
                    <strong>Ghi chú:</strong> ${orderHeader.note}
                </div>
            </c:if>

            <table>
                <thead>
                    <tr>
                        <th>Sản phẩm</th>
                        <th>SKU</th>
                        <th style="text-align: center;">Số lượng</th>
                        <th style="text-align: right;">Đơn giá</th>
                        <th style="text-align: right;">Thành tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${orderItems}" var="item">
                        <tr>
                            <td>${item.name}</td>
                            <td><code style="background:#f1f5f9; padding:2px 4px;">${item.sku}</code></td>
                            <td style="text-align: center;">${item.quantity}</td>
                            <td style="text-align: right;"><fmt:formatNumber value="${item.price}" type="number"/>đ</td>
                            <td style="text-align: right; font-weight: bold;">
                                <fmt:formatNumber value="${item.lineTotal}" type="number"/>đ
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <div class="total-section">
                <div class="total-row">
                    Tổng cộng: <fmt:formatNumber value="${orderHeader.totalAmount}" type="number"/> VNĐ
                </div>
            </div>
        </div>
    </body>
    <script>
        function printBill() {
            // Thay đổi kiểu hiển thị của Modal từ ẩn sang hiện (Flex)
            document.getElementById('invoiceModal').style.display = 'flex';
        }

        function closeModal() {
            document.getElementById('invoiceModal').style.display = 'none';
        }

        // Đóng bằng phím Esc cho tiện
        document.addEventListener('keydown', function (e) {
            if (e.key === "Escape")
                closeModal();
        });
    </script>
</html>
