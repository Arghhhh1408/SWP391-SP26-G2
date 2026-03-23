<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết khách hàng - S.I.M</title>
        <style>
            .admin-main {
                margin-left: 240px;
                padding: 20px;
                background: #f4f6f9;
                min-height: 100vh;
                font-family: sans-serif;
            }
            .box {
                background: #fff;
                border-radius: 8px;
                border: 1px solid #e0e0e0;
                margin-bottom: 20px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            }
            .box-header {
                padding: 15px 20px;
                border-bottom: 1px solid #eee;
                background: #fcfcfc;
                font-weight: bold;
                color: #333;
            }
            .box-body {
                padding: 20px;
            }

            /* Table Styles */
            .history-table {
                width: 100%;
                border-collapse: collapse;
                background: #fff;
            }
            .history-table th {
                background: #8b5cf6;
                color: #ffffff !important; /* Ép chữ tiêu đề màu trắng */
                padding: 12px;
                text-align: left;
                font-weight: 600;
            }
            .history-table td {
                padding: 12px;
                border-bottom: 1px solid #eee;
                color: #444; /* Màu chữ nội dung bảng */
            }
            .history-table tr:hover {
                background: #f9fafb;
            }

            .info-label {
                font-weight: bold;
                color: #666;
                width: 150px;
                display: inline-block;
            }
            .info-value {
                color: #111;
                font-weight: 500;
            }
            .btn-back {
                font-size: 13px;
                color: #3b82f6;
                text-decoration: none;
                display: inline-block;
                margin-top: 5px;
            }
        </style>
    </head>
    <body>
        <c:set var="currentPage" value="customer" scope="request" />
        <jsp:include page="saleSidebar.jsp" />

        <div class="admin-main">
            <div style="background: #fff; padding: 15px 25px; border-bottom: 1px solid #e0e0e0; margin-bottom: 20px; border-radius: 8px;">
                <h1 style="font-size: 20px; margin: 0; color: #111;">Hồ sơ khách hàng: ${customer.name}</h1>
                <a href="sales_dashboard?tab=customers" class="btn-back">← Quay lại danh sách</a>
            </div>

            <div class="admin-content">
                <div class="box">
                    <div class="box-body">
                        <div style="display: flex; gap: 50px;">
                            <div style="flex: 1;">
                                <p><span class="info-label">Mã khách hàng:</span> <span class="info-value">#${customer.customerId}</span></p>
                                <p><span class="info-label">Số điện thoại:</span> <span class="info-value">${customer.phone}</span></p>
                                <p><span class="info-label">Địa chỉ:</span> <span class="info-value">${customer.address}</span></p>
                            </div>
                            <div style="flex: 1;">
                                <p><span class="info-label">Tổng công nợ:</span> <span class="info-value" style="color: #ef4444;"><fmt:formatNumber value="${customer.debt}" type="number"/> VNĐ</span></p>
                                <p><span class="info-label">Email:</span> <span class="info-value">${customer.email}</span></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="box">
                    <div class="box-header">📜 Lịch sử giao dịch (Đơn hàng đã mua)</div>
                    <div class="box-body">
                        <table class="history-table">
                            <thead>
                                <tr>
                                    <th>Mã HĐ</th>
                                    <th>Ngày mua</th>
                                    <th>Người bán</th>
                                    <th>Tổng tiền</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${order}" var="o">
                                    <tr>
                                        <td>#${o.customerid}</td>
                                        <td>${o.date}</td>
                                        <td>${o.staffName}</td>
                                        <td><b><fmt:formatNumber value="${o.total}" type="number"/> đ</b></td>
                                        <td><a href="#" style="color: #8b5cf6;">Xem hóa đơn</a></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty history}">
                                    <tr>
                                        <td colspan="5" style="text-align: center; padding: 30px; color: #999;">Khách hàng này chưa có giao dịch nào.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>