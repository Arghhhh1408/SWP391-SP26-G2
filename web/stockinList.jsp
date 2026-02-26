<%-- 
    Document   : stockinList
    Created on : 26 thg 2, 2026, 15:51:39
    Author     : dotha
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Danh sách phiếu nhập hàng</title>

        <style>
            body {
                font-family: Arial, sans-serif;
            }

            h2 {
                margin-bottom: 20px;
            }

            table {
                border-collapse: collapse;
                width: 100%;
            }

            th, td {
                border: 1px solid #333;
                padding: 8px;
                text-align: left;
            }

            th {
                background-color: #f2f2f2;
            }

            tr:hover {
                background-color: #f9f9f9;
            }

            .back-btn {
                margin-bottom: 15px;
                display: inline-block;
            }
        </style>
    </head>

    <body>

        <h2>Danh sách phiếu nhập hàng</h2>

        <a class="back-btn" href="category">← Quay lại trang sản phẩm</a>
        <p>Debug size: ${stockList.size()}</p>
        <c:if test="${empty stockList}">
            <p>Chưa có phiếu nhập hàng nào.</p>
        </c:if>

        <c:if test="${not empty stockList}">
            <table>
                <thead>
                    <tr>
                        <th>Mã phiếu</th>
                        <th>Nhà cung cấp</th>
                        <th>Sản phẩm</th>
                        <th>Số lượng</th>
                        <th>Giá nhập</th>
                        <th>Thành tiền</th>
                        <th>Ngày nhập</th>
                        <th>Nhân viên nhập</th>
                        <th>Ghi chú</th>
                        <th>Trạng thái</th>
                    </tr>
                </thead>
                <tbody>

                    <c:forEach var="s" items="${stockList}">
                        <c:forEach var="d" items="${s.details}">
                            <tr>
                                <td>${s.stockInId}</td>
                                <td>${s.supplierName}</td>
                                <td>${d.productName}</td>
                                <td>${d.quantity}</td>

                                <td>
                                    <fmt:formatNumber value="${d.unitCost}" 
                                                      type="number" 
                                                      groupingUsed="true" />
                                </td>

                                <td>
                                    <fmt:formatNumber value="${d.subTotal}" 
                                                      type="number" 
                                                      groupingUsed="true" />
                                </td>

                                <td>
                                    <fmt:formatDate value="${s.date}" 
                                                    pattern="dd/MM/yyyy HH:mm" />
                                </td>

                                <td>${s.staffName}</td>
                                <td>${s.note}</td>
                                <td>${s.status}</td>
                            </tr>
                        </c:forEach>
                    </c:forEach>

                </tbody>
            </table>

            <div>
                <a href="createStockIn">+ Tạo phiếu nhập hàng</a>
            </div>
        </c:if>

    </body>
</html>
