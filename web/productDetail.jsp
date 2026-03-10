<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
                    </div><!-- /admin-content -->
                </div><!-- /admin-main -->
            </body>

            </html>