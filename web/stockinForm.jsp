<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Tạo Phiếu Nhập Kho</title>
    </head>
    <body>

        <h2>TẠO PHIẾU NHẬP KHO</h2>

        <a href="createStockIn?action=clear&redirect=1">
            ← Quay lại danh sách phiếu nhập
        </a>
        <br><br>

        <c:if test="${not empty message}">
            <p style="color: green;">${message}</p>
        </c:if>

        <!-- ====================================== -->
        <!-- FORM GET: GIỮ DRAFT + TÌM/CHỌN/XÓA -->
        <!-- ====================================== -->
        <form action="createStockIn" method="get">

            <fieldset>
                <legend>Thông tin phiếu nhập</legend>

                <p>
                    Supplier ID:<br>
                    <input type="number" name="supplierId" value="${supplierIdDraft}" required>
                </p>

                <p>
                    Created By: ${sessionScope.acc.username}
                </p>

                <p>
                    Ghi chú:<br>
                    <textarea name="note" rows="3" cols="40">${noteDraft}</textarea>
                </p>

                <p>
                    Thanh toán:<br>
                    <label>
                        <input type="radio" name="paymentOption" value="paid"
                               <c:if test="${paymentOptionDraft == 'paid' or empty paymentOptionDraft}">checked</c:if>>
                               Đã thanh toán
                        </label>

                        <label style="margin-left:12px;">
                            <input type="radio" name="paymentOption" value="pay_later"
                            <c:if test="${paymentOptionDraft == 'pay_later'}">checked</c:if>>
                            Thanh toán sau
                        </label>
                    </p>
                </fieldset>

                <br>

                <fieldset>
                    <legend>Tìm & chọn sản phẩm</legend>

                    <input type="text" name="keyword" value="${keyword}" placeholder="Nhập tên hoặc SKU..." style="width:320px;">
                <button type="submit">Tìm</button>
                <a href="createStockIn?action=clear" style="margin-left:10px;">Xóa danh sách đã chọn</a>

                <c:if test="${not empty productList}">
                    <table border="1" cellpadding="8" cellspacing="0" width="100%" style="margin-top:10px;">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tên</th>
                                <th>SKU</th>
                                <th>ĐVT</th>
                                <th>Giá bán</th>
                                <th>Tồn</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${productList}">
                                <tr>
                                    <td>${p.id}</td>
                                    <td>${p.name}</td>
                                    <td>${p.sku}</td>
                                    <td>${p.unit}</td>
                                    <td>
                                        <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/>
                                    </td>
                                    <td>${p.quantity}</td>
                                    <td>
                                        <button type="submit" name="addPid" value="${p.id}">
                                            Chọn
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:if>

                <c:if test="${empty productList}">
                    <p style="margin-top:10px;">Không có sản phẩm phù hợp.</p>
                </c:if>
            </fieldset>

            <br>

            <fieldset>
                <legend>Danh sách sản phẩm đã chọn</legend>

                <table border="1" cellpadding="8" cellspacing="0" width="100%">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên</th>
                            <th>SKU</th>
                            <th>ĐVT</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:if test="${empty cart}">
                            <tr>
                                <td colspan="5" style="text-align:center; padding:12px;">
                                    Chưa có sản phẩm nào được chọn
                                </td>
                            </tr>
                        </c:if>

                        <c:if test="${not empty cart}">
                            <c:forEach var="entry" items="${cart}">
                                <c:set var="p" value="${entry.value}" />
                                <tr>
                                    <td>${p.id}</td>
                                    <td>${p.name}</td>
                                    <td>${p.sku}</td>
                                    <td>${p.unit}</td>
                                    <td>
                                        <button type="submit" name="removePid" value="${p.id}">
                                            Xóa
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:if>
                    </tbody>
                </table>
            </fieldset>
        </form>

        <hr>

        <!-- ====================================== -->
        <!-- FORM POST: TẠO PHIẾU NHẬP -->
        <!-- ====================================== -->
        <h3>Xác nhận tạo phiếu nhập</h3>

        <form action="createStockIn" method="post">
            <input type="hidden" name="keyword" value="${keyword}">
            <input type="hidden" name="supplierId" value="${supplierIdDraft}">
            <input type="hidden" name="note" value="${noteDraft}">
            <input type="hidden" name="paymentOption" value="${paymentOptionDraft}">

            <fieldset>
                <legend>Chi tiết nhập kho</legend>

                <table border="1" cellpadding="8" cellspacing="0" width="100%">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên</th>
                            <th>SKU</th>
                            <th>ĐVT</th>
                            <th>Số lượng</th>
                            <th>Giá nhập</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:if test="${empty cart}">
                            <tr>
                                <td colspan="6" style="text-align:center; padding:12px;">
                                    Chưa có sản phẩm nào để tạo phiếu nhập
                                </td>
                            </tr>
                        </c:if>

                        <c:if test="${not empty cart}">
                            <c:forEach var="entry" items="${cart}">
                                <c:set var="p" value="${entry.value}" />
                                <tr>
                                    <td>${p.id}</td>
                                    <td>${p.name}</td>
                                    <td>${p.sku}</td>
                                    <td>${p.unit}</td>
                                    <td>
                                        <input type="number" name="qty_${p.id}" min="1" value="1" required style="width:90px;">
                                    </td>
                                    <td>
                                        <input type="number" name="cost_${p.id}" min="0" step="0.01" value="${p.price}" required style="width:130px;">
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:if>
                    </tbody>
                </table>
            </fieldset>

            <br>

            <button type="submit">Tạo phiếu nhập</button>
            <button type="reset">Làm lại</button>
        </form>

    </body>
</html>