<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Danh s&#225;ch phi&#7871;u &#273;i&#7873;u ch&#7881;nh t&#7891;n kho</title>
<link rel="stylesheet" href="css/inventoryAdjustment.css">
</head>
<body>
<jsp:include page="staffSidebar.jsp"/>
<div class="admin-main">
<div class="adj-page">

<c:if test="${not empty sessionScope.adjSuccess}">
  <div class="adj-alert success">${sessionScope.adjSuccess}</div>
  <c:remove var="adjSuccess" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.adjError}">
  <div class="adj-alert error">${sessionScope.adjError}</div>
  <c:remove var="adjError" scope="session"/>
</c:if>

<div class="list-header">
  <h2>&#272;i&#7873;u ch&#7881;nh t&#7891;n kho</h2>
  <a href="inventoryAdjustment?mode=create" class="btn-new">+ T&#7841;o phi&#7871;u m&#7899;i</a>
</div>

<table class="adj-list-table">
  <thead><tr>
    <th>M&#227; phi&#7871;u</th>
    <th>Ng&#224;y</th>
    <th>Kho h&#224;ng</th>
    <th>Ng&#432;&#7901;i t&#7841;o</th>
    <th>L&#253; do</th>
    <th>S&#7843;n ph&#7849;m</th>
    <th>T&#259;ng</th>
    <th>Gi&#7843;m</th>
    <th>Tr&#7841;ng th&#225;i</th>
    <th></th>
  </tr></thead>
  <tbody>
  <c:forEach items="${adjustments}" var="a">
    <tr>
      <td><strong>${a.adjustmentCode}</strong></td>
      <td>${a.adjustmentDate}</td>
      <td>${a.warehouse}</td>
      <td>${a.createdByName}</td>
      <td>${a.generalReason}</td>
      <td>${a.totalProducts}</td>
      <td style="color:#3fb950">+${a.totalIncrease}</td>
      <td style="color:#f85149">-${a.totalDecrease}</td>
      <td>
        <span class="status-badge ${a.status == 'Confirmed' ? 'status-confirmed' : 'status-draft'}">
          ${a.status == 'Confirmed' ? '&#272;&#227; x&#225;c nh&#7853;n' : 'Nh&#225;p'}
        </span>
      </td>
      <td><a href="inventoryAdjustment?mode=view&id=${a.adjustmentId}" style="color:#58a6ff;font-size:13px">Xem</a></td>
    </tr>
  </c:forEach>
  <c:if test="${empty adjustments}">
    <tr><td colspan="10" class="empty-state" style="padding:40px">Ch&#432;a c&#243; phi&#7871;u &#273;i&#7873;u ch&#7881;nh n&#224;o.</td></tr>
  </c:if>
  </tbody>
</table>

<c:if test="${adjTotalPages > 1}">
  <div class="pager">
    <c:if test="${adjPage > 1}">
      <a href="inventoryAdjustment?page=${adjPage - 1}">&#171; Tr&#432;&#7899;c</a>
    </c:if>
    <span>Trang ${adjPage} / ${adjTotalPages} &middot; ${adjTotal} phi&#7871;u</span>
    <c:if test="${adjPage < adjTotalPages}">
      <a href="inventoryAdjustment?page=${adjPage + 1}">Sau &#187;</a>
    </c:if>
  </div>
</c:if>

</div></div>
</body>
</html>
