<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>Product Categories</title>
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        padding: 20px;
                    }

                    table {
                        border-collapse: separate;
                        border-spacing: 2px;
                        width: 100%;
                    }

                    th,
                    td {
                        border: 1px solid #777;
                        padding: 4px;
                        text-align: left;
                    }

                    th {
                        font-weight: bold;
                    }

                    .action-link {
                        border: 1px solid black;
                        padding: 2px 5px;
                        text-decoration: underline;
                        color: blue;
                        margin-right: 2px;
                        font-size: 0.9em;
                    }

                    .active-category {
                        font-weight: bold;
                        text-decoration: none;
                        color: black;
                    }

                    .category-menu {
                        list-style: none;
                        padding: 0;
                        display: flex;
                        gap: 10px;
                    }

                    .subcategory-menu {
                        display: none;
                        position: absolute;
                        background: white;
                        border: 1px solid black;
                        padding: 5px;
                        z-index: 10;
                    }

                    .category-item:hover .subcategory-menu {
                        display: block;
                    }
                </style>
            </head>

            <body>
                <div class="nav-links">
                    <h2>Inventory Management</h2>
                    <a href="category">Home</a> |
                    <a href="addProduct">Add Product</a> |
                    <a href="manageCategories">Manage Categories</a> |
                    <a href="logout" style="color: red;">Logout</a>
                </div>
                <br><br/>
                <div class="category-nav">
                    <strong>Category:</strong>
                    <ul class="category-menu">
                        <li class="category-item">
                            <a href="category"
                                class="category-link ${empty selectedCategoryId ? 'active-category' : ''}">All
                                Products</a>
                        </li>
                        <c:forEach items="${categories}" var="c">
                            <c:if test="${empty c.parentID}">
                                <li class="category-item">
                                    <a href="category?categoryId=${c.id}"
                                        class="category-link ${c.id == selectedCategoryId ? 'active-category' : ''}">${c.name}</a>

                                    <c:set var="hasSub" value="false" />
                                    <c:forEach items="${categories}" var="subCheck">
                                        <c:if test="${subCheck.parentID == c.id}">
                                            <c:set var="hasSub" value="true" />
                                        </c:if>
                                    </c:forEach>

                                    <c:if test="${hasSub}">
                                        <ul class="subcategory-menu">
                                            <c:forEach items="${categories}" var="sub">
                                                <c:if test="${sub.parentID == c.id}">
                                                    <li class="subcategory-item">
                                                        <a href="category?categoryId=${sub.id}"
                                                            class="subcategory-link ${sub.id == selectedCategoryId ? 'active-category' : ''}">${sub.name}</a>
                                                    </li>
                                                </c:if>
                                            </c:forEach>
                                        </ul>
                                    </c:if>
                                </li>
                            </c:if>
                        </c:forEach>
                    </ul>
                </div>

                <div class="search-section">
                    <form action="category" method="get">
                        Search: <input type="text" name="keyword" value="${keyword}" placeholder="Name/SKU">
                        Price: <input type="number" name="minPrice" value="${minPrice}" style="width: 80px;"> -
                        <input type="number" name="maxPrice" value="${maxPrice}" style="width: 80px;">
                        <c:if test="${not empty param.categoryId}">
                            <input type="hidden" name="categoryId" value="${param.categoryId}">
                        </c:if>
                        <button type="submit">Filter</button>
                        <a href="category">[Reset]</a>
                    </form>
                </div>

                <h1>Products</h1>

                <c:if test="${not empty error}">
                    <h3 style="color: red;">${error}</h3>
                    <p>Please ensure you have run the database script in the correct database
                        (SimpleInventoryManagement).
                    </p>
                </c:if>

                <c:if test="${empty error and empty products}">
                    <p>No products found.</p>
                </c:if>

                <c:if test="${not empty products}">
                    <table border="1">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Image</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Status</th>
                                <th colspan="3">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${products}" var="p">
                                <tr>
                                    <td>${p.id}</td>
                                    <td><a href="productDetail?id=${p.id}">${p.name}</a></td>
                                    <td><img src="${p.imageURL}" alt="${p.name}" style="width: 40px;"></td>
                                    <td>
                                        <fmt:formatNumber value="${p.price}" type="number" />
                                    </td>
                                    <td>${p.stockQuantity}</td>
                                    <td>${p.status}</td>
                                    <td>
                                        <a href="productDetail?id=${p.id}" class="action-link">Xem chi tiết</a>
                                    </td>
                                    <td>
                                        <a href="editProduct?id=${p.id}" class="action-link">Sửa</a>
                                    </td>
                                    <td>
                                        <a href="deleteProduct?id=${p.id}" class="action-link"
                                            onclick="return confirm('Xóa?');">Xóa</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <!-- Pagination Controls -->
                    <c:if test="${totalPages > 1}">
                        <div style="margin-top: 20px; text-align: center;">
                            <c:url var="paginationUrl" value="category">
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

                            <!-- Previous Button -->
                            <c:if test="${currentPage > 1}">
                                <a href="${paginationUrl}&page=${currentPage - 1}">« Previous</a>
                            </c:if>

                            <!-- Page Numbers -->
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <c:choose>
                                    <c:when test="${i == currentPage}">
                                        <strong style="margin: 0 5px;">${i}</strong>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${paginationUrl}&page=${i}" style="margin: 0 5px;">${i}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <!-- Next Button -->
                            <c:if test="${currentPage < totalPages}">
                                <a href="${paginationUrl}&page=${currentPage + 1}">Next »</a>
                            </c:if>

                            <p style="margin-top: 10px; color: #666;">
                                Page ${currentPage} of ${totalPages} (Total: ${totalProducts} products)
                            </p>
                        </div>
                    </c:if>
                </c:if>
            </body>

            </html>