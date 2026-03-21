<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html>

        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <title>${empty category ? 'Thêm danh mục' : 'Sửa danh mục'} – IMS Manager</title>
            <style>
                .form-box {
                    background: #fff;
                    border: 1px solid #e0e0e0;
                    border-radius: 8px;
                    padding: 24px;
                    max-width: 600px;
                    margin-top: 20px;
                }

                .form-group {
                    margin-bottom: 20px;
                }

                .form-group label {
                    display: block;
                    font-size: 14px;
                    font-weight: 600;
                    color: #555;
                    margin-bottom: 8px;
                }

                .form-control {
                    width: 100%;
                    padding: 10px 12px;
                    border: 1px solid #ddd;
                    border-radius: 4px;
                    font-size: 14px;
                }
            </style>
        </head>

        <body>
            <c:set var="currentPage" value="manageCategories" scope="request" />
            <jsp:include page="managerSidebar.jsp" />

            <div class="admin-main">
                <div class="admin-topbar">
                    <div>
                        <h1>${empty category ? 'Thêm danh mục mới' : 'Chỉnh sửa danh mục'}</h1>
                        <small>Manager &rsaquo; Danh mục &rsaquo; ${empty category ? 'Thêm mới' : 'Chỉnh sửa'}</small>
                    </div>
                </div>

                <div class="admin-content">
                    <div style="margin-bottom: 20px;">
                        <a href="manageCategories" class="btn btn-outline">&larr; Quay lại danh sách</a>
                    </div>

                    <div class="form-box">
                        <c:if test="${not empty error}">
                            <div
                                style="color: #dc3545; background: #f8d7da; padding: 10px; border-radius: 4px; margin-bottom: 20px;">
                                ${error}
                            </div>
                        </c:if>

                        <form action="${empty category ? 'addCategory' : 'editCategory'}" method="post">
                            <c:if test="${not empty category}">
                                <input type="hidden" name="id" value="${category.id}">
                            </c:if>

                            <div class="form-group">
                                <label>Tên danh mục:</label>
                                <input type="text" name="name" class="form-control" value="${category.name}" required>
                            </div>

                            <div class="form-group">
                                <label>Danh mục cha:</label>
                                <select name="parentId" class="form-control">
                                    <option value="">None (Top Level)</option>
                                    <c:forEach items="${categories}" var="c">
                                        <c:if test="${empty category or c.id != category.id}">
                                            <option value="${c.id}" ${category.parentId==c.id ? 'selected' : '' }>
                                                ${c.name}
                                            </option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </div>

                            <div style="margin-top: 30px;">
                                <input type="submit" class="btn btn-primary" style="padding: 10px 24px;"
                                    value="${empty category ? 'Lưu danh mục' : 'Cập nhật danh mục'}">
                            </div>
                        </form>
                    </div>
                </div><!-- /admin-content -->
            </div><!-- /admin-main -->
        </body>

        </html>