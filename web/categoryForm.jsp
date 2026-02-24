<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>${empty category ? 'Add Category' : 'Edit Category'}</title>
        </head>

        <body>
            <h1>${empty category ? 'Add New Category' : 'Edit Category'}</h1>
            <a href="manageCategories">Back to List</a>
            <h3 style="color: red;">${error}</h3>

            <form action="${empty category ? 'addCategory' : 'editCategory'}" method="post">
                <c:if test="${not empty category}">
                    <input type="hidden" name="id" value="${category.id}">
                </c:if>
                <table>
                    <tr>
                        <td>Name:</td>
                        <td><input type="text" name="name" value="${category.name}" required></td>
                    </tr>
                    <tr>
                        <td>Description:</td>
                        <td><textarea name="description" rows="3" cols="50">${category.description}</textarea></td>
                    </tr>
                    <tr>
                        <td>Parent Category:</td>
                        <td>
                            <select name="parentID">
                                <option value="0">-- None (Top Level) --</option>
                                <c:forEach items="${categories}" var="c">
                                    <c:if test="${empty category || c.id != category.id}">
                                        <option value="${c.id}" ${category.parentID==c.id ? 'selected' : '' }>${c.name}
                                        </option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2"><input type="submit"
                                value="${empty category ? 'Add Category' : 'Update Category'}"></td>
                    </tr>
                </table>
            </form>
        </body>

        </html>