<%-- 
    Document   : editStockIn
    Created on : 7 thg 3, 2026, 13:43:01
    Author     : dotha
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Sửa phiếu nhập hàng</title>

        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
                font-family: Arial, sans-serif;
            }

            body {
                background: #f4f6f9;
                color: #333;
                padding: 30px;
            }

            .container {
                max-width: 1100px;
                margin: 0 auto;
            }

            .page-title {
                font-size: 28px;
                font-weight: bold;
                margin-bottom: 20px;
                color: #1f4e79;
            }

            .back-link {
                display: inline-block;
                margin-bottom: 20px;
                text-decoration: none;
                color: #1f4e79;
                font-weight: bold;
            }

            .back-link:hover {
                text-decoration: underline;
            }

            .card {
                background: #fff;
                border-radius: 12px;
                padding: 20px;
                margin-bottom: 20px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            }

            .card h3 {
                margin-bottom: 16px;
                color: #1f4e79;
                border-bottom: 2px solid #eef2f7;
                padding-bottom: 10px;
            }

            .form-grid {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
                gap: 16px;
            }

            .form-group {
                display: flex;
                flex-direction: column;
            }

            .form-group.full-width {
                grid-column: 1 / -1;
            }

            label {
                margin-bottom: 6px;
                font-weight: bold;
                color: #444;
            }

            input[type="text"],
            textarea,
            select {
                width: 100%;
                padding: 10px 12px;
                border: 1px solid #ccc;
                border-radius: 8px;
                outline: none;
                font-size: 14px;
            }

            input:focus,
            textarea:focus,
            select:focus {
                border-color: #1f4e79;
                box-shadow: 0 0 0 3px rgba(31, 78, 121, 0.12);
            }

            textarea {
                resize: vertical;
                min-height: 100px;
            }

            .readonly-box {
                padding: 10px 12px;
                background: #f8fafc;
                border: 1px solid #dbe3eb;
                border-radius: 8px;
            }

            .summary-box {
                background: #f8fafc;
                border: 1px solid #dbe3eb;
                border-radius: 10px;
                padding: 14px 16px;
                margin-bottom: 16px;
            }

            .summary-box p {
                margin: 6px 0;
            }

            .table-wrapper {
                overflow-x: auto;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                background: #fff;
            }

            th, td {
                padding: 12px;
                border-bottom: 1px solid #e5e7eb;
                text-align: left;
                vertical-align: middle;
            }

            th {
                background: #f1f5f9;
                color: #1f4e79;
                font-weight: bold;
            }

            tr:hover td {
                background: #fafcff;
            }

            .empty-state {
                text-align: center;
                color: #777;
                padding: 20px;
            }

            .money {
                font-weight: bold;
                color: #0f766e;
            }

            .action-row {
                display: flex;
                justify-content: flex-end;
                gap: 10px;
                margin-top: 20px;
                flex-wrap: wrap;
            }

            .btn {
                border: none;
                padding: 10px 16px;
                border-radius: 8px;
                cursor: pointer;
                font-weight: bold;
                font-size: 14px;
                transition: 0.2s;
                text-decoration: none;
                display: inline-block;
            }

            .btn-primary {
                background: #1f4e79;
                color: #fff;
            }

            .btn-primary:hover {
                background: #163a59;
            }

            .btn-secondary {
                background: #78909c;
                color: #fff;
            }

            .btn-secondary:hover {
                background: #546e7a;
            }

            @media (max-width: 768px) {
                .form-grid {
                    grid-template-columns: 1fr;
                }

                .action-row {
                    justify-content: center;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="page-title">Sửa phiếu nhập hàng</div>

            <a class="back-link" href="stockinList">← Quay lại danh sách phiếu nhập</a>

            <form action="stockinList" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="stockInId" value="${stockIn.stockInId}">

                <div class="card">
                    <h3>Thông tin phiếu nhập</h3>

                    <div class="form-grid">
                        <div class="form-group">
                            <label>Mã phiếu nhập</label>
                            <div class="readonly-box">#${stockIn.stockInId}</div>
                        </div>

                        <div class="form-group">
                            <label>Ngày tạo</label>
                            <div class="readonly-box">
                                <fmt:formatDate value="${stockIn.date}" pattern="dd/MM/yyyy HH:mm"/>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Nhà cung cấp</label>
                            <div class="readonly-box">${stockIn.supplierName}</div>
                        </div>

                        <div class="form-group">
                            <label>Nhân viên tạo</label>
                            <div class="readonly-box">${stockIn.staffName}</div>
                        </div>

                        <div class="form-group">
                            <label>Trạng thái nhập hàng</label>
                            <select name="stockStatus">
                                <option value="Pending" ${stockIn.stockStatus == 'Pending' ? 'selected' : ''}>Pending</option>
                                <option value="Completed" ${stockIn.stockStatus == 'Completed' ? 'selected' : ''}>Completed</option>
                                <option value="Cancelled" ${stockIn.stockStatus == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Trạng thái thanh toán</label>
                            <select name="paymentStatus">
                                <option value="Unpaid" ${stockIn.paymentStatus == 'Unpaid' ? 'selected' : ''}>Unpaid</option>
                                <option value="Partial" ${stockIn.paymentStatus == 'Partial' ? 'selected' : ''}>Partial</option>
                                <option value="Paid" ${stockIn.paymentStatus == 'Paid' ? 'selected' : ''}>Paid</option>
                                <option value="Cancelled" ${stockIn.paymentStatus == 'Cancelled' ? 'selected' : ''}>Cancelled</option>
                            </select>
                        </div>

                        <div class="form-group full-width">
                            <label>Ghi chú</label>
                            <textarea name="note">${stockIn.note}</textarea>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <h3>Chi tiết phiếu nhập</h3>

                    <div class="summary-box">
                        <p><strong>Tổng số lượng nhập:</strong> ${stockIn.totalQuantity}</p>
                        <p>
                            <strong>Tổng giá trị phiếu:</strong>
                            <span class="money">
                                <fmt:formatNumber value="${stockIn.totalAmountCalculated}" type="number" groupingUsed="true"/>
                            </span>
                        </p>
                    </div>

                    <div class="table-wrapper">
                        <table>
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên sản phẩm</th>
                                    <th>Số lượng</th>
                                    <th>Giá nhập</th>
                                    <th>Thành tiền</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:if test="${empty stockIn.details}">
                                    <tr>
                                        <td colspan="5" class="empty-state">Không có chi tiết sản phẩm</td>
                                    </tr>
                                </c:if>

                                <c:if test="${not empty stockIn.details}">
                                    <c:forEach var="d" items="${stockIn.details}">
                                        <tr>
                                            <td>${d.productId}</td>
                                            <td>${d.productName}</td>
                                            <td>${d.quantity}</td>
                                            <td>
                                                <fmt:formatNumber value="${d.unitCost}" type="number" groupingUsed="true"/>
                                            </td>
                                            <td class="money">
                                                <fmt:formatNumber value="${d.quantity * d.unitCost}" type="number" groupingUsed="true"/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:if>
                            </tbody>
                        </table>
                    </div>

                    <div class="action-row">
                        <a href="stockinList" class="btn btn-secondary">Hủy</a>
                        <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                    </div>
                </div>
            </form>
        </div>
    </body>
</html>
