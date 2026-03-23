<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c" %>
<%@taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<% request.setCharacterEncoding("UTF-8"); %>
<div class="box">
    <div class="box-header" style="display: flex; justify-content: space-between; align-items: center; padding: 15px 20px; background: #fcfcfc;">
        <h3 style="margin: 0;">👥 Danh sách khách hàng</h3>

        <div style="display: flex; gap: 8px;">
            <input type="text" id="customerSearchInput" 
                   placeholder="Nhập tên hoặc SĐT..." 
                   style="padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px; width: 200px; outline: none;">

            <button type="button" onclick="filterCustomers()" 
                    style="background: #3b82f6; color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer; font-weight: bold;">
                🔍 TÌM KIẾM
            </button>

            <button type="button" onclick="resetSearch()" 
                    style="background: #94a3b8; color: white; border: none; padding: 8px 12px; border-radius: 4px; cursor: pointer;">
                🔄
            </button>
        </div>
    </div>

    <div class="box-body">
        <table id="customerTable" style="width: 100%; border-collapse: collapse; font-size: 14px;">
            <thead>
                <tr style="background: #f8fafc; text-align: left;">
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Mã KH</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Tên khách hàng</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Số điện thoại</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Địa chỉ</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Công nợ</th>
                    <th style="padding: 12px; border-bottom: 2px solid #e2e8f0;">Thao tác</th>
                </tr>
            </thead>
            <tbody>
            <c:forEach items="${customerList}" var="c">
                <tr class="customer-row">
                    <td style="padding: 12px; border-bottom: 1px solid #eee;">#${c.customerId}</td>
                    <td class="cus-name" style="padding: 12px; border-bottom: 1px solid #eee;"><strong>${c.name}</strong></td>
                    <td class="cus-phone" style="padding: 12px; border-bottom: 1px solid #eee;">${c.phone}</td>
                    <td style="padding: 12px; border-bottom: 1px solid #eee;">${c.address}</td>
                    <td style="padding: 12px; border-bottom: 1px solid #eee; color: ${c.debt > 0 ? '#ef4444' : '#22c55e'}; font-weight: bold;">
                <fmt:formatNumber value="${c.debt}" type="number"/> đ
                </td>
                <td style="padding: 12px; border-bottom: 1px solid #eee;">
                    <a href="customer_detail?id=${c.customerId}" class="btn" 
                       style="background:#8b5cf6; color:white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-size:12px; display: inline-block;">
                        📜 Lịch sử
                    </a>
                </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<script>
    function filterCustomers() {
        const input = document.getElementById("customerSearchInput");
        const filter = input.value.toLowerCase().trim();
        const rows = document.getElementsByClassName("customer-row");

        for (let i = 0; i < rows.length; i++) {
            const name = rows[i].querySelector(".cus-name").innerText.toLowerCase();
            const phone = rows[i].querySelector(".cus-phone").innerText.toLowerCase();

            if (name.includes(filter) || phone.includes(filter)) {
                rows[i].style.display = "";
            } else {
                rows[i].style.display = "none";
            }
        }
    }

    function resetSearch() {
        document.getElementById("customerSearchInput").value = "";
        const rows = document.getElementsByClassName("customer-row");
        for (let i = 0; i < rows.length; i++) {
            rows[i].style.display = "";
        }
    }

// Thêm tính năng nhấn Enter cũng tìm được luôn
    document.getElementById("customerSearchInput").addEventListener("keypress", function (event) {
        if (event.key === "Enter") {
            event.preventDefault();
            filterCustomers();
        }
    });
</script>