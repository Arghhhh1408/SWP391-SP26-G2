<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    .wl-panel { background: #fff; color: #1e293b; }
    .wl-search-wrap {
        position: relative;
        margin-bottom: 12px;
    }
    .wl-search-wrap .wl-icon {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #94a3b8;
        font-size: 18px;
        pointer-events: none;
    }
    .wl-search-input {
        width: 100%;
        box-sizing: border-box;
        padding: 14px 16px 14px 44px;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        font-size: 15px;
        background: #fff;
    }
    .wl-search-input:focus {
        outline: none;
        border-color: #22c55e;
        box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.15);
    }
    .wl-search-actions {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 8px;
        margin-top: 10px;
    }
    .wl-btn-search {
        width: auto;
        padding: 6px 14px;
        background: #22c55e;
        color: #fff;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        font-size: 13px;
        line-height: 1.3;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
    }
    .wl-btn-search:hover { background: #16a34a; }
    .wl-btn-reset {
        width: auto;
        padding: 6px 12px;
        background: #fff;
        color: #64748b;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        cursor: pointer;
        font-size: 13px;
        line-height: 1.3;
    }
    .wl-btn-reset:hover {
        border-color: #cbd5e1;
        color: #475569;
        background: #f8fafc;
    }
    .wl-chips-label {
        font-size: 12px;
        font-weight: 700;
        color: #64748b;
        margin: 20px 0 8px;
        letter-spacing: 0.05em;
    }
    .wl-chips {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 16px;
    }
    .wl-chip {
        padding: 8px 14px;
        border-radius: 999px;
        border: 1px solid #e2e8f0;
        background: #fff;
        color: #475569;
        font-size: 13px;
        text-decoration: none;
        cursor: pointer;
    }
    .wl-chip.wl-chip-active {
        border-color: #22c55e;
        color: #15803d;
        background: #f0fdf4;
        font-weight: 600;
    }
    .wl-toolbar-row {
        display: flex;
        justify-content: flex-end;
        align-items: center;
        gap: 8px;
        margin-bottom: 16px;
    }
    .wl-toolbar-row label { font-size: 13px; color: #64748b; }
    .wl-toolbar-row select {
        padding: 8px 12px;
        border-radius: 8px;
        border: 1px solid #e2e8f0;
        background: #fff;
        font-size: 13px;
    }
    .wl-table-wrap { overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 12px; }
    .wl-table { width: 100%; border-collapse: collapse; font-size: 14px; background: #fff; }
    .wl-table th {
        text-align: left;
        padding: 12px 14px;
        background: #f8fafc;
        color: #475569;
        font-weight: 600;
        border-bottom: 1px solid #e2e8f0;
        white-space: nowrap;
    }
    .wl-table td {
        padding: 14px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
    }
    .wl-prod-cell { display: flex; align-items: center; gap: 12px; }
    .wl-prod-img {
        width: 48px; height: 48px; object-fit: contain;
        border-radius: 8px; background: #f8fafc; border: 1px solid #e2e8f0;
    }
    .wl-prod-name { font-weight: 600; color: #0f172a; }
    .wl-prod-sku { font-size: 12px; color: #64748b; margin-top: 2px; }
    .wl-serial {
        display: inline-block;
        padding: 6px 10px;
        border-radius: 8px;
        border: 1px solid #22c55e;
        color: #15803d;
        font-size: 13px;
        font-family: ui-monospace, monospace;
        background: #f0fdf4;
    }
    .wl-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        border-radius: 999px;
        font-size: 12px;
        font-weight: 700;
    }
    .wl-badge-expired { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
    .wl-badge-active { background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; }
    .wl-badge-expiring { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
    .wl-badge-processing { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
    .wl-btn-action {
        padding: 10px 16px;
        border-radius: 10px;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        border: none;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .wl-btn-create { background: #1e293b; color: #fff; }
    .wl-btn-create:hover { background: #334155; }
    .wl-btn-reject {
        background: #fff;
        color: #b91c1c;
        border: 1px solid #fecaca;
    }
    .wl-pager { display: flex; gap: 10px; margin-top: 16px; flex-wrap: wrap; }
    .wl-pager a {
        padding: 8px 14px;
        border-radius: 8px;
        border: 1px solid #e2e8f0;
        color: #334155;
        text-decoration: none;
        font-size: 13px;
    }
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

<c:set var="wlEmbed" value="${warrantyUiEmbed}"/>
<c:set var="wlSearchAction" value="${wlEmbed ? 'sales_dashboard' : 'sales-warranty-lookup'}"/>
<c:set var="wlSubmitAction" value="${pageContext.request.contextPath}/sales-warranty-submit"/>

<p class="wl-hint" style="font-size:13px;color:#64748b;margin-bottom:16px;">
    Nhập <strong>SKU</strong>, <strong>tên sản phẩm</strong>, hoặc <strong>SĐT khách hàng</strong>. Bảo hành <strong>12 tháng</strong> kể từ ngày bán.
    <br/><span style="color:#b45309;">Trả hàng: chỉ trong <strong>7 ngày</strong> kể từ ngày mua (mục &quot;Trả hàng&quot; trong form chỉ bật khi còn hạn).</span>
</p>

<form action="${wlSearchAction}" method="get" id="wlSearchForm">
    <c:if test="${wlEmbed}"><input type="hidden" name="tab" value="warranty-lookup"/></c:if>
    <input type="hidden" name="wf" value="${empty wf ? 'all' : wf}"/>
    <input type="hidden" name="page" value="1"/>

    <div class="wl-search-wrap">
        <span class="wl-icon">&#128269;</span>
        <input type="text" name="q" class="wl-search-input" placeholder="SKU, tên SP hoặc SĐT khách…"
               value="${q}" autocomplete="off"/>
    </div>
    <div class="wl-search-actions">
        <button type="submit" class="wl-btn-search">&#128269; Tìm kiếm</button>
        <button type="button" class="wl-btn-reset" onclick="wlResetSearch()">&#8635; Đặt lại</button>
    </div>

    <div class="wl-chips-label">TRẠNG THÁI</div>
    <div class="wl-chips">
        <c:url var="chipAll" value="${wlSearchAction}">
            <c:if test="${wlEmbed}"><c:param name="tab" value="warranty-lookup"/></c:if>
            <c:param name="q" value="${q}"/><c:param name="wf" value="all"/><c:param name="sort" value="${sort}"/><c:param name="pageSize" value="${warrantyPageSize}"/>
        </c:url>
        <c:url var="chipIn" value="${wlSearchAction}">
            <c:if test="${wlEmbed}"><c:param name="tab" value="warranty-lookup"/></c:if>
            <c:param name="q" value="${q}"/><c:param name="wf" value="in_warranty"/><c:param name="sort" value="${sort}"/><c:param name="pageSize" value="${warrantyPageSize}"/>
        </c:url>
        <c:url var="chipEx" value="${wlSearchAction}">
            <c:if test="${wlEmbed}"><c:param name="tab" value="warranty-lookup"/></c:if>
            <c:param name="q" value="${q}"/><c:param name="wf" value="expiring"/><c:param name="sort" value="${sort}"/><c:param name="pageSize" value="${warrantyPageSize}"/>
        </c:url>
        <c:url var="chipHd" value="${wlSearchAction}">
            <c:if test="${wlEmbed}"><c:param name="tab" value="warranty-lookup"/></c:if>
            <c:param name="q" value="${q}"/><c:param name="wf" value="expired"/><c:param name="sort" value="${sort}"/><c:param name="pageSize" value="${warrantyPageSize}"/>
        </c:url>
        <c:url var="chipPr" value="${wlSearchAction}">
            <c:if test="${wlEmbed}"><c:param name="tab" value="warranty-lookup"/></c:if>
            <c:param name="q" value="${q}"/><c:param name="wf" value="processing"/><c:param name="sort" value="${sort}"/><c:param name="pageSize" value="${warrantyPageSize}"/>
        </c:url>
        <a href="${chipAll}" class="wl-chip ${wf == 'all' || empty wf ? 'wl-chip-active' : ''}">Tất cả</a>
        <a href="${chipIn}" class="wl-chip ${wf == 'in_warranty' ? 'wl-chip-active' : ''}">Còn hạn</a>
        <a href="${chipEx}" class="wl-chip ${wf == 'expiring' ? 'wl-chip-active' : ''}">Sắp hết hạn</a>
        <a href="${chipHd}" class="wl-chip ${wf == 'expired' ? 'wl-chip-active' : ''}">Hết hạn</a>
        <a href="${chipPr}" class="wl-chip ${wf == 'processing' ? 'wl-chip-active' : ''}">Đang xử lý</a>
    </div>

    <div class="wl-toolbar-row">
        <label for="wlSort">Sắp xếp:</label>
        <select name="sort" id="wlSort" onchange="document.getElementById('wlSearchForm').submit()">
            <option value="serial" ${sort == 'serial' ? 'selected' : ''}>Serial</option>
            <option value="sku" ${sort == 'sku' ? 'selected' : ''}>SKU</option>
            <option value="purchase_date" ${sort == 'purchase_date' || empty sort ? 'selected' : ''}>Ngày mua</option>
        </select>
        <label for="wlPs" style="margin-left:12px;">/ trang</label>
        <input type="number" name="pageSize" id="wlPs" value="${warrantyPageSize}" min="1" max="50"
               style="width:56px;padding:8px;border-radius:8px;border:1px solid #e2e8f0;" onchange="document.getElementById('wlSearchForm').submit()"/>
    </div>
</form>

<c:if test="${not empty error}">
    <div style="color:#b42318;background:#fef3f2;border:1px solid #fecdca;padding:12px;border-radius:10px;margin-bottom:14px;">${error}</div>
</c:if>
<c:if test="${not empty lookupSuccess}">
    <div style="color:#0f5132;background:#d1e7dd;border:1px solid #badbcc;padding:12px;border-radius:10px;margin-bottom:14px;">${lookupSuccess}</div>
</c:if>
<c:if test="${not empty created}">
    <div style="color:#0f5132;background:#d1e7dd;border:1px solid #badbcc;padding:12px;border-radius:10px;margin-bottom:14px;">
        Đã tạo yêu cầu bảo hành: <strong>${created}</strong>
    </div>
</c:if>
<c:if test="${not empty returnCreated}">
    <div style="color:#0f5132;background:#d1e7dd;border:1px solid #badbcc;padding:12px;border-radius:10px;margin-bottom:14px;">
        Đã tạo yêu cầu trả hàng: <strong>${returnCreated}</strong>
    </div>
</c:if>

<c:choose>
    <c:when test="${warrantyHasFilter == false}">
        <p style="color:#64748b;">Nhập từ khóa hoặc chọn một trạng thái (khác &quot;Tất cả&quot;), rồi bấm <strong>Tìm kiếm</strong>.</p>
    </c:when>
    <c:when test="${warrantyResults != null && not empty warrantyResults}">
        <p style="font-size:13px;color:#64748b;margin-bottom:10px;">
            <strong>${warrantyTotal}</strong> kết quả
            <c:if test="${warrantyPage != null && warrantyTotalPages != null}"> · Trang ${warrantyPage} / ${warrantyTotalPages}</c:if>
        </p>
        <div class="wl-table-wrap">
            <table class="wl-table">
                <thead>
                    <tr>
                        <th>Thiết bị / SKU</th>
                        <th>Số serial</th>
                        <th>Ngày mua</th>
                        <th>Hạn bảo hành</th>
                        <th>Trạng thái</th>
                        <th style="text-align:right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${warrantyResults}" var="r">
                        <tr>
                            <td>
                                <div class="wl-prod-cell">
                                    <c:choose>
                                        <c:when test="${not empty r.imageUrl}">
                                            <img class="wl-prod-img" src="${r.imageUrl}" alt="" onerror="this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%2248%22 height=%2248%22%3E%3Crect fill=%22%23f1f5f9%22 width=%2248%22 height=%2248%22/%3E%3C/svg%3E'"/>
                                        </c:when>
                                        <c:otherwise>
                                            <img class="wl-prod-img" src="data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%2248%22 height=%2248%22%3E%3Crect fill=%22%23f1f5f9%22 width=%2248%22 height=%2248%22/%3E%3C/svg%3E" alt=""/>
                                        </c:otherwise>
                                    </c:choose>
                                    <div>
                                        <div class="wl-prod-name"><c:out value="${r.productName}"/></div>
                                        <div class="wl-prod-sku">SKU: <c:out value="${r.productCode}"/></div>
                                    </div>
                                </div>
                            </td>
                            <td><span class="wl-serial"><c:out value="${r.serialNumber}"/></span></td>
                            <td>${r.purchaseDateVi}</td>
                            <td>${r.warrantyEndDateVi}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.uiStatus == 'PROCESSING'}">
                                        <span class="wl-badge wl-badge-processing">&#8987; Đang xử lý</span>
                                    </c:when>
                                    <c:when test="${r.uiStatus == 'EXPIRED'}">
                                        <span class="wl-badge wl-badge-expired">&#10007; Hết hạn</span>
                                    </c:when>
                                    <c:when test="${r.uiStatus == 'EXPIRING_SOON'}">
                                        <span class="wl-badge wl-badge-expiring">&#9888; Sắp hết hạn</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="wl-badge wl-badge-active">&#10003; Còn hạn</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align:right;">
                                <c:if test="${r.inWarranty}">
                                    <button type="button" class="wl-btn-action wl-btn-create"
                                            data-stock="<c:out value='${r.stockOutId}'/>"
                                            data-sku="<c:out value='${r.productCode}'/>"
                                            data-pname="<c:out value='${r.productName}'/>"
                                            data-cname="<c:out value='${r.customerName}'/>"
                                            data-cphone="<c:out value='${r.customerPhone}'/>"
                                            data-cemail="<c:out value='${r.customerEmail}'/>"
                                            data-qty="<c:out value='${r.quantity}'/>"
                                            data-unit-price="${r.unitPrice}"
                                            data-return-eligible="${r.returnEligible}"
                                            onclick="wlOpenModal(this)">Tạo bảo hành &#8594;</button>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <div class="wl-pager">
            <c:if test="${warrantyPage > 1}">
                <c:url var="wlPrev" value="${wlSearchAction}">
                    <c:if test="${wlEmbed}"><c:param name="tab" value="warranty-lookup"/></c:if>
                    <c:param name="q" value="${q}"/><c:param name="wf" value="${wf}"/><c:param name="sort" value="${sort}"/>
                    <c:param name="pageSize" value="${warrantyPageSize}"/><c:param name="page" value="${warrantyPage - 1}"/>
                </c:url>
                <a href="${wlPrev}">« Trang trước</a>
            </c:if>
            <c:if test="${warrantyPage < warrantyTotalPages}">
                <c:url var="wlNext" value="${wlSearchAction}">
                    <c:if test="${wlEmbed}"><c:param name="tab" value="warranty-lookup"/></c:if>
                    <c:param name="q" value="${q}"/><c:param name="wf" value="${wf}"/><c:param name="sort" value="${sort}"/>
                    <c:param name="pageSize" value="${warrantyPageSize}"/><c:param name="page" value="${warrantyPage + 1}"/>
                </c:url>
                <a href="${wlNext}">Trang sau »</a>
            </c:if>
        </div>
    </c:when>
    <c:otherwise>
        <p style="color:#64748b;">Không có kết quả phù hợp.</p>
    </c:otherwise>
</c:choose>

<div style="margin-top:20px;">
    <a class="btn" style="background:#0f766e;color:#fff;text-decoration:none;padding:8px 14px;border-radius:8px;"
       href="${wlEmbed ? 'sales_dashboard?tab=warranty-lookup&showClaims=1' : 'sales-warranty-lookup?showClaims=1'}">Xem yêu cầu bảo hành đang xử lý</a>
</div>

<c:if test="${showInProgressClaims}">
    <div style="margin-top:24px;">
        <h4 style="margin-bottom:10px;">Yêu cầu bảo hành của bạn</h4>
        <c:choose>
            <c:when test="${inProgressClaims != null && not empty inProgressClaims}">
                <table class="wl-table">
                    <thead><tr><th>Mã</th><th>SKU</th><th>Sản phẩm</th><th>Trạng thái</th></tr></thead>
                    <tbody>
                        <c:forEach items="${inProgressClaims}" var="c">
                            <tr>
                                <td>${c.claimCode}</td>
                                <td>${c.sku}</td>
                                <td>${c.productName}</td>
                                <td>${c.statusLabelVi}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <p style="color:#64748b;">Chưa có yêu cầu đang xử lý.</p>
            </c:otherwise>
        </c:choose>
    </div>
</c:if>

<div id="wlModalOverlay" class="wl-modal-overlay" aria-hidden="true">
    <div class="wl-modal" role="dialog" aria-modal="true" aria-labelledby="wlModalTitle">
        <div class="wl-modal-head">
            <h3 id="wlModalTitle">Tạo yêu cầu mới</h3>
            <button type="button" class="wl-modal-close" onclick="wlCloseModal()" aria-label="Đóng">&times;</button>
        </div>
        <form class="wl-modal-body" method="post" action="${wlSubmitAction}" id="wlModalForm">
            <input type="hidden" name="stockOutId" id="wlMStock"/>
            <input type="hidden" name="sku" id="wlMSku"/>
            <c:if test="${wlEmbed}">
                <input type="hidden" name="redirectTarget" value="dashboard"/>
            </c:if>

            <div class="wl-form-grid">
                <div class="wl-field">
                    <label>Loại yêu cầu</label>
                    <select name="requestType" id="wlMType" required>
                        <option value="warranty">Bảo hành</option>
                        <option value="return">Trả hàng</option>
                    </select>
                </div>
                <div class="wl-field">
                    <label>Mức ưu tiên</label>
                    <select name="priority" id="wlMPriority">
                        <option value="medium" selected>Trung bình</option>
                        <option value="high">Cao</option>
                        <option value="low">Thấp</option>
                    </select>
                </div>
                <div class="wl-field wl-full">
                    <label>Tên khách hàng</label>
                    <input type="text" id="wlMCname" readonly/>
                </div>
                <div class="wl-field wl-full">
                    <label>Số điện thoại</label>
                    <input type="text" id="wlMCphone" readonly placeholder="—"/>
                </div>
                <div class="wl-field">
                    <label>Email</label>
                    <input type="text" id="wlMCemail" readonly placeholder="email@example.com"/>
                </div>
                <div class="wl-field">
                    <label>Mã đơn hàng</label>
                    <input type="text" id="wlMOrder" readonly placeholder="SO-XXXX"/>
                </div>
                <div class="wl-field">
                    <label>Sản phẩm</label>
                    <input type="text" id="wlMProduct" readonly placeholder="Tên sản phẩm / SKU"/>
                </div>
                <div class="wl-field">
                    <label>Số lượng</label>
                    <input type="text" id="wlMQty" readonly/>
                </div>
                <div class="wl-field wl-full">
                    <label>Mô tả lỗi / lý do (*)</label>
                    <textarea name="issueDescription" id="wlMIssue" required placeholder="Mô tả chi tiết vấn đề của sản phẩm..."></textarea>
                </div>
                <div class="wl-field" id="wlRefundFieldWrap">
                    <label>Số tiền hoàn (VNĐ)</label>
                    <input type="text" id="wlMRefund" readonly aria-describedby="wlRefundHint"/>
                    <div id="wlRefundHint" class="wl-refund-hint">Tính từ đơn giá × số lượng trên phiếu bán (chỉ áp dụng khi trả hàng).</div>
                </div>
                <div class="wl-field">
                    <label>Nhân viên xử lý</label>
                    <input type="text" id="wlMStaff" readonly value="<c:out value='${empty sessionScope.acc ? "" : (not empty sessionScope.acc.fullName ? sessionScope.acc.fullName : sessionScope.acc.username)}'/>"/>
                </div>
            </div>
            <div class="wl-modal-actions">
                <button type="button" class="wl-btn-cancel" onclick="wlCloseModal()">Hủy</button>
                <button type="submit" class="wl-btn-submit">&#10003; Tạo yêu cầu</button>
            </div>
        </form>
    </div>
</div>

<script>
(function() {
    window.wlResetSearch = function() {
        var wlDash = <c:choose><c:when test="${wlEmbed}">true</c:when><c:otherwise>false</c:otherwise></c:choose>;
    var base = wlDash ? 'sales_dashboard?tab=warranty-lookup' : 'sales-warranty-lookup';
        window.location.href = base;
    };
    window.wlRefreshRefundDisplay = function() {
        var typeSel = document.getElementById('wlMType');
        var refundInp = document.getElementById('wlMRefund');
        var hint = document.getElementById('wlRefundHint');
        if (!refundInp || !typeSel) return;
        if (typeSel.value === 'return') {
            refundInp.value = window._wlLineRefundVndFmt || '0';
            refundInp.style.opacity = '1';
            if (hint) hint.style.display = '';
        } else {
            refundInp.value = '—';
            refundInp.style.opacity = '0.85';
            if (hint) hint.textContent = 'Không áp dụng cho yêu cầu bảo hành.';
        }
    };
    window.wlOpenModal = function(btn) {
        document.getElementById('wlMStock').value = btn.getAttribute('data-stock') || '';
        document.getElementById('wlMSku').value = btn.getAttribute('data-sku') || '';
        document.getElementById('wlMCname').value = btn.getAttribute('data-cname') || '';
        document.getElementById('wlMCphone').value = btn.getAttribute('data-cphone') || '';
        document.getElementById('wlMCemail').value = btn.getAttribute('data-cemail') || '';
        document.getElementById('wlMOrder').value = 'SO-' + (btn.getAttribute('data-stock') || '');
        var pn = btn.getAttribute('data-pname') || '';
        var sk = btn.getAttribute('data-sku') || '';
        document.getElementById('wlMProduct').value = (pn && sk) ? (pn + ' / ' + sk) : (pn || sk || '');
        document.getElementById('wlMQty').value = btn.getAttribute('data-qty') || '1';
        document.getElementById('wlMIssue').value = '';
        var up = parseFloat(btn.getAttribute('data-unit-price') || '0') || 0;
        var qty = parseInt(btn.getAttribute('data-qty') || '1', 10) || 1;
        var totalVnd = Math.round(up * qty);
        window._wlLineRefundVndFmt = totalVnd.toLocaleString('vi-VN');
        var typeSel = document.getElementById('wlMType');
        var retOk = btn.getAttribute('data-return-eligible') === 'true';
        var optRet = typeSel ? typeSel.querySelector('option[value=\"return\"]') : null;
        if (optRet) {
            optRet.disabled = !retOk;
            if (!retOk && typeSel.value === 'return') {
                typeSel.value = 'warranty';
            }
        }
        var hint = document.getElementById('wlRefundHint');
        if (hint) hint.textContent = 'Tính từ đơn giá × số lượng trên phiếu bán (chỉ áp dụng khi trả hàng).';
        window.wlRefreshRefundDisplay();
        document.getElementById('wlModalOverlay').classList.add('wl-open');
        document.getElementById('wlModalOverlay').setAttribute('aria-hidden', 'false');
    };
    window.wlCloseModal = function() {
        document.getElementById('wlModalOverlay').classList.remove('wl-open');
        document.getElementById('wlModalOverlay').setAttribute('aria-hidden', 'true');
    };
    var wlOv = document.getElementById('wlModalOverlay');
    if (wlOv) {
        wlOv.addEventListener('click', function(e) {
            if (e.target === this) wlCloseModal();
        });
    }
    var wlTypeEl = document.getElementById('wlMType');
    if (wlTypeEl) {
        wlTypeEl.addEventListener('change', function() { window.wlRefreshRefundDisplay(); });
    }
})();
</script>
