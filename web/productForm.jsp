<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="jakarta.tags.core" %>
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
            <h1>${empty product ? 'Add New Product' : 'Edit Product'}</h1>
            <a href="products">Back to List</a>
            <h3 style="color: red;">${error}</h3>

            <form action="${empty product ? 'addProduct' : 'editProduct'}" method="post">
                <c:if test="${not empty product}">
                    <input type="hidden" name="id" value="${product.id}">
                </c:if>
                <table>
                    <tr>
                        <td>Category:</td>
                        <td>
                            <select name="categoryId" required>
                                <c:forEach items="${categories}" var="c">
                                    <option value="${c.id}" ${product.categoryId==c.id ? 'selected' : '' }>${c.name}
                                    </option>
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td>Name:</td>
                        <td><input type="text" name="name" value="${product.name}" required></td>
                    </tr>
                    <tr>
                        <td>SKU:</td>
                        <td><input type="text" name="sku" value="${product.sku}" required></td>
                    </tr>
                    <tr>
                        <td>Cost:</td>
                        <td><input type="number" step="0.01" name="cost" value="${product.cost}" required></td>
                    </tr>
                    <tr>
                        <td>Price:</td>
                        <td><input type="number" step="0.01" name="price" value="${product.price}" required></td>
                    </tr>
                    <tr>
                        <td>Quantity:</td>
                        <td><input type="number" name="quantity" value="${product.quantity}" required></td>
                    </tr>
                    <tr>
                        <td>Warranty Period (months):</td>
                        <td><input type="number" name="warrantyPeriod" value="${product.warrantyPeriod}" min="0" required></td>
                    </tr>
                    <tr>
                        <td>Unit:</td>
                        <td><input type="text" name="unit" value="${product.unit}" required></td>
                    </tr>
                    <tr>
                        <td>Status:</td>
                        <td>
                            <select name="status">
                                <option value="Active" ${product.status !=null &&
                                    product.status.trim().equalsIgnoreCase('Active') ? 'selected' : '' }>Active</option>
                                <option value="Deactivated" ${product.status !=null &&
                                    product.status.trim().equalsIgnoreCase('Deactivated') ? 'selected' : '' }>
                                    Deactivated</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td>Image URL:</td>
                        <td><input type="text" name="imageURL" value="${product.imageURL}" required></td>
                    </tr>
                    <tr>
                        <td>Description:</td>
                        <td><textarea name="description" rows="4" cols="50">${product.description}</textarea></td>
                    </tr>
                    <tr>
                        <td colspan="2"><input type="submit"
                                value="${empty product ? 'Add Product' : 'Update Product'}"></td>
                    </tr>
                </table>
            </form>
        </body>

        </html>