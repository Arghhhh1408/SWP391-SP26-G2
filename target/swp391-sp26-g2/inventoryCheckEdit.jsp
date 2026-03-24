<%-- 
    Document   : inventoryCheckEdit
    Created on : 16 thg 3, 2026, 17:11:27
    Author     : dotha
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Sửa kiểm kê kho</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 24px;
                background: #f5f7fa;
                color: #333;
            }

            .container {
                max-width: 950px;
                margin: 0 auto;
            }

            .card {
                background: #fff;
                border-radius: 14px;
                padding: 28px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            }

            h2 {
                margin-top: 0;
                margin-bottom: 20px;
                color: #0d274d;
            }

            .top-link {
                margin-bottom: 20px;
            }

            .top-link a {
                text-decoration: none;
                color: #1976d2;
                font-weight: bold;
            }

            .error-box {
                background: #ffebee;
                color: #c62828;
                border-left: 4px solid #c62828;
                padding: 12px 14px;
                border-radius: 8px;
                margin-bottom: 18px;
            }

            .info-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 18px;
            }

            .form-row {
                margin-bottom: 16px;
            }

            .full-width {
                grid-column: 1 / -1;
            }

            label {
                display: block;
                margin-bottom: 6px;
                font-weight: bold;
                color: #37506d;
            }

            input[type="text"],
            input[type="number"],
            input[type="date"],
            select,
            textarea {
                width: 100%;
                padding: 10px 12px;
                border: 1px solid #cfd8e3;
                border-radius: 8px;
                box-sizing: border-box;
                font-size: 14px;
                background: #fff;
            }

            textarea {
                min-height: 100px;
                resize: vertical;
            }

            .readonly {
                background: #f4f6f8;
                color: #56677d;
            }

            .status-box {
                margin-top: 8px;
                font-size: 14px;
                color: #60758f;
                line-height: 1.5;
            }

            .result-badge {
                display: inline-block;
                padding: 8px 14px;
                border-radius: 999px;
                font-size: 13px;
                font-weight: 700;
            }

            .match {
                background: #d7f4df;
                color: #169b45;
            }

            .excess {
                background: #fff0db;
                color: #ef6c00;
            }

            .shortage {
                background: #ffe0e3;
                color: #c62828;
            }

            .pending {
                background: #ffe9cc;
                color: #d77a00;
            }

            .approved {
                background: #d7f4df;
                color: #169b45;
            }

            .rejected {
                background: #ffdfe0;
                color: #ef3c3c;
            }

            .actions {
                margin-top: 24px;
                display: flex;
                flex-wrap: wrap;
                gap: 12px;
            }

            .btn {
                padding: 11px 18px;
                border: none;
                border-radius: 8px;
                cursor: pointer;
                font-weight: bold;
                text-decoration: none;
                display: inline-block;
            }

            .btn-save {
                background: #2e7d32;
                color: white;
            }

            .btn-back {
                background: #e3f2fd;
                color: #1565c0;
            }

            .note-box {
                margin-top: 18px;
                padding: 14px 16px;
                background: #f8fbff;
                border-left: 4px solid #90caf9;
                border-radius: 8px;
                color: #46627f;
                font-size: 14px;
                line-height: 1.6;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="card">
                <h2>Sửa bản ghi kiểm kê kho</h2>

                <c:if test="${not empty error}">
                    <div class="error-box">${error}</div>
                </c:if>

                <form action="inventoryCheck" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="countId" value="${item.countId}">

                    <div class="info-grid">

                        <div class="form-row">
                            <label>Count ID</label>
                            <input type="text" value="${item.countId}" class="readonly" readonly>
                        </div>

                        <div class="form-row">
                            <label>Session Code</label>
                            <input type="text" value="${item.sessionCode}" class="readonly" readonly>
                        </div>

                        <div class="form-row">
                            <label>Tên sản phẩm</label>
                            <input type="text" value="${item.productName}" class="readonly" readonly>
                        </div>

                        <div class="form-row">
                            <label>SKU</label>
                            <input type="text" value="${item.sku}" class="readonly" readonly>
                        </div>

                        <div class="form-row">
                            <label>Đơn vị tính</label>
                            <input type="text" value="${item.unit}" class="readonly" readonly>
                        </div>

                        <div class="form-row">
                            <label>Ngày kiểm kê</label>
                            <input type="text" value="${item.date}" class="readonly" readonly>
                        </div>

                        <div class="form-row">
                            <label>Số lượng hệ thống</label>
                            <input type="number" id="systemQuantity" name="systemQuantity"
                                   value="${item.systemQuantity}" class="readonly" readonly>
                        </div>

                        <div class="form-row">
                            <label>Số lượng thực tế</label>
                            <input type="number" id="physicalQuantity" name="physicalQuantity"
                                   min="0" value="${item.physicalQuantity}" required>
                        </div>

                        <div class="form-row">
                            <label>Kết quả chênh lệch hiện tại</label>
                            <div class="status-box">
                                <c:choose>
                                    <c:when test="${item.variance == 0}">
                                        <span class="result-badge match">Khớp (${item.variance})</span>
                                    </c:when>
                                    <c:when test="${item.variance > 0}">
                                        <span class="result-badge excess">Dư (+${item.variance})</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="result-badge shortage">Thiếu (${item.variance})</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="form-row">
                            <label>Trạng thái hiện tại</label>
                            <div class="status-box">
                                <c:choose>
                                    <c:when test="${item.status == 'Pending'}">
                                        <span class="result-badge pending">Pending</span>
                                    </c:when>
                                    <c:when test="${item.status == 'Approved'}">
                                        <span class="result-badge approved">Approved</span>
                                    </c:when>
                                    <c:when test="${item.status == 'Rejected'}">
                                        <span class="result-badge rejected">Rejected</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="result-badge">${item.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="form-row full-width">
                            <label>Lý do chênh lệch</label>
                            <textarea id="reason" name="reason"
                                      placeholder="Nhập lý do nếu số lượng thực tế khác số lượng hệ thống">${item.reason}</textarea>
                        </div>

                        <div class="form-row">
                            <label>Trạng thái cập nhật</label>

                            <c:choose>
                                <c:when test="${sessionScope.acc.roleID == 2}">
                                    <select name="status">
                                        <option value="Pending" ${item.status == 'Pending' ? 'selected' : ''}>Pending</option>
                                        <option value="Approved" ${item.status == 'Approved' ? 'selected' : ''}>Approved</option>
                                        <option value="Rejected" ${item.status == 'Rejected' ? 'selected' : ''}>Rejected</option>
                                    </select>
                                </c:when>
                                <c:otherwise>
                                    <input type="hidden" name="status" value="${item.status}">
                                    <input type="text" value="${item.status}" class="readonly" readonly>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="form-row">
                            <label>Người duyệt</label>
                            <input type="text" value="${item.approvedBy != null ? item.approvedBy : 'Chưa duyệt'}" class="readonly" readonly>
                        </div>

                    </div>

                    <div class="note-box">
                        Nếu số lượng thực tế khác số lượng hệ thống, bạn cần nhập lý do chênh lệch.
                    </div>

                    <div class="actions">
                        <button type="submit" class="btn btn-save">Lưu cập nhật</button>
                        <a href="inventoryCheck?mode=view&id=${item.countId}" class="btn btn-back">← Quay lại</a>
                    </div>
                </form>
            </div>
        </div>
        <script>
            function toggleReasonField() {
                const systemInput = document.getElementById("systemQuantity");
                const physicalInput = document.getElementById("physicalQuantity");
                const reasonInput = document.getElementById("reason");

                if (!systemInput || !physicalInput || !reasonInput)
                    return;

                const systemQty = parseInt(systemInput.value || "0", 10);
                const physicalQty = parseInt(physicalInput.value || "0", 10);

                if (!isNaN(systemQty) && !isNaN(physicalQty) && systemQty === physicalQty) {
                    reasonInput.value = "";
                    reasonInput.readOnly = true;
                    reasonInput.style.backgroundColor = "#f4f6f8";
                    reasonInput.placeholder = "Không cần nhập lý do khi số lượng khớp";
                } else {
                    reasonInput.readOnly = false;
                    reasonInput.style.backgroundColor = "#fff";
                    reasonInput.placeholder = "Nhập lý do nếu số lượng thực tế khác số lượng hệ thống";
                }
            }

            document.addEventListener("DOMContentLoaded", function () {
                toggleReasonField();

                const physicalInput = document.getElementById("physicalQuantity");
                if (physicalInput) {
                    physicalInput.addEventListener("input", toggleReasonField);
                }
            });
        </script>
    </body>
</html>
