<%-- 
    Document   : supplierProductList
    Created on : 22 thg 3, 2026, 16:17:32
    Author     : dotha
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Quản lý sản phẩm theo nhà cung cấp</title>
        <style>
            * {
                box-sizing: border-box;
                font-family: Arial, sans-serif;
            }

            body {
                margin: 0;
                padding: 30px;
                background: #f4f7fb;
                color: #333;
            }

            .container {
                max-width: 1200px;
                margin: auto;
                background: white;
                padding: 24px;
                border-radius: 14px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            }

            h1, h3 {
                color: #1f3c88;
                margin-top: 0;
            }

            .top-link {
                display: inline-block;
                margin-bottom: 20px;
                text-decoration: none;
                color: #1f3c88;
                font-weight: bold;
            }

            .top-link:hover {
                text-decoration: underline;
            }

            .message {
                padding: 12px 16px;
                border-radius: 8px;
                margin-bottom: 16px;
                font-weight: 600;
            }

            .message.success {
                background: #e8f8ee;
                color: #1e7e34;
                border: 1px solid #b7ebc6;
            }

            .message.error {
                background: #fdeaea;
                color: #c0392b;
                border: 1px solid #f5c6cb;
            }

            .form-box {
                background: #f9fbff;
                border: 1px solid #dbe6f3;
                padding: 18px;
                border-radius: 12px;
                margin-bottom: 20px;
            }

            .form-row {
                display: grid;
                grid-template-columns: 2fr 1fr auto;
                gap: 15px;
                align-items: end;
            }

            .form-group {
                display: flex;
                flex-direction: column;
                position: relative;
            }

            .form-group label {
                margin-bottom: 6px;
                font-weight: 600;
            }

            .form-group input {
                padding: 10px 12px;
                border: 1px solid #cfd9e6;
                border-radius: 8px;
                outline: none;
            }

            .form-group input:focus {
                border-color: #4a90e2;
                box-shadow: 0 0 0 3px rgba(74,144,226,0.15);
            }

            .btn {
                padding: 10px 16px;
                border-radius: 8px;
                border: none;
                cursor: pointer;
                font-weight: 600;
                background: #1f78ff;
                color: white;
            }

            .btn:hover {
                background: #0d63e6;
            }

            .dropdown-box {
                position: absolute;
                top: 100%;
                left: 0;
                right: 0;
                background: white;
                border: 1px solid #cfd9e6;
                border-radius: 8px;
                max-height: 220px;
                overflow-y: auto;
                z-index: 1000;
                display: none;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
                margin-top: 4px;
            }

            .dropdown-item {
                padding: 10px 12px;
                cursor: pointer;
                border-bottom: 1px solid #edf1f5;
            }

            .dropdown-item:hover {
                background: #f3f8ff;
            }

            .table-wrapper {
                overflow-x: auto;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                min-width: 800px;
            }

            thead {
                background: #1f3c88;
                color: white;
            }

            th, td {
                padding: 12px;
                border-bottom: 1px solid #edf1f5;
                text-align: left;
                vertical-align: middle;
            }

            tbody tr:hover {
                background: #f8fbff;
            }

            .status-active {
                color: #16a34a;
                font-weight: bold;
            }

            .status-inactive {
                color: #dc2626;
                font-weight: bold;
            }

            .empty-row {
                text-align: center;
                color: #777;
            }

            @media (max-width: 768px) {
                .form-row {
                    grid-template-columns: 1fr;
                }

                body {
                    padding: 15px;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Quản lý sản phẩm theo nhà cung cấp</h1>
            <a class="top-link" href="supplierList">← Quay lại danh sách nhà cung cấp</a>

            <c:if test="${not empty sessionScope.message}">
                <div class="message ${sessionScope.status == 'success' ? 'success' : 'error'}">
                    ${sessionScope.message}
                </div>
            </c:if>
            <c:remove var="message" scope="session"/>
            <c:remove var="status" scope="session"/>
            <c:if test="${sessionScope.acc.roleID == 2}">
                <div class="form-box">

                    <h3>Thêm mới sản phẩm cho nhà cung cấp</h3>


                    <form action="supplierProduct" method="post">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="supplierId" value="${supplierId}">
                        <input type="hidden" name="productId" id="productId" required>

                        <div class="form-row">
                            <div class="form-group">
                                <label>Sản phẩm</label>
                                <input type="text" id="productSearch" placeholder="Tìm kiếm sản phẩm..." autocomplete="off">
                                <div id="productDropdown" class="dropdown-box">
                                    <c:forEach items="${productList}" var="p">
                                        <div class="dropdown-item"
                                             data-id="${p.id}"
                                             data-name="${p.name}">
                                            ${p.name}
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>

                            <div class="form-group">
                                <label>Giá nhập</label>
                                <input type="number" step="0.01" name="supplyPrice" required>
                            </div>

                            <div class="form-group">
                                <button type="submit" class="btn">Thêm</button>
                            </div>

                        </div>
                    </form>
                </div>
            </c:if>
            <c:if test="${sessionScope.acc.roleID == 1}">
                <div class="form-box">
                    <h3>Tìm kiếm sản phẩm theo nhà cung cấp</h3>
                    <form action="supplierProduct" method="get">
                        <input type="hidden" name="supplierId" value="${supplierId}">
                        <div class="form-row">
                            <div class="form-group">
                                <label>Từ khóa</label>
                                <input type="text" name="keyword" placeholder="Nhập tên sản phẩm, giá nhập, trạng thái..."
                                       value="${keyword}">
                            </div>
                            <div class="form-group">
                                <button type="submit" class="btn">Tìm kiếm</button>
                            </div>
                            <div class="form-group">
                                <a href="supplierProduct?supplierId=${supplierId}" class="btn"
                                   style="text-decoration:none; display:inline-block; text-align:center;">Làm mới</a>
                            </div>
                        </div>
                    </form>
                </div>
            </c:if>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên sản phẩm</th>
                            <th>Giá nhập</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty supplierProducts}">
                                <c:forEach items="${supplierProducts}" var="sp">
                                    <tr>
                                        <td>${sp.supplierProductID}</td>
                                        <td>${sp.productName}</td>
                                        <td>${sp.supplyPrice}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${sp.active}">
                                                    <span class="status-active">Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-inactive">Ngừng</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" class="empty-row">Chưa có sản phẩm nào cho nhà cung cấp này.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <script>
            const searchInput = document.getElementById("productSearch");
            const dropdown = document.getElementById("productDropdown");
            const hiddenProductId = document.getElementById("productId");
            const items = document.querySelectorAll(".dropdown-item");

            searchInput.addEventListener("focus", function () {
                dropdown.style.display = "block";
            });

            searchInput.addEventListener("input", function () {
                const keyword = this.value.toLowerCase().trim();
                dropdown.style.display = "block";

                items.forEach(item => {
                    const name = item.dataset.name.toLowerCase();
                    item.style.display = name.includes(keyword) ? "block" : "none";
                });

                hiddenProductId.value = "";
            });

            items.forEach(item => {
                item.addEventListener("click", function () {
                    searchInput.value = this.dataset.name;
                    hiddenProductId.value = this.dataset.id;
                    dropdown.style.display = "none";
                });
            });

            document.addEventListener("click", function (e) {
                if (!searchInput.contains(e.target) && !dropdown.contains(e.target)) {
                    dropdown.style.display = "none";
                }
            });
        </script>
    </body>
</html>
