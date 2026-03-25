<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>

<style>
    .rl-panel { background: #fff; color: #1e293b; }
    .rl-search-wrap { position: relative; margin-bottom: 12px; }
    .rl-search-wrap .rl-icon {
        position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
        color: #94a3b8; font-size: 18px; pointer-events: none;
    }
    .rl-search-input {
        width: 100%; box-sizing: border-box; padding: 14px 16px 14px 44px;
        border: 1px solid #e2e8f0; border-radius: 10px; font-size: 15px; background: #fff;
    }
    .rl-search-input:focus {
        outline: none; border-color: #3b82f6;
        box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
    }
    .rl-search-actions { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
    .rl-btn-search {
        padding: 6px 14px; background: #3b82f6; color: #fff; border: none; border-radius: 8px;
        font-weight: 600; font-size: 13px; cursor: pointer;
    }
    .rl-btn-search:hover { background: #2563eb; }
    .rl-btn-reset {
        padding: 6px 12px; background: #fff; color: #64748b; border: 1px solid #e2e8f0;
        border-radius: 8px; cursor: pointer; font-size: 13px;
    }
    .rl-toolbar-row {
        display: flex; justify-content: flex-end; align-items: center; gap: 8px;
        margin: 16px 0; flex-wrap: wrap;
    }
    .rl-toolbar-row label { font-size: 13px; color: #64748b; }
    .rl-toolbar-row select, .rl-toolbar-row input[type="number"] {
        padding: 8px 12px; border-radius: 8px; border: 1px solid #e2e8f0; font-size: 13px;
    }
    .rl-table-wrap { overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 12px; }
    .rl-table { width: 100%; border-collapse: collapse; font-size: 14px; background: #fff; }
    .rl-table th {
        text-align: left; padding: 12px 14px; background: #f8fafc; color: #475569;
        font-weight: 600; border-bottom: 1px solid #e2e8f0; white-space: nowrap;
    }
    .rl-table td { padding: 14px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
    .rl-prod-cell { display: flex; align-items: center; gap: 12px; }
    .rl-prod-img {
        width: 48px; height: 48px; object-fit: contain; border-radius: 8px;
        background: #f8fafc; border: 1px solid #e2e8f0;
    }
    .rl-prod-name { font-weight: 600; color: #0f172a; }
    .rl-prod-sku { font-size: 12px; color: #64748b; margin-top: 2px; }
    .rl-serial {
        display: inline-block; padding: 6px 10px; border-radius: 8px;
        border: 1px solid #3b82f6; color: #1d4ed8; font-size: 13px;
        font-family: ui-monospace, monospace; background: #eff6ff;
    }
    .rl-pager { margin-top: 16px; display: flex; gap: 16px; flex-wrap: wrap; }
    .rl-pager a { color: #2563eb; text-decoration: none; font-weight: 600; }
    .rl-pager a:hover { text-decoration: underline; }
    .rl-btn-create {
        display: inline-block; padding: 6px 12px; background: #1e293b; color: #fff !important;
        border-radius: 8px; text-decoration: none !important; font-size: 13px; font-weight: 600;
        border: none; cursor: pointer; font-family: inherit;
    }
    .rl-btn-create:hover { background: #334155; }
    /* Modal tạo yêu cầu (cùng layout với tra cứu bảo hành) */
    .wl-modal-overlay {
        display: none;
        position: fixed;
        inset: 0;
        background: rgba(15, 23, 42, 0.45);
        z-index: 10000;
        align-items: center;
        justify-content: center;
        padding: 20px;
    }
    .wl-modal-overlay.wl-open { display: flex; }
    .wl-modal {
        background: #fff;
        border-radius: 16px;
        max-width: 720px;
        width: 100%;
        max-height: 90vh;
        overflow-y: auto;
        box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
    }
    .wl-modal-head {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 18px 22px;
        border-bottom: 1px solid #e2e8f0;
    }
    .wl-modal-head h3 { margin: 0; font-size: 18px; color: #0f172a; }
    .wl-modal-close {
        background: none;
        border: none;
        font-size: 22px;
        cursor: pointer;
        color: #64748b;
        line-height: 1;
    }
    .wl-modal-body { padding: 22px; }
    .wl-form-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 14px 18px;
    }
    .wl-form-grid .wl-full { grid-column: 1 / -1; }
    .wl-field label {
        display: block;
        font-size: 11px;
        font-weight: 700;
        color: #64748b;
        margin-bottom: 6px;
        text-transform: uppercase;
        letter-spacing: 0.04em;
    }
    .wl-modal .wl-field input, .wl-modal .wl-field select, .wl-modal .wl-field textarea {
        width: 100%;
        box-sizing: border-box;
        padding: 10px 12px;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        font-size: 14px;
        background: #fff;
        color: #0f172a;
    }
    .wl-modal .wl-field input[readonly], .wl-modal .wl-field textarea[readonly] {
        background: #f8fafc;
        color: #334155;
    }
    .wl-modal .wl-field input:focus, .wl-modal .wl-field select:focus, .wl-modal .wl-field textarea:focus {
        outline: none;
        border-color: #ea580c;
        box-shadow: 0 0 0 2px rgba(234, 88, 12, 0.18);
    }
    .wl-field textarea { min-height: 100px; resize: vertical; }
    .wl-modal-actions {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        margin-top: 20px;
        padding-top: 16px;
        border-top: 1px solid #e2e8f0;
    }
    .wl-btn-cancel { padding: 10px 18px; border-radius: 10px; border: 1px solid #cbd5e1; background: #fff; color: #334155; font-weight: 600; cursor: pointer; }
    .wl-btn-submit { padding: 10px 20px; border-radius: 10px; border: none; background: #ea580c; color: #fff; font-weight: 600; cursor: pointer; }
    .wl-refund-hint { font-size: 11px; color: #94a3b8; margin-top: 4px; font-weight: 500; text-transform: none; letter-spacing: 0; }
</style>

<c:set var="rlAction" value="${empty returnLookupFormAction ? 'sales_dashboard' : returnLookupFormAction}"/>
<c:set var="rlTab" value="${empty returnLookupTabValue ? 'return-lookup' : returnLookupTabValue}"/>
<c:set var="rlCanCreate" value="${returnLookupCanCreate == true}"/>
<c:set var="rlModalSubmit" value="${pageContext.request.contextPath}/sales-warranty-submit"/>
<c:set var="rlModalEmbedSalesDash" value="${rlAction == 'sales_dashboard'}"/>

<p style="font-size:13px;color:#64748b;margin-bottom:16px;">
    Nhập <strong>serial</strong> (VD: SN-1-2), <strong>SKU</strong>, <strong>tên sản phẩm</strong>, <strong>khách / SĐT / email</strong>, hoặc <strong>mã phiếu xuất</strong>.
    <br/><span style="color:#b45309;">Chỉ được tạo yêu cầu trả hàng trong <strong>7 ngày</strong> kể từ <strong>ngày mua</strong> của đúng dòng phiếu (theo cột ngày mua).</span>
</p>

<form action="${rlAction}" method="get" id="rlSearchForm">
    <input type="hidden" name="tab" value="${rlTab}"/>
    <input type="hidden" name="rlPage" value="1"/>

    <div class="rl-search-wrap">
        <span class="rl-icon">&#128269;</span>
        <input type="text" name="q" class="rl-search-input"
               placeholder="Serial, SKU, tên SP, khách, SĐT, email hoặc mã phiếu xuất…"
               value="${rlq}" autocomplete="off"/>
    </div>
    <div class="rl-search-actions">
        <button type="submit" class="rl-btn-search">&#128269; Tìm kiếm</button>
        <button type="button" class="rl-btn-reset" onclick="rlResetSearch()">&#8635; Đặt lại</button>
    </div>

    <div class="rl-toolbar-row">
        <label for="rlSortSel">Sắp xếp:</label>
        <select name="rlSort" id="rlSortSel" onchange="document.getElementById('rlSearchForm').submit()">
            <option value="serial" ${returnLookupSort == 'serial' ? 'selected' : ''}>Serial</option>
            <option value="sku" ${returnLookupSort == 'sku' ? 'selected' : ''}>SKU</option>
            <option value="purchase_date" ${returnLookupSort == 'purchase_date' || empty returnLookupSort ? 'selected' : ''}>Ngày mua</option>
        </select>
        <label for="rlPs" style="margin-left:12px;">Số dòng / trang</label>
        <input type="number" name="rlPageSize" id="rlPs" value="${returnLookupPageSize}" min="1" max="50"
               onchange="document.getElementById('rlSearchForm').submit()"/>
    </div>
</form>

<c:choose>
    <c:when test="${returnLookupHasFilter == false}">
        <p style="color:#64748b;">Nhập từ khóa rồi bấm <strong>Tìm kiếm</strong> để xem dòng bán hàng.</p>
    </c:when>
    <c:when test="${returnLookupResults != null && not empty returnLookupResults}">
        <p style="font-size:13px;color:#64748b;margin-bottom:10px;">
            <strong>${returnLookupTotal}</strong> kết quả
            <c:if test="${returnLookupPage != null && returnLookupTotalPages != null}">
                · Trang ${returnLookupPage} / ${returnLookupTotalPages}
            </c:if>
        </p>
        <div class="rl-table-wrap">
            <table class="rl-table">
                <thead>
                    <tr>
                        <th>Thiết bị / SKU</th>
                        <th>Serial</th>
                        <th>Khách</th>
                        <th>SL</th>
                        <th>Đơn giá</th>
                        <th>Ngày mua</th>
                        <th style="text-align:right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${returnLookupResults}" var="r">
                        <tr>
                            <td>
                                <div class="rl-prod-cell">
                                    <c:choose>
                                        <c:when test="${not empty r.imageUrl}">
                                            <img class="rl-prod-img" src="${r.imageUrl}" alt=""
                                                 onerror="this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%2248%22 height=%2248%22%3E%3Crect fill=%22%23f1f5f9%22 width=%2248%22 height=%2248%22/%3E%3C/svg%3E'"/>
                                        </c:when>
                                        <c:otherwise>
                                            <img class="rl-prod-img" src="data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%2248%22 height=%2248%22%3E%3Crect fill=%22%23f1f5f9%22 width=%2248%22 height=%2248%22/%3E%3C/svg%3E" alt=""/>
                                        </c:otherwise>
                                    </c:choose>
                                    <div>
                                        <div class="rl-prod-name"><c:out value="${r.productName}"/></div>
                                        <div class="rl-prod-sku">SKU: <c:out value="${r.productCode}"/></div>
                                    </div>
                                </div>
                            </td>
                            <td><span class="rl-serial"><c:out value="${r.serialNumber}"/></span></td>
                            <td>
                                <div style="font-weight:500;"><c:out value="${r.customerName}"/></div>
                                <div style="font-size:12px;color:#64748b;"><c:out value="${r.customerPhone}"/></div>
                            </td>
                            <td>${r.quantity}</td>
                            <td><fmt:formatNumber value="${r.unitPrice}" type="number" maxFractionDigits="0"/> đ</td>
                            <td>
                                ${r.purchaseDateVi}
                                <c:choose>
                                    <c:when test="${r.returnEligible}">
                                        <div style="font-size:11px;color:#15803d;margin-top:4px;">Còn hạn trả (≤7 ngày)</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div style="font-size:11px;color:#b91c1c;margin-top:4px;">Quá 7 ngày</div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align:right;">
                                <c:if test="${rlCanCreate}">
                                    <c:choose>
                                        <c:when test="${r.returnEligible}">
                                            <button type="button" class="rl-btn-create"
                                                    data-stock="<c:out value='${r.stockOutId}'/>"
                                                    data-sku="<c:out value='${r.productCode}'/>"
                                                    data-pname="<c:out value='${r.productName}'/>"
                                                    data-cname="<c:out value='${r.customerName}'/>"
                                                    data-cphone="<c:out value='${r.customerPhone}'/>"
                                                    data-cemail="<c:out value='${r.customerEmail}'/>"
                                                    data-qty="<c:out value='${r.quantity}'/>"
                                                    data-unit-price="${r.unitPrice}"
                                                    data-return-eligible="true"
                                                    data-default-request-type="return"
                                                    onclick="wlOpenModalRl(this)">Tạo yêu cầu trả</button>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="font-size:12px;color:#94a3b8;">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <div class="rl-pager">
            <c:if test="${returnLookupPage > 1}">
                <c:url var="rlPrev" value="${rlAction}">
                    <c:param name="tab" value="${rlTab}"/>
                    <c:param name="q" value="${rlq}"/>
                    <c:param name="rlSort" value="${returnLookupSort}"/>
                    <c:param name="rlPageSize" value="${returnLookupPageSize}"/>
                    <c:param name="rlPage" value="${returnLookupPage - 1}"/>
                </c:url>
                <a href="${rlPrev}">« Trang trước</a>
            </c:if>
            <c:if test="${returnLookupPage < returnLookupTotalPages}">
                <c:url var="rlNext" value="${rlAction}">
                    <c:param name="tab" value="${rlTab}"/>
                    <c:param name="q" value="${rlq}"/>
                    <c:param name="rlSort" value="${returnLookupSort}"/>
                    <c:param name="rlPageSize" value="${returnLookupPageSize}"/>
                    <c:param name="rlPage" value="${returnLookupPage + 1}"/>
                </c:url>
                <a href="${rlNext}">Trang sau »</a>
            </c:if>
        </div>
    </c:when>
    <c:otherwise>
        <p style="color:#64748b;">Không có kết quả phù hợp.</p>
    </c:otherwise>
</c:choose>

<div id="wlModalOverlayRl" class="wl-modal-overlay" aria-hidden="true">
    <div class="wl-modal" role="dialog" aria-modal="true" aria-labelledby="wlModalTitleRl">
        <div class="wl-modal-head">
            <h3 id="wlModalTitleRl">Tạo yêu cầu mới</h3>
            <button type="button" class="wl-modal-close" onclick="wlCloseModalRl()" aria-label="Đóng">&times;</button>
        </div>
        <form class="wl-modal-body" method="post" action="${rlModalSubmit}" id="wlModalFormRl">
            <input type="hidden" name="stockOutId" id="wlMStockRl"/>
            <input type="hidden" name="sku" id="wlMSkuRl"/>
            <c:if test="${rlModalEmbedSalesDash}">
                <input type="hidden" name="redirectTarget" value="dashboard"/>
            </c:if>

            <div class="wl-form-grid">
                <div class="wl-field">
                    <label>Loại yêu cầu</label>
                    <select name="requestType" id="wlMTypeRl" required>
                        <option value="warranty">Bảo hành</option>
                        <option value="return">Trả hàng</option>
                    </select>
                </div>
                <div class="wl-field">
                    <label>Mức ưu tiên</label>
                    <select name="priority" id="wlMPriorityRl">
                        <option value="medium" selected>Trung bình</option>
                        <option value="high">Cao</option>
                        <option value="low">Thấp</option>
                    </select>
                </div>
                <div class="wl-field wl-full">
                    <label>Tên khách hàng</label>
                    <input type="text" id="wlMCnameRl" readonly/>
                </div>
                <div class="wl-field wl-full">
                    <label>Số điện thoại</label>
                    <input type="text" id="wlMCphoneRl" readonly placeholder="—"/>
                </div>
                <div class="wl-field">
                    <label>Email</label>
                    <input type="text" id="wlMCemailRl" readonly placeholder="email@example.com"/>
                </div>
                <div class="wl-field">
                    <label>Mã đơn hàng</label>
                    <input type="text" id="wlMOrderRl" readonly placeholder="SO-XXXX"/>
                </div>
                <div class="wl-field">
                    <label>Sản phẩm</label>
                    <input type="text" id="wlMProductRl" readonly placeholder="Tên sản phẩm / SKU"/>
                </div>
                <div class="wl-field">
                    <label>Số lượng</label>
                    <input type="text" id="wlMQtyRl" readonly/>
                </div>
                <div class="wl-field wl-full">
                    <label>Mô tả lỗi / lý do (*)</label>
                    <textarea name="issueDescription" id="wlMIssueRl" required placeholder="Mô tả chi tiết vấn đề của sản phẩm..."></textarea>
                </div>
                <div class="wl-field" id="wlRefundFieldWrapRl">
                    <label>Số tiền hoàn (VNĐ)</label>
                    <input type="text" id="wlMRefundRl" readonly aria-describedby="wlRefundHintRl"/>
                    <div id="wlRefundHintRl" class="wl-refund-hint">Tính từ đơn giá × số lượng trên phiếu bán (chỉ áp dụng khi trả hàng).</div>
                </div>
                <div class="wl-field">
                    <label>Nhân viên xử lý</label>
                    <input type="text" id="wlMStaffRl" readonly value="<c:out value='${empty sessionScope.acc ? "" : (not empty sessionScope.acc.fullName ? sessionScope.acc.fullName : sessionScope.acc.username)}'/>"/>
                </div>
            </div>
            <div class="wl-modal-actions">
                <button type="button" class="wl-btn-cancel" onclick="wlCloseModalRl()">Hủy</button>
                <button type="submit" class="wl-btn-submit">&#10003; Tạo yêu cầu</button>
            </div>
        </form>
    </div>
</div>

<c:url var="rlResetBaseUrl" value="${rlAction}"><c:param name="tab" value="${rlTab}"/></c:url>
<script>
function rlResetSearch() {
    window.location.href = '<c:out value="${rlResetBaseUrl}"/>';
}
(function() {
    window.wlRefreshRefundDisplayRl = function() {
        var typeSel = document.getElementById('wlMTypeRl');
        var refundInp = document.getElementById('wlMRefundRl');
        var hint = document.getElementById('wlRefundHintRl');
        if (!refundInp || !typeSel) return;
        if (typeSel.value === 'return') {
            refundInp.value = window._wlLineRefundVndFmtRl || '0';
            refundInp.style.opacity = '1';
            if (hint) hint.style.display = '';
        } else {
            refundInp.value = '\u2014';
            refundInp.style.opacity = '0.85';
            if (hint) hint.textContent = 'Không áp dụng cho yêu cầu bảo hành.';
        }
    };
    window.wlOpenModalRl = function(btn) {
        document.getElementById('wlMStockRl').value = btn.getAttribute('data-stock') || '';
        document.getElementById('wlMSkuRl').value = btn.getAttribute('data-sku') || '';
        document.getElementById('wlMCnameRl').value = btn.getAttribute('data-cname') || '';
        document.getElementById('wlMCphoneRl').value = btn.getAttribute('data-cphone') || '';
        document.getElementById('wlMCemailRl').value = btn.getAttribute('data-cemail') || '';
        document.getElementById('wlMOrderRl').value = 'SO-' + (btn.getAttribute('data-stock') || '');
        var pn = btn.getAttribute('data-pname') || '';
        var sk = btn.getAttribute('data-sku') || '';
        document.getElementById('wlMProductRl').value = (pn && sk) ? (pn + ' / ' + sk) : (pn || sk || '');
        document.getElementById('wlMQtyRl').value = btn.getAttribute('data-qty') || '1';
        document.getElementById('wlMIssueRl').value = '';
        var up = parseFloat(btn.getAttribute('data-unit-price') || '0') || 0;
        var qty = parseInt(btn.getAttribute('data-qty') || '1', 10) || 1;
        window._wlLineRefundVndFmtRl = (Math.round(up * qty)).toLocaleString('vi-VN');
        var typeSel = document.getElementById('wlMTypeRl');
        var defReq = btn.getAttribute('data-default-request-type');
        if (typeSel && (defReq === 'return' || defReq === 'warranty')) {
            typeSel.value = defReq;
        }
        var retOk = btn.getAttribute('data-return-eligible') === 'true';
        var optRet = typeSel ? typeSel.querySelector('option[value="return"]') : null;
        if (optRet) {
            optRet.disabled = !retOk;
            if (!retOk && typeSel.value === 'return') {
                typeSel.value = 'warranty';
            }
        }
        var hint = document.getElementById('wlRefundHintRl');
        if (hint) hint.textContent = 'Tính từ đơn giá × số lượng trên phiếu bán (chỉ áp dụng khi trả hàng).';
        window.wlRefreshRefundDisplayRl();
        var ov = document.getElementById('wlModalOverlayRl');
        if (ov) {
            ov.classList.add('wl-open');
            ov.setAttribute('aria-hidden', 'false');
        }
    };
    window.wlCloseModalRl = function() {
        var ov = document.getElementById('wlModalOverlayRl');
        if (ov) {
            ov.classList.remove('wl-open');
            ov.setAttribute('aria-hidden', 'true');
        }
    };
    var wlOvRl = document.getElementById('wlModalOverlayRl');
    if (wlOvRl) {
        wlOvRl.addEventListener('click', function(e) {
            if (e.target === this) wlCloseModalRl();
        });
    }
    var wlTypeRl = document.getElementById('wlMTypeRl');
    if (wlTypeRl) {
        wlTypeRl.addEventListener('change', function() { window.wlRefreshRefundDisplayRl(); });
    }
})();
</script>
