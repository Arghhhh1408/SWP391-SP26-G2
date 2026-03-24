<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết khách hàng - S.I.M</title>
    <%-- Nhúng lại CSS chung để Sidebar không bị vỡ --%>
    <style>
        .admin-main { margin-left: 240px; padding: 20px; background: #f4f6f9; min-height: 100vh; }
        .box { background: #fff; border-radius: 8px; border: 1px solid #e0e0e0; margin-bottom: 20px; overflow: hidden; }
        .box-header { padding: 15px 20px; border-bottom: 1px solid #eee; background: #fcfcfc; font-weight: bold; }
        .box-body { padding: 20px; }
        /* Thêm các CSS table của bạn ở đây */
    </style>
</head>
<body>
    <%-- 1. Nhúng Sidebar --%>
    <c:set var="currentPage" value="customers" scope="request" />
    <jsp:include page="saleSidebar.jsp" />

    <div class="admin-main">
        <%-- 2. Nhúng Topbar (nếu bạn có file riêng hoặc viết trực tiếp) --%>
        <div style="background: #fff; padding: 15px 25px; border-bottom: 1px solid #e0e0e0; margin-bottom: 20px; border-radius: 8px;">
            <h1 style="font-size: 20px; margin: 0;">Hồ sơ khách hàng: ${customer.name}</h1>
            <a href="salesDashboard?tab=customers" style="font-size: 13px; color: #3b82f6;">← Quay lại danh sách</a>
        </div>

        <div class="admin-content">
            <%-- 3. NỘI DUNG HIỆN TẠI CỦA BẠN ĐỂ Ở ĐÂY --%>
            <div class="box">
                <div class="box-body">
                    <div style="display: flex; justify-content: space-between;">
                        <div>
                            <p><b>Mã khách hàng:</b> #${customer.id}</p>
                            <p><b>Số điện thoại:</b> ${customer.phone}</p>
                            <p><b>Địa chỉ:</b> ${customer.address}</p>
                        </div>
                        <div>
                            <p><b>Tổng công nợ:</b> <fmt:formatNumber value="${customer.debt}" type="number"/> VNĐ</p>
                            <p><b>Email:</b> ${customer.email}</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="box">
                <div class="box-header">📜 Lịch sử giao dịch (Đơn hàng đã mua)</div>
                <div class="box-body">
                    <table style="width: 100%; border-collapse: collapse;">
                        <tr style="background: #8b5cf6; color: white;">
                            <th style="padding: 10px;">Mã HĐ</th>
                            <th style="padding: 10px;">Ngày mua</th>
                            <th style="padding: 10px;">Người bán</th>
                            <th style="padding: 10px;">Tổng tiền</th>
                            <th style="padding: 10px;">Hành động</th>
                        </tr>
                        <c:forEach items="${orders}" var="o">
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #eee;">#${o.id}</td>
                                <td style="padding: 10px; border-bottom: 1px solid #eee;">${o.date}</td>
                                <td style="padding: 10px; border-bottom: 1px solid #eee;">${o.staffName}</td>
                                <td style="padding: 10px; border-bottom: 1px solid #eee;"><b><fmt:formatNumber value="${o.total}" type="number"/> đ</b></td>
                                <td style="padding: 10px; border-bottom: 1px solid #eee;"><a href="#">Xem hóa đơn</a></td>
                            </tr>
                        </c:forEach>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>