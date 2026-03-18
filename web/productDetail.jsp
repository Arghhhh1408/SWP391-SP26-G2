<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="jakarta.tags.core" %>
        <%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>${product.name} - Chi tiết sản phẩm</title>
                <style>
                    .detail-card {
                        background: #fff;
                        border: 1px solid #e0e0e0;
                        border-radius: 8px;
                        padding: 24px;
                        display: grid;
                        grid-template-columns: 350px 1fr;
                        gap: 40px;
                        margin-top: 20px;
                    }

                    .product-visuals {
                        text-align: center;
                    }

                    .product-full-img {
                        width: 100%;
                        height: auto;
                        max-height: 400px;
                        object-fit: contain;
                        border-radius: 8px;
                        border: 1px solid #f0f0f0;
                        margin-bottom: 20px;
                    }

                    .info-section h3 {
                        margin-top: 0;
                        font-size: 24px;
                        color: #333;
                        border-bottom: 1px solid #eee;
                        padding-bottom: 15px;
                        margin-bottom: 20px;
                    }

                    .info-row {
                        display: flex;
                        padding: 12px 0;
                        border-bottom: 1px dotted #eee;
                    }

                    .info-label {
                        width: 180px;
                        font-weight: 600;
                        color: #777;
                        font-size: 14px;
                    }

                    .info-value {
                        flex: 1;
                        color: #333;
                        font-size: 14px;
                    }

                    .price-highlight {
                        font-size: 20px;
                        color: #dc3545;
                        font-weight: 700;
                    }

                    .description-box {
                        margin-top: 20px;
                        background: #fcfcfc;
                        padding: 15px;
                        border-radius: 4px;
                        border: 1px solid #f0f0f0;
                        color: #555;
                        line-height: 1.6;
                    }

                    .status-badge {
                        display: inline-block;
                        padding: 4px 12px;
                        border-radius: 15px;
                        font-size: 12px;
                        font-weight: 600;
                    }

                    .status-active {
                        background: #d4edda;
                        color: #155724;
                    }

                    .status-inactive {
                        background: #f8d7da;
                        color: #721c24;
                    }

                    .history-section {
                        margin-top: 40px;
                        border-top: 2px solid #eee;
                        padding-top: 30px;
                    }

                    .history-table {
                        width: 100%;
                        border-collapse: collapse;
                        margin-top: 15px;
                        font-size: 13px;
                    }

                    .history-table th {
                        text-align: left;
                        padding: 12px;
                        background: #f8f9fa;
                        border-bottom: 2px solid #dee2e6;
                        color: #495057;
                    }

                    .history-table td {
                        padding: 12px;
                        border-bottom: 1px solid #eee;
                        vertical-align: top;
                    }

                    .action-badge {
                        padding: 2px 8px;
                        border-radius: 4px;
                        font-weight: 600;
                        font-size: 11px;
                        text-transform: uppercase;
                    }

                    .action-add { background: #d4edda; color: #155724; }
                    .action-edit { background: #fff3cd; color: #856404; }
                    .action-stockin { background: #cce5ff; color: #004085; }
                </style>
            </head>

            <body>
                <c:set var="currentPage" value="category" scope="request" />
                <jsp:include page="managerSidebar.jsp" />

                <div class="admin-main">
                    <div class="admin-topbar">
                        <div>
                            <h1>${product.name}</h1>
                            <small>Manager &rsaquo; Kho hàng &rsaquo; Chi tiết sản phẩm</small>
                        </div>
                        <div>Xin chào, <strong>${sessionScope.acc.fullName}</strong></div>
                    </div>

                    <div class="admin-content">
                        <div
                            style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                            <a href="category" class="btn btn-outline">&larr; Quay lại danh sách</a>
                            <div>
                                <a href="editProduct?id=${product.id}" class="btn btn-primary"
                                    style="background: #ffc107; border-color: #ffc107; color: #000;">Sửa sản phẩm</a>
                                <a href="deleteProduct?id=${product.id}" class="btn btn-outline"
                                    style="border-color: #dc3545; color: #dc3545;"
                                    onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');">Xóa</a>
                            </div>
                        </div>

                        <div class="detail-card">
                            <div class="product-visuals">
                                <img class="product-full-img" src="${product.imageURL}" alt="${product.name}">
                                <div style="color: #999; font-size: 12px;">SKU: ${product.sku}</div>
                            </div>

                            <div class="info-section">
                                <h3>Thông tin cơ bản</h3>

                                <div class="info-row">
                                    <div class="info-label">Mã sản phẩm (ID):</div>
                                    <div class="info-value">#${product.id}</div>
                                </div>

                                <div class="info-row">
                                    <div class="info-label">Tên sản phẩm:</div>
                                    <div class="info-value" style="font-weight: 600;">${product.name}</div>
                                </div>

                                <div class="info-row">
                                    <div class="info-label">Giá bán:</div>
                                    <div class="info-value price-highlight">
                                        <fmt:formatNumber value="${product.price}" type="number" groupingUsed="true" />
                                        VNĐ
                                    </div>
                                </div>

                                <div class="info-row">
                                    <div class="info-label">Giá vốn:</div>
                                    <div class="info-value">
                                        <fmt:formatNumber value="${product.cost}" type="number" groupingUsed="true" />
                                        VNĐ
                                    </div>
                                </div>

                                <div class="info-row">
                                    <div class="info-label">Số lượng hiện có:</div>
                                    <div class="info-value">
                                        <span style="font-weight: 600; font-size: 16px;">${product.quantity}</span>
                                        ${product.unit}
                                    </div>
                                </div>

                                <div class="info-row">
                                    <div class="info-label">Thời gian bảo hành:</div>
                                    <div class="info-value">${product.warrantyPeriod} tháng</div>
                                </div>

                                <div class="info-row">
                                    <div class="info-label">Trạng thái:</div>
                                    <div class="info-value">
                                        <span
                                            class="status-badge ${product.status == 'Active' ? 'status-active' : 'status-inactive'}">
                                            ${product.status}
                                        </span>
                                    </div>
                                </div>

                                <div class="info-row">
                                    <div class="info-label">Ngày tạo:</div>
                                    <div class="info-value">${product.createDate}</div>
                                </div>

                                <div class="info-row">
                                    <div class="info-label">Lần cuối cập nhật:</div>
                                    <div class="info-value">${product.updateDate}</div>
                                </div>

                                <div style="margin-top: 30px;">
                                    <h4 style="margin-bottom: 10px; color: #555;">Mô tả sản phẩm:</h4>
                                    <div class="description-box">
                                        ${product.description}
                                    </div>
                                </div>
                            </div>
                        </div>

                        <c:if test="${sessionScope.acc.roleID == 2}">
                            <div class="detail-card history-section" style="display: block;">
                                <h3 style="margin-bottom: 20px; color: #333; display: flex; align-items: center;">
                                    <span style="margin-right: 10px;">📋</span> Lịch sử thay đổi sản phẩm
                                </h3>
                                
                                <c:choose>
                                    <c:when test="${not empty productHistory}">
                                        <table class="history-table">
                                            <thead>
                                                <tr>
                                                    <th style="width: 180px;">Thời gian</th>
                                                    <th style="width: 120px;">Hành động</th>
                                                    <th style="width: 150px;">Người thực hiện</th>
                                                    <th>Chi tiết thay đổi</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${productHistory}" var="h">
                                                    <tr>
                                                        <td style="color: #666;">
                                                            <fmt:formatDate value="${h.logDate}" pattern="dd/MM/yyyy HH:mm:ss" />
                                                        </td>
                                                        <td>
                                                            <span class="action-badge ${h.action == 'ADD_PRODUCT' ? 'action-add' : (h.action == 'EDIT_PRODUCT' ? 'action-edit' : 'action-stockin')}">
                                                                ${h.action}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <strong>${h.name}</strong>
                                                            <div style="font-size: 11px; color: #999;">IP: ${h.ipAddress}</div>
                                                        </td>
                                                        <td style="line-height: 1.5; color: #444;">
                                                            ${h.description}
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </c:when>
                                    <c:otherwise>
                                        <div style="padding: 40px; text-align: center; color: #999; background: #fafafa; border-radius: 4px;">
                                            Chưa có lịch sử ghi lại cho sản phẩm này.
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>
                    </div><!-- /admin-content -->
                </div><!-- /admin-main -->
            </body>

            </html>