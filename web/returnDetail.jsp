<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Chi tiết trả hàng &amp; hoàn tiền</title>
    </head>
    <body>
        <h1>Chi tiết trả hàng &amp; hoàn tiền</h1>

        <a href="returns">← Danh sách yêu cầu</a>
        <br><br>

        <c:if test="${not empty error}">
            <p style="color: red">${error}</p>
        </c:if>

        <c:if test="${empty rr}">
            <p>Không có dữ liệu.</p>
        </c:if>

        <c:if test="${not empty rr}">
            <h2>Thông tin yêu cầu</h2>
            <table border="1" cellpadding="6" cellspacing="0">
                <tr><th align="left">ID</th><td>${rr.id}</td></tr>
                <tr><th align="left">Mã yêu cầu</th><td>${rr.returnCode}</td></tr>
                <tr><th align="left">SKU</th><td>${rr.sku}</td></tr>
                <tr><th align="left">Tên sản phẩm</th><td>${rr.productName}</td></tr>
                <tr><th align="left">Khách hàng</th><td>${rr.customerName}</td></tr>
                <tr><th align="left">SĐT</th><td>${rr.customerPhone}</td></tr>
                <tr><th align="left">Lý do</th><td>${rr.reason}</td></tr>
                <tr><th align="left">Tình trạng</th><td>${rr.conditionNote}</td></tr>
                <tr><th align="left">Trạng thái</th><td>${rr.status}</td></tr>
                <tr><th align="left">Tạo lúc</th><td>${rr.createdAt}</td></tr>
                <tr><th align="left">Cập nhật</th><td>${rr.updatedAt}</td></tr>
            </table>

            <br>

            <h2>Thông tin hoàn tiền</h2>
            <table border="1" cellpadding="6" cellspacing="0">
                <tr><th align="left">Số tiền</th><td>${rr.refundAmount}</td></tr>
                <tr><th align="left">Phương thức</th><td>${rr.refundMethod}</td></tr>
                <tr><th align="left">Mã tham chiếu</th><td>${rr.refundReference}</td></tr>
                <tr><th align="left">Hoàn lúc</th><td>${rr.refundedAt}</td></tr>
            </table>

            <br>

            <fieldset>
                <legend>Cập nhật trạng thái</legend>
                <form action="returns" method="post">
                    <input type="hidden" name="action" value="updateStatus" />
                    <input type="hidden" name="id" value="${rr.id}" />

                    <label for="newStatus">Trạng thái mới:</label>
                    <select id="newStatus" name="newStatus">
                        <c:forEach items="${statuses}" var="st">
                            <option value="${st}" ${rr.status == st ? 'selected' : ''}>${st}</option>
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
                <legend>Ghi nhận hoàn tiền (khung)</legend>
                <form action="returns" method="post">
                    <input type="hidden" name="action" value="recordRefund" />
                    <input type="hidden" name="id" value="${rr.id}" />

                    <label for="amount">Số tiền (*):</label>
                    <input id="amount" type="text" name="refundAmount" required />
                    <br><br>

                    <label for="method">Phương thức (tùy chọn):</label>
                    <input id="method" type="text" name="refundMethod" />
                    <br><br>

                    <label for="ref">Mã tham chiếu (tùy chọn):</label>
                    <input id="ref" type="text" name="refundReference" />
                    <br><br>

                    <label for="rnote">Ghi chú (tùy chọn):</label><br>
                    <textarea id="rnote" name="note" rows="3" cols="80"></textarea>
                    <br><br>

                    <input type="submit" value="Hoàn tiền" />
                </form>
            </fieldset>

            <br>

            <fieldset>
                <legend>Thêm ghi chú</legend>
                <form action="returns" method="post">
                    <input type="hidden" name="action" value="addNote" />
                    <input type="hidden" name="id" value="${rr.id}" />

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
                <c:forEach items="${rr.events}" var="e">
                    <tr>
                        <td>${e.time}</td>
                        <td>${e.actor}</td>
                        <td>${e.action}</td>
                        <td>${e.note}</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty rr.events}">
                    <tr><td colspan="4">Chưa có lịch sử.</td></tr>
                </c:if>
            </table>
        </c:if>
    </body>
</html>

