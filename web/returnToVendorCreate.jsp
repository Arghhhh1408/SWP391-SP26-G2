<%-- 
    Document   : returnToVendorCreate
    Created on : 25 thg 3, 2026, 04:46:00
    Author     : dotha
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Create Return To Vendor</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #f4f6f9;
                margin: 0;
                padding: 24px;
            }
            .container {
                max-width: 1250px;
                margin: auto;
            }
            .card {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 4px 18px rgba(0,0,0,0.08);
                padding: 24px;
                margin-bottom: 20px;
            }
            h2, h3 {
                margin-top: 0;
                color: #1f2937;
            }
            .row {
                display: flex;
                gap: 16px;
                flex-wrap: wrap;
            }
            .col {
                flex: 1;
                min-width: 280px;
            }
            label {
                display: block;
                font-weight: bold;
                margin-bottom: 6px;
            }
            input, select, textarea {
                width: 100%;
                box-sizing: border-box;
                padding: 10px;
                border: 1px solid #d1d5db;
                border-radius: 10px;
            }
            textarea {
                resize: vertical;
                min-height: 90px;
            }
            .btn {
                padding: 10px 16px;
                border: none;
                border-radius: 10px;
                cursor: pointer;
                color: white;
                font-weight: bold;
            }
            .btn-primary {
                background: #2563eb;
            }
            .btn-danger {
                background: #dc2626;
            }
            .btn-success {
                background: #16a34a;
            }
            .btn-secondary {
                background: #6b7280;
            }
            .toolbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
                flex-wrap: wrap;
                gap: 12px;
            }
            .lookup-box {
                position: relative;
            }
            .lookup-popup {
                position: absolute;
                z-index: 1000;
                width: 100%;
                background: #fff;
                border: 1px solid #d1d5db;
                border-radius: 12px;
                box-shadow: 0 6px 20px rgba(0,0,0,0.12);
                margin-top: 6px;
                padding: 10px;
                display: none;
            }
            .lookup-popup input[type="text"] {
                margin-bottom: 10px;
            }
            .lookup-list {
                max-height: 240px;
                overflow: hidden;
            }
            .lookup-item {
                padding: 10px;
                border-radius: 8px;
                cursor: pointer;
            }
            .lookup-item:hover {
                background: #eff6ff;
            }
            .pager {
                display: flex;
                justify-content: space-between;
                margin-top: 10px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            table th, table td {
                border: 1px solid #e5e7eb;
                padding: 10px;
                text-align: center;
                vertical-align: middle;
            }
            thead {
                background: #111827;
                color: white;
            }
            .error {
                color: #b91c1c;
                margin-bottom: 10px;
            }
            .readonly {
                background: #f3f4f6;
            }
        </style>
    </head>
    <body>
        <div class="container">

            <div class="toolbar">
                <h2>Create Return To Vendor</h2>
                <a href="return-to-vendor" class="btn btn-secondary" style="text-decoration:none;">Back to list</a>
            </div>

            <% if (request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
            <% } %>

            <form action="return-to-vendor" method="post" id="returnToVendorForm" onsubmit="return validateReturnToVendorForm()">
                <input type="hidden" name="action" value="create"/>

                <div class="card">
                    <div class="row">
                        <div class="col">
                            <label>Supplier</label>
                            <div class="lookup-box">
                                <input type="hidden" name="supplierID" id="supplierID" required>
                                <input type="text" id="supplierDisplay" placeholder="Click to choose supplier" readonly onclick="openSupplierLookup()">
                                <div class="lookup-popup" id="supplierPopup">
                                    <input type="text" id="supplierSearch" placeholder="Search supplier..." onkeyup="loadSuppliers(1)">
                                    <div class="lookup-list" id="supplierList"></div>
                                    <div class="pager">
                                        <button type="button" onclick="prevSupplierPage()">Prev</button>
                                        <button type="button" onclick="nextSupplierPage()">Next</button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col">
                            <label>Settlement Type</label>
                            <select name="settlementType">
                                <option value="OFFSET_DEBT">OFFSET_DEBT - Cấn trừ công nợ</option>
                                <option value="REFUND">REFUND - Hoàn tiền</option>
                                <option value="REPLACEMENT">REPLACEMENT - Đổi hàng</option>
                            </select>
                        </div>

                        <div class="col">
                            <label>Reason</label>
                            <input type="text" name="reason" required>
                        </div>
                    </div>

                    <div class="row" style="margin-top:16px;">
                        <div class="col">
                            <label>Note</label>
                            <textarea name="note"></textarea>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                        <h3>Return Items</h3>
                        <button type="button" class="btn btn-success" onclick="addRow()">Add Row</button>
                    </div>

                    <table>
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>StockIn Detail</th>
                                <th>Available Qty</th>
                                <th>Quantity</th>
                                <th>UnitCost</th>
                                <th>Line Total</th>
                                <th>Reason Detail</th>
                                <th>Condition</th>
                                <th>Remove</th>
                            </tr>
                        </thead>
                        <tbody id="detailBody"></tbody>
                    </table>

                    <div style="text-align:right; margin-top:16px;">
                        <strong>Total Amount: </strong>
                        <span id="grandTotal">0</span>
                    </div>

                    <div style="margin-top:20px;">
                        <button type="submit" class="btn btn-primary">Create Return To Vendor</button>
                    </div>
                </div>
            </form>
        </div>

        <script>
            const contextPath = "<%= request.getContextPath() %>";
            let supplierPage = 1;
            const productPages = {};
            const detailPages = {};
            let rowIndex = 0;

            function openSupplierLookup() {
                const popup = document.getElementById("supplierPopup");
                if (!popup) {
                    return;
                }
                popup.style.display = "block";
                loadSuppliers(1);
            }

            function loadSuppliers(page) {
                supplierPage = page < 1 ? 1 : page;
                const keyword = document.getElementById("supplierSearch").value || "";

                fetch(contextPath + "/rtv-lookup?type=supplier&keyword=" + encodeURIComponent(keyword) + "&page=" + supplierPage)
                        .then(res => res.text())
                        .then(html => {
                            document.getElementById("supplierList").innerHTML = html;
                        })
                        .catch(err => {
                            console.error("Load supplier error:", err);
                        });
            }

            function prevSupplierPage() {
                if (supplierPage > 1) {
                    loadSuppliers(supplierPage - 1);
                }
            }

            function nextSupplierPage() {
                loadSuppliers(supplierPage + 1);
            }

            function clearRowSelection(idx) {
                const fields = [
                    ["productID_", ""],
                    ["productDisplay_", ""],
                    ["stockInDetailID_", ""],
                    ["detailDisplay_", ""],
                    ["availableQty_", ""],
                    ["quantity_", ""],
                    ["unitCost_", ""],
                    ["lineTotal_", ""]
                ];

                fields.forEach(([prefix, value]) => {
                    const el = document.getElementById(prefix + idx);
                    if (el) {
                        el.value = value;
                    }
                });
            }

            function selectSupplier(id, name) {
                document.getElementById("supplierID").value = id;
                document.getElementById("supplierDisplay").value = id + " - " + name;
                document.getElementById("supplierPopup").style.display = "none";

                document.querySelectorAll("[id^='productID_']").forEach(input => {
                    const idx = input.id.replace("productID_", "");
                    clearRowSelection(idx);
                });

                document.querySelectorAll("[id^='productPopup_'], [id^='detailPopup_']").forEach(p => p.style.display = "none");
                calculateGrandTotal();
            }

            function addRow() {
                const tbody = document.getElementById("detailBody");
                const idx = rowIndex++;

                const tr = document.createElement("tr");
                tr.innerHTML = ''
                        + '<td>'
                        + '  <div class="lookup-box">'
                        + '    <input type="hidden" name="productID" id="productID_' + idx + '">'
                        + '    <input type="text" id="productDisplay_' + idx + '" placeholder="Choose product" readonly onclick="openProductLookup(' + idx + ')">'
                        + '    <div class="lookup-popup" id="productPopup_' + idx + '">'
                        + '      <input type="text" id="productSearch_' + idx + '" placeholder="Search product..." onkeyup="loadProducts(' + idx + ', 1)">'
                        + '      <div class="lookup-list" id="productList_' + idx + '"></div>'
                        + '      <div class="pager">'
                        + '        <button type="button" onclick="prevProductPage(' + idx + ')">Prev</button>'
                        + '        <button type="button" onclick="nextProductPage(' + idx + ')">Next</button>'
                        + '      </div>'
                        + '    </div>'
                        + '  </div>'
                        + '</td>'

                        + '<td>'
                        + '  <div class="lookup-box">'
                        + '    <input type="hidden" name="stockInDetailID" id="stockInDetailID_' + idx + '">'
                        + '    <input type="text" id="detailDisplay_' + idx + '" placeholder="Choose stock in detail" readonly onclick="openDetailLookup(' + idx + ')">'
                        + '    <div class="lookup-popup" id="detailPopup_' + idx + '">'
                        + '      <input type="text" id="detailSearch_' + idx + '" placeholder="Search detail..." onkeyup="loadDetails(' + idx + ', 1)">'
                        + '      <div class="lookup-list" id="detailList_' + idx + '"></div>'
                        + '      <div class="pager">'
                        + '        <button type="button" onclick="prevDetailPage(' + idx + ')">Prev</button>'
                        + '        <button type="button" onclick="nextDetailPage(' + idx + ')">Next</button>'
                        + '      </div>'
                        + '    </div>'
                        + '  </div>'
                        + '</td>'

                        + '<td><input type="number" id="availableQty_' + idx + '" class="readonly" readonly></td>'
                        + '<td><input type="number" name="quantity" id="quantity_' + idx + '" min="1" oninput="calculateLineTotal(' + idx + ')"></td>'
                        + '<td><input type="number" id="unitCost_' + idx + '" class="readonly" readonly></td>'
                        + '<td><input type="number" id="lineTotal_' + idx + '" class="readonly" readonly></td>'
                        + '<td><input type="text" name="reasonDetail"></td>'
                        + '<td>'
                        + '  <select name="itemCondition">'
                        + '    <option value="Damaged">Damaged</option>'
                        + '    <option value="Defective">Defective</option>'
                        + '    <option value="Wrong Item">Wrong Item</option>'
                        + '    <option value="Expired">Expired</option>'
                        + '    <option value="Other">Other</option>'
                        + '  </select>'
                        + '</td>'
                        + '<td><button type="button" class="btn btn-danger" onclick="removeRow(this)">X</button></td>';

                tbody.appendChild(tr);
            }

            function removeRow(btn) {
                const tr = btn.closest("tr");
                if (tr) {
                    tr.remove();
                }
                calculateGrandTotal();
            }

            function openProductLookup(idx) {
                const supplierID = document.getElementById("supplierID").value;
                if (!supplierID) {
                    alert("Please select supplier first.");
                    openSupplierLookup();
                    return;
                }

                const popup = document.getElementById("productPopup_" + idx);
                if (!popup) {
                    return;
                }

                popup.style.display = "block";
                loadProducts(idx, 1);
            }

            function loadProducts(idx, page) {
                productPages[idx] = page < 1 ? 1 : page;

                const supplierID = document.getElementById("supplierID").value;
                const searchInput = document.getElementById("productSearch_" + idx);
                const keyword = searchInput ? searchInput.value : "";

                const url = contextPath + "/rtv-lookup?type=product&supplierID="
                        + supplierID + "&keyword=" + encodeURIComponent(keyword) + "&page=" + productPages[idx];

                fetch(url)
                        .then(res => res.text())
                        .then(html => {
                            html = html.split("CURRENT_ROW_INDEX").join(String(idx));
                            const listBox = document.getElementById("productList_" + idx);
                            if (listBox) {
                                listBox.innerHTML = html;
                            }
                        })
                        .catch(err => {
                            console.error("loadProducts error =", err);
                        });
            }

            function prevProductPage(idx) {
                const page = productPages[idx] || 1;
                if (page > 1) {
                    loadProducts(idx, page - 1);
                }
            }

            function nextProductPage(idx) {
                const page = productPages[idx] || 1;
                loadProducts(idx, page + 1);
            }

            function selectProduct(idx, productID, productName) {
                const productIDInput = document.getElementById("productID_" + idx);
                const productDisplayInput = document.getElementById("productDisplay_" + idx);
                const productPopup = document.getElementById("productPopup_" + idx);

                if (!productIDInput || !productDisplayInput || !productPopup) {
                    return;
                }

                productIDInput.value = productID;
                productDisplayInput.value = productID + " - " + productName;
                productPopup.style.display = "none";

                const quantityInput = document.getElementById("quantity_" + idx);
                clearRowSelection(idx);
                productIDInput.value = productID;
                productDisplayInput.value = productID + " - " + productName;
                if (quantityInput) {
                    quantityInput.value = "";
                }
                calculateGrandTotal();
            }

            function openDetailLookup(idx) {
                const supplierID = document.getElementById("supplierID").value;
                const productID = document.getElementById("productID_" + idx).value;

                if (!supplierID || !productID) {
                    alert("Please select supplier and product first.");
                    return;
                }

                const popup = document.getElementById("detailPopup_" + idx);
                if (!popup) {
                    return;
                }

                popup.style.display = "block";
                loadDetails(idx, 1);
            }

            function loadDetails(idx, page) {
                detailPages[idx] = page < 1 ? 1 : page;

                const supplierID = document.getElementById("supplierID").value;
                const productID = document.getElementById("productID_" + idx).value;
                const searchInput = document.getElementById("detailSearch_" + idx);
                const keyword = searchInput ? searchInput.value : "";

                const url = contextPath + "/rtv-lookup?type=detail"
                        + "&supplierID=" + supplierID
                        + "&productID=" + productID
                        + "&keyword=" + encodeURIComponent(keyword)
                        + "&page=" + detailPages[idx];

                fetch(url)
                        .then(res => res.text())
                        .then(html => {
                            html = html.split("CURRENT_ROW_INDEX").join(String(idx));
                            const listBox = document.getElementById("detailList_" + idx);
                            if (listBox) {
                                listBox.innerHTML = html;
                            }
                        })
                        .catch(err => {
                            console.error("loadDetails error =", err);
                        });
            }

            function prevDetailPage(idx) {
                const page = detailPages[idx] || 1;
                if (page > 1) {
                    loadDetails(idx, page - 1);
                }
            }

            function nextDetailPage(idx) {
                const page = detailPages[idx] || 1;
                loadDetails(idx, page + 1);
            }

            function selectDetail(idx, stockInDetailID, stockInID, productID, remainingQuantity, unitCost) {
                if (isDetailAlreadyUsed(stockInDetailID, idx)) {
                    alert("This StockIn Detail has already been selected in another row.");
                    return;
                }

                document.getElementById("stockInDetailID_" + idx).value = stockInDetailID;
                document.getElementById("detailDisplay_" + idx).value = "StockInDetail " + stockInDetailID + " - StockIn " + stockInID;
                document.getElementById("availableQty_" + idx).value = remainingQuantity;
                document.getElementById("unitCost_" + idx).value = unitCost;
                document.getElementById("detailPopup_" + idx).style.display = "none";

                const quantityInput = document.getElementById("quantity_" + idx);
                if (quantityInput && quantityInput.value) {
                    calculateLineTotal(idx);
                } else {
                    document.getElementById("lineTotal_" + idx).value = "";
                    calculateGrandTotal();
                }
            }

            function isDetailAlreadyUsed(stockInDetailID, currentIdx) {
                const inputs = document.querySelectorAll("[id^='stockInDetailID_']");
                for (let input of inputs) {
                    if (input.id !== "stockInDetailID_" + currentIdx && input.value === String(stockInDetailID)) {
                        return true;
                    }
                }
                return false;
            }

            function calculateLineTotal(idx) {
                const stockInDetailID = document.getElementById("stockInDetailID_" + idx).value;
                const qtyInput = document.getElementById("quantity_" + idx);
                const lineTotalInput = document.getElementById("lineTotal_" + idx);
                const qty = parseFloat(qtyInput.value || 0);
                const unitCost = parseFloat(document.getElementById("unitCost_" + idx).value || 0);
                const availableQty = parseFloat(document.getElementById("availableQty_" + idx).value || 0);

                if (!stockInDetailID) {
                    if (qtyInput.value !== "") {
                        alert("Please choose StockIn Detail first.");
                    }
                    qtyInput.value = "";
                    lineTotalInput.value = "";
                    calculateGrandTotal();
                    return;
                }

                if (qty <= 0) {
                    lineTotalInput.value = "";
                    calculateGrandTotal();
                    return;
                }

                if (availableQty <= 0) {
                    alert("This StockIn Detail has no remaining quantity to return.");
                    qtyInput.value = "";
                    lineTotalInput.value = "";
                    calculateGrandTotal();
                    return;
                }

                if (qty > availableQty) {
                    alert("Quantity cannot exceed available quantity (" + availableQty + ").");
                    qtyInput.value = "";
                    lineTotalInput.value = "";
                    calculateGrandTotal();
                    return;
                }

                lineTotalInput.value = (qty * unitCost).toFixed(2);
                calculateGrandTotal();
            }

            function calculateGrandTotal() {
                let total = 0;
                document.querySelectorAll("[id^='lineTotal_']").forEach(input => {
                    total += parseFloat(input.value || 0);
                });
                document.getElementById("grandTotal").innerText = total.toLocaleString(undefined, {
                    minimumFractionDigits: 0,
                    maximumFractionDigits: 2
                });
            }

            function validateReturnToVendorForm() {
                const supplierID = document.getElementById("supplierID").value;
                if (!supplierID) {
                    alert("Please select supplier first.");
                    openSupplierLookup();
                    return false;
                }

                let validRowCount = 0;
                for (let idx = 0; idx < rowIndex; idx++) {
                    const productInput = document.getElementById("productID_" + idx);
                    const detailInput = document.getElementById("stockInDetailID_" + idx);
                    const quantityInput = document.getElementById("quantity_" + idx);
                    const availableQtyInput = document.getElementById("availableQty_" + idx);

                    if (!productInput || !detailInput || !quantityInput || !availableQtyInput) {
                        continue;
                    }

                    const hasAnyValue = Boolean(productInput.value || detailInput.value || quantityInput.value);
                    if (!hasAnyValue) {
                        continue;
                    }

                    validRowCount++;

                    if (!productInput.value) {
                        alert("Please select product for every used row.");
                        return false;
                    }

                    if (!detailInput.value) {
                        alert("Please select StockIn Detail for every used row.");
                        return false;
                    }

                    const qty = parseFloat(quantityInput.value || 0);
                    const availableQty = parseFloat(availableQtyInput.value || 0);

                    if (!quantityInput.value || qty <= 0) {
                        alert("Please enter a valid return quantity.");
                        return false;
                    }

                    if (qty > availableQty) {
                        alert("Return quantity cannot exceed available quantity.");
                        return false;
                    }
                }

                if (validRowCount === 0) {
                    alert("Please add at least one return item.");
                    return false;
                }

                return true;
            }

            document.addEventListener("click", function (e) {
                if (!e.target.closest(".lookup-box")) {
                    document.querySelectorAll(".lookup-popup").forEach(p => p.style.display = "none");
                }
            });

            addRow();
        </script>
    </body>
</html>