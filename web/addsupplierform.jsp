<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>
            <c:if test="${empty supplier}">Thêm Nhà Cung Cấp</c:if>
            <c:if test="${not empty supplier}">Sửa Nhà Cung Cấp</c:if>
            </title>

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
                    max-width: 800px;
                    margin: auto;
                    background: #fff;
                    padding: 28px 32px;
                    border-radius: 14px;
                    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
                }

                h1 {
                    margin-top: 0;
                    color: #1f3c88;
                }

                .back-link {
                    display: inline-block;
                    margin-bottom: 20px;
                    text-decoration: none;
                    color: #1f3c88;
                    font-weight: bold;
                }

                .back-link:hover {
                    text-decoration: underline;
                }

                table {
                    width: 100%;
                    border-collapse: separate;
                    border-spacing: 0 14px;
                }

                td {
                    vertical-align: top;
                }

                label,
                td:first-child {
                    font-weight: 600;
                    color: #2c3e50;
                    width: 180px;
                }

                input[type="text"],
                input[type="email"] {
                    width: 100%;
                    padding: 11px 12px;
                    border: 1px solid #cfd9e6;
                    border-radius: 8px;
                    outline: none;
                    transition: 0.2s;
                }

                input[type="text"]:focus,
                input[type="email"]:focus {
                    border-color: #4a90e2;
                    box-shadow: 0 0 0 3px rgba(74,144,226,0.15);
                }

                .readonly-input {
                    background-color: #e9ecef;
                    color: #555;
                }

                .checkbox-wrap {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    padding-top: 8px;
                }

                .btn-submit {
                    background: #1f78ff;
                    color: white;
                    border: none;
                    padding: 12px 18px;
                    border-radius: 8px;
                    cursor: pointer;
                    font-size: 15px;
                    font-weight: 600;
                    transition: 0.2s;
                }

                .btn-submit:hover {
                    background: #0d63e6;
                }

                .msg-success {
                    margin-top: 18px;
                    padding: 12px 16px;
                    border-radius: 8px;
                    background: #e8f8ee;
                    color: #1e7e34;
                    border: 1px solid #b7ebc6;
                }

                .msg-error {
                    margin-top: 18px;
                    padding: 12px 16px;
                    border-radius: 8px;
                    background: #fdeaea;
                    color: #c0392b;
                    border: 1px solid #f5c6cb;
                }

                @media (max-width: 768px) {
                    body {
                        padding: 15px;
                    }

                    .container {
                        padding: 20px;
                    }

                    table, tr, td {
                        display: block;
                        width: 100%;
                    }

                    td:first-child {
                        margin-bottom: 6px;
                    }

                    tr {
                        margin-bottom: 14px;
                    }
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>
                <c:if test="${empty supplier}">Thêm Nhà Cung Cấp</c:if>
                <c:if test="${not empty supplier}">Sửa Nhà Cung Cấp</c:if>
                </h1>

                <a href="supplierList" class="back-link">← Quay lại Danh Sách Nhà Cung Cấp</a>

                <form action="${pageContext.request.contextPath}/addSupplier" method="post">
                <input type="hidden" name="action"
                       value="${not empty supplier ? 'updateSupplier' : 'addSupplier'}" />

                <c:if test="${not empty supplier}">
                    <input type="hidden" name="supplierID" value="${supplier.id}">
                </c:if>

                <table>
                    <c:choose>
                        <c:when test="${not empty supplier}">
                            <tr>
                                <td>Supplier ID:</td>
                                <td>
                                    <input type="text"
                                           value="${supplier.id}"
                                           readonly
                                           class="readonly-input">
                                </td>
                            </tr>

                            <tr>
                                <td>Tên nhà cung cấp:</td>
                                <td>
                                    <input type="text"
                                           name="supplierName"
                                           value="${supplier.supplierName}"
                                           required>
                                </td>
                            </tr>

                            <tr>
                                <td>Số điện thoại:</td>
                                <td>
                                    <input type="text"
                                           name="phone"
                                           value="${supplier.phone}"
                                           required>
                                </td>
                            </tr>

                            <tr>
                                <td>Địa chỉ:</td>
                                <td>
                                    <input type="text"
                                           name="address"
                                           value="${supplier.address}">
                                </td>
                            </tr>

                            <tr>
                                <td>Email:</td>
                                <td>
                                    <input type="email"
                                           name="email"
                                           value="${supplier.email}"
                                           required>
                                </td>
                            </tr>

                            <tr>
                                <td>Trạng thái:</td>
                                <td>
                                    <div class="checkbox-wrap">
                                        <input type="checkbox"
                                               name="status"
                                               <c:if test="${supplier.status}">checked</c:if>>
                                               <span>Hoạt động</span>
                                        </div>
                                    </td>
                                </tr>
                        </c:when>

                        <c:otherwise>
                            <tr>
                                <td>Tên nhà cung cấp:</td>
                                <td>
                                    <input type="text"
                                           name="supplierName"
                                           value="${param.supplierName}"
                                           required>
                                </td>
                            </tr>

                            <tr>
                                <td>Số điện thoại:</td>
                                <td>
                                    <input type="text"
                                           name="phone"
                                           value="${param.phone}"
                                           required>
                                </td>
                            </tr>

                            <tr>
                                <td>Email:</td>
                                <td>
                                    <input type="email"
                                           name="email"
                                           value="${param.email}"
                                           required>
                                </td>
                            </tr>

                            <tr>
                                <td>Địa chỉ:</td>
                                <td>
                                    <input type="text"
                                           name="address"
                                           value="${param.address}">
                                </td>
                            </tr>

                            <tr>
                                <td>Trạng thái:</td>
                                <td>
                                    <div class="checkbox-wrap">
                                        <input type="checkbox"
                                               name="status"
                                               <c:if test="${formStatus == null || formStatus}">checked</c:if>>
                                               <span>Hoạt động</span>
                                        </div>
                                    </td>
                                </tr>
                        </c:otherwise>
                    </c:choose>

                    <tr>
                        <td></td>
                        <td>
                            <input type="submit"
                                   class="btn-submit"
                                   value="${not empty supplier ? 'Cập nhật' : 'Thêm nhà cung cấp'}">
                        </td>
                    </tr>
                </table>
            </form>

            <c:if test="${not empty sessionScope.message}">
                <div class="${sessionScope.status == 'success' ? 'msg-success' : 'msg-error'}">
                    ${sessionScope.message}
                </div>
            </c:if>

            <c:remove var="message" scope="session"/>
            <c:remove var="status" scope="session"/>

            <c:if test="${not empty requestScope.error}">
                <div class="msg-error">${requestScope.error}</div>
            </c:if>
        </div>
    </body>
</html>