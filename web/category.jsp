<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>Product Categories</title>
                <style>
                    table {
                        border-collapse: collapse;
                        width: 100%;
                        margin-top: 20px;
                    }

                    th,
                    td {
                        border: 1px solid black;
                        padding: 8px;
                        text-align: left;
                    }
                </style>
            </head>

            <body>
                <h1 href="category">Categories</h1>
                <a href="logout">Đăng xuất</a> |
                <a href="addProduct">Add Product</a> |
                <a href="manageCategories">Manage Categories</a>

                <p>
                    <label for="categorySelect">Filter by Category:</label>
                    <select id="categorySelect" onchange="window.location.href=this.value">
                        <option value="category" ${empty param.categoryId ? 'selected' : '' }>All Products</option>
                        <c:forEach items="${categories}" var="c">
                            <option value="category?categoryId=${c.id}" ${c.id==param.categoryId ? 'selected' : '' }>
                                ${c.name}</option>
                        </c:forEach>
                    </select>
                </p>

                <!-- Search Form -->
                <form action="category" method="get" style="margin: 15px 0; padding: 10px 0;">
                    <strong>Search:</strong>
                    <input type="text" id="keyword" name="keyword" value="${keyword}" placeholder="Name or SKU"
                        style="margin: 0 5px; padding: 5px; width: 180px;">

                    <label for="minPrice" style="margin-left: 10px;">Price:</label>
                    <input type="number" id="minPrice" name="minPrice" value="${minPrice}" min="0" step="1000"
                        placeholder="Min" style="margin: 0 3px; padding: 5px; width: 100px;">
                    -
                    <input type="number" id="maxPrice" name="maxPrice" value="${maxPrice}" min="0" step="1000"
                        placeholder="Max" style="margin: 0 3px; padding: 5px; width: 100px;">

                    <c:if test="${not empty param.categoryId}">
                        <input type="hidden" name="categoryId" value="${param.categoryId}">
                    </c:if>
                    <button type="submit" style="margin: 0 5px; padding: 5px 15px;">Search</button>
                    <a href="category" style="margin-left: 5px;">Clear</a>
                </form>

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
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Image</th>
                                <th>Price</th>
                                <th>Quantity</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${products}" var="p">
                                <tr>
                                    <td>${p.id}</td>
                                    <td><a href="productDetail?id=${p.id}">${p.name}</a></td>
                                    <td><img src="${p.imageURL}" alt="${p.name}" style="width: 50px; height: auto;">
                                    </td>
                                    <td>
                                        <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"
                                            maxFractionDigits="0" />
                                    </td>
                                    <td>${p.quantity}</td>
                                    <td>${p.status}</td>
                                    <td>
                                        <a href="productDetail?id=${p.id}">View</a> |
                                        <a href="editProduct?id=${p.id}">Edit</a> |
                                        <a href="deleteProduct?id=${p.id}"
                                            onclick="return confirm('Are you sure?');">Delete</a>
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