<%-- 
    Document   : editStockIn
    Created on : 7 thg 3, 2026, 13:43:01
    Author     : dotha
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Sửa phiếu nhập hàng</title>
    </head>
    <body>
        <h2>Sửa phiếu nhập hàng</h2>

        <form action="stockinList" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="stockInId" value="${stockIn.stockInId}">

            <table border="1" cellpadding="8" cellspacing="0">
                <tr>
                    <td>Mã đơn hàng</td>
                    <td>
                        <input type="text" value="${stockIn.stockInId}" readonly>
                    </td>
                </tr>

                <tr>
                    <td>Ngày tạo</td>
                    <td>
                        <fmt:formatDate value="${stockIn.date}" pattern="dd/MM/yyyy HH:mm" var="formattedDate"/>
                        <input type="text" value="${formattedDate}" readonly>
                    </td>
                </tr>

                <tr>
                    <td>Nhà cung cấp</td>
                    <td>
                        <input type="text" value="${stockIn.supplierName}" readonly>
                    </td>
                </tr>

                <tr>
                    <td>Nhân viên tạo</td>
                    <td>
                        <input type="text" value="${stockIn.staffName}" readonly>
                    </td>
                </tr>

                <tr>
                    <td>Số lượng nhập</td>
                    <td>
                        <input type="text" value="${stockIn.totalQuantity}" readonly>
                    </td>
                </tr>

                <tr>
                    <td>Giá trị đơn</td>
                    <td>
                        <fmt:formatNumber value="${stockIn.totalAmountCalculated}" type="number" groupingUsed="true" var="formattedAmount"/>
                        <input type="text" value="${formattedAmount}" readonly>
                    </td>
                </tr>

                <tr>
                    <td>Trạng thái</td>
                    <td>
                        <select name="status">
                            <option value="Pending"
                                    <c:if test="${stockIn.status == 'Pending'}">selected</c:if>>
                                Pending
                            </option>
                            <option value="Complete"
                                    <c:if test="${stockIn.status == 'Complete'}">selected</c:if>>
                                Complete
                            </option>
                        </select>
                    </td>
                </tr>

                <tr>
                    <td>Ghi chú</td>
                    <td>
                        <textarea name="note" rows="4" cols="40">${stockIn.note}</textarea>
                    </td>
                </tr>

                <tr>
                    <td colspan="2">
                        <button type="submit">Lưu</button>
                        <a href="stockinList">Hủy</a>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>
