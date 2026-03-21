<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <title>Sales Dashboard</title>
        </head>

        <body>
            <%-- Set active page for sidebar highlight --%>
            <c:set var="currentPage" value="sales_dashboard" scope="request" />

            <%-- Include the shared sales sidebar --%>
            <jsp:include page="saleSidebar.jsp" />

            <div class="admin-main">
                <div class="admin-topbar">
                    <div>
                        <h1>Trang quản lý Sales</h1>
                        <small>Salesperson &rsaquo; ${tab == 'warranty-create' ? 'Tạo yêu cầu bảo hành' : (tab ==
                            'warranty-lookup' ? 'Tra cứu bảo hành' : (tab == 'return-create' ? 'Tạo yêu cầu trả hàng' :
                            (tab == 'return-lookup' ? 'Tra cứu trả hàng' : (tab == 'products' ? 'Danh sách sản phẩm' :
                            'Dashboard'))))}</small>
                    </div>
                    <div>
                        Xin chào, <strong>${sessionScope.acc.fullName}</strong>
                    </div>
                </div>

                <div class="admin-content">
                    <c:choose>
                        <c:when test="${tab == 'warranty-create'}">
                            <div class="box">
                                <div class="box-header">
                                    <h3>Tạo yêu cầu bảo hành</h3>
                                </div>
                                <div class="box-body">
                                    <c:if test="${not empty error}">
                                        <div class="error">${error}</div>
                                    </c:if>
                                    <form action="sales_dashboard" method="post">
                                        <input type="hidden" name="action" value="createWarranty">
                                        <div class="row">
                                            <label for="sku">SKU (*)</label>
                                            <input id="sku" name="sku" required value="${sku}">
                                        </div>
                                        <div class="row">
                                            <label for="productName">Tên sản phẩm</label>
                                            <input id="productName" name="productName" value="${productName}">
                                        </div>
                                        <div class="row">
                                            <label for="customerName">Tên khách hàng (*)</label>
                                            <input id="customerName" name="customerName" required
                                                value="${customerName}">
                                        </div>
                                        <div class="row">
                                            <label for="customerPhone">Số điện thoại khách hàng</label>
                                            <input id="customerPhone" name="customerPhone" value="${customerPhone}">
                                        </div>
                                        <div class="row">
                                            <label for="issueDescription">Mô tả lỗi (*)</label>
                                            <textarea id="issueDescription" name="issueDescription"
                                                required>${issueDescription}</textarea>
                                        </div>
                                        <button type="submit" class="btn">Gửi yêu cầu bảo hành</button>
                                    </form>
                                </div>
                            </div>
                        </c:when>

                        <c:when test="${tab == 'warranty-lookup'}">
                            <div class="box">
                                <div class="box-header">
                                    <h3>Tra cứu bảo hành</h3>
                                </div>
                                <div class="box-body">
                                    <c:if test="${not empty created}">
                                        <div class="ok">Đã tạo yêu cầu thành công: <strong>${created}</strong></div>
                                    </c:if>
                                    <form class="toolbar" action="sales_dashboard" method="get">
                                        <input type="hidden" name="tab" value="warranty-lookup">
                                        <input type="text" name="q" value="${q}"
                                            placeholder="Tìm theo mã yêu cầu / SKU / khách hàng / SĐT">
                                        <button class="btn" type="submit">Tìm</button>
                                    </form>

                                    <table>
                                        <tr>
                                            <th>Mã yêu cầu</th>
                                            <th>SKU</th>
                                            <th>Sản phẩm</th>
                                            <th>Khách hàng</th>
                                            <th>SĐT</th>
                                            <th>Trạng thái</th>
                                            <th>Cập nhật</th>
                                        </tr>
                                        <c:forEach items="${claims}" var="c">
                                            <tr>
                                                <td>${c.claimCode}</td>
                                                <td>${c.sku}</td>
                                                <td>${c.productName}</td>
                                                <td>${c.customerName}</td>
                                                <td>${c.customerPhone}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${c.status == 'NEW'}">Đang tiến hành</c:when>
                                                        <c:when test="${c.status == 'RECEIVED'}">Đã tiếp nhận</c:when>
                                                        <c:when test="${c.status == 'IN_REPAIR'}">Đang sửa chữa</c:when>
                                                        <c:when test="${c.status == 'APPROVED'}">Đã xác nhận</c:when>
                                                        <c:when test="${c.status == 'REJECTED'}">Từ chối</c:when>
                                                        <c:when test="${c.status == 'COMPLETED'}">Đã bảo hành</c:when>
                                                        <c:when test="${c.status == 'CANCELLED'}">Đã hủy</c:when>
                                                        <c:otherwise>${c.status}</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>${c.updatedAt}</td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty claims}">
                                            <tr>
                                                <td colspan="7">Chưa có yêu cầu bảo hành nào.</td>
                                            </tr>
                                        </c:if>
                                    </table>
                                </div>
                            </div>
                        </c:when>

                        <c:when test="${tab == 'return-create'}">
                            <div class="box">
                                <div class="box-header">
                                    <h3>Tạo yêu cầu trả hàng</h3>
                                </div>
                                <div class="box-body">
                                    <c:if test="${not empty returnCreated}">
                                        <div class="ok">Đã tạo yêu cầu trả hàng thành công:
                                            <strong>${returnCreated}</strong>
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty error}">
                                        <div class="error">${error}</div>
                                    </c:if>
                                    <form action="sales_dashboard" method="post">
                                        <input type="hidden" name="action" value="createReturn">
                                        <div class="row">
                                            <label for="returnSku">SKU (*)</label>
                                            <input id="returnSku" name="returnSku" required value="${returnSku}">
                                        </div>
                                        <div class="row">
                                            <label for="returnProductName">Tên sản phẩm</label>
                                            <input id="returnProductName" name="returnProductName"
                                                value="${returnProductName}">
                                        </div>
                                        <div class="row">
                                            <label for="returnCustomerName">Tên khách hàng (*)</label>
                                            <input id="returnCustomerName" name="returnCustomerName" required
                                                value="${returnCustomerName}">
                                        </div>
                                        <div class="row">
                                            <label for="returnCustomerPhone">Số điện thoại khách hàng</label>
                                            <input id="returnCustomerPhone" name="returnCustomerPhone"
                                                value="${returnCustomerPhone}">
                                        </div>
                                        <div class="row">
                                            <label for="returnReason">Lý do trả hàng (*)</label>
                                            <textarea id="returnReason" name="returnReason"
                                                required>${returnReason}</textarea>
                                        </div>
                                        <div class="row">
                                            <label for="returnConditionNote">Tình trạng hàng</label>
                                            <textarea id="returnConditionNote"
                                                name="returnConditionNote">${returnConditionNote}</textarea>
                                        </div>
                                        <button type="submit" class="btn">Gửi yêu cầu trả hàng</button>
                                    </form>
                                </div>
                            </div>
                        </c:when>

                        <c:when test="${tab == 'return-lookup'}">
                            <div class="box">
                                <div class="box-header">
                                    <h3>Tra cứu trả hàng</h3>
                                </div>
                                <div class="box-body">
                                    <c:if test="${not empty returnCreated}">
                                        <div class="ok">Đã tạo yêu cầu trả hàng thành công:
                                            <strong>${returnCreated}</strong>
                                        </div>
                                    </c:if>
                                    <form class="toolbar" action="sales_dashboard" method="get">
                                        <input type="hidden" name="tab" value="return-lookup">
                                        <input type="text" name="rq" value="${rq}"
                                            placeholder="Tìm theo mã yêu cầu / SKU / khách hàng / SĐT">
                                        <button class="btn" type="submit">Tìm</button>
                                    </form>

                                    <table>
                                        <tr>
                                            <th>Mã yêu cầu</th>
                                            <th>SKU</th>
                                            <th>Sản phẩm</th>
                                            <th>Khách hàng</th>
                                            <th>SĐT</th>
                                            <th>Trạng thái</th>
                                            <th>Cập nhật</th>
                                        </tr>
                                        <c:forEach items="${returnClaims}" var="r">
                                            <tr>
                                                <td>${r.returnCode}</td>
                                                <td>${r.sku}</td>
                                                <td>${r.productName}</td>
                                                <td>${r.customerName}</td>
                                                <td>${r.customerPhone}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${r.status == 'NEW'}">Đang xử lý</c:when>
                                                        <c:when test="${r.status == 'RECEIVED'}">Đã tiếp nhận</c:when>
                                                        <c:when test="${r.status == 'INSPECTING'}">Đang kiểm tra
                                                        </c:when>
                                                        <c:when test="${r.status == 'APPROVED'}">Đã xác nhận</c:when>
                                                        <c:when test="${r.status == 'REJECTED'}">Từ chối</c:when>
                                                        <c:when test="${r.status == 'REFUNDED'}">Đã hoàn tiền</c:when>
                                                        <c:when test="${r.status == 'COMPLETED'}">Đã trả hàng</c:when>
                                                        <c:when test="${r.status == 'CANCELLED'}">Đã hủy</c:when>
                                                        <c:otherwise>${r.status}</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>${r.updatedAt}</td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty returnClaims}">
                                            <tr>
                                                <td colspan="7">Chưa có yêu cầu trả hàng nào.</td>
                                            </tr>
                                        </c:if>
                                    </table>
                                </div>
                            </div>
                        </c:when>

                        <c:when test="${tab == 'products'}">
                            <div class="box">
                                <div class="box-header">
                                    <h3>Tất cả sản phẩm</h3>
                                </div>
                                <div class="box-body">
                                    <c:if test="${not empty error}">
                                        <div class="error">${error}</div>
                                    </c:if>
                                    <table>
                                        <tr>
                                            <th>ID</th>
                                            <th>Tên sản phẩm</th>
                                            <th>SKU</th>
                                            <th>Giá bán</th>
                                            <th>Tồn kho</th>
                                            <th>Đơn vị</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                        <c:forEach items="${salesProducts}" var="p">
                                            <tr>
                                                <td>${p.id}</td>
                                                <td>${p.name}</td>
                                                <td>${p.sku}</td>
                                                <td>${p.price}</td>
                                                <td>${p.quantity}</td>
                                                <td>${p.unit}</td>
                                                <td>${p.status}</td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty salesProducts}">
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
                                    <h3>Hướng dẫn sử dụng</h3>
                                </div>
                                <div class="box-body">
                                    <p>- Bấm menu bên trái để mở đúng chức năng, không rời khỏi trang quản lý sales.</p>
                                    <p>- "Tạo yêu cầu bảo hành" sẽ hiển thị form ngay tại khu vực nội dung này.</p>
                                    <p>- "Tạo yêu cầu trả hàng" cũng hiển thị form trong cùng trang.</p>
                                    <p>- "Tra cứu bảo hành" hiển thị danh sách yêu cầu bạn đã tạo.</p>
                                    <p>- "Tra cứu trả hàng" hiển thị danh sách yêu cầu trả hàng bạn đã tạo.</p>
                                    <p>- "Xem tất cả sản phẩm" hiển thị toàn bộ sản phẩm trong hệ thống.</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </body>

        </html>