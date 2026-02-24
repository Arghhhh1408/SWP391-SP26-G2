<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html>

            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <title>${product.name} - Detail</title>
                <style>
                    .detail-container {
                        max-width: 800px;
                        margin: 20px auto;
                        padding: 20px;
                        border: 1px solid #ccc;
                        border-radius: 5px;
                    }

                    .detail-row {
                        margin-bottom: 10px;
                    }

                    .label {
                        font-weight: bold;
                        display: inline-block;
                        width: 150px;
                    }

                    .product-image {
                        max-width: 300px;
                        display: block;
                        margin: 0 auto 20px;
                    }

                    .actions {
                        margin-top: 20px;
                        text-align: center;
                    }
                </style>
            </head>

            <body>
                <div class="detail-container">
                    <h1>${product.name}</h1>

                    <c:if test="${not empty product.imageURL}">
                        <img class="product-image" src="${product.imageURL}" alt="${product.name}">
                    </c:if>

                    <div class="detail-row">
                        <span class="label">ID:</span> ${product.id}
                    </div>
                    <div class="detail-row">
                        <span class="label">SKU:</span> ${product.sku}
                    </div>
                    <div class="detail-row">
                        <span class="label">Category ID:</span> ${product.categoryId}
                    </div>
                    <div class="detail-row">
                        <span class="label">Price:</span>
                        <fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"
                            maxFractionDigits="0" />
                    </div>
                    <div class="detail-row">
                        <span class="label">Cost:</span>
                        <fmt:formatNumber value="${product.cost}" type="number" groupingUsed="true"
                            maxFractionDigits="0" />
                    </div>
                    <div class="detail-row">
                        <span class="label">Stock Quantity:</span> ${product.stockQuantity} ${product.unit}
                    </div>
                    <div class="detail-row">
                        <span class="label">Warranty Period:</span>
                        <c:choose>
                            <c:when test="${product.warrantyPeriod > 0}">
                                ${product.warrantyPeriod} months
                            </c:when>
                            <c:otherwise>
                                No warranty
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="detail-row">
                        <span class="label">Status:</span> ${product.status}
                    </div>
                    <div class="detail-row">
                        <span class="label">Created Date:</span> ${product.createDate}
                    </div>
                    <div class="detail-row">
                        <span class="label">Last Updated:</span> ${product.updateDate}
                    </div>
                    <div class="detail-row">
                        <span class="label">Description:</span> <br />
                        <p>${product.description}</p>
                    </div>

                    <div class="actions">
                        <a href="category">Back to List</a> |
                        <a href="editProduct?id=${product.id}">Edit</a> |
                        <a href="deleteProduct?id=${product.id}" onclick="return confirm('Are you sure?');">Delete</a>
                    </div>
                </div>
            </body>

            </html>