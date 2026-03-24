<%-- Document : supplierList Created on : 2 thg 2, 2026, 12:50:33 Author : dotha --%>

<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Danh sách nhà cung cấp</title>
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
                max-width: 1400px;
                margin: auto;
                background: #fff;
                padding: 25px 30px;
                border-radius: 14px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            }

            h1, h3 {
                margin-top: 0;
                color: #1f3c88;
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
                margin: 15px 0;
                font-weight: 500;
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

            .search-box {
                background: #f9fbff;
                border: 1px solid #dbe6f3;
                padding: 18px;
                border-radius: 12px;
                margin-bottom: 20px;
            }

            .search-grid {
                display: grid;
                grid-template-columns: repeat(5, 1fr);
                gap: 15px;
            }

            .form-group {
                display: flex;
                flex-direction: column;
            }

            .form-group label {
                margin-bottom: 6px;
                font-weight: 600;
                color: #2c3e50;
            }

            .form-group input,
            .form-group select {
                padding: 10px 12px;
                border: 1px solid #cfd9e6;
                border-radius: 8px;
                outline: none;
                transition: 0.2s;
                background: #fff;
            }

            .form-group input:focus,
            .form-group select:focus {
                border-color: #4a90e2;
                box-shadow: 0 0 0 3px rgba(74,144,226,0.15);
            }

            .action-row {
                margin-top: 18px;
                display: flex;
                gap: 10px;
                align-items: center;
                flex-wrap: wrap;
            }

            .btn {
                display: inline-block;
                padding: 10px 16px;
                border-radius: 8px;
                text-decoration: none;
                border: none;
                cursor: pointer;
                font-weight: 600;
                transition: 0.2s;
            }

            .btn-primary {
                background: #1f78ff;
                color: white;
            }

            .btn-primary:hover {
                background: #0d63e6;
            }

            .btn-secondary {
                background: #e9eef5;
                color: #333;
            }

            .btn-secondary:hover {
                background: #dce4ee;
            }

            .btn-add {
                background: #16a34a;
                color: white;
                margin-bottom: 18px;
            }

            .btn-add:hover {
                background: #12813b;
            }

            .table-wrapper {
                overflow-x: auto;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                overflow: hidden;
                border-radius: 12px;
                background: white;
                min-width: 1200px;
            }

            thead {
                background: #1f3c88;
                color: white;
            }

            th, td {
                padding: 14px 12px;
                text-align: left;
                border-bottom: 1px solid #edf1f5;
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

            .table-action {
                text-decoration: none;
                font-weight: 600;
                margin-right: 8px;
                display: inline-block;
                margin-bottom: 4px;
            }

            .edit-link {
                color: #1f78ff;
            }

            .delete-link {
                color: #dc2626;
            }

            .debt-link {
                color: #9333ea;
            }

            .product-link {
                color: #0f766e;
            }

            .empty-row {
                text-align: center;
                color: #777;
                padding: 20px;
            }

            @media (max-width: 1200px) {
                .search-grid {
                    grid-template-columns: repeat(3, 1fr);
                }
            }

            @media (max-width: 768px) {
                .search-grid {
                    grid-template-columns: repeat(2, 1fr);
                }

                body {
                    padding: 15px;
                }

                .container {
                    padding: 18px;
                }
            }

            @media (max-width: 576px) {
                .search-grid {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Danh sách nhà cung cấp</h1>

            <c:if test="${sessionScope.acc.roleID == 1}">
                <a class="top-link" href="staff_dashboard">← Quay lại bảng điều khiển của nhân viên</a>
            </c:if>

            <c:if test="${sessionScope.acc.roleID == 2}">
                <a class="top-link" href="category">← Quay lại bảng điều khiển của quản lý</a>
            </c:if>

            <c:if test="${not empty sessionScope.message}">
                <div class="message ${sessionScope.status == 'success' ? 'success' : 'error'}">
                    ${sessionScope.message}
                </div>
            </c:if>
            <c:remove var="message" scope="session"/>
            <c:remove var="status" scope="session"/>

            <h3>Tìm kiếm nhà cung cấp</h3>

            <form action="supplierList" method="get" class="search-box">
                <div class="search-grid">
                    <div class="form-group">
                        <label>Tên nhà cung cấp</label>
                        <input type="text" name="supplierName" value="${param.supplierName}" placeholder="Nhập tên nhà cung cấp">
                    </div>

                    <div class="form-group">
                        <label>Số điện thoại</label>
                        <input type="text" name="supplierPhone" value="${param.supplierPhone}" placeholder="Nhập số điện thoại">
                    </div>

                    <div class="form-group">
                        <label>Địa chỉ</label>
                        <input type="text" name="supplierAddress" value="${param.supplierAddress}" placeholder="Nhập địa chỉ">
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <input type="text" name="supplierEmail" value="${param.supplierEmail}" placeholder="Nhập email">
                    </div>

                    <div class="form-group">
                        <label>Trạng thái</label>
                        <select name="status">
                            <option value="">-- Tất cả --</option>
                            <option value="active" ${param.status == 'active' ? 'selected' : ''}>Hoạt động</option>
                            <option value="inactive" ${param.status == 'inactive' ? 'selected' : ''}>Ngừng hoạt động</option>
                        </select>
                    </div>
                </div>

                <div class="action-row">
                    <button type="submit" class="btn btn-primary">Tìm kiếm</button>
                    <a href="supplierList" class="btn btn-secondary">Làm mới</a>
                </div>
            </form>

            <c:if test="${sessionScope.acc.roleID == 2}">
                <a href="addSupplier?action=add" class="btn btn-add">+ Thêm nhà cung cấp mới</a>
            </c:if>

            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Mã NCC</th>
                            <th>Tên nhà cung cấp</th>
                            <th>Số điện thoại</th>
                            <th>Địa chỉ</th>
                            <th>Email</th>
                            <th>Trạng thái</th>

                            <c:if test="${sessionScope.acc.roleID == 1 || sessionScope.acc.roleID == 2}">
                                <th>Công nợ</th>
                                <th>Sản phẩm</th>
                                </c:if>

                            <c:if test="${sessionScope.acc.roleID == 2}">
                                <th>Sửa</th>
                                <th>Ngừng hoạt động</th>
                                </c:if>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty requestScope.list}">
                                <c:forEach items="${requestScope.list}" var="s">
                                    <tr>
                                        <td>${s.id}</td>
                                        <td>${s.supplierName}</td>
                                        <td>${s.phone}</td>
                                        <td>${s.address}</td>
                                        <td>${s.email}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${s.status}">
                                                    <span class="status-active">Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-inactive">Ngừng hoạt động</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <c:if test="${sessionScope.acc.roleID == 1 || sessionScope.acc.roleID == 2}">
                                            <td>
                                                <a class="table-action debt-link" href="supplierDebt?supplierId=${s.id}">
                                                    Xem công nợ
                                                </a>
                                            </td>
                                        </c:if>

                                        <c:if test="${sessionScope.acc.roleID == 1 || sessionScope.acc.roleID == 2}">
                                            <td>
                                                <a class="table-action product-link" href="supplierProduct?supplierId=${s.id}">
                                                    Quản lý sản phẩm
                                                </a>
                                            </td>
                                        </c:if>
                                        <c:if test="${sessionScope.acc.roleID == 2}">
                                            <td>
                                                <a class="table-action edit-link" href="addSupplier?action=edit&id=${s.id}">
                                                    Sửa
                                                </a>
                                            </td>
                                            <td>
                                                <c:if test="${s.status}">
                                                    <a class="table-action delete-link"
                                                       href="addSupplier?action=delete&id=${s.id}"
                                                       onclick="return confirm('Bạn có chắc muốn ngừng hoạt động nhà cung cấp này?');">
                                                        Ngừng hoạt động
                                                    </a>
                                                </c:if>
                                                <c:if test="${not s.status}">
                                                    <span class="status-inactive">Đã ngừng</span>
                                                </c:if>
                                            </td>
                                        </c:if>
                                    </tr>
                                </c:forEach>
                            </c:when>

                            <c:otherwise>
                                <tr>
                                    <td class="empty-row" colspan="${sessionScope.acc.roleID == 2 ? 10 : 6}">
                                        Không có nhà cung cấp nào.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>
