<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>${empty product ? 'Thêm sản phẩm' : 'Sửa sản phẩm'} – IMS Manager</title>
            <style>
                .form-box {
                    background: #fff;
                    border: 1px solid #e0e0e0;
                    border-radius: 8px;
                    padding: 24px;
                    max-width: 800px;
                    margin-top: 20px;
                }

                .form-grid {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 20px;
                }

                .form-group {
                    margin-bottom: 20px;
                }

                .form-group.full-width {
                    grid-column: span 2;
                }

                .form-group label {
                    display: block;
                    font-size: 14px;
                    font-weight: 600;
                    color: #555;
                    margin-bottom: 8px;
                }

                .form-control {
                    width: 100%;
                    padding: 10px 12px;
                    border: 1px solid #ddd;
                    border-radius: 4px;
                    font-size: 14px;
                    box-sizing: border-box;
                }
                
                .form-control:focus {
                    border-color: #007bff;
                    outline: none;
                    box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.1);
                }

                textarea.form-control {
                    resize: vertical;
                    min-height: 100px;
                }
                
                .action-row {
                    margin-top: 30px;
                    display: flex;
                    justify-content: flex-end;
                    gap: 10px;
                }
            </style>
        </head>

        <body>
            <c:set var="currentPage" value="productForm" scope="request" />
            <jsp:include page="managerSidebar.jsp" />

            <div class="admin-main">
                <div class="admin-topbar">
                    <div>
                        <h1>${empty product ? 'Thêm sản phẩm mới' : 'Chỉnh sửa sản phẩm'}</h1>
                        <small>Manager &rsaquo; Kho hàng &rsaquo; Danh sách sản phẩm &rsaquo; ${empty product ? 'Thêm mới' : 'Chỉnh sửa'}</small>
                    </div>
                    <div>Xin chào, <strong>${sessionScope.acc.fullName}</strong></div>
                </div>

                <div class="admin-content">
                    <div style="margin-bottom: 20px;">
                        <c:choose>
                            <c:when test="${sessionScope.acc.roleID == 1}">
                                <a href="staff_dashboard?tab=products" class="btn btn-outline">&larr; Quay lại danh sách</a>
                            </c:when>
                            <c:when test="${sessionScope.acc.roleID == 2}">
                                <a href="category" class="btn btn-outline">&larr; Quay lại danh sách</a>
                            </c:when>
                            <c:otherwise>
                                <a href="products" class="btn btn-outline">&larr; Quay lại danh sách</a>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="form-box">
                        <c:if test="${not empty error}">
                            <div style="color: #dc3545; background: #f8d7da; padding: 10px; border-radius: 4px; margin-bottom: 20px;">
                                ⚠️ ${error}
                            </div>
                        </c:if>

                        <form action="${empty product ? 'addProduct' : 'editProduct'}" method="post">
                            <c:if test="${not empty product}">
                                <input type="hidden" name="id" value="${product.id}">
                            </c:if>

                            <div class="form-grid">
                                <div class="form-group">
                                    <label>Danh mục:</label>
                                    <select name="categoryId" class="form-control" required>
                                        <c:forEach items="${categories}" var="c">
                                            <option value="${c.id}" ${product.categoryId==c.id ? 'selected' : '' }>${c.name}</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label>Trạng thái:</label>
                                    <select name="status" class="form-control">
                                        <option value="Active" ${product.status !=null && product.status.trim().equalsIgnoreCase('Active') ? 'selected' : '' }>Active</option>
                                        <option value="Deactivated" ${product.status !=null && product.status.trim().equalsIgnoreCase('Deactivated') ? 'selected' : '' }>Deactivated</option>
                                    </select>
                                </div>

                                <div class="form-group full-width">
                                    <label>Tên sản phẩm:</label>
                                    <input type="text" name="name" class="form-control" value="${product.name}" required>
                                </div>

                                <div class="form-group">
                                    <label>SKU:</label>
                                    <input type="text" name="sku" class="form-control" value="${product.sku}" required>
                                </div>

                                <div class="form-group">
                                    <label>Đơn vị (VD: Cái, Hộp):</label>
                                    <input type="text" name="unit" class="form-control" value="${product.unit}" required>
                                </div>

                                <div class="form-group">
                                    <label>Giá nhập (Cost):</label>
                                    <input type="number" step="0.01" name="cost" class="form-control" value="${product.cost}" min="0" required>
                                </div>

                                <div class="form-group">
                                    <label>Giá bán (Price):</label>
                                    <input type="number" step="0.01" name="price" class="form-control" value="${product.price}" min="0" required>
                                </div>

                                <div class="form-group">
                                    <label>Số lượng:</label>
                                    <input type="number" name="quantity" class="form-control" value="${product.quantity}" min="0" required>
                                </div>

                                 <div class="form-group">
                                    <label>Bảo hành (tháng):</label>
                                    <input type="number" name="warrantyPeriod" class="form-control" value="${product.warrantyPeriod}" min="0" required>
                                </div>
                                
                                <div class="form-group">
                                    <label>Ngưỡng kho thấp:</label>
                                    <input type="number" name="lowStockThreshold" class="form-control" value="${product.lowStockThreshold}" min="0" required>
                                    <small style="color: #666;">Cảnh báo khi số lượng nhỏ hơn số này.</small>
                                </div>

                                <div class="form-group full-width">
                                    <label>Image URL:</label>
                                    <input type="text" name="imageURL" class="form-control" value="${product.imageURL}" required>
                                </div>

                                <div class="form-group full-width">
                                    <label>Mô tả:</label>
                                    <textarea name="description" class="form-control" rows="4">${product.description}</textarea>
                                </div>
                            </div>

                            <div class="action-row">
                                <input type="submit" class="btn btn-primary" style="padding: 10px 24px;"
                                    value="${empty product ? 'Lưu sản phẩm' : 'Cập nhật sản phẩm'}">
                            </div>
                        </form>
                    </div>
                </div><!-- /admin-content -->
            </div><!-- /admin-main -->
        </body>

        </html>