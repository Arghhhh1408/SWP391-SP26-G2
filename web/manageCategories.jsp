<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>Quản lý danh mục – IMS Manager</title>
        </head>

        <body>
            <c:set var="currentPage" value="manageCategories" scope="request" />
            <jsp:include page="managerSidebar.jsp" />

            <div class="admin-main">
                <div class="admin-topbar">
                    <div>
                        <h1>Quản lý danh mục</h1>
                        <small>Manager &rsaquo; Danh mục sản phẩm</small>
                    </div>
                    <div>Xin chào, <strong>${sessionScope.acc.fullName}</strong></div>
                </div>

                <div class="admin-content">

                    <!-- Search & Filter Box -->
                    <div class="search-box"
                        style="background: #fff; border: 1px solid #e0e0e0; border-radius: 8px; padding: 20px; margin-bottom: 24px;">
                        <form action="manageCategories" method="get">
                            <div style="display: flex; flex-wrap: wrap; align-items: flex-end; gap: 20px;">
                                <!-- Filter by Parent -->
                                <div style="display: flex; flex-direction: column; gap: 6px; min-width: 250px;">
                                    <label style="font-size: 12px; color: #888; font-weight: 600;">Lọc theo danh mục
                                        cha</label>
                                    <select name="parentIdFilter" class="form-control"
                                        style="padding: 8px; border: 1px solid #ddd; border-radius: 4px; width: 100%;">
                                        <option value="">-- Tất cả --</option>
                                        <option value="0" ${selectedParentId==0 ? 'selected' : '' }>-- Chỉ hiện danh mục
                                            gốc --</option>
                                        <c:forEach items="${allCategoriesList}" var="pc">
                                            <c:if test="${empty pc.parentId || pc.parentId == 0}">
                                                <option value="${pc.id}" ${selectedParentId==pc.id ? 'selected' : '' }>
                                                    ${pc.name}
                                                </option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>

                                <!-- Sort by alphabet -->
                                <div style="display: flex; flex-direction: column; gap: 6px; min-width: 200px;">
                                    <label style="font-size: 12px; color: #888; font-weight: 600;">Sắp xếp theo</label>
                                    <select name="sortBy" class="form-control"
                                        style="padding: 8px; border: 1px solid #ddd; border-radius: 4px; width: 100%;">
                                        <option value="name_asc" ${selectedSortBy=='name_asc' ? 'selected' : '' }>Tên
                                            A-Z</option>
                                        <option value="name_desc" ${selectedSortBy=='name_desc' ? 'selected' : '' }>Tên
                                            Z-A</option>
                                        <option value="id_asc" ${selectedSortBy=='id_asc' ? 'selected' : '' }>Mã ID
                                        </option>
                                    </select>
                                </div>

                                <div style="display: flex; gap: 10px;">
                                    <button type="submit" class="btn btn-primary" style="padding: 8px 24px;">Áp
                                        dụng</button>
                                    <a href="manageCategories" class="btn btn-outline" style="padding: 8px 24px;">Xóa bộ
                                        lọc</a>
                                </div>
                            </div>
                        </form>
                    </div>

                    <div style="display: flex; justify-content: flex-end; margin-bottom: 20px;">
                        <a href="addCategory" class="btn btn-primary">+ Thêm danh mục mới</a>
                    </div>

                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th style="width: 80px;">ID</th>
                                <th>Tên danh mục</th>
                                <th>Danh mục cha</th>
                                <th style="text-align: right; width: 150px;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty categories}">
                                    <tr>
                                        <td colspan="4" style="text-align: center; padding: 40px; color: #999;">
                                            <i>Không tìm thấy danh mục nào với bộ lọc này.</i>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${categories}" var="c">
                                        <tr>
                                            <td><small style="color: #999;">#${c.id}</small></td>
                                            <td><strong style="color: #333;">${c.name}</strong></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty c.parentId && c.parentId > 0}">
                                                        <c:forEach items="${allCategoriesList}" var="parent">
                                                            <c:if test="${parent.id == c.parentId}">
                                                                <span class="status-badge"
                                                                    style="background: #e9ecef; color: #495057; font-size: 11px; padding: 2px 8px;">${parent.name}</span>
                                                            </c:if>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span
                                                            style="color: #bbb; font-style: italic; font-size: 12px;">(Danh
                                                            mục gốc)</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="text-align: right;">
                                                <a href="editCategory?id=${c.id}" class="btn btn-outline"
                                                    style="padding: 4px 10px;">Sửa</a>
                                                <a href="deleteCategory?id=${c.id}" class="btn btn-outline"
                                                    style="padding: 4px 10px; border-color: #dc3545; color: #dc3545;"
                                                    onclick="return confirm('Bạn có chắc muốn xóa danh mục này?');">Xóa</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div><!-- /admin-content -->
            </div><!-- /admin-main -->
        </body>

        </html>