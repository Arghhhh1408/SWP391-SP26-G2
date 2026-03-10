<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>${not empty product ? 'Sửa' : 'Thêm'} sản phẩm</title>
            <style>
                .form-card {
                    background: #fff;
                    border: 1px solid #e0e0e0;
                    border-radius: 8px;
                    padding: 24px;
                    max-width: 900px;
                    margin: 20px auto;
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
                    margin-bottom: 8px;
                    font-weight: 600;
                    color: #555;
                    font-size: 14px;
                }

                .form-control {
                    width: 100%;
                    padding: 10px;
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
                    height: 120px;
                    resize: vertical;
                }

                .btn-group {
                    margin-top: 30px;
                    display: flex;
                    gap: 12px;
                    justify-content: flex-end;
                }
            </style>
        </head>

        <body>
            <c:set var="currentPage" value="category" scope="request" />
            <jsp:include page="managerSidebar.jsp" />

            <div class="admin-main">
                <div class="admin-topbar">
                    <div>
                        <h1>${not empty product.id ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới'}</h1>
                        <small>Manager &rsaquo; Kho hàng &rsaquo; ${not empty product.id ? 'Sửa' : 'Thêm'}</small>
                    </div>
                </div>

                <div class="admin-content">
                    <div style="margin-bottom: 20px;">
                        <a href="category" class="btn btn-outline">&larr; Quay lại danh sách</a>
                    </div>

                    <div class="form-card">
                        <c:if test="${not empty error}">
                            <div
                                style="color: #dc3545; padding: 12px; background: #f8d7da; border-radius: 4px; margin-bottom: 20px; font-size: 14px;">
                                ${error}
                            </div>
                        </c:if>

                        <form action="${not empty product.id ? 'editProduct' : 'addProduct'}" method="post">
                            <c:if test="${not empty product.id}">
                                <input type="hidden" name="id" value="${product.id}">
                            </c:if>

                            <div class="form-grid">
                                <div class="form-group">
                                    <label>Tên sản phẩm:</label>
                                    <input type="text" name="name" class="form-control" value="${product.name}" required
                                        placeholder="Nhập tên sản phẩm">
                                </div>

                                <div class="form-group">
                                    <label>Mã SKU:</label>
                                    <input type="text" name="sku" class="form-control" value="${product.sku}" required
                                        placeholder="Vd: IP15-PRO-BLK">
                                </div>

                                <div class="form-group">
                                    <label>Danh mục:</label>
                                    <select name="categoryId" class="form-control" required>
                                        <option value="">-- Chọn danh mục --</option>
                                        <c:forEach items="${categories}" var="cat">
                                            <option value="${cat.id}" ${product.categoryId==cat.id ? 'selected' : '' }>
                                                ${cat.name}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label>Trạng thái:</label>
                                    <select name="status" class="form-control">
                                        <option value="Active" ${product.status=='Active' ? 'selected' : '' }>Active
                                        </option>
                                        <option value="Inactive" ${product.status=='Inactive' ? 'selected' : '' }>
                                            Inactive</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label>Giá vốn (Cost):</label>
                                    <input type="number" name="cost" class="form-control" value="${product.cost}"
                                        step="0.01" required>
                                </div>

                                <div class="form-group">
                                    <label>Giá bán (Price):</label>
                                    <input type="number" name="price" class="form-control" value="${product.price}"
                                        step="0.01" required>
                                </div>

                                <div class="form-group">
                                    <label>Số lượng hiện có:</label>
                                    <input type="number" name="quantity" class="form-control"
                                        value="${product.quantity}" required>
                                </div>

                                <div class="form-group">
                                    <label>Đơn vị tính:</label>
                                    <input type="text" name="unit" class="form-control" value="${product.unit}" required
                                        placeholder="Vd: Cái, Bộ, kg...">
                                </div>

                                <div class="form-group">
                                    <label>Thời gian bảo hành (tháng):</label>
                                    <input type="number" name="warrantyPeriod" class="form-control"
                                        value="${product.warrantyPeriod}" min="0" required>
                                </div>

                                <div class="form-group">
                                    <label>Đường dẫn ảnh (URL):</label>
                                    <input type="text" name="imageURL" class="form-control" value="${product.imageURL}"
                                        required>
                                </div>

                                <div class="form-group full-width">
                                    <label>Mô tả chi tiết:</label>
                                    <textarea name="description" class="form-control"
                                        placeholder="Nhập mô tả sản phẩm...">${product.description}</textarea>
                                </div>
                            </div>

                            <div class="btn-group">
                                <a href="category" class="btn btn-outline" style="padding: 10px 25px;">Hủy</a>
                                <button type="submit" class="btn btn-primary" style="padding: 10px 30px;">
                                    ${not empty product.id ? 'Cập nhật' : 'Lưu sản phẩm'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </body>

        </html>