<%-- Document : admin --%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Admin Hệ Thống – Dashboard</title>
    <!-- CSS is included in adminSidebar.jsp, we just add dashboard-specific CSS here -->
    <style>
        /* ===== NOTIFICATION ===== */
        .notification-box {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
            border-radius: 6px;
            padding: 10px 16px;
            margin-bottom: 20px;
        }

        /* ===== SUMMARY CARDS ===== */
        .cards-row {
            display: flex;
            gap: 16px;
            margin-bottom: 28px;
            flex-wrap: wrap;
        }

        .card {
            flex: 1;
            min-width: 160px;
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 18px 20px;
        }

        .card .card-label {
            font-size: 12px;
            color: #888;
            margin-bottom: 6px;
        }

        .card .card-value {
            font-size: 28px;
            font-weight: bold;
            color: #1a1a2e;
        }

        .card .card-icon {
            font-size: 22px;
            margin-bottom: 8px;
        }

        /* ===== DASHBOARD GRID ===== */
        .dashboard-grid {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }

        .dashboard-grid .left {
            flex: 2;
            min-width: 280px;
        }

        .dashboard-grid .right {
            flex: 1;
            min-width: 220px;
        }

        /* ===== SECTION BOX ===== */
        .box {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .box-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 14px 18px;
            border-bottom: 1px solid #e0e0e0;
        }

        .box-header h3 {
            font-size: 15px;
            color: #1a1a2e;
        }

        .box-header a {
            font-size: 12px;
            color: #007bff;
            text-decoration: none;
        }

        .box-body {
            padding: 16px 18px;
        }

        /* ===== LOG TABLE ===== */
        .log-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        .log-table th {
            text-align: left;
            padding: 8px 10px;
            background: #f8f9fa;
            color: #555;
            border-bottom: 1px solid #e0e0e0;
            font-size: 12px;
        }

        .log-table td {
            padding: 10px;
            border-bottom: 1px solid #f0f0f0;
            color: #333;
            vertical-align: top;
        }

        .log-table tr:last-child td {
            border-bottom: none;
        }

        .log-table tr:hover td {
            background: #f8f9fa;
        }

        .badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 11px;
            background: #e8f4fd;
            color: #0056b3;
        }

        /* ===== ROLE DISTRIBUTION ===== */
        .role-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }

        .role-row .role-name {
            font-size: 13px;
            color: #333;
            flex: 1;
        }

        .role-bar-wrap {
            flex: 2;
            background: #f0f0f0;
            border-radius: 4px;
            height: 8px;
            margin: 0 10px;
            overflow: hidden;
        }

        .role-bar {
            height: 100%;
            border-radius: 4px;
            background: #007bff;
        }

        .role-count {
            font-size: 13px;
            font-weight: bold;
            color: #333;
            min-width: 20px;
            text-align: right;
        }
    </style>
</head>

<body>

    <!-- Bắt đầu include sidebar (sẽ chứa luôn CSS layout toàn trang) -->
    <jsp:include page="adminSidebar.jsp">
        <jsp:param name="currentPage" value="dashboard" />
    </jsp:include>
    <!-- Kết thúc include sidebar -->

    <!-- ===== MAIN ===== -->
    <div class="admin-main">
        <div class="admin-topbar">
            <div>
                <h1>Dashboard Quản trị</h1>
                <small>Admin &rsaquo; Tổng quan hệ thống</small>
            </div>
            <div>
                Xin chào, <strong>${sessionScope.acc.fullName}</strong>
            </div>
        </div>

        <div class="admin-content">

            <!-- Notification -->
            <c:if test="${not empty notification}">
                <div class="notification-box">&#10004; ${notification}</div>
            </c:if>

            <!-- ROW 1: Tổng số tài khoản + Phân bổ vai trò ngang nhau -->
            <div class="dashboard-grid">

                <!-- Left: Total Accounts card -->
                <div class="left">
                    <div class="box">
                        <div class="box-body"
                            style="display:flex; align-items:center; gap:16px; padding:24px;">
                            <div style="font-size:40px;">&#128101;</div>
                            <div>
                                <div style="font-size:12px; color:#888; margin-bottom:4px;">Tổng số tài
                                    khoản</div>
                                <div style="font-size:38px; font-weight:bold; color:#1a1a2e;">
                                    ${totalAccounts}</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right: Role Distribution -->
                <div class="right">
                    <div class="box">
                        <div class="box-header">
                            <h3>&#128100; Phân bổ vai trò</h3>
                        </div>
                        <div class="box-body">
                            <c:choose>
                                <c:when test="${empty roleDistribution}">
                                    <p style="color:#888; font-size:13px;">Không có dữ liệu.</p>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="entry" items="${roleDistribution}">
                                        <c:set var="pct"
                                            value="${totalAccounts > 0 ? (entry.value * 100 / totalAccounts) : 0}" />
                                        <div class="role-row">
                                            <span class="role-name">${entry.key}</span>
                                            <div class="role-bar-wrap">
                                                <div class="role-bar" style="width: ${pct}%">
                                                </div>
                                            </div>
                                            <span class="role-count">${entry.value}</span>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

            </div><!-- /dashboard-grid row 1 -->

            <!-- ROW 2: System Log full width -->
            <div class="box">
                <div class="box-header">
                    <h3>&#128196; System Log – Gần đây</h3>
                    <a href="systemlog">Tất cả &#8594;</a>
                </div>
                <div class="box-body">
                    <c:choose>
                        <c:when test="${empty recentLogs}">
                            <p style="color:#888; font-size:13px;">Chưa có log nào.</p>
                        </c:when>
                        <c:otherwise>
                            <table class="log-table">
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
                                            <td><span class="badge">${log.action}</span></td>
                                            <td>${log.targetObject}</td>
                                            <td>${log.description}</td>
                                            <td style="white-space:nowrap; color:#888; font-size:12px;">
                                                <fmt:formatDate value="${log.logDate}"
                                                    pattern="dd/MM/yyyy HH:mm" />
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div><!-- /system log box -->



        </div><!-- /content -->
    </div><!-- /main -->

</body>

</html>