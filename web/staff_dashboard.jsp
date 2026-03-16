<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <title>Warehouse Staff Dashboard</title>
        </head>

        <body>
            <%-- Set active page for sidebar highlight --%>
            <c:set var="currentPage" value="staff_dashboard" scope="request" />

            <%-- Include the shared staff sidebar --%>
            <jsp:include page="staffSidebar.jsp" />

            <div class="admin-main">
                <div class="admin-topbar">
                    <div>
                        <h1>Trang quản lý Warehouse Staff</h1>
                        <small>Warehouse Staff > ${tab == 'returns' ? 'Yeu cau tra hang' : (tab == 'products' ? 'Danh
                            sach san pham' : 'Yeu cau bao hanh')}</small>
                    </div>
                    <div>Xin chao, <strong>${sessionScope.acc.fullName}</strong></div>
                </div>

                <div class="admin-content">
                    <c:choose>
                        <c:when test="${tab == 'returns'}">
                            <div class="box">
                                <div class="box-header">
                                    <h3>Danh sách yêu cầu trả hành</h3>
                                </div>
                                <div class="box-body">
                                    <table>
                                        <tr>
                                            <th>Ma yeu cau</th>
                                            <th>SKU</th>
                                            <th>San pham</th>
                                            <th>Khach hang</th>
                                            <th>Ly do</th>
                                            <th>Trang thai</th>
                                            <th>Hanh dong</th>
                                        </tr>
                                        <c:forEach items="${returns}" var="r">
                                            <tr>
                                                <td>${r.returnCode}</td>
                                                <td>${r.sku}</td>
                                                <td>${r.productName}</td>
                                                <td>${r.customerName}</td>
                                                <td>${r.reason}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${r.status == 'COMPLETED'}"><span
                                                                class="tag-done">Da tra hang</span></c:when>
                                                        <c:when test="${r.status == 'APPROVED'}">Đã xác nhận</c:when>
                                                        <c:when test="${r.status == 'REJECTED'}">Từ chối</c:when>
                                                        <c:when test="${r.status == 'NEW'}">Đang xử Cập</c:when>
                                                        <c:otherwise>${r.status}</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when
                                                            test="${r.status == 'COMPLETED' || r.status == 'REJECTED'}">
                                                            -</c:when>
                                                        <c:otherwise>
                                                            <div class="action-row">
                                                                <form action="staff_dashboard" method="post">
                                                                    <input type="hidden" name="action"
                                                                        value="completeReturn">
                                                                    <input type="hidden" name="id" value="${r.id}">
                                                                    <button type="submit" class="btn"
                                                                        onclick="return confirm('Xac nhan da tra hang?');">Xac
                                                                        nhan da tra hang</button>
                                                                </form>
                                                                <form action="staff_dashboard" method="post">
                                                                    <input type="hidden" name="action"
                                                                        value="rejectReturn">
                                                                    <input type="hidden" name="id" value="${r.id}">
                                                                    <button type="submit" class="btn btn-reject"
                                                                        onclick="return confirm('Ban muon tu choi yeu cau nay?');">Tu
                                                                        choi</button>
                                                                </form>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty returns}">
                                            <tr>
                                                <td colspan="7">Chưa có yêu cầu bảo hành.</td>
                                            </tr>
                                        </c:if>
                                    </table>
                                </div>
                            </div>
                        </c:when>
                        <c:when test="${tab == 'products'}">
                            <div class="box">
                                <div class="box-header">
                                    <h3>Danh sách sản phẩm</h3>
                                </div>
                                <div class="box-body">
                                    <c:if test="${not empty error}">
                                        <p style="color: red;">${error}</p>
                                    </c:if>
                                    <table>
                                        <tr>
                                            <th>ID</th>
                                            <th>Ten san pham</th>
                                            <th>SKU</th>
                                            <th>Gia</th>
                                            <th>So luong</th>
                                            <th>Trang thai</th>
                                        </tr>
                                        <c:forEach items="${products}" var="p">
                                            <tr>
                                                <td>${p.id}</td>
                                                <td>${p.name}</td>
                                                <td>${p.sku}</td>
                                                <td>${p.price}</td>
                                                <td>${p.quantity}</td>
                                                <td>${p.status}</td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty products}">
                                            <tr>
                                                <td colspan="7">Không có sản phẩm nào.</td>
                                            </tr>
                                        </c:if>
                                    </table>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="box">
                                <div class="box-header">
                                    <h3>Danh sách yêu cầu bảo hành</h3>
                                </div>
                                <div class="box-body">
                                    <table>
                                        <tr>
                                            <th>Ma yeu cau</th>
                                            <th>SKU</th>
                                            <th>San pham</th>
                                            <th>Khach hang</th>
                                            <th>Mo ta loi</th>
                                            <th>Trang thai</th>
                                            <th>Hanh dong</th>
                                        </tr>
                                        <c:forEach items="${claims}" var="c">
                                            <tr>
                                                <td>${c.claimCode}</td>
                                                <td>${c.sku}</td>
                                                <td>${c.productName}</td>
                                                <td>${c.customerName}</td>
                                                <td>${c.issueDescription}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${c.status == 'COMPLETED'}"><span
                                                                class="tag-done">Da bao hanh</span></c:when>
                                                        <c:when test="${c.status == 'APPROVED'}">Da xac nhan</c:when>
                                                        <c:when test="${c.status == 'REJECTED'}">Tu choi</c:when>
                                                        <c:when test="${c.status == 'NEW'}">Dang xu ly</c:when>
                                                        <c:otherwise>${c.status}</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when
                                                            test="${c.status == 'COMPLETED' || c.status == 'REJECTED'}">
                                                            -</c:when>
                                                        <c:otherwise>
                                                            <div class="action-row">
                                                                <form action="staff_dashboard" method="post">
                                                                    <input type="hidden" name="action"
                                                                        value="completeWarranty">
                                                                    <input type="hidden" name="id" value="${c.id}">
                                                                    <button type="submit" class="btn"
                                                                        onclick="return confirm('Xac nhan da bao hanh?');">Xac
                                                                        nhan da bao hanh</button>
                                                                </form>
                                                                <form action="staff_dashboard" method="post">
                                                                    <input type="hidden" name="action"
                                                                        value="rejectWarranty">
                                                                    <input type="hidden" name="id" value="${c.id}">
                                                                    <button type="submit" class="btn btn-reject"
                                                                        onclick="return confirm('Ban muon tu choi yeu cau nay?');">Tu
                                                                        choi</button>
                                                                </form>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty claims}">
                                            <tr>
                                                <td colspan="7">Chưa có yêu cầu bảo hành.</td>
                                            </tr>
                                        </c:if>
                                    </table>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </body>

        </html>