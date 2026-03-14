<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="model.User" %>
<%
    User acc = (User) session.getAttribute("acc");
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Thu nợ khách hàng - S.I.M</title>
        <style>
            /* CSS Đồng bộ hệ thống S.I.M */
            * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
            body { background: #f4f6f9; color: #1f2937; }
            .layout { display: flex; min-height: 100vh; }
            
            /* Sidebar tối */
            .sidebar { width: 240px; background: #1f2d3d; color: #fff; display: flex; flex-direction: column; flex-shrink: 0; }
            .logo { padding: 25px 20px; font-size: 24px; font-weight: bold; background: #1a2533; text-align: center; color: #3b82f6; letter-spacing: 2px; }
            .user-box { padding: 18px; border-bottom: 1px solid rgba(255,255,255,0.08); font-size: 14px; background: #263544; }
            .menu { list-style: none; padding: 10px 0; flex: 1; }
            .menu li a { display: block; padding: 14px 20px; color: #cbd5e1; text-decoration: none; transition: 0.3s; }
            .menu li a:hover, .menu li a.active { background: #374151; color: #fff; border-left: 4px solid #3b82f6; }

            .main { flex: 1; display: flex; flex-direction: column; }
            .topbar { height: 64px; background: #fff; border-bottom: 1px solid #e5e7eb; display: flex; align-items: center; padding: 0 25px; }
            .content { padding: 40px; display: flex; justify-content: center; }

            .card {
                background: #fff; border-radius: 12px; padding: 30px; 
                box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); border: 1px solid #e5e7eb; 
                width: 100%; max-width: 500px;
            }
            .card h3 { margin-bottom: 20px; font-size: 18px; color: #111827; border-left: 4px solid #3b82f6; padding-left: 12px; }

            .info-summary { background: #f9fafb; padding: 20px; border-radius: 10px; margin-bottom: 25px; border: 1px solid #f3f4f6; }
            .info-row { margin-bottom: 10px; font-size: 15px; display: flex; justify-content: space-between; }
            .debt-highlight { color: #dc2626; font-weight: 800; font-size: 1.2em; }

            .field { margin-top: 20px; }
            .field label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 8px; color: #374151; }
            .field input {
                width: 100%; padding: 12px 15px; border: 2px solid #d1d5db; border-radius: 10px;
                font-size: 18px; font-weight: bold; color: #111827; outline: none;
            }
            .field input:focus { border-color: #3b82f6; }

            .btn-group { margin-top: 30px; display: flex; gap: 12px; }
            .btn-submit {
                flex: 2; background: #10b981; color: white; border: none; padding: 14px;
                border-radius: 10px; cursor: pointer; font-weight: bold; font-size: 16px;
            }
            .btn-cancel {
                flex: 1; background: #f3f4f6; color: #4b5563; border: 1px solid #d1d5db;
                padding: 14px; border-radius: 10px; text-decoration: none; text-align: center; font-weight: 600;
            }
        </style>
    </head>
    <body>
        <div class="layout">
            <aside class="sidebar">
                <div class="logo">S.I.M</div>
                <div class="user-box">Chào: <b><%= acc != null ? acc.getUsername() : "" %></b></div>
                <ul class="menu">
                    <li><a href="${pageContext.request.contextPath}/dashboard">Trang chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/products">Sản phẩm</a></li>
                    <li><a href="${pageContext.request.contextPath}/pos">Bán hàng</a></li>
                    <li><a class="active" href="${pageContext.request.contextPath}/customers">Khách hàng</a></li>
                </ul>
            </aside>

            <main class="main">
                <div class="topbar"><h2>Ghi nhận thu nợ</h2></div>
                <div class="content">
                    <div class="card">
                        <h3>Thông tin thu tiền</h3>
                        <div class="info-summary">
                            <div class="info-row"><b>Khách hàng:</b> <span>${customer.name}</span></div>
                            <div class="info-row"><b>Số điện thoại:</b> <span>${customer.phone}</span></div>
                            <div class="info-row" style="margin-top: 10px; padding-top: 10px; border-top: 1px dashed #ccc;">
                                <b>Số nợ hiện tại:</b> 
                                <span class="debt-highlight">
                                    <fmt:formatNumber value="${customer.debt}" type="number"/> đ
                                </span>
                            </div>
                        </div>

                        <form action="collectDebt" method="post">
                            <input type="hidden" name="customerId" value="${customer.customerId}">

                            <div class="field">
                                <label for="amountPaid">Số tiền thu thực tế (đ)</label>
                                <input type="number" id="amountPaid" name="amountPaid" 
                                       value="<fmt:formatNumber value='${customer.debt}' pattern='#' />"
                                       max="${customer.debt}" min="1000" step="1000" required>
                            </div>

                            <div class="btn-group">
                                <button type="submit" class="btn-submit">Xác nhận thu nợ</button>
                                <a href="customerDetail?id=${customer.customerId}" class="btn-cancel">Hủy bỏ</a>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
        </div>
    </body>
</html>