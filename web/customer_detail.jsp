<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết khách hàng</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #f4f7f6;
                padding: 20px;
            }
            .container {
                max-width: 900px;
                margin: auto;
                background: white;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-bottom: 2px solid #eee;
                padding-bottom: 10px;
            }
            .info-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
                margin: 20px 0;
                padding: 15px;
                background: #f9f9f9;
                border-radius: 5px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
            }
            th, td {
                padding: 12px;
                border: 1px solid #ddd;
                text-align: left;
            }
            th {
                background: #8b5cf6;
                color: white;
            }
            .btn-back {
                text-decoration: none;
                color: #666;
                font-size: 14px;
            }
            .debt-high {
                color: red;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h2>Hồ sơ khách hàng: ${customer.name}</h2>
                <a href="sales_dashboard?tab=customers" class="btn-back">⬅ Quay lại danh sách</a>
            </div>

            <div class="info-grid">
                <div>
                    <p><strong>Mã khách hàng:</strong> #${customer.customerId}</p>
                    <p><strong>Số điện thoại:</strong> ${customer.phone}</p>
                    <p><strong>Địa chỉ:</strong> ${customer.address}</p>
                </div>
                <div>
                    <p><strong>Tổng công nợ:</strong> 
                        <span class="${customer.debt > 0 ? 'debt-high' : ''}">
                            <fmt:formatNumber value="${customer.debt}" type="number"/> VNĐ
                        </span>
                    </p>
                    <p><strong>Email:</strong> ${customer.email}</p>
                </div>
            </div>
            <%-- Thêm vào trong div bên phải của info-grid --%>
            <c:if test="${customer.debt > 0}">
                <form action="update_debt" method="post" style="margin-top: 10px;">
                    <input type="hidden" name="customerId" value="${customer.customerId}">
                    <input type="number" name="payAmount" placeholder="Nhập số tiền khách trả..." required 
                           style="padding: 5px; border: 1px solid #ddd; border-radius: 4px;">
                    <button type="submit" style="background: #10b981; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer;">
                        Thu nợ
                    </button>
                </form>
            </c:if>

            <h3>📜 Lịch sử giao dịch (Đơn hàng đã mua)</h3>
            <table>
                <thead>
                    <tr>
                        <th>Mã HĐ</th>
                        <th>Ngày mua</th>
                        <th>Người bán</th>
                        <th>Tổng tiền</th>
                        <th>Ghi chú</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${history}" var="h">
                        <tr>
                            <td>#${h.stockOutId}</td>
                            <td><fmt:formatDate value="${h.date}" pattern="dd/MM/yyyy HH:mm"/></td>
                            <td>${h.createdByName}</td>
                            <td><strong><fmt:formatNumber value="${h.totalAmount}" type="number"/></strong> đ</td>
                            <td>${h.note}</td>
                            <td>
                                <a href="orderdetail?id=${h.stockOutId}" style="color: #8b5cf6;">Xem hóa đơn</a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty history}">
                        <tr><td colspan="6" align="center">Khách hàng này chưa có giao dịch nào.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </body>
</html>