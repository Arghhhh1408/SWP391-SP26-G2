<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="jakarta.tags.core" %>
        <%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>Quản lý kho hàng</title>
                <style>
                    .admin-content {
                        padding: 24px;
                        background: #f8f9fa;
                        min-height: calc(100vh - 70px);
                    }

                    .search-box {
                        background: #fff;
                        padding: 20px;
                        border-radius: 8px;
                        border: 1px solid #e0e0e0;
                        margin-bottom: 24px;
                        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
                    }

                    .search-row {
                        display: flex;
                        gap: 15px;
                        align-items: flex-end;
                        flex-wrap: wrap;
                    }

                    .search-group {
                        display: flex;
                        flex-direction: column;
                        gap: 6px;
                    }

                    .search-group label {
                        font-size: 12px;
                        font-weight: 600;
                        color: #666;
                        text-transform: uppercase;
                    }

                    .input-field {
                        padding: 8px 12px;
                        border: 1px solid #ddd;
                        border-radius: 4px;
                        font-size: 14px;
                        min-width: 200px;
                    }

                    .input-field:focus {
                        border-color: #007bff;
                        outline: none;
                    }

                    /* Category Navigation */
                    .category-nav {
                        display: flex;
                        gap: 10px;
                        margin-bottom: 24px;
                        flex-wrap: wrap;
                    }

                    .cat-pill {
                        position: relative;
                        background: #fff;
                        border: 1px solid #ddd;
                        border-radius: 20px;
                        padding: 0;
                        transition: all 0.2s;
                    }

                    .cat-pill a {
                        display: block;
                        padding: 8px 18px;
                        text-decoration: none;
                        color: #555;
                        font-size: 14px;
                        font-weight: 500;
                    }

                    .cat-pill:hover {
                        border-color: #007bff;
                        background: #f0f7ff;
                    }

                    .cat-pill.active {
                        background: #007bff;
                        border-color: #007bff;
                    }

                    .cat-pill.active a {
                        color: #fff;
                    }

                    /* Sub-menu on Hover */
                    .sub-menu {
                        position: absolute;
                        top: 100%;
                        left: 0;
                        background: #fff;
                        border: 1px solid #ddd;
                        border-radius: 8px;
                        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                        display: none;
                        flex-direction: column;
                        min-width: 180px;
                        z-index: 100;
                        margin-top: 5px;
                        padding: 8px 0;
                    }

                    .cat-pill:hover>.sub-menu {
                        display: flex;
                    }

                    .sub-menu::before {
                        content: '';
                        position: absolute;
                        top: -10px;
                        left: 0;
                        width: 100%;
                        height: 10px;
                        background: transparent;
                    }

                    .sub-menu a {
                        padding: 8px 16px;
                        color: #444;
                        font-weight: 400;
                        border-radius: 0;
                    }

                    .sub-menu a:hover {
                        background: #f8f9fa;
                        color: #007bff;
                    }

                    .sub-menu a.active {
                        background: #e7f1ff;
                        color: #007bff;
                        font-weight: 600;
                    }

                    /* Grandchild Menu Styling */
                    .sub-menu-item {
                        position: relative;
                    }

                    .grandchild-menu {
                        position: absolute;
                        top: 0;
                        left: 100%;
                        background: #fff;
                        border: 1px solid #ddd;
                        border-radius: 8px;
                        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                        display: none;
                        flex-direction: column;
                        min-width: 180px;
                        z-index: 101;
                        padding: 8px 0;
                        margin-left: 0;
                    }

                    .sub-menu-item:hover>.grandchild-menu {
                        display: flex;
                    }

                    .grandchild-menu a {
                        padding: 8px 16px;
                        color: #444;
                        font-weight: 400;
                    }

                    .grandchild-menu a:hover {
                        background: #f8f9fa;
                        color: #007bff;
                    }

                    .cat-pill a.has-children::after {
                        content: '▾';
                        margin-left: 5px;
                        font-size: 10px;
                    }

                    .sub-menu-item a.has-children::after {
                        content: '▸';
                        float: right;
                        margin-left: 10px;
                        font-size: 10px;
                    }

                    /* Product Table Styling */
                    .admin-table {
                        width: 100%;
                        background: #fff;
                        border-collapse: collapse;
                        border-radius: 8px;
                        overflow: hidden;
                        border: 1px solid #e0e0e0;
                    }

                    .admin-table th {
                        background: #f1f3f5;
                        padding: 14px 16px;
                        text-align: left;
                        font-size: 13px;
                        font-weight: 600;
                        color: #495057;
                        border-bottom: 2px solid #dee2e6;
                    }

                    .admin-table td {
                        padding: 16px;
                        border-bottom: 1px solid #eee;
                        font-size: 14px;
                        color: #333;
                        vertical-align: middle;
                    }

                    .product-img {
                        width: 50px;
                        height: 50px;
                        object-fit: contain;
                        background: #f8f9fa;
                        border-radius: 4px;
                        border: 1px solid #eee;
                    }

                    .status-badge {
                        padding: 4px 10px;
                        border-radius: 12px;
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

                    /* Pagination */
                    .pagination {
                        display: flex;
                        align-items: center;
                        gap: 5px;
                        margin-top: 24px;
                    }

                    .page-link {
                        padding: 6px 12px;
                        border: 1px solid #ddd;
                        background: #fff;
                        color: #555;
                        text-decoration: none;
                        border-radius: 4px;
                        font-size: 13px;
                    }

                    .page-link:hover {
                        background: #f8f9fa;
                    }

                    .page-link.active {
                        background: #007bff;
                        color: #fff;
                        border-color: #0056b3;
                    }

                    .stock-badge {
                        font-weight: 600;
                    }

                    .stock-low {
                        color: #dc3545;
                    }
                </style>
            </head>

            <body>
                <c:set var="currentPage" value="category" scope="request" />
                <jsp:include page="managerSidebar.jsp" />

                <div class="admin-main">
                    <div class="admin-topbar">
                        <div>
                            <h1>Tất cả sản phẩm</h1>
                            <small>Manager &rsaquo; Kho hàng &rsaquo; Danh sách</small>
                        </div>
                        <div>Xin chào, <strong>${sessionScope.acc.fullName}</strong></div>
                    </div>

                    <div class="admin-content">
                        <c:if test="${not empty sessionScope.error}">
                            <div
                                style="color: #dc3545; padding: 15px; background: #f8d7da; border-radius: 8px; margin-bottom: 20px; border: 1px solid #f5c2c2;">
                                ${sessionScope.error}
                                <c:remove var="error" scope="session" />
                            </div>
                        </c:if>

                        <!-- Search & Filter Box -->
                        <div class="search-box">
                            <form action="category" method="get">
                                <div class="search-row">
                                    <div class="search-group">
                                        <label>Tên/SKU</label>
                                        <input type="text" name="keyword" class="input-field" value="${keyword}"
                                            placeholder="Tìm kiếm...">
                                    </div>
                                    <div class="search-group">
                                        <label>Giá từ</label>
                                        <input type="number" name="minPrice" class="input-field" value="${minPrice}"
                                            style="width: 100px;">
                                    </div>
                                    <div class="search-group">
                                        <label>Đến</label>
                                        <input type="number" name="maxPrice" class="input-field" value="${maxPrice}"
                                            style="width: 100px;">
                                    </div>
                                    <div class="search-group">
                                        <label>Trạng thái</label>
                                        <select name="status" class="input-field" style="min-width: 120px;">
                                            <option value="all" ${status == 'all' ? 'selected' : ''}>Tất cả</option>
                                            <option value="Active" ${status == 'Active' ? 'selected' : ''}>Hoạt động</option>
                                            <option value="Deactivated" ${status == 'Deactivated' ? 'selected' : ''}>Ngừng kinh doanh</option>
                                        </select>
                                    </div>
                                    <c:if test="${not empty param.categoryId}">
                                        <input type="hidden" name="categoryId" value="${param.categoryId}">
                                    </c:if>
                                    <div class="search-group">
                                        <button type="submit" class="btn btn-primary" style="padding: 8px 20px;">Tìm
                                            kiếm</button>
                                    </div>
                                    <div class="search-group">
                                        <a href="category" class="btn btn-outline" style="padding: 8px 20px;">Xóa bộ
                                            lọc</a>
                                    </div>
                                </div>
                            </form>
                        </div>

                        <!-- Category Navigation -->
                        <div class="category-nav">
                            <div class="cat-pill ${empty param.categoryId ? 'active' : ''}">
                                <a href="category">Tất cả</a>
                            </div>
                            <c:forEach items="${categories}" var="cat">
                                <div class="cat-pill ${cat.id == param.categoryId ? 'active' : ''}">
                                    <a href="category?categoryId=${cat.id}"
                                        class="${not empty cat.children ? 'has-children' : ''}">
                                        ${cat.name}
                                    </a>
                                    <c:if test="${not empty cat.children}">
                                        <div class="sub-menu">
                                            <c:forEach items="${cat.children}" var="child">
                                                <div class="sub-menu-item">
                                                    <a href="category?categoryId=${child.id}"
                                                        class="${child.id == param.categoryId ? 'active' : ''} ${not empty child.children ? 'has-children' : ''}">
                                                        ${child.name}
                                                    </a>
                                                    <c:if test="${not empty child.children}">
                                                        <div class="grandchild-menu">
                                                            <c:forEach items="${child.children}" var="gchild">
                                                                <a href="category?categoryId=${gchild.id}"
                                                                    class="${gchild.id == param.categoryId ? 'active' : ''}">
                                                                    ${gchild.name}
                                                                </a>
                                                            </c:forEach>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>

                        <div
                            style="display: flex; justify-content: flex-end; margin-bottom: 20px; gap: 10px; align-items: center; flex-wrap: wrap;">
                            <div id="bulkActions"
                                style="display: none; gap: 10px; align-items: center; background: #f8fafc; padding: 5px 10px; border-radius: 6px; border: 1px solid #e2e8f0;">
                                <span style="font-size: 13px; font-weight: 600; color: #64748b;">Hàng loạt:</span>
                                <button type="button" onclick="submitBulkAction('softDelete')" class="btn btn-outline"
                                    style="background: #fef9c3; color: #854d0e; border-color: #fef08a; padding: 4px 8px; font-size: 12px;">Xóa
                                    mềm</button>
                                <button type="button" onclick="submitBulkAction('activate')" class="btn btn-outline"
                                    style="background: #dcfce7; color: #166534; border-color: #bbf7d0; padding: 4px 8px; font-size: 12px;">Kích hoạt</button>
                                <button type="button" onclick="submitBulkAction('hardDelete')" class="btn btn-outline"
                                    style="background: #fee2e2; color: #991b1b; border-color: #fecaca; padding: 4px 8px; font-size: 12px;">Xóa
                                    cứng</button>
                            </div>

                            <a href="exportProducts" class="btn btn-outline"
                                style="background: #dcfce7; color: #166534; border-color: #bbf7d0;">Export Excel</a>

                            <form action="importProducts" method="post" enctype="multipart/form-data"
                                style="display: flex; gap: 5px;">
                                <input type="file" name="file" accept=".xlsx, .xls"
                                    style="font-size: 12px; width: 150px;" required>
                                <button type="submit" class="btn btn-primary" style="padding: 5px 10px;">Import
                                    Excel</button>
                            </form>

                            <a href="addProduct" class="btn btn-primary">+ Thêm sản phẩm mới</a>
                        </div>

                        <c:if test="${not empty error}">
                            <div
                                style="color: #dc3545; padding: 15px; background: #f8d7da; border-radius: 8px; margin-bottom: 20px;">
                                ${error}
                            </div>
                        </c:if>

                        <c:if test="${empty error and empty products}">
                            <div
                                style="text-align: center; padding: 60px; color: #888; background: #fff; border: 1px solid #e0e0e0; border-radius: 8px;">
                                <span style="font-size: 48px;">&#128269;</span>
                                <p>Không tìm thấy sản phẩm nào phù hợp.</p>
                            </div>
                        </c:if>

                        <c:if test="${not empty products}">
                            <form id="bulkActionForm" action="bulkProductAction" method="post">
                                <input type="hidden" name="action" id="bulkActionType" value="">
                                <table class="admin-table">
                                    <thead>
                                        <tr>
                                            <th style="width: 40px;"><input type="checkbox" id="selectAll"
                                                    onclick="toggleSelectAll(this)"></th>
                                            <th>ID</th>
                                            <th>Ảnh</th>
                                            <th>Tên sản phẩm</th>
                                            <th>Giá (VNĐ)</th>
                                            <th>Số lượng</th>
                                            <th>Trạng thái</th>
                                            <th style="text-align: right;">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${products}" var="p">
                                            <tr>
                                                <td><input type="checkbox" name="selectedProducts" value="${p.id}"
                                                        onclick="updateBulkActionsVisibility()"></td>
                                                <td><small style="color: #999;">#${p.id}</small></td>
                                                <td><img src="${p.imageURL}" class="product-img" alt="${p.name}"></td>
                                                <td>
                                                    <a href="productDetail?id=${p.id}"
                                                        style="text-decoration: none; color: #007bff; font-weight: 600;">
                                                        ${p.name}
                                                    </a>
                                                </td>
                                                <td>
                                                    <fmt:formatNumber value="${p.price}" type="number"
                                                        groupingUsed="true" />
                                                </td>
                                                <td>
                                                    <span
                                                        class="stock-badge ${p.quantity < 5 ? 'stock-low' : ''}">${p.quantity}</span>
                                                </td>
                                                <td>
                                                    <span
                                                        class="status-badge ${p.status == 'Active' ? 'status-active' : 'status-inactive'}">
                                                        ${p.status}
                                                    </span>
                                                </td>
                                                <td style="text-align: right;">
                                                    <a href="productDetail?id=${p.id}" class="btn btn-outline"
                                                        style="padding: 4px 10px;">Xem</a>
                                                    <a href="editProduct?id=${p.id}" class="btn btn-outline"
                                                        style="padding: 4px 10px;">Sửa</a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </form>
                            </tbody>
                            </table>

                            <!-- Pagination -->
                            <c:if test="${totalPages > 1}">
                                <div class="pagination">
                                    <c:url var="basePageUrl" value="category">
                                        <c:if test="${not empty param.categoryId}">
                                            <c:param name="categoryId" value="${param.categoryId}" />
                                        </c:if>
                                        <c:if test="${not empty keyword}">
                                            <c:param name="keyword" value="${keyword}" />
                                        </c:if>
                                        <c:if test="${not empty minPrice}">
                                            <c:param name="minPrice" value="${minPrice}" />
                                        </c:if>
                                        <c:if test="${not empty maxPrice}">
                                            <c:param name="maxPrice" value="${maxPrice}" />
                                        </c:if>
                                        <c:if test="${not empty status}">
                                            <c:param name="status" value="${status}" />
                                        </c:if>
                                    </c:url>

                                    <c:set var="pageSep" value="${basePageUrl.contains('?') ? '&' : '?'}" />

                                    <c:if test="${currentPaginationPage > 1}">
                                        <a href="${basePageUrl}${pageSep}page=1" class="page-link">«</a>
                                        <a href="${basePageUrl}${pageSep}page=${currentPaginationPage - 1}"
                                            class="page-link">‹</a>
                                    </c:if>

                                    <c:forEach begin="${currentPaginationPage - 2 > 0 ? currentPaginationPage - 2 : 1}"
                                        end="${currentPaginationPage + 2 < totalPages ? currentPaginationPage + 2 : totalPages}"
                                        var="i">
                                        <a href="${basePageUrl}${pageSep}page=${i}"
                                            class="page-link ${i == currentPaginationPage ? 'active' : ''}">${i}</a>
                                    </c:forEach>

                                    <c:if test="${currentPaginationPage < totalPages}">
                                        <a href="${basePageUrl}${pageSep}page=${currentPaginationPage + 1}"
                                            class="page-link">›</a>
                                        <a href="${basePageUrl}${pageSep}page=${totalPages}" class="page-link">»</a>
                                    </c:if>
                                </div>
                            </c:if>
                        </c:if>
                    </div>
                </div>
                <script>
                    function toggleSelectAll(source) {
                        var checkboxes = document.getElementsByName('selectedProducts');
                        for (var i = 0, n = checkboxes.length; i < n; i++) {
                            checkboxes[i].checked = source.checked;
                        }
                        updateBulkActionsVisibility();
                    }

                    function updateBulkActionsVisibility() {
                        var checkboxes = document.getElementsByName('selectedProducts');
                        var bulkActions = document.getElementById('bulkActions');
                        var anyChecked = false;
                        for (var i = 0; i < checkboxes.length; i++) {
                            if (checkboxes[i].checked) {
                                anyChecked = true;
                                break;
                            }
                        }
                        if (bulkActions) {
                            bulkActions.style.display = anyChecked ? 'flex' : 'none';
                        }

                        // Update Select All checkbox state
                        var selectAll = document.getElementById('selectAll');
                        if (selectAll) {
                            var allChecked = true;
                            if (checkboxes.length === 0) allChecked = false;
                            for (var i = 0; i < checkboxes.length; i++) {
                                if (!checkboxes[i].checked) {
                                    allChecked = false;
                                    break;
                                }
                            }
                            selectAll.checked = allChecked;
                        }
                    }

                    function submitBulkAction(action) {
                        var confirmMsg = '';
                        if (action === 'hardDelete') {
                            confirmMsg = 'Bạn có chắc chắn muốn XÓA VĨNH VIỄN các sản phẩm đã chọn không? Thao tác này không thể hoàn tác!';
                        } else if (action === 'activate') {
                            confirmMsg = 'Bạn có muốn chuyển trạng thái các sản phẩm đã chọn thành Active không?';
                        } else {
                            confirmMsg = 'Bạn có muốn chuyển trạng thái các sản phẩm đã chọn thành Deactive không?';
                        }

                        if (confirm(confirmMsg)) {
                            document.getElementById('bulkActionType').value = action;
                            document.getElementById('bulkActionForm').submit();
                        }
                    }
                </script>
            </body>

            </html>