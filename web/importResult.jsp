<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Kết quả Import - IMS Manager</title>
        <style>
            .container { padding: 40px; font-family: sans-serif; }
            .success { color: green; font-weight: bold; }
            .error-list { color: red; margin-top: 20px; }
            .btn { display: inline-block; padding: 10px 20px; background: #2f6fed; color: #fff; border-radius: 8px; text-decoration: none; margin-top: 20px; }
            .card { background: #fff; border: 1px solid #ddd; padding: 24px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        </style>
    </head>
    <body style="background: #f3f6fb;">
        <div class="container">
            <div class="card">
                <h1>Kết quả Import Sản phẩm</h1>
                <hr>
                
                <c:if test="${not empty error}">
                    <p class="error-list">${error}</p>
                </c:if>

                <c:if test="${empty error}">
                    <p class="success">Import thành công: ${successCount} / ${totalAttempted} sản phẩm.</p>
                    
                    <c:if test="${not empty errors}">
                        <div class="error-list">
                            <h3>Lỗi Dữ liệu (${errors.size()}):</h3>
                            <p><small>(Các dòng này sẽ không được xử lý)</small></p>
                            <ul>
                                <c:forEach items="${errors}" var="err">
                                    <li>${err}</li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty dbErrors}">
                        <div class="error-list" style="color: #d32f2f; background: #ffebee; padding: 10px; border-radius: 8px; margin-top: 10px;">
                            <h3>Lỗi Hệ thống / Database (${dbErrors.size()}):</h3>
                            <p><small>(Sản phẩm hợp lệ về định dạng nhưng gặp lỗi khi lưu vào cơ sở dữ liệu)</small></p>
                            <ul>
                                <c:forEach items="${dbErrors}" var="err">
                                    <li>${err}</li>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:if>
                </c:if>

                <c:choose>
                    <c:when test="${sessionScope.acc.roleID == 1}">
                        <a href="staff_dashboard?tab=products" class="btn">Quay lại danh sách sản phẩm</a>
                    </c:when>
                    <c:when test="${sessionScope.acc.roleID == 2}">
                        <a href="category" class="btn">Quay lại danh sách sản phẩm</a>
                    </c:when>
                    <c:otherwise>
                        <a href="category" class="btn">Quay lại danh sách sản phẩm</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </body>
</html>
