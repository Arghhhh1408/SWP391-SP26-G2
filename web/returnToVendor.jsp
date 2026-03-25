<%-- 
    Document   : returnToVendor
    Created on : 25 thg 3, 2026, 04:46:39
    Author     : dotha
--%>

<%@ page import="java.util.List" %>
<%@ page import="model.ReturnToVendor" %>
<%@ page import="model.User" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Return To Vendor List</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #f4f6f9;
                margin: 0;
                padding: 24px;
            }
            .container {
                max-width: 1280px;
                margin: auto;
            }
            .header-box, .table-box {
                background: white;
                border-radius: 14px;
                box-shadow: 0 4px 18px rgba(0,0,0,0.08);
            }
            .header-box {
                padding: 20px;
                margin-bottom: 20px;
            }
            .header-top {
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 12px;
            }
            .actions {
                display: flex;
                gap: 10px;
            }
            .btn {
                display: inline-block;
                padding: 10px 16px;
                border-radius: 10px;
                text-decoration: none;
                color: white;
                font-weight: bold;
            }
            .btn-back {
                background: #6b7280;
            }
            .btn-create {
                background: #2563eb;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            thead {
                background: #111827;
                color: white;
            }
            th, td {
                padding: 14px 12px;
                text-align: center;
            }
            tbody tr:nth-child(even) {
                background: #f9fafb;
            }
            tbody tr:hover {
                background: #eef4ff;
            }
            .status {
                padding: 6px 12px;
                border-radius: 999px;
                font-size: 13px;
                font-weight: bold;
                display: inline-block;
            }
            .pending {
                background: #fef3c7;
                color: #92400e;
            }
            .approved {
                background: #dbeafe;
                color: #1d4ed8;
            }
            .completed {
                background: #dcfce7;
                color: #166534;
            }
            .rejected {
                background: #fee2e2;
                color: #991b1b;
            }
            .view-link {
                color: #2563eb;
                font-weight: bold;
                text-decoration: none;
            }
            .empty {
                padding: 30px;
                text-align: center;
                color: #6b7280;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <%
                User acc = (User) session.getAttribute("acc");
                String backUrl = "login";
                String backLabel = "Back";

                if (acc != null) {
                    if (acc.getRoleID() == 1) {
                        backUrl = "staff_dashboard";
                        backLabel = "Back to Staff Dashboard";
                    } else if (acc.getRoleID() == 2) {
                        backUrl = "manager_dashboard";
                        backLabel = "Back to Manager Dashboard";
                    }
                }

                List<ReturnToVendor> list = (List<ReturnToVendor>) request.getAttribute("list");
            %>

            <div class="header-box">
                <div class="header-top">
                    <h2>Return To Vendor List</h2>
                    <div class="actions">
                        <a class="btn btn-back" href="<%= backUrl %>"><%= backLabel %></a>
                        <% if (acc != null && (acc.getRoleID() == 0 || acc.getRoleID() == 1)) { %>
                        <a class="btn btn-create" href="return-to-vendor?action=create">Create New Return</a>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="table-box">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Return Code</th>
                            <th>Supplier</th>
                            <th>Created By</th>
                            <th>Status</th>
                            <th>Total Amount</th>
                            <th>Created Date</th>
                            <th>Settlement</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (list != null && !list.isEmpty()) { %>
                        <% for (ReturnToVendor rtv : list) { %>
                        <%
                            String statusClass = "pending";
                            if ("Approved".equalsIgnoreCase(rtv.getStatus())) statusClass = "approved";
                            else if ("Completed".equalsIgnoreCase(rtv.getStatus())) statusClass = "completed";
                            else if ("Rejected".equalsIgnoreCase(rtv.getStatus())) statusClass = "rejected";
                        %>
                        <tr>
                            <td><%= rtv.getRtvID() %></td>
                            <td><%= rtv.getReturnCode() %></td>
                            <td><%= rtv.getSupplierName() != null ? rtv.getSupplierName() : rtv.getSupplierID() %></td>
                            <td><%= rtv.getCreatedByName() != null ? rtv.getCreatedByName() : rtv.getCreatedBy() %></td>
                            <td><span class="status <%= statusClass %>"><%= rtv.getStatus() %></span></td>
                            <td><%= String.format("%,.0f", rtv.getTotalAmount()) %></td>
                            <td><%= rtv.getCreatedDate() %></td>
                            <td><%= rtv.getSettlementType() %></td>
                            <td><a class="view-link" href="return-to-vendor?action=detail&id=<%= rtv.getRtvID() %>">View</a></td>
                        </tr>
                        <% } %>
                        <% } else { %>
                        <tr>
                            <td colspan="9" class="empty">No return to vendor records found.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>
