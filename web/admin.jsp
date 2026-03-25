<%-- Document : admin --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Admin Dashboard | Modern IMS</title>
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 24px;
            margin-bottom: 32px;
        }

        .stat-card {
            background: #fff;
            padding: 28px;
            border-radius: 20px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            gap: 20px;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }

        .stat-info .value {
            display: block;
            font-size: 28px;
            font-weight: 800;
            color: #0f172a;
            line-height: 1;
        }

        .stat-info .label {
            font-size: 13px;
            color: #64748b;
            font-weight: 500;
            margin-top: 4px;
        }

        .role-distribution {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .role-row {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .role-name {
            width: 120px;
            font-size: 13px;
            font-weight: 600;
            color: #475569;
        }

        .role-bar-container {
            flex: 1;
            height: 8px;
            background: #f1f5f9;
            border-radius: 4px;
            overflow: hidden;
        }

        .role-bar {
            height: 100%;
            background: var(--primary);
            border-radius: 4px;
        }

        .role-count {
            width: 30px;
            text-align: right;
            font-size: 13px;
            font-weight: 700;
            color: #1e293b;
        }
    </style>
</head>

<body>

    <jsp:include page="adminSidebar.jsp">
        <jsp:param name="currentPage" value="dashboard" />
    </jsp:include>

    <div class="admin-main">
        <div class="admin-topbar">
            <div class="topbar-left">
                <h1>Hệ thống Quản trị</h1>
                <small>Admin &rsaquo; Tổng quan hệ thống</small>
            </div>
            <div class="user-profile">
                <span style="font-size: 18px;">👤</span>
                <strong>${sessionScope.acc.fullName}</strong>
            </div>
        </div>

        <div class="admin-content">

            <c:if test="${not empty notification}">
                <div style="background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; padding: 12px 16px; border-radius: 12px; margin-bottom: 24px;">
                    ✅ ${notification}
                </div>
            </c:if>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon" style="background: rgba(99, 102, 241, 0.1); color: #6366f1;">👥</div>
                    <div class="stat-info">
                        <span class="value">${totalAccounts}</span>
                        <span class="label">Tổng số tài khoản</span>
                    </div>
                </div>
                
                <div class="stat-card" style="flex: 2;">
                    <div class="stat-info" style="width: 100%;">
                        <div class="role-distribution">
                            <c:forEach var="entry" items="${roleDistribution}">
                                <c:set var="pct" value="${totalAccounts > 0 ? (entry.value * 100 / totalAccounts) : 0}" />
                                <div class="role-row">
                                    <span class="role-name">${entry.key}</span>
                                    <div class="role-bar-container">
                                        <div class="role-bar" style="width: ${pct}%"></div>
                                    </div>
                                    <span class="role-count">${entry.value}</span>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>

            <div class="glass-card">
                <div class="card-header">
                    <h3>📋 Lịch sử hoạt động gần đây</h3>
                    <div style="display: flex; gap: 8px;">
                        <a href="systemlog" class="btn btn-outline" style="padding: 6px 14px; font-size: 12px;">Xem tất cả</a>
                    </div>
                </div>
                <div class="card-body" style="padding: 0;">
                    <c:choose>
                        <c:when test="${empty recentLogs}">
                            <div style="padding: 40px; text-align: center; color: var(--text-muted);">
                                <span style="font-size: 40px; display: block; margin-bottom: 10px;">📄</span>
                                Chưa có hoạt động nào được ghi lại.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="admin-table">
                                <thead>
                                    <tr>
                                        <th>Hành động</th>
                                        <th>Đối tượng</th>
                                        <th>Mô tả</th>
                                        <th>Thời gian</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="log" items="${recentLogs}">
                                        <tr>
                                            <td>
                                                <span class="badge" style="background: rgba(99, 102, 241, 0.1); color: var(--primary);">
                                                    ${log.action}
                                                </span>
                                            </td>
                                            <td style="font-weight: 500;">${log.targetObject}</td>
                                            <td style="color: var(--text-muted); font-size: 13px;">${log.description}</td>
                                            <td style="white-space:nowrap; color: var(--text-muted); font-size: 12px;">
                                                <fmt:formatDate value="${log.logDate}" pattern="dd/MM/yyyy HH:mm" />
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        </div>
    </div>

</body>

</html>