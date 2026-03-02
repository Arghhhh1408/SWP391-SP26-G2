<%-- 
    Document   : stockinForm
    Created on : 25 thg 2, 2026, 14:02:32
    Author     : dotha
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Tạo Phiếu Nhập Kho</title>
    </head>
    <body>

        <h2>TẠO PHIẾU NHẬP KHO</h2>

        <a href="category">Back to List</a>
        <!-- Hiển thị thông báo -->
        <%
            String message = (String) request.getAttribute("message");
            if (message != null) {
        %>
        <p style="color: green;"><%= message %></p>
        <%
            }
        %>

        <form action="createStockIn" method="post">

            <fieldset>
                <legend>Thông tin phiếu nhập</legend>

                <p>
                    Supplier ID:<br>
                    <input type="number" name="supplierId" required>
                </p>

                <p>
                    Created By: ${sessionScope.acc.username}
                </p>

                <p>
                    Ghi chú:<br>
                    <textarea name="note" rows="3" cols="40"></textarea>
                </p>
            </fieldset>

            <br>

            <fieldset>
                <legend>Chi tiết sản phẩm</legend>

                <!-- Dòng sản phẩm 1 -->
                <p>
                    Product ID:
                    <input type="number" name="productId" required>

                    Quantity:
                    <input type="number" name="quantity" required>

                    Unit Cost:
                    <input type="number" step="0.01" name="unitCost" required>
                </p>

                <!-- Dòng sản phẩm 2 -->
                <p>
                    Product ID:
                    <input type="number" name="productId">

                    Quantity:
                    <input type="number" name="quantity">

                    Unit Cost:
                    <input type="number" step="0.01" name="unitCost">
                </p>

                <!-- Có thể copy thêm nhiều dòng nếu muốn -->

            </fieldset>

            <br>

            <button type="submit">Tạo phiếu nhập</button>
            <button type="reset">Làm lại</button>

        </form>

    </body>
</html>