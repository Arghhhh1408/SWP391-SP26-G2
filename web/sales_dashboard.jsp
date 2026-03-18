<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sales Dashboard</title>
    <%-- Link đến file CSS dùng chung --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-style.css">
</head>
<body>

    <%-- 1. Nhúng Sidebar --%>
    <c:set var="currentPage" value="sales_dashboard" scope="request" />
    <jsp:include page="saleSidebar.jsp" />

    <%-- 2. Phần nội dung chính (phải bọc trong admin-main) --%>
    <div class="admin-main">
        <div class="admin-topbar">
            <div>
                <h1>Trang quản lý Sales</h1>
                <small>Xin chào, ${sessionScope.acc.fullName}</small>
            </div>
        </div>

        <div class="admin-content">
            <c:choose>
                <%-- Khi chọn tab Sản phẩm --%>
                <c:when test="${tab == 'products'}">
                    <div class="box">
                        <div class="box-header"><h3>Danh sách sản phẩm</h3></div>
                        <div class="box-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Tên sản phẩm</th>
                                        <th>SKU</th>
                                        <th>Giá</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${salesProducts}" var="p">
                                        <tr>
                                            <td>${p.name}</td>
                                            <td>${p.sku}</td>
                                            <td>${p.price} đ</td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </c:when>
                
                <%-- Mặc định hiện hướng dẫn hoặc Dashboard --%>
                <c:otherwise>
                    <div class="box">
                        <div class="box-header"><h3>Chào mừng Mạnh Lý quay trở lại!</h3></div>
                        <div class="box-body">
                            Hôm nay bạn muốn thực hiện thao tác gì? Hãy chọn menu bên trái nhé.
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>