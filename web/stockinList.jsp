<%-- Document : stockinList Created on : 26 thg 2, 2026, 15:51:39 Author : dotha --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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

                        th,
                        td {
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

                    <c:if test="${sessionScope.acc.roleID == 1}">
                        <a href="staff_dashboard">← Quay lại bảng điều khiển của nhân viên</a>
                    </c:if>
                    <c:if test="${sessionScope.acc.roleID == 2}">
                        <a href="category">← Quay lại bảng điều khiển của quản lý</a>
                    </c:if>

                    <% String message=(String) request.getAttribute("message"); if (message !=null) { %>
                        <p style="color: green;">
                            <%= message %>
                        </p>
                        <% } %>

                            <table border="1" cellpadding="8" cellspacing="0" width="100%">
                                <thead>
                                    <tr>
                                        <th>Mã đơn nhập</th>
                                        <th>Ngày tạo</th>
                                        <th>Nhà cung cấp</th>
                                        <th>Nhân viên tạo</th>
                                        <th>Số lượng nhập</th>
                                        <th>Giá trị đơn</th>
                                        <th>Trạng thái</th>
                                        <th>Ghi chú</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <!-- Trường hợp không có dữ liệu -->
                                    <c:if test="${empty stockList}">
                                        <tr>
                                            <td colspan="9" style="text-align:center; padding:12px;">
                                                Không có phiếu nhập hàng nào
                                            </td>
                                        </tr>
                                    </c:if>

                                    <!-- Trường hợp có dữ liệu -->
                                    <c:if test="${not empty stockList}">
                                        <c:forEach var="s" items="${stockList}">
                                            <tr>
                                                <td>${s.stockInId}</td>

                                                <td>
                                                    <fmt:formatDate value="${s.date}" pattern="dd/MM/yyyy HH:mm" />
                                                </td>

                                                <td>${s.supplierName}</td>
                                                <td>${s.staffName}</td>

                                                <!-- Tổng số lượng (tính trong model StockIn: getTotalQuantity()) -->
                                                <td>${s.totalQuantity}</td>

                                                <!-- Tổng tiền (tính trong model StockIn: getTotalAmountCalculated()) -->
                                                <td>
                                                    <fmt:formatNumber value="${s.totalAmountCalculated}" type="number"
                                                        groupingUsed="true" />
                                                </td>

                                                <td>${s.status}</td>
                                                <td>${s.note}</td>


                                                <td>

                                                    <a href="stockinList?action=edit&id=${s.stockInId}">Sửa</a>

                                                    |

                                                    <a href="stockinList?action=delete&id=${s.stockInId}"
                                                        onclick="return confirm('Bạn có chắc muốn xóa không?');">
                                                        Xóa
                                                    </a>

                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:if>
                                </tbody>
                            </table>

                            <div style="margin-top: 12px;">
                                <a href="createStockIn">+ Tạo phiếu nhập hàng</a>
                            </div>

                </body>

                </html>