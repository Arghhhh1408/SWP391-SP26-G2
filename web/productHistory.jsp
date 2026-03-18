<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c"%>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử thay đổi sản phẩm - IMS PRO</title>
    <!-- Include Sidebar Styles (from sidebar fragment or directly) -->
    <style>
        .history-card {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
            padding: 30px;
            margin-top: 20px;
        }
        .history-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin-top: 20px;
        }
        .history-table th {
            background: #f8fafc;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #475569;
            border-bottom: 2px solid #e2e8f0;
        }
        .history-table td {
            padding: 15px;
            border-bottom: 1px solid #f1f5f9;
            vertical-align: top;
            font-size: 14px;
        }
        .action-badge {
            padding: 4px 10px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 11px;
            text-transform: uppercase;
        }
        .action-ADD { background: #dcfce7; color: #166534; }
        .action-EDIT { background: #fef9c3; color: #854d0e; }
        .action-STOCKIN { background: #dbeafe; color: #1e40af; }
        .user-info {
            display: flex;
            flex-direction: column;
        }
        .user-info .name { font-weight: 600; color: #1e293b; }
        .user-info .ip { font-size: 11px; color: #94a3b8; }
        .log-desc {
            max-width: 500px;
            overflow-wrap: break-word;
            line-height: 1.5;
            color: #334155;
        }
        .empty-state {
            text-align: center;
            padding: 60px;
            color: #94a3b8;
        }
        .page-header {
            margin-bottom: 30px;
        }
        .page-header h1 {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
            margin: 0;
        }
        .page-header p {
            color: #64748b;
            margin: 5px 0 0;
        }
    </style>
</head>
<body>
    <jsp:include page="managerSidebar.jsp" />
    
    <div class="admin-main">
        <header class="admin-topbar">
            <span>Quản lý kho > <strong>Lịch sử sản phẩm</strong></span>
            <div>Xin chào, <strong>${sessionScope.acc.fullName}</strong></div>
        </header>

        <div class="admin-content">
            <div class="page-header">
                <h1>📋 Nhật ký thay đổi hệ thống</h1>
                <p>Theo dõi toàn bộ các hoạt động Thêm, Sửa, và Nhập kho liên quan đến sản phẩm.</p>
            </div>

            <div class="history-card">
                <c:choose>
                    <c:when test="${not empty history}">
                        <table class="history-table">
                            <thead>
                                <tr>
                                    <th style="width: 180px;">Thời gian</th>
                                    <th style="width: 130px;">Hành động</th>
                                    <th style="width: 180px;">Người thực hiện</th>
                                    <th style="width: 200px;">Đối tượng</th>
                                    <th>Chi tiết hoạt động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${history}" var="h">
                                    <tr>
                                        <td style="color: #64748b; font-weight: 500;">
                                            <fmt:formatDate value="${h.logDate}" pattern="dd/MM/yyyy HH:mm:ss" />
                                        </td>
                                        <td>
                                            <span class="action-badge action-${h.action.contains('ADD') ? 'ADD' : (h.action.contains('EDIT') ? 'EDIT' : 'STOCKIN')}">
                                                ${h.action}
                                            </span>
                                        </td>
                                        <td>
                                            <div class="user-info">
                                                <span class="name">${h.name}</span>
                                                <span class="ip">IP: ${h.ipAddress}</span>
                                            </div>
                                        </td>
                                        <td>
                                            <strong style="color: #0f172a;">${not empty h.productName ? h.productName : '(N/A)'}</strong>
                                        </td>
                                        <td>
                                            <div class="log-desc">${h.description}</div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <span style="font-size: 48px;">📄</span>
                            <p>Không có dữ liệu nhật ký nào được tìm thấy.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</body>
</html>
