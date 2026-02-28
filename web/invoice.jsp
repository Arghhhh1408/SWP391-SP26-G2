<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
        <jsp:useBean id="now" class="java.util.Date" />

<!DOCTYPE html>
<html>
<head>
    <title>Hóa đơn</title>
    <style>
        body {
            width: 80mm;
            margin: 0 auto;
            font-family: monospace;
            font-size: 12px;
        }
        .center { text-align: center; }
        .line { border-top: 1px dashed #000; margin: 6px 0; }
        .row {
            display: flex;
            justify-content: space-between;
        }
        .small { font-size: 11px; }
        .no-print { margin-top: 10px; text-align: center; }
        @media print {
            .no-print { display: none; }
        }
    </style>
    
</head>

    <body>
        
    <div class="center">
        <b>Điện tử Độ Mixi</b><br/>
        Địa chỉ: Cao Bằng<br/>

    </div>

    <div class="line"></div>

    <div class="center"><b>HÓA ĐƠN BÁN HÀNG</b></div>

    <div class="small">
        Ngày: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy HH:mm:ss"/><br/>
    </div>

    <!-- HIỂN THỊ TRÊN HÓA ĐƠN -->
    <div class="small">
        Khách hàng: ${sessionScope.customerName}<br/>
        SĐT: ${sessionScope.customerPhone}
    </div>

    <div class="line"></div>

    <!-- DANH SÁCH SẢN PHẨM -->
    <c:set var="grandTotal" value="0" />
    <c:forEach items="${lastOrder.values()}" var="it">
        <div>
            ${it.name}
            <div class="row">
                <span>${it.qty} x ${it.price}</span>
                <span>${it.lineTotal}</span>
            </div>
        </div>
        <c:set var="grandTotal" value="${grandTotal + it.lineTotal}" />
    </c:forEach>

    <div class="line"></div>

    <div class="row">
        <b>TỔNG TIỀN</b>
        <b>${lastTotal}</b>
    </div>

    <div class="line"></div>

    <div class="center small">
        Xin cảm ơn quý khách!<br/>
        Hẹn gặp lại ❤️
    </div>

    <!-- NÚT -->
    <div class="no-print">
        <button type="button" onclick="window.print()">In hóa đơn</button>

        <button type="button" onclick="submitFinish()"> Hoàn tất</button>

        <a href="${pageContext.request.contextPath}/pos">Quay lại POS</a>
    </div>

    <form id="finishForm"
          action="${pageContext.request.contextPath}/invoice/finish"
          method="post">
        <input type="hidden" name="note" value="" />

        <!-- thêm 2 hidden này để JS đổ dữ liệu -->
        <input type="hidden" name="customerName" value="${sessionScope.customerName}" />
        <input type="hidden" name="customerPhone" value="${sessionScope.customerPhone}" />
    </form>




    <script>
    function submitFinish() {
      // nếu bạn có nơi lưu tên/sđt thì gán vào hidden ở đây
      // hiện tại invoice.jsp không có input customerName/customerPhone nên sẽ gửi rỗng
      document.getElementById('finishForm').submit();
    }
</script>


    </body>
    </html>
