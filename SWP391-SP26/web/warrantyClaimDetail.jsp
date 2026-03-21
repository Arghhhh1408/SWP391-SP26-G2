<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Warranty Claim Detail</title>
    </head>
    <body>
        <h1>Warranty Claim Detail</h1>

        <a href="warrantyClaims">← Danh sách yêu cầu</a>
        <br><br>

        <c:if test="${not empty error}">
            <p style="color: red">${error}</p>
        </c:if>

        <c:if test="${empty claim}">
            <p>Không có dữ liệu.</p>
        </c:if>

        <c:if test="${not empty claim}">
            <h2>Thông tin yêu cầu</h2>
            <table border="1" cellpadding="6" cellspacing="0">
                <tr><th align="left">ID</th><td>${claim.id}</td></tr>
                <tr><th align="left">Mã yêu cầu</th><td>${claim.claimCode}</td></tr>
                <tr><th align="left">SKU</th><td>${claim.sku}</td></tr>
                <tr><th align="left">Tên sản phẩm</th><td>${claim.productName}</td></tr>
                <tr><th align="left">Khách hàng</th><td>${claim.customerName}</td></tr>
                <tr><th align="left">SĐT</th><td>${claim.customerPhone}</td></tr>
                <tr><th align="left">Mô tả lỗi</th><td>${claim.issueDescription}</td></tr>
                <tr><th align="left">Trạng thái</th><td>${claim.status}</td></tr>
                <tr><th align="left">Tạo lúc</th><td>${claim.createdAt}</td></tr>
                <tr><th align="left">Cập nhật</th><td>${claim.updatedAt}</td></tr>
            </table>

            <br>

            <fieldset>
                <legend>Cập nhật trạng thái</legend>
                <form action="warrantyClaims" method="post">
                    <input type="hidden" name="action" value="updateStatus" />
                    <input type="hidden" name="id" value="${claim.id}" />

                    <label for="newStatus">Trạng thái mới:</label>
                    <select id="newStatus" name="newStatus">
                        <c:forEach items="${statuses}" var="st">
                            <option value="${st}" ${claim.status == st ? 'selected' : ''}>${st}</option>
                        </c:forEach>
                    </select>
                    <br><br>

                    <label for="note">Ghi chú (tùy chọn):</label><br>
                    <textarea id="note" name="note" rows="3" cols="80"></textarea>
                    <br><br>

                    <input type="submit" value="Cập nhật" />
                </form>
            </fieldset>

            <br>

            <fieldset>
                <legend>Thêm ghi chú</legend>
                <form action="warrantyClaims" method="post">
                    <input type="hidden" name="action" value="addNote" />
                    <input type="hidden" name="id" value="${claim.id}" />

                    <textarea name="note" rows="3" cols="80" required></textarea>
                    <br><br>
                    <input type="submit" value="Thêm" />
                </form>
            </fieldset>

            <br>

            <h2>Lịch sử xử lý</h2>
            <table border="1" cellpadding="6" cellspacing="0">
                <tr>
                    <th>Thời gian</th>
                    <th>Actor</th>
                    <th>Action</th>
                    <th>Note</th>
                </tr>
                <c:forEach items="${claim.events}" var="e">
                    <tr>
                        <td>${e.time}</td>
                        <td>${e.actor}</td>
                        <td>${e.action}</td>
                        <td>${e.note}</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty claim.events}">
                    <tr><td colspan="4">Chưa có lịch sử.</td></tr>
                </c:if>
            </table>
        </c:if>
    </body>
</html>

