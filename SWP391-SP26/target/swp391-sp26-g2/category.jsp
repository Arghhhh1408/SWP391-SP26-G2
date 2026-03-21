<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="jakarta.tags.core" %>
        <%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>Product Categories</title>
            </head>

            <body>
                <h1>Categories</h1>
                <p>
                    <a href="logout">Đăng xuất</a> |
                    <a href="addProduct">Thêm sản phẩm mới</a> |
                    <a href="manageCategories">Quản lý danh mục</a> |
                    <a href="stockinList">Danh sách nhập kho</a> |
                    <a href="supplierList">Danh sách nhà cung cấp</a>
                </p>

                <h3>Tìm kiếm sản phẩm</h3>
                <form action="category" method="get" style="margin-bottom: 20px;">
                    Tên/SKU: <input type="text" name="keyword" value="${keyword}">
                    Giá từ: <input type="number" name="minPrice" value="${minPrice}" style="width: 80px;">
                    đến: <input type="number" name="maxPrice" value="${maxPrice}" style="width: 80px;">
                    <c:if test="${not empty param.categoryId}">
                        <input type="hidden" name="categoryId" value="${param.categoryId}">
                    </c:if>
                    <input type="submit" value="Tìm Kiếm">
                    <a href="category">Xóa bộ lọc</a>
                </form>

                <p>
                    Lọc theo danh mục:
                    <select onchange="window.location.href = this.value">
                        <option value="category" ${empty param.categoryId ? 'selected' : '' }>Tất cả</option>
                        <c:forEach items="${categories}" var="c">
                            <option value="category?categoryId=${c.id}" ${c.id==param.categoryId ? 'selected' : '' }>
                                ${c.name}</option>
                        </c:forEach>
                    </select>
                </p>

                <c:if test="${not empty error}">
                    <p style="color: red;">${error}</p>
                </c:if>

                <c:if test="${empty error and empty products}">
                    <p>Không tìm thấy sản phẩm nào.</p>
                </c:if>

                <c:if test="${not empty products}">
                    <table border="1">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tên sản phẩm</th>
                                <th>Ảnh</th>
                                <th>Giá</th>
                                <th>Số lượng</th>
                                <th>Trạng thái</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${products}" var="p">
                                <tr>
                                    <td>${p.id}</td>
                                    <td><a href="productDetail?id=${p.id}">${p.name}</a></td>
                                    <td><img src="${p.imageURL}" alt="${p.name}" style="width: 50px;"></td>
                                    <td>
                                        <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true" />
                                    </td>
                                    <td>${p.quantity}</td>
                                    <td>${p.status}</td>
                                    <td>
                                        <a href="productDetail?id=${p.id}">Xem</a> |
                                        <a href="editProduct?id=${p.id}">Sửa</a> |
                                        <a href="deleteProduct?id=${p.id}"
                                            onclick="return confirm('Bạn có chắc chắn?');">Xóa</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <div style="margin-top: 15px;">
                            <!-- First Page -->
                            <c:choose>
                                <c:when test="${currentPage > 1}">
                                    <c:url var="firstUrl" value="category">
                                        <c:param name="page" value="1" />
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
                                    </c:url>
                                    <a href="${firstUrl}">« Đầu</a> |
                                </c:when>
                                <c:otherwise><span style="color: gray;">« Đầu</span> | </c:otherwise>
                            </c:choose>

                            <!-- Previous Button -->
                            <c:choose>
                                <c:when test="${currentPage > 1}">
                                    <c:url var="prevUrl" value="category">
                                        <c:param name="page" value="${currentPage - 1}" />
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
                                    </c:url>
                                    <a href="${prevUrl}">Trước</a>
                                </c:when>
                                <c:otherwise><span style="color: gray;">Trước</span></c:otherwise>
                            </c:choose>

                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <c:choose>
                                    <c:when test="${i == currentPage}">
                                        <strong>[${i}]</strong>
                                    </c:when>
                                    <c:otherwise>
                                        <c:url var="pageUrl" value="category">
                                            <c:param name="page" value="${i}" />
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
                                        </c:url>
                                        <a href="${pageUrl}">${i}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <c:choose>
                                <c:when test="${currentPage < totalPages}">
                                    <c:url var="nextUrl" value="category">
                                        <c:param name="page" value="${currentPage + 1}" />
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
                                    </c:url>
                                    <a href="${nextUrl}">Sau</a>
                                </c:when>
                                <c:otherwise><span style="color: gray;">Sau</span></c:otherwise>
                            </c:choose>

                            <!-- Last Page -->
                            <c:choose>
                                <c:when test="${currentPage < totalPages}">
                                    | <c:url var="lastUrl" value="category">
                                        <c:param name="page" value="${totalPages}" />
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
                                    </c:url>
                                    <a href="${lastUrl}">Cuối »</a>
                                </c:when>
                                <c:otherwise> | <span style="color: gray;">Cuối »</span></c:otherwise>
                            </c:choose>

                            <p style="font-size: 0.9em; color: gray;">
                                Trang ${currentPage} / ${totalPages} (${totalProducts} sản phẩm)
                            </p>
                        </div>
                    </c:if>
                </c:if>
            </body>

            </html>