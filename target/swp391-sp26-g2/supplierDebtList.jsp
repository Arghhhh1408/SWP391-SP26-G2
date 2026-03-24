<%-- 
    Document   : supplierDebtList
    Created on : 22 thg 3, 2026, 16:17:06
    Author     : dotha
--%>

<%-- 
    Document   : supplierDebtList
    Created on : 22 thg 3, 2026, 16:17:06
    Author     : dotha
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Công nợ nhà cung cấp</title>
        <style>
            * {
                box-sizing: border-box;
                font-family: Arial, sans-serif;
            }
            body {
                margin: 0;
                padding: 30px;
                background: #f4f7fb;
                color: #333;
            }
            .container {
                max-width: 1300px;
                margin: auto;
                background: white;
                padding: 24px;
                border-radius: 14px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            }
            h1, h3 {
                color: #1f3c88;
                margin-top: 0;
            }
            .top-link {
                display: inline-block;
                margin-bottom: 20px;
                text-decoration: none;
                color: #1f3c88;
                font-weight: bold;
            }
            .supplier-info {
                margin-bottom: 18px;
                padding: 12px 16px;
                background: #f9fbff;
                border: 1px solid #dbe6f3;
                border-radius: 10px;
                color: #2c3e50;
                font-weight: 600;
            }
            .search-box {
                background: #f9fbff;
                border: 1px solid #dbe6f3;
                padding: 18px;
                border-radius: 12px;
                margin-bottom: 20px;
            }
            .search-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 15px;
            }
            .form-group {
                display: flex;
                flex-direction: column;
            }
            .form-group label {
                margin-bottom: 6px;
                font-weight: 600;
            }
            .form-group input, .form-group select {
                padding: 10px 12px;
                border: 1px solid #cfd9e6;
                border-radius: 8px;
            }
            .action-row {
                margin-top: 18px;
                display: flex;
                gap: 10px;
            }
            .btn {
                display: inline-block;
                padding: 10px 16px;
                border-radius: 8px;
                text-decoration: none;
                border: none;
                cursor: pointer;
                font-weight: 600;
            }
            .btn-primary {
                background: #1f78ff;
                color: white;
            }
            .btn-secondary {
                background: #e9eef5;
                color: #333;
            }
            .table-wrapper {
                overflow-x: auto;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                min-width: 900px;
            }
            thead {
                background: #1f3c88;
                color: white;
            }
            th, td {
                padding: 14px 12px;
                border-bottom: 1px solid #edf1f5;
                text-align: left;
            }
            tbody tr:hover {
                background: #f8fbff;
            }
            .status-pending {
                color: #d97706;
                font-weight: bold;
            }
            .status-partial {
                color: #2563eb;
                font-weight: bold;
            }
            .status-paid {
                color: #16a34a;
                font-weight: bold;
            }
            .status-overdue {
                color: #dc2626;
                font-weight: bold;
            }
            .status-cancelled {
                color: #7f1d1d;
                font-weight: bold;
            }
            .empty-row {
                text-align: center;
                color: #777;
            }
            .error {
                color: red;
                margin-bottom: 15px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Công nợ nhà cung cấp</h1>
                <a class="top-link" href="supplierList">← Quay lại danh sách nhà cung cấp</a>

            <c:if test="${not empty requestScope.error}">
                <div class="error">${requestScope.error}</div>
            </c:if>

            <div class="supplier-info">
                Nhà cung cấp:
                <c:choose>
                    <c:when test="${not empty selectedSupplierName}">
                        ${selectedSupplierName} (Mã NCC: ${selectedSupplierId})
                    </c:when>
                    <c:otherwise>
                        <br>Mã NCC: ${selectedSupplierId}
                    </c:otherwise>
                </c:choose>
            </div>

            <h3>Tìm kiếm công nợ</h3>
            <form action="supplierDebt" method="get" class="search-box">
                <input type="hidden" name="supplierId" value="${selectedSupplierId}">

                <div class="search-grid">
                    <div class="form-group">
                        <label>Trạng thái</label>
                        <select name="status">
                            <option value="">-- Tất cả --</option>
                            <option value="Pending" ${param.status == 'Pending' ? 'selected' : ''}>Pending</option>
                            <option value="Partial" ${param.status == 'Partial' ? 'selected' : ''}>Partial</option>
                            <option value="Paid" ${param.status == 'Paid' ? 'selected' : ''}>Paid</option>
                            <option value="Overdue" ${param.status == 'Overdue' ? 'selected' : ''}>Overdue</option>
                            <option value="Cancelled" ${param.status == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Từ ngày đến hạn</label>
                        <input type="date" name="fromDate" value="${param.fromDate}">
                    </div>

                    <div class="form-group">
                        <label>Đến ngày đến hạn</label>
                        <input type="date" name="toDate" value="${param.toDate}">
                    </div>
                </div>

                <div class="action-row">
                    <button type="submit" class="btn btn-primary">Tìm kiếm</button>
                    <a href="supplierDebt?supplierId=${selectedSupplierId}" class="btn btn-secondary">Làm mới</a>
                </div>
            </form>

            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Debt ID</th>
                            <th>StockIn ID</th>
                            <th>Số tiền nợ</th>
                            <th>Hạn thanh toán</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty debtList}">
                                <c:forEach items="${debtList}" var="d">
                                    <tr>
                                        <td>${d.debtID}</td>
                                        <td>${d.stockInID}</td>
                                        <td>
                                <fmt:formatNumber value="${d.amount}" type="number" groupingUsed="true"/>
                                </td>
                                <td>
                                <fmt:formatDate value="${d.dueDate}" pattern="dd/MM/yyyy"/>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${d.status == 'Pending'}">
                                            <span class="status-pending">Pending</span>
                                        </c:when>
                                        <c:when test="${d.status == 'Partial'}">
                                            <span class="status-partial">Partial</span>
                                        </c:when>
                                        <c:when test="${d.status == 'Paid'}">
                                            <span class="status-paid">Paid</span>
                                        </c:when>
                                        <c:when test="${d.status == 'Cancelled'}">
                                            <span class="status-cancelled">Cancelled</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-overdue">Overdue</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="5" class="empty-row">Không có dữ liệu công nợ.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>
