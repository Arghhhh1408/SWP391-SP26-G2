<%-- 
    Document   : returnToVendorDetail
    Created on : 25 thg 3, 2026, 04:47:25
    Author     : dotha
--%>

<%@ page import="model.ReturnToVendor" %>
<%@ page import="model.ReturnToVendorDetail" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Return To Vendor Detail</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 24px;
                background: #f4f6f9;
            }
            .container {
                max-width: 1200px;
                margin: auto;
            }
            .card {
                border: 1px solid #ddd;
                background: #fff;
                border-radius: 14px;
                padding: 18px;
                margin-bottom: 20px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                background: white;
            }
            table, th, td {
                border: 1px solid #ddd;
            }
            th, td {
                padding: 10px;
                text-align: center;
            }
            .btn {
                padding: 10px 14px;
                border: none;
                cursor: pointer;
                border-radius: 10px;
                color: white;
            }
            .approve {
                background: #16a34a;
            }
            .reject {
                background: #dc2626;
            }
            .complete {
                background: #2563eb;
            }
            .back {
                background: #6b7280;
                color: white;
                text-decoration: none;
                padding: 10px 14px;
                border-radius: 10px;
                display: inline-block;
                margin-bottom: 20px;
            }
            .msg {
                color: green;
                margin-bottom: 12px;
            }
            .error {
                color: red;
                margin-bottom: 12px;
            }
            textarea {
                width: 320px;
                height: 80px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <a class="back" href="return-to-vendor">Back to list</a>

            <%
                ReturnToVendor rtv = (ReturnToVendor) request.getAttribute("rtv");
                String msg = request.getParameter("msg");
                String error = request.getParameter("error");
            %>

            <% if (msg != null) { %>
            <div class="msg">Success: <%= msg %></div>
            <% } %>

            <% if (error != null) { %>
            <div class="error">Error: <%= error %></div>
            <% } %>

            <% if (rtv != null) { %>
            <div class="card">
                <h2>Return To Vendor Detail</h2>
                <p><strong>RTVID:</strong> <%= rtv.getRtvID() %></p>
                <p><strong>Return Code:</strong> <%= rtv.getReturnCode() %></p>
                <p><strong>Supplier:</strong> <%= rtv.getSupplierName() != null ? rtv.getSupplierName() : rtv.getSupplierID() %></p>
                <p><strong>Status:</strong> <%= rtv.getStatus() %></p>
                <p><strong>Reason:</strong> <%= rtv.getReason() %></p>
                <p><strong>Note:</strong> <%= rtv.getNote() %></p>
                <p><strong>Settlement Type:</strong> <%= rtv.getSettlementType() %></p>
                <p><strong>Total Amount:</strong> <%= String.format("%,.0f", rtv.getTotalAmount()) %></p>
                <p><strong>Created Date:</strong> <%= rtv.getCreatedDate() %></p>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>RTV Detail ID</th>
                        <th>Detail ID</th>
                        <th>StockIn ID</th>
                        <th>Product</th>
                        <th>Quantity</th>
                        <th>UnitCost</th>
                        <th>Line Total</th>
                        <th>Reason Detail</th>
                        <th>Condition</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<ReturnToVendorDetail> details = rtv.getDetails();
                        if (details != null && !details.isEmpty()) {
                            for (ReturnToVendorDetail d : details) {
                    %>
                    <tr>
                        <td><%= d.getRtvDetailID() %></td>
                        <td><%= d.getStockInDetailID() %></td>
                        <td><%= d.getStockInID() %></td>
                        <td><%= d.getProductName() != null ? d.getProductName() : d.getProductID() %></td>
                        <td><%= d.getQuantity() %></td>
                        <td><%= d.getUnitCost() %></td>
                        <td><%= d.getLineTotal() %></td>
                        <td><%= d.getReasonDetail() %></td>
                        <td><%= d.getItemCondition() %></td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="9">No detail found.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>

            <br/>

            <% if ("Pending".equalsIgnoreCase(rtv.getStatus())) { %>
            <form action="return-to-vendor" method="post" style="display:inline;">
                <input type="hidden" name="action" value="approve"/>
                <input type="hidden" name="rtvID" value="<%= rtv.getRtvID() %>"/>
                <button type="submit" class="btn approve">Approve</button>
            </form>

            <form action="return-to-vendor" method="post" style="display:inline;">
                <input type="hidden" name="action" value="reject"/>
                <input type="hidden" name="rtvID" value="<%= rtv.getRtvID() %>"/>
                <textarea name="rejectNote" placeholder="Enter reject reason"></textarea><br/>
                <button type="submit" class="btn reject">Reject</button>
            </form>
            <% } %>

            <% if ("Approved".equalsIgnoreCase(rtv.getStatus())) { %>
            <form action="return-to-vendor" method="post" style="display:inline;">
                <input type="hidden" name="action" value="complete"/>
                <input type="hidden" name="rtvID" value="<%= rtv.getRtvID() %>"/>
                <button type="submit" class="btn complete">Complete Return</button>
            </form>
            <% } %>

            <% } else { %>
            <div class="error">Return record not found.</div>
            <% } %>
        </div>
    </body>
</html>
