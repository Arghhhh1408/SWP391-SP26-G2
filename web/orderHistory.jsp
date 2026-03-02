<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>Lịch sử đơn hàng</title>

        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 16px;
                background: #fafafa;
                color:#111;
            }
            .wrap {
                max-width: 1100px;
                margin: 0 auto;
            }

            .card{
                background:#fff;
                border:1px solid #e6e6e6;
                border-radius: 12px;
                padding: 14px;
                box-shadow: 0 1px 2px rgba(0,0,0,.04);
            }

            .head{
                display:flex;
                justify-content: space-between;
                align-items: center;
                gap: 10px;
                flex-wrap: wrap;
                margin-bottom: 12px;
            }

            h2{
                margin: 0;
                font-size: 20px;
            }

            .filters{
                display:flex;
                gap: 10px;
                flex-wrap: wrap;
                align-items: end;
                margin: 10px 0 12px;
            }
            .field label{
                display:block;
                font-size: 12px;
                color:#444;
                margin-bottom: 4px;
            }
            .field input, .field select{
                padding: 8px;
                border:1px solid #d0d7de;
                border-radius: 8px;
                min-width: 180px;
                background:#fff;
                font-size: 14px;
            }

            .btn{
                padding: 8px 12px;
                border-radius: 10px;
                border:1px solid #111;
                background:#111;
                color:#fff;
                cursor:pointer;
                font-size: 13px;
                height: 36px;
            }
            .btn.secondary{
                background:#fff;
                color:#111;
                border-color:#bbb;
                text-decoration:none;
                display:inline-flex;
                align-items:center;
                justify-content:center;
            }

            .table{
                width:100%;
                border-collapse: collapse;
                background:#fff;
                overflow:hidden;
                border-radius: 12px;
            }

            .table th, .table td{
                border-top:1px solid #eee;
                padding: 10px 10px;
                text-align:left;
                vertical-align: top;
                font-size: 13px;
            }
            .table th{
                background:#f6f8fa;
                border-top:none;
                font-size: 12px;
                color:#333;
                text-transform: uppercase;
                letter-spacing: .02em;
            }

            .table tr:hover{
                background:#f9fafb;
            }

            .money{
                white-space: nowrap;
                font-variant-numeric: tabular-nums;
                font-weight: 700;
            }
            .muted{
                color:#666;
                font-size: 12px;
            }

            .link{
                text-decoration:none;
                border-bottom: 1px dotted #111;
                color:#111;
                padding: 2px 0;
                font-size: 13px;
            }

            .empty{
                padding: 14px;
                border: 1px dashed #cbd5e1;
                border-radius: 12px;
                background: #f8fafc;
                color:#334155;
            }

            @media print{
                .filters, .toplinks {
                    display:none;
                }
                body{
                    background:#fff;
                }
                .card{
                    border:none;
                    box-shadow:none;
                    padding:0;
                }
            }
        </style>
    </head>

    <body>
        <div class="wrap">
            <div class="card">

                <div class="head">
                    <h2>Lịch sử đơn hàng</h2>
                    <div class="toplinks">
                        <a class="link" href="${pageContext.request.contextPath}/pos">← Quay lại POS</a>
                    </div>
                </div>

                <c:choose>

                    <c:when test="${empty orders}">
                        <div class="empty">Chưa có đơn hàng nào.</div>
                    </c:when>

                    <c:otherwise>

                        <form method="get" action="${pageContext.request.contextPath}/orders" class="filters">
                            <div class="field">
                                <label>Lọc</label>
                                <select name="range">
                                    <option value="all"   ${param.range == 'all'   ? 'selected' : ''}>Tất cả</option>
                                    <option value="day"   ${param.range == 'day'   ? 'selected' : ''}>Hôm nay</option>
                                    <option value="week"  ${param.range == 'week'  ? 'selected' : ''}>Tuần này</option>
                                    <option value="month" ${param.range == 'month' ? 'selected' : ''}>Tháng này</option>
                                </select>
                            </div>

                            <div class="field">
                                <label>Sắp xếp</label>
                                <select name="sort">
                                    <option value="new" ${sort == 'new' ? 'selected' : ''}>Mới nhất</option>
                                    <option value="old" ${sort == 'old' ? 'selected' : ''}>Cũ nhất</option>
                                </select>
                                <input name="keyword" placeholder="Mã đơn hoặc SĐT"
                                       value="${param.keyword}" style="padding:6px; margin-left:10px;">
                            </div>

                            <button class="btn" type="submit">Áp dụng</button>
                            <a class="btn secondary" href="${pageContext.request.contextPath}/orders">Reset</a>
                        </form>

                        <table class="table">
                            <tr>
                                <th>Mã đơn</th>
                                <th>Thời gian</th>
                                <th>Khách hàng</th>
                                <th>SĐT</th>
                                <th>Tổng tiền</th>
                                <th>Sale</th>
                                <th>Ghi chú</th>
                                <th>Chi tiết</th>
                            </tr>

                            <c:forEach items="${orders}" var="o">
                                <tr>
                                    <td><b>${o.stockOutId}</b></td>
                                    <td class="muted">${o.date}</td>
                                    <td>${o.customerName}</td>
                                    <td>${o.customerPhone}</td>
                                    <td class="money">${o.totalAmount}</td>
                                    <td>${o.createdByName}</td>
                                    <td>${o.note}</td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/orderdetail?id=${o.stockOutId}">Xem</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </table>

                    </c:otherwise>

                </c:choose>

            </div>
        </div>
    </body>
</html>