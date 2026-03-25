<%-- Document : admin --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Admin Dashboard | IMS PRO</title>
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: #fff;
            padding: 25px;
            border-radius: 15px;
            display: flex;
            align-items: center;
            gap: 15px;
            box-shadow: 0 0 20px 0 rgba(76, 87, 125, 0.02);
        }

        .stat-icon {
            width: 45px;
            height: 45px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            background: #f3f6f9;
        }

        .stat-content {
            display: flex;
            flex-direction: column;
        }

        .stat-value {
            font-size: 22px;
            font-weight: 800;
            color: #181c32;
        }

        .stat-label {
            font-size: 12px;
            color: #b5b5c3;
            font-weight: 600;
            margin-top: 2px;
        }

        .role-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }

        .role-item {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 15px;
        }

        .role-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .role-name {
            font-size: 13px;
            font-weight: 700;
            color: #3f4254;
        }

        .role-count {
            font-size: 12px;
            font-weight: 800;
            color: var(--primary);
        }

        .role-progress {
            height: 8px;
            background: #f3f6f9;
            border-radius: 4px;
            overflow: hidden;
        }

        .role-bar {
            height: 100%;
            background: var(--primary);
            border-radius: 4px;
        }

        @media (max-width: 1400px) {
            .stats-grid { grid-template-columns: repeat(3, 1fr); }
        }
        @media (max-width: 900px) {
            .stats-grid { grid-template-columns: 1fr 1fr; }
            .role-section { grid-template-columns: 1fr; }
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
                <p>Tổng quan hệ thống &rsaquo; Thống kê tài khoản</p>
            </div>
            <div class="user-profile">
                <span>👤 ${sessionScope.acc.fullName}</span>
            </div>
        </div>

        <div class="admin-content">
            <c:if test="${not empty notification}">
                <div class="badge-success" style="padding: 15px; border-radius: 10px; margin-bottom: 25px; font-weight: 600;">
                    ✅ ${notification}
                </div>
            </c:if>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon" style="color: #5c67f2;">👥</div>
                    <div class="stat-content">
                        <span class="stat-value">${totalAccounts}</span>
                        <span class="stat-label">Tổng Users</span>
                    </div>
                </div>
                <c:forEach var="entry" items="${roleDistribution}">
                    <div class="stat-card">
                        <div class="stat-icon">🛡️</div>
                        <div class="stat-content">
                            <span class="stat-value">${entry.value}</span>
                            <span class="stat-label">${entry.key}</span>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div class="role-section">
                <div class="card">
                    <div class="card-header">
                        <h3>📊 Tỷ lệ vai trò</h3>
                    </div>
                    <div class="card-body">
                        <c:forEach var="entry" items="${roleDistribution}">
                            <c:set var="pct" value="${totalAccounts > 0 ? (entry.value * 100 / totalAccounts) : 0}" />
                            <div class="role-item">
                                <div class="role-header">
                                    <span class="role-name">${entry.key}</span>
                                    <span class="role-count">${entry.value}</span>
                                </div>
                                <div class="role-progress">
                                    <div class="role-bar" style="width: ${pct}%"></div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h3>📋 Hoạt động mới nhất</h3>
                        <a href="systemlog" class="btn btn-outline" style="padding: 6px 15px; font-size: 11px;">Xem hết</a>
                    </div>
                    <div class="card-body" style="padding: 0;">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Hành động</th>
                                    <th>Đối tượng</th>
                                    <th>Thời gian</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="log" items="${recentLogs}" varStatus="status">
                                    <c:if test="${status.index < 5}">
                                        <tr>
                                            <td><span class="badge badge-primary">${log.action}</span></td>
                                            <td style="font-weight: 600;">${log.targetObject}</td>
                                            <td style="color: #b5b5c3; font-size: 12px;">
                                                <fmt:formatDate value="${log.logDate}" pattern="HH:mm dd/MM" />
                                            </td>
                                        </tr>
                                    </c:if>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>
    </div>
</body>
</html>