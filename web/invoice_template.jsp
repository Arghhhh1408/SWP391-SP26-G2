<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<style>
    .invoice-card {
        background: #fff;
        padding: 20px;
        font-family: 'Courier New', Courier, monospace;
        color: #000;
        width: 100%;
    }
    .invoice-header { text-align: center; margin-bottom: 20px; }
    .invoice-header h2 { margin: 0; text-transform: uppercase; }
    .invoice-info { font-size: 13px; margin-bottom: 15px; }
    .invoice-table { width: 100%; border-collapse: collapse; margin-bottom: 15px; }
    .invoice-table th { border-bottom: 1px solid #000; text-align: left; padding: 5px; }
    .invoice-table td { padding: 5px; vertical-align: top; }
    .total-section { border-top: 1px dashed #000; padding-top: 10px; }
    .total-row { display: flex; justify-content: space-between; font-weight: bold; margin-bottom: 5px; }
    
    @media print {
        body * { visibility: hidden; }
        #invoice-print-area, #invoice-print-area * { visibility: visible; }
        #invoice-print-area { position: absolute; left: 0; top: 0; width: 100%; }
        .no-print { display: none; }
    }
</style>

<div class="invoice-card" id="invoice-print-area">
    <div class="invoice-header">
        <h2>HÓA ĐƠN BÁN LẺ</h2>
        <p>Ngày: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy HH:mm"/></p>
    </div>

    <div class="invoice-info">
        <div><strong>Khách hàng:</strong> ${param.cusName}</div>
        <div><strong>SĐT:</strong> ${param.cusPhone}</div>
        <c:if test="${not empty param.note}">
            <div><strong>Ghi chú:</strong> ${param.note}</div>
        </c:if>
    </div>

    <table class="invoice-table">
        <thead>
            <tr>
                <th>SP</th>
                <th style="text-align: center;">SL</th>
                <th style="text-align: right;">T.Tiền</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${sessionScope.cart}" var="entry">
                <c:set var="item" value="${entry.value}" />
                <tr>
                    <td>${item.name}</td>
                    <td style="text-align: center;">${item.qty}</td>
                    <td style="text-align: right;"><fmt:formatNumber value="${item.price * item.qty}" type="number"/>đ</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <div class="total-section">
        <div class="total-row">
            <span>Tổng cộng:</span>
            <span><fmt:formatNumber value="${totalPrice}" type="number"/>đ</span>
        </div>
        <div class="total-row">
            <span>Khách trả:</span>
            <span><fmt:formatNumber value="${param.amountPaid}" type="number"/>đ</span>
        </div>
        <div class="total-row" style="color: red;">
            <span>Công nợ:</span>
            <span>${param.debt} đ</span>
        </div>
    </div>
    <p style="text-align: center; margin-top: 20px; font-style: italic;">Cảm ơn quý khách!</p>
</div>