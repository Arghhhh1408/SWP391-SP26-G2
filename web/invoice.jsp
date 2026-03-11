<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:useBean id="now" class="java.util.Date" />

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Hóa đơn</title>
    <style>
        :root{
            --w: 80mm;
        }

        body{
            width: var(--w);
            margin: 0 auto;
            padding: 10px 8px;
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
            font-size: 12px;
            color: #111;
            background: #fff;
        }

        .receipt{
            border: 1px solid #000;
            padding: 10px 8px;
            border-radius: 6px;
        }

        .center{ text-align:center; }

        .store-name{
            font-size: 14px;
            font-weight: 800;
            letter-spacing: .2px;
        }

        .store-sub{
            font-size: 11px;
            margin-top: 2px;
        }

        .title{
            font-size: 13px;
            font-weight: 900;
            margin: 6px 0 0;
        }

        .meta{
            font-size: 11px;
            margin-top: 6px;
            line-height: 1.35;
        }

        .line{
            border-top: 1px dashed #000;
            margin: 8px 0;
        }

        .kv{
            display:flex;
            justify-content: space-between;
            gap: 8px;
        }

        .kv .k{ color:#333; }
        .kv .v{ text-align:right; }

        .items{ margin-top: 2px; }

        .item{ margin: 6px 0; }

        .item-name{
            font-weight: 700;
            word-break: break-word;
        }

        .row{
            display:flex;
            justify-content: space-between;
            gap: 8px;
        }

        .muted{
            color:#333;
            font-size: 11px;
        }

        .money{
            font-variant-numeric: tabular-nums;
            white-space: nowrap;
        }

        .total{
            display:flex;
            justify-content: space-between;
            align-items: baseline;
            font-weight: 900;
            font-size: 13px;
        }

        .thanks{
            margin-top: 8px;
            line-height: 1.35;
            font-size: 11px;
        }

        .no-print{
            margin-top: 10px;
            display:flex;
            justify-content:center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .btn{
            border: 1px solid #111;
            background: #111;
            color: #fff;
            padding: 8px 10px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 12px;
        }

        .link-btn{
            border: 1px solid #111;
            background:#fff;
            color:#111;
            padding: 8px 10px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 12px;
            text-decoration:none;
        }

        @media print{
            body{
                padding: 0;
            }

            .receipt{
                border: none;
                padding: 0;
                border-radius: 0;
            }

            .no-print{
                display:none;
            }
        }
    </style>
</head>

<body>
    <div class="receipt">

        <div class="center">
            <div class="store-name">Điện tử Độ Mixi</div>
            <div class="store-sub">Địa chỉ: Cao Bằng</div>
        </div>

        <div class="line"></div>

        <div class="center">
            <div class="title">HÓA ĐƠN BÁN HÀNG</div>
        </div>

        <div class="meta">
            <div class="kv">
                <div class="k">Ngày</div>
                <div class="v">
                    <fmt:formatDate value="${now}" pattern="dd/MM/yyyy HH:mm:ss"/>
                </div>
            </div>

            <div class="kv">
                <div class="k">Khách hàng</div>
                <div class="v">${empty sessionScope.customerName ? 'Khách lẻ' : sessionScope.customerName}</div>
            </div>

            <div class="kv">
                <div class="k">SĐT</div>
                <div class="v">${empty sessionScope.customerPhone ? '-' : sessionScope.customerPhone}</div>
            </div>
        </div>

        <div class="line"></div>

        <div class="items">
            <c:forEach items="${lastOrder.values()}" var="it">
                <div class="item">
                    <div class="item-name">${it.name}</div>
                    <div class="row muted">
                        <span>
                            ${it.qty} x
                            <span class="money">
                                <fmt:formatNumber value="${it.price}" type="number" groupingUsed="true"/>
                            </span>
                        </span>
                        <span class="money">
                            <fmt:formatNumber value="${it.lineTotal}" type="number" groupingUsed="true"/>
                        </span>
                    </div>
                </div>
            </c:forEach>
        </div>

        <div class="line"></div>

        <div class="total">
            <span>TỔNG TIỀN</span>
            <span class="money">
                <fmt:formatNumber value="${lastTotal}" type="number" groupingUsed="true"/> đ
            </span>
        </div>

        <div class="line"></div>

        <div class="center thanks">
            Xin cảm ơn quý khách!<br/>
            Hẹn gặp lại ❤️
        </div>
    </div>

    <div class="no-print">
        <button class="btn" type="button" onclick="window.print()">In hóa đơn</button>
        <button class="btn" type="button" onclick="submitFinish()">Hoàn tất và lưu đơn</button>
        <button class="link-btn" type="button" onclick="backToPos()">Quay lại POS</button>
        <button class="link-btn" type="button" onclick="window.close()">Đóng</button>
    </div>

    <form id="finishForm"
          action="${pageContext.request.contextPath}/invoice/finish"
          method="post">
        <input type="hidden" name="customerName" value="${sessionScope.customerName}" />
        <input type="hidden" name="customerPhone" value="${sessionScope.customerPhone}" />
        <input type="hidden" name="note" value="" />
    </form>

    <script>
        function submitFinish() {
            const f = document.getElementById('finishForm');
            if (!f) {
                alert("Thiếu form finishForm");
                return;
            }
            f.submit();
        }

        function backToPos() {
            if (!confirm('Bạn chưa bấm Hoàn tất. Quay lại thì đơn chưa được ghi nhận/trừ kho. Tiếp tục?')) {
                return;
            }

            const posUrl = '${pageContext.request.contextPath}/pos';

            if (window.opener && !window.opener.closed) {
                window.opener.location.href = posUrl;
                window.close();
            } else {
                window.location.href = posUrl;
            }
        }
    </script>
</body>
</html>