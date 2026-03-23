<%-- 
    Document   : inventoryApproval
    Created on : 23 thg 3, 2026, 19:09:38
    Author     : dotha
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Duyệt phiếu kiểm kho</title>
        <style>
            body {
                margin: 0;
                font-family: 'Inter', Arial, sans-serif;
                background: #f8fafc;
                color: #1e293b;
            }

            .page-wrap {
                display: flex;
                min-height: 100vh;
            }

            .admin-main {
                margin-left: 260px;
                flex: 1;
                min-width: 0;
            }

            .admin-content {
                padding: 32px;
            }

            .page-title {
                font-size: 28px;
                font-weight: 700;
                margin-bottom: 8px;
                color: #0f172a;
            }

            .page-subtitle {
                color: #64748b;
                margin-bottom: 24px;
            }

            .alert {
                padding: 14px 16px;
                border-radius: 12px;
                margin-bottom: 18px;
                font-size: 14px;
                font-weight: 500;
            }

            .alert-success {
                background: #ecfdf5;
                color: #047857;
                border: 1px solid #a7f3d0;
            }

            .alert-error {
                background: #fef2f2;
                color: #b91c1c;
                border: 1px solid #fecaca;
            }

            .card {
                background: #fff;
                border-radius: 18px;
                padding: 24px;
                box-shadow: 0 8px 24px rgba(15, 23, 42, 0.06);
                margin-bottom: 24px;
            }

            .card-title {
                font-size: 18px;
                font-weight: 700;
                margin-bottom: 16px;
                color: #0f172a;
            }

            .table-wrap {
                overflow-x: auto;
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            th, td {
                padding: 14px 12px;
                border-bottom: 1px solid #e2e8f0;
                text-align: left;
                font-size: 14px;
            }

            th {
                color: #475569;
                font-size: 13px;
                text-transform: uppercase;
                letter-spacing: 0.4px;
                background: #f8fafc;
            }

            tr:hover td {
                background: #fafcff;
            }

            .badge {
                display: inline-block;
                padding: 6px 12px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: 700;
            }

            .badge-pending {
                background: #fff7ed;
                color: #c2410c;
            }

            .badge-approved {
                background: #ecfdf5;
                color: #047857;
            }

            .badge-rejected {
                background: #fef2f2;
                color: #b91c1c;
            }

            .match {
                color: #15803d;
                font-weight: 700;
            }

            .excess {
                color: #ea580c;
                font-weight: 700;
            }

            .shortage {
                color: #dc2626;
                font-weight: 700;
            }

            .btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 10px 16px;
                border-radius: 10px;
                border: none;
                text-decoration: none;
                font-size: 13px;
                font-weight: 700;
                cursor: pointer;
                gap: 8px;
            }

            .btn-view {
                background: #e0f2fe;
                color: #0369a1;
            }

            .btn-approve {
                background: #10b981;
                color: #fff;
            }

            .btn-reject {
                background: #ef4444;
                color: #fff;
            }

            .btn-outline {
                background: #fff;
                color: #334155;
                border: 1px solid #cbd5e1;
            }

            .form-row {
                margin-bottom: 16px;
            }

            label {
                display: block;
                font-size: 14px;
                font-weight: 600;
                margin-bottom: 8px;
                color: #334155;
            }

            textarea {
                width: 100%;
                min-height: 100px;
                padding: 12px 14px;
                border: 1px solid #cbd5e1;
                border-radius: 12px;
                font-family: inherit;
                font-size: 14px;
                box-sizing: border-box;
                resize: vertical;
            }

            .action-row {
                display: flex;
                flex-wrap: wrap;
                gap: 12px;
                margin-top: 18px;
            }

            .meta-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 14px;
                margin-bottom: 18px;
            }

            .meta-box {
                background: #f8fafc;
                border: 1px solid #e2e8f0;
                border-radius: 14px;
                padding: 14px;
            }

            .meta-label {
                font-size: 12px;
                color: #64748b;
                margin-bottom: 6px;
            }

            .meta-value {
                font-size: 16px;
                font-weight: 700;
                color: #0f172a;
            }

            .note {
                color: #64748b;
                font-size: 13px;
                line-height: 1.6;
                margin-top: 10px;
            }

            @media (max-width: 1000px) {
                .meta-grid {
                    grid-template-columns: repeat(2, 1fr);
                }
            }

            @media (max-width: 640px) {
                .meta-grid {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>
        <div class="page-wrap">
            <jsp:include page="managerSidebar.jsp" />

            <div class="admin-main">
                <div class="admin-content">
                    <div class="page-title">Duyệt phiếu kiểm kho</div>
                    <div class="page-subtitle">
                        Quản lý có thể xem các phiếu kiểm kho do staff gửi lên và thực hiện approve/reject.
                    </div>

                    <c:if test="${not empty sessionScope.message}">
                        <div class="alert alert-success">${sessionScope.message}</div>
                        <c:remove var="message" scope="session"/>
                    </c:if>

                    <c:if test="${not empty sessionScope.error}">
                        <div class="alert alert-error">${sessionScope.error}</div>
                        <c:remove var="error" scope="session"/>
                    </c:if>

                    <div class="card">
                        <div class="card-title">Danh sách phiếu kiểm kho chờ duyệt</div>

                        <c:choose>
                            <c:when test="${not empty approvalSessions}">
                                <div class="table-wrap">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Session Code</th>
                                                <th>Ngày tạo</th>
                                                <th>Người tạo</th>
                                                <th>Số sản phẩm</th>
                                                <th>Trạng thái</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="s" items="${approvalSessions}">
                                            <tr>
                                                <td>${s.sessionCode}</td>
                                                <td>${s.date}</td>
                                                <td>${s.createdBy}</td>
                                                <td>${s.totalCheckTimes}</td>
                                                <td>
                                            <c:choose>
                                                <c:when test="${s.status == 'Pending'}">
                                                    <span class="badge badge-pending">Pending</span>
                                                </c:when>
                                                <c:when test="${s.status == 'Approved'}">
                                                    <span class="badge badge-approved">Approved</span>
                                                </c:when>
                                                <c:when test="${s.status == 'Rejected'}">
                                                    <span class="badge badge-rejected">Rejected</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge">${s.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                            </td>
                                            <td>
                                                <a class="btn btn-view"
                                                   href="inventoryCheck?mode=approvalDetail&sessionCode=${s.sessionCode}">
                                                    Xem chi tiết
                                                </a>
                                            </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="note">Hiện không có phiếu kiểm kho nào đang chờ duyệt.</div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <c:if test="${not empty selectedSessionItems}">
                        <div class="card">
                            <div class="card-title">Chi tiết phiếu kiểm kho</div>

                            <div class="meta-grid">
                                <div class="meta-box">
                                    <div class="meta-label">Session Code</div>
                                    <div class="meta-value">${selectedSessionCode}</div>
                                </div>
                                <div class="meta-box">
                                    <div class="meta-label">Ngày tạo</div>
                                    <div class="meta-value">${selectedSessionDate}</div>
                                </div>
                                <div class="meta-box">
                                    <div class="meta-label">Người tạo</div>
                                    <div class="meta-value">${selectedSessionCreatedBy}</div>
                                </div>
                                <div class="meta-box">
                                    <div class="meta-label">Số sản phẩm</div>
                                    <div class="meta-value">${selectedSessionSize}</div>
                                </div>
                            </div>

                            <div class="table-wrap">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Product ID</th>
                                            <th>SKU</th>
                                            <th>Tên sản phẩm</th>
                                            <th>Tồn hệ thống</th>
                                            <th>Thực tế</th>
                                            <th>Chênh lệch</th>
                                            <th>Lý do</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="i" items="${selectedSessionItems}">
                                        <tr>
                                            <td>${i.productId}</td>
                                            <td>${i.sku}</td>
                                            <td>${i.productName}</td>
                                            <td>${i.systemQuantity}</td>
                                            <td>${i.physicalQuantity}</td>
                                            <td>
                                        <c:choose>
                                            <c:when test="${i.variance == 0}">
                                                <span class="match">0 (Khớp)</span>
                                            </c:when>
                                            <c:when test="${i.variance > 0}">
                                                <span class="excess">+${i.variance} (Dư)</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="shortage">${i.variance} (Thiếu)</span>
                                            </c:otherwise>
                                        </c:choose>
                                        </td>
                                        <td>${i.reason}</td>
                                        <td>
                                        <c:choose>
                                            <c:when test="${i.status == 'Pending'}">
                                                <span class="badge badge-pending">Pending</span>
                                            </c:when>
                                            <c:when test="${i.status == 'Approved'}">
                                                <span class="badge badge-approved">Approved</span>
                                            </c:when>
                                            <c:when test="${i.status == 'Rejected'}">
                                                <span class="badge badge-rejected">Rejected</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge">${i.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                        </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <div class="note">
                                Approve sẽ cập nhật tồn kho hệ thống bằng số lượng thực tế của từng sản phẩm trong phiếu này.
                                Reject sẽ giữ nguyên tồn kho hiện tại.
                            </div>

                            <div class="action-row">
                                <form action="inventoryCheck" method="post" style="display:inline;">
                                    <input type="hidden" name="action" value="approveSession">
                                    <input type="hidden" name="sessionCode" value="${selectedSessionCode}">
                                    <button type="submit" class="btn btn-approve">Approve phiếu</button>
                                </form>

                                <form action="inventoryCheck" method="post" style="flex:1; min-width:300px;">
                                    <input type="hidden" name="action" value="rejectSession">
                                    <input type="hidden" name="sessionCode" value="${selectedSessionCode}">

                                    <div class="form-row">
                                        <label for="rejectReason">Lý do reject</label>
                                        <textarea id="rejectReason" name="rejectReason"
                                                  placeholder="Nhập lý do từ chối phiếu kiểm kho này" required></textarea>
                                    </div>

                                    <button type="submit" class="btn btn-reject">Reject phiếu</button>
                                </form>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </body>
</html>
