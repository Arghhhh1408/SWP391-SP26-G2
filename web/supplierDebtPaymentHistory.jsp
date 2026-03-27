<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Theo dõi thanh toán công nợ</title>
    <style>
        * { box-sizing: border-box; font-family: Arial, sans-serif; }
        body { margin:0; padding:30px; background:#f4f7fb; color:#333; }
        .container { max-width:1300px; margin:auto; background:#fff; padding:24px; border-radius:14px; box-shadow:0 4px 20px rgba(0,0,0,0.08); }
        h1,h3 { color:#1f3c88; margin-top:0; }
        .top-link { display:inline-block; margin-bottom:16px; text-decoration:none; color:#1f3c88; font-weight:bold; }
        .summary { display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:14px; margin:20px 0; }
        .card { background:#f9fbff; border:1px solid #dbe6f3; border-radius:12px; padding:16px; }
        .card .label { color:#64748b; font-size:13px; margin-bottom:8px; }
        .card .value { color:#1f3c88; font-weight:700; font-size:22px; }
        .section { margin-top:20px; }
        .form-box { background:#f9fbff; border:1px solid #dbe6f3; padding:18px; border-radius:12px; margin-bottom:20px; }
        .form-grid { display:grid; grid-template-columns:repeat(3, 1fr); gap:12px; }
        .form-group { display:flex; flex-direction:column; }
        .form-group label { margin-bottom:6px; font-weight:600; }
        .form-group input, .form-group textarea { padding:10px 12px; border:1px solid #cfd9e6; border-radius:8px; }
        .form-group textarea { min-height:42px; resize:vertical; }
        .btn { display:inline-block; padding:10px 16px; border-radius:8px; text-decoration:none; border:none; cursor:pointer; font-weight:600; }
        .btn-primary { background:#1f78ff; color:#fff; }
        .btn-secondary { background:#e9eef5; color:#333; }
        .btn-success { background:#16a34a; color:#fff; }
        .message { margin-bottom:15px; padding:12px 16px; border-radius:8px; }
        .success { border:1px solid #b7ebc6; background:#e8f8ee; color:#1e7e34; }
        .error { border:1px solid #f5c2c7; background:#fdecef; color:#842029; }
        table { width:100%; border-collapse:collapse; }
        thead { background:#1f3c88; color:white; }
        th, td { padding:14px 12px; border-bottom:1px solid #edf1f5; text-align:left; }
        tbody tr:hover { background:#f8fbff; }
        .status-pending { color:#d97706; font-weight:bold; }
        .status-partial { color:#2563eb; font-weight:bold; }
        .status-paid { color:#16a34a; font-weight:bold; }
        .status-overdue { color:#dc2626; font-weight:bold; }
        .status-cancelled { color:#7f1d1d; font-weight:bold; }
        @media (max-width: 900px) { .form-grid { grid-template-columns:1fr; } }
    </style>
</head>
<body>
<div class="container">
    <h1>Theo dõi thanh toán công nợ</h1>
    <a class="top-link" href="supplierDebt?supplierId=${selectedSupplierId}">← Quay lại danh sách công nợ</a>

    <c:if test="${param.msg eq 'payment_added'}">
        <div class="message success">Đã ghi nhận một đợt thanh toán mới.</div>
    </c:if>
    <c:if test="${param.msg eq 'paid_confirmed'}">
        <div class="message success">Đã xác nhận thanh toán hết công nợ. Phiếu nhập liên quan cũng được cập nhật trạng thái Paid.</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="message error">Thao tác không thành công. Mã lỗi: ${param.error}</div>
    </c:if>

    <div class="summary">
        <div class="card">
            <div class="label">Nhà cung cấp</div>
            <div class="value" style="font-size:18px;">${selectedSupplierName}</div>
        </div>
        <div class="card">
            <div class="label">Debt ID / StockIn ID</div>
            <div class="value" style="font-size:18px;">#${debt.debtID} / #${debt.stockInID}</div>
        </div>
        <div class="card">
            <div class="label">Còn phải trả</div>
            <div class="value"><fmt:formatNumber value="${debt.amount}" type="number" groupingUsed="true"/></div>
        </div>
        <div class="card">
            <div class="label">Đã thanh toán</div>
            <div class="value"><fmt:formatNumber value="${debt.paidAmount}" type="number" groupingUsed="true"/></div>
        </div>
        <div class="card">
            <div class="label">Công nợ ban đầu</div>
            <div class="value"><fmt:formatNumber value="${debt.originalAmount}" type="number" groupingUsed="true"/></div>
        </div>
        <div class="card">
            <div class="label">Trạng thái</div>
            <div class="value" style="font-size:18px;">
                <c:choose>
                    <c:when test="${debt.status eq 'Pending'}"><span class="status-pending">Pending</span></c:when>
                    <c:when test="${debt.status eq 'Partial'}"><span class="status-partial">Partial</span></c:when>
                    <c:when test="${debt.status eq 'Paid'}"><span class="status-paid">Paid</span></c:when>
                    <c:when test="${debt.status eq 'Cancelled'}"><span class="status-cancelled">Cancelled</span></c:when>
                    <c:otherwise><span class="status-overdue">Overdue</span></c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="section">
        <h3>Lịch sử thanh toán theo đợt</h3>
        <table>
            <thead>
            <tr>
                <th>Payment ID</th>
                <th>Số tiền</th>
                <th>Thời gian</th>
                <th>Người xác nhận</th>
                <th>Ghi chú</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${not empty paymentList}">
                    <c:forEach items="${paymentList}" var="p">
                        <tr>
                            <td>${p.paymentID}</td>
                            <td><fmt:formatNumber value="${p.amount}" type="number" groupingUsed="true"/></td>
                            <td><fmt:formatDate value="${p.paymentDate}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                            <td>${p.createdByName}</td>
                            <td>${p.note}</td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr><td colspan="5" style="text-align:center;color:#777;">Chưa có đợt thanh toán nào.</td></tr>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>

    <c:if test="${sessionScope.acc.roleID == 2 and debt.status ne 'Paid' and debt.status ne 'Cancelled'}">
        <div class="section">
            <h3>Ghi nhận thanh toán từng đợt</h3>
            <form action="supplierDebtPayments" method="post" class="form-box">
                <input type="hidden" name="action" value="addPayment">
                <input type="hidden" name="supplierId" value="${selectedSupplierId}">
                <input type="hidden" name="debtId" value="${debt.debtID}">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Số tiền thanh toán</label>
                        <input type="number" step="0.01" min="0.01" max="${debt.amount}" name="paymentAmount" required>
                    </div>
                    <div class="form-group" style="grid-column: span 2;">
                        <label>Ghi chú</label>
                        <textarea name="note" placeholder="Ví dụ: thanh toán đợt 1"></textarea>
                    </div>
                </div>
                <div style="margin-top:14px; display:flex; gap:10px; flex-wrap:wrap;">
                    <button type="submit" class="btn btn-primary">Ghi nhận đợt thanh toán</button>
                </div>
            </form>

            <h3>Xác nhận trả hết công nợ</h3>
            <form action="supplierDebtPayments" method="post" class="form-box">
                <input type="hidden" name="action" value="confirmPaid">
                <input type="hidden" name="supplierId" value="${selectedSupplierId}">
                <input type="hidden" name="debtId" value="${debt.debtID}">
                <div class="form-group">
                    <label>Ghi chú</label>
                    <textarea name="note" placeholder="Ví dụ: đã thanh toán đủ cho nhà cung cấp"></textarea>
                </div>
                <div style="margin-top:14px; display:flex; gap:10px; flex-wrap:wrap;">
                    <button type="submit" class="btn btn-success">Xác nhận đã trả hết</button>
                </div>
            </form>
        </div>
    </c:if>
</div>
</body>
</html>
