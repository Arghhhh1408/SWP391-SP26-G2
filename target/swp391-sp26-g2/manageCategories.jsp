<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>Manage Categories</title>
            <style>
                table {
                    border-collapse: collapse;
                    width: 50%;
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
            <h1>Manage Categories</h1>
            <a href="category">Back to Products</a> |
            <a href="addCategory">Add New Category</a>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${categories}" var="c">
                        <tr>
                            <td>${c.id}</td>
                            <td>${c.name}</td>
                            <td>
                                <a href="editCategory?id=${c.id}">Edit</a> |
                                <a href="deleteCategory?id=${c.id}"
                                    onclick="return confirm('Delete this category?');">Delete</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </body>

        </html>