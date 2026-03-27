<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Dieu chinh ton kho</title>
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
<c:choose>
<c:when test="${mode == 'view' and adj != null}">
<div class="adj-topbar">
  <a href="inventoryAdjustment" class="back-btn">&larr; Quay lai</a>
  <h2>Dieu chinh ton kho</h2>
  <span class="status-badge ${adj.status == 'Confirmed' ? 'status-confirmed' : 'status-draft'}">
    ${adj.status == 'Confirmed' ? 'Da xac nhan' : 'Nhap'}
  </span>
  <c:if test="${adj.status == 'Draft'}">
    <form method="post" action="inventoryAdjustment" style="margin:0">
      <input type="hidden" name="action" value="confirmExisting">
      <input type="hidden" name="id" value="${adj.adjustmentId}">
      <button type="submit" class="btn btn-confirm">Xac nhan dieu chinh</button>
    </form>
  </c:if>
</div>
<div class="adj-summary">
  <div class="sum-card"><div class="label">Tong san pham</div>
    <div class="value val-neutral">${adj.totalProducts} <span class="val-sub">dong</span></div></div>
  <div class="sum-card"><div class="label">Tang ton kho</div>
    <div class="value val-up">+${adj.totalIncrease} <span class="val-sub">don vi</span></div></div>
  <div class="sum-card"><div class="label">Giam ton kho</div>
    <div class="value val-down">-${adj.totalDecrease} <span class="val-sub">don vi</span></div></div>
  <div class="sum-card"><div class="label">Gia tri thay doi</div>
    <div class="value val-money">
      <c:choose>
        <c:when test="${adj.totalValueChange != null}"><fmt:formatNumber value="${adj.totalValueChange}" maxFractionDigits="0"/> d</c:when>
        <c:otherwise>--</c:otherwise>
      </c:choose>
    </div></div>
</div>
<div class="adj-body">
  <div class="adj-card">
    <h4>THONG TIN PHIEU</h4>
    <div class="form-row">
      <div class="form-group"><label>Ma phieu</label><input type="text" value="${adj.adjustmentCode}" readonly></div>
      <div class="form-group"><label>Ngay dieu chinh</label><input type="text" value="${adj.adjustmentDate}" readonly></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Kho hang</label><input type="text" value="${adj.warehouse}" readonly></div>
      <div class="form-group"><label>Nguoi tao</label><input type="text" value="${adj.createdByName}" readonly></div>
    </div>
  </div>
  <div class="adj-card">
    <h4>GHI CHU &amp; PHE DUYET</h4>
    <div class="form-group" style="margin-bottom:12px">
      <label>Ly do dieu chinh chung</label>
      <input type="text" value="${adj.generalReason}" readonly>
    </div>
    <div class="form-group"><label>Ghi chu</label><textarea readonly>${adj.note}</textarea></div>
  </div>
</div>
<div class="adj-card">
  <table class="prod-table">
    <thead><tr>
      <th>San pham</th><th>Don vi</th><th>Ton hien tai</th>
      <th>So luong moi</th><th>Chenh lech</th><th>Ly do</th><th>Ghi chu</th>
    </tr></thead>
    <tbody>
    <c:forEach items="${adj.items}" var="item">
      <tr>
        <td>
          <div style="display:flex;align-items:center;gap:10px">
            <c:choose>
              <c:when test="${not empty item.imageUrl}"><img src="${item.imageUrl}" class="prod-img" alt=""></c:when>
              <c:otherwise><div class="prod-img prod-img-placeholder">P</div></c:otherwise>
            </c:choose>
            <div><div class="prod-name">${item.productName}</div><div class="prod-sku">SKU: ${item.sku}</div></div>
          </div>
        </td>
        <td>${item.unit}</td><td>${item.oldQuantity}</td>
        <td><strong>${item.newQuantity}</strong></td>
        <td><span class="variance-badge ${item.variance > 0 ? 'var-up' : (item.variance < 0 ? 'var-down' : 'var-zero')}">${item.variance > 0 ? '+' : ''}${item.variance}</span></td>
        <td><c:out value="${not empty item.reason ? item.reason : '--'}"/></td>
        <td><c:out value="${not empty item.itemNote ? item.itemNote : '--'}"/></td>
      </tr>
    </c:forEach>
    <c:if test="${empty adj.items}"><tr><td colspan="7" class="empty-state">Khong co dong nao.</td></tr></c:if>
    </tbody>
  </table>
</div>
</c:when>
<c:otherwise><%-- CREATE MODE --%>
<form method="post" action="inventoryAdjustment" id="adjForm">
<div class="adj-topbar">
  <a href="inventoryAdjustment" class="back-btn">&larr; Quay lai</a>
  <h2>Dieu chinh ton kho</h2>
  <span class="status-badge status-draft">Nhap</span>
  <button type="button" class="btn btn-cancel" onclick="location.href='inventoryAdjustment'">Huy</button>
  <button type="submit" name="action" value="save" class="btn btn-save">Luu nhap</button>
  <button type="submit" name="action" value="confirm" class="btn btn-confirm">Xac nhan dieu chinh</button>
</div>
<div class="adj-summary">
  <div class="sum-card"><div class="label">Tong san pham</div><div class="value val-neutral" id="sumTotal">0 <span class="val-sub">dong</span></div></div>
  <div class="sum-card"><div class="label">Tang ton kho</div><div class="value val-up" id="sumUp">+0 <span class="val-sub">don vi</span></div></div>
  <div class="sum-card"><div class="label">Giam ton kho</div><div class="value val-down" id="sumDown">-0 <span class="val-sub">don vi</span></div></div>
  <div class="sum-card"><div class="label">Gia tri thay doi</div><div class="value val-money" id="sumValue">0 d</div></div>
</div>
<div class="adj-body">
  <div class="adj-card">
    <h4>THONG TIN PHIEU</h4>
    <div class="form-row">
      <div class="form-group"><label>Ma phieu</label><input type="text" name="adjCode" value="${adjCode}" readonly></div>
      <div class="form-group"><label>Ngay dieu chinh</label><input type="date" name="adjDate" id="adjDate" required></div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Kho hang</label>
        <select name="warehouse">
          <option value="Kho chinh - Ha Noi">Kho chinh - Ha Noi</option>
          <option value="Kho phu - HCM">Kho phu - HCM</option>
          <option value="Kho trung chuyen">Kho trung chuyen</option>
        </select>
      </div>
      <div class="form-group">
        <label>Nguoi tao</label>
        <input type="text" value="${not empty sessionScope.acc.fullName ? sessionScope.acc.fullName : sessionScope.acc.username}" readonly>
      </div>
    </div>
  </div>
  <div class="adj-card">
    <h4>GHI CHU &amp; PHE DUYET</h4>
    <div class="form-group" style="margin-bottom:12px">
      <label>Ly do dieu chinh chung</label>
      <select name="generalReason">
        <option value="Kiem ke dinh ky">Kiem ke dinh ky</option>
        <option value="Hang hong / het han">Hang hong / het han</option>
        <option value="Nhap thua / nhap nham">Nhap thua / nhap nham</option>
        <option value="Mat mat / that thoat">Mat mat / that thoat</option>
        <option value="Dieu chuyen noi bo">Dieu chuyen noi bo</option>
        <option value="Khac">Khac</option>
      </select>
    </div>
    <div class="form-group">
      <label>Ghi chu</label>
      <textarea name="note" placeholder="Nhap mo ta them ve dot dieu chinh nay..."></textarea>
    </div>
  </div>
</div>
<div class="adj-card">
  <div class="prod-toolbar">
    <div class="search-wrap">
      <span class="search-icon">&#128269;</span>
      <input type="text" id="productSearch" placeholder="Tim theo ten san pham hoac SKU..." autocomplete="off">
      <div class="search-dropdown" id="searchDropdown"></div>
    </div>
    <div class="filter-tabs">
      <span class="ftab active" onclick="filterRows('all',this)" id="tabAll">Tat ca (0)</span>
      <span class="ftab ftab-up" onclick="filterRows('up',this)" id="tabUp">Tang (0)</span>
      <span class="ftab ftab-down" onclick="filterRows('down',this)" id="tabDown">Giam (0)</span>
      <button type="button" class="btn-excel">Nhap tu Excel</button>
    </div>
  </div>
  <table class="prod-table" id="prodTable">
    <thead><tr>
      <th><input type="checkbox" class="cb-row" id="cbAll" onclick="toggleAll(this)"></th>
      <th>San pham</th><th>Don vi</th><th>Ton hien tai</th>
      <th>So luong moi</th><th>Chenh lech</th><th>Ly do</th><th>Ghi chu</th><th></th>
    </tr></thead>
    <tbody id="prodBody">
      <tr id="emptyRow"><td colspan="9" class="empty-state">Tim va them san pham can dieu chinh</td></tr>
    </tbody>
  </table>
</div>
</form>
</c:otherwise>
</c:choose>
</div></div><script>
(function() {
  var adjDateEl = document.getElementById('adjDate');
  if (adjDateEl) adjDateEl.value = new Date().toISOString().split('T')[0];

  var rows = [];
  var searchInput = document.getElementById('productSearch');
  var dropdown = document.getElementById('searchDropdown');
  if (!searchInput) return;

  var searchTimer;
  searchInput.addEventListener('input', function() {
    clearTimeout(searchTimer);
    var q = this.value.trim();
    if (q.length < 1) { dropdown.classList.remove('open'); return; }
    searchTimer = setTimeout(function() {
      fetch('inventoryAdjustment?mode=searchProduct&q=' + encodeURIComponent(q))
        .then(function(r) { return r.json(); })
        .then(function(data) {
          dropdown.innerHTML = '';
          if (!data.length) {
            dropdown.innerHTML = '<div style="padding:12px;color:#94a3b8;font-size:13px">Khong tim thay san pham</div>';
          } else {
            data.forEach(function(p) {
              var div = document.createElement('div');
              div.className = 'sd-item';
              var imgHtml = p.image ? '<img src="'+p.image+'" class="sd-img" alt="">' : '<div class="sd-img sd-img-ph">P</div>';
              div.innerHTML = imgHtml + '<div class="sd-info"><div class="sd-name">'+p.name+'</div><div class="sd-sku">SKU: '+p.sku+'</div></div><div class="sd-stock">Ton: '+p.stock+'</div>';
              div.addEventListener('click', function() { addRow(p); dropdown.classList.remove('open'); searchInput.value = ''; });
              dropdown.appendChild(div);
            });
          }
          dropdown.classList.add('open');
        }).catch(function(){});
    }, 300);
  });

  document.addEventListener('click', function(e) {
    if (!searchInput.contains(e.target) && !dropdown.contains(e.target)) dropdown.classList.remove('open');
  });

  function addRow(p) {
    for (var i = 0; i < rows.length; i++) { if (rows[i].productId === p.productId) return; }
    rows.push({productId:p.productId,sku:p.sku,name:p.name,unit:p.unit,stock:p.stock,cost:p.cost,image:p.image,newQty:p.stock,reason:'',note:''});
    renderTable();
  }

  window.removeRow = function(idx) { rows.splice(idx,1); renderTable(); };

  window.onQtyChange = function(idx, val) {
    var v = parseInt(val); if (isNaN(v)||v<0) v=0;
    rows[idx].newQty = v;
    var variance = v - rows[idx].stock;
    var varEl = document.getElementById('var_'+idx);
    if (varEl) {
      varEl.textContent = (variance>0?'+':'')+variance;
      varEl.className = 'variance-badge '+(variance>0?'var-up':(variance<0?'var-down':'var-zero'));
    }
    var tr = document.querySelector('tr[data-idx="'+idx+'"]');
    if (tr) tr.setAttribute('data-var', variance);
    updateSummary(); updateTabs();
  };

  window.filterRows = function(type, el) {
    document.querySelectorAll('.ftab').forEach(function(t){t.classList.remove('active');});
    el.classList.add('active');
    document.querySelectorAll('#prodBody tr[data-idx]').forEach(function(tr) {
      var v = parseInt(tr.getAttribute('data-var')||'0');
      tr.style.display = (type==='all'||(type==='up'&&v>0)||(type==='down'&&v<0)) ? '' : 'none';
    });
  };

  window.toggleAll = function(cb) {
    document.querySelectorAll('.cb-item').forEach(function(c){c.checked=cb.checked;});
  };

  function renderTable() {
    var tbody = document.getElementById('prodBody');
    if (!rows.length) {
      tbody.innerHTML = '<tr><td colspan="9" class="empty-state">Tim va them san pham can dieu chinh</td></tr>';
      updateSummary(); updateTabs(); return;
    }
    var html = '';
    rows.forEach(function(r, idx) {
      var variance = r.newQty - r.stock;
      var varClass = variance>0?'var-up':(variance<0?'var-down':'var-zero');
      var varText = (variance>0?'+':'')+variance;
      var imgHtml = r.image ? '<img src="'+r.image+'" class="prod-img" alt="">' : '<div class="prod-img prod-img-placeholder">P</div>';
      var reasonOpts = [['',''],['Kiem ke dinh ky','Kiem ke dinh ky'],['Hang hong','Hang hong'],['Nhap nham','Nhap nham'],['Mat mat','Mat mat'],['Dieu chuyen','Dieu chuyen'],['Khac','Khac']];
      var sel = '<select class="reason-select" name="reason[]" onchange="rows['+idx+'].reason=this.value">';
      reasonOpts.forEach(function(ro){ sel+='<option value="'+ro[0]+'"'+(r.reason===ro[0]?' selected':'')+'>'+ro[1]+'</option>'; });
      sel += '</select>';
      html += '<tr data-idx="'+idx+'" data-var="'+variance+'">';
      html += '<td><input type="checkbox" class="cb-row cb-item"></td>';
      html += '<td><div style="display:flex;align-items:center;gap:10px">'+imgHtml+'<div><div class="prod-name">'+r.name+'</div><div class="prod-sku">SKU: '+r.sku+'</div></div></div>'
            + '<input type="hidden" name="productId[]" value="'+r.productId+'">'
            + '<input type="hidden" name="oldQty[]" value="'+r.stock+'"></td>';
      html += '<td>'+r.unit+'</td><td>'+r.stock+'</td>';
      html += '<td><input type="number" class="qty-input" name="newQty[]" value="'+r.newQty+'" min="0" oninput="onQtyChange('+idx+',this.value)"></td>';
      html += '<td><span class="variance-badge '+varClass+'" id="var_'+idx+'">'+varText+'</span></td>';
      html += '<td>'+sel+'</td>';
      html += '<td><input type="text" class="note-input" name="itemNote[]" value="'+esc(r.note)+'" placeholder="Ghi chu..." onchange="rows['+idx+'].note=this.value"></td>';
      html += '<td><button type="button" class="del-btn" onclick="removeRow('+idx+')" title="Xoa">&#10005;</button></td>';
      html += '</tr>';
    });
    tbody.innerHTML = html;
    updateSummary(); updateTabs();
  }

  function esc(s){ return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

  function updateSummary() {
    var total=rows.length, up=0, down=0, val=0;
    rows.forEach(function(r){ var v=r.newQty-r.stock; if(v>0)up+=v; else if(v<0)down+=Math.abs(v); val+=Math.abs(v)*(r.cost||0); });
    var g=function(id){return document.getElementById(id);};
    if(g('sumTotal')) g('sumTotal').innerHTML=total+' <span class="val-sub">dong</span>';
    if(g('sumUp'))    g('sumUp').innerHTML='+'+up+' <span class="val-sub">don vi</span>';
    if(g('sumDown'))  g('sumDown').innerHTML='-'+down+' <span class="val-sub">don vi</span>';
    if(g('sumValue')) g('sumValue').textContent=val.toLocaleString('vi-VN')+' d';
  }

  function updateTabs() {
    var total=rows.length;
    var upC=rows.filter(function(r){return r.newQty-r.stock>0;}).length;
    var dnC=rows.filter(function(r){return r.newQty-r.stock<0;}).length;
    var g=function(id){return document.getElementById(id);};
    if(g('tabAll'))  g('tabAll').textContent='Tat ca ('+total+')';
    if(g('tabUp'))   g('tabUp').textContent='Tang ('+upC+')';
    if(g('tabDown')) g('tabDown').textContent='Giam ('+dnC+')';
  }
})();
</script>
</body>
</html>