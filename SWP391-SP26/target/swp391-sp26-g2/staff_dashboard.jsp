<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="jakarta.tags.core" prefix="c"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Warehouse Staff Dashboard</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { display: flex; min-height: 100vh; font-family: Arial, sans-serif; background: #f4f6f9; }
        .sidebar { width: 240px; background: #1a1a2e; color: #ccc; display: flex; flex-direction: column; }
        .sidebar-brand { padding: 20px 16px 12px; border-bottom: 1px solid #2e2e50; }
        .sidebar-brand h2 { color: #fff; font-size: 18px; }
        .sidebar-brand small { font-size: 11px; color: #888; }
        .sidebar-section-title { padding: 16px 16px 6px; font-size: 10px; text-transform: uppercase; letter-spacing: 1px; color: #555; }
        .sidebar nav a { display: block; padding: 10px 16px; color: #bbb; text-decoration: none; font-size: 14px; }
        .sidebar nav a:hover, .sidebar nav a.active { background: #2e2e50; color: #fff; }
        .sidebar-footer { margin-top: auto; padding: 14px 16px; border-top: 1px solid #2e2e50; font-size: 12px; color: #555; }
        .sidebar-footer a { color: #e05252; text-decoration: none; font-size: 13px; }
        .main { flex: 1; display: flex; flex-direction: column; }
        .topbar { background: #fff; padding: 14px 24px; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: space-between; }
        .topbar h1 { font-size: 20px; color: #1a1a2e; }
        .topbar small { color: #888; font-size: 12px; }
        .content { padding: 24px; }
        .box { background: #fff; border: 1px solid #e0e0e0; border-radius: 8px; margin-bottom: 18px; }
        .box-header { padding: 14px 18px; border-bottom: 1px solid #e0e0e0; }
        .box-body { padding: 16px 18px; color: #333; line-height: 1.7; }
        .btn {
            border: none;
            border-radius: 6px;
            background: #38bdf8;
            color: #0c4a6e;
            padding: 7px 10px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 700;
        }
        .btn:hover { background: #0ea5e9; color: #fff; }
        .btn-reject { background: #fecaca; color: #7f1d1d; }
        .btn-reject:hover { background: #f87171; color: #fff; }
        .action-row { display: flex; gap: 6px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #e5e7eb; padding: 10px; text-align: left; font-size: 14px; }
        th { background: #f8fafc; }
        .tag-done {
            background: #d1e7dd;
            color: #0f5132;
            border: 1px solid #badbcc;
            border-radius: 12px;
            padding: 2px 8px;
            font-size: 12px;
        }
    </style>
</head>
<body>
<aside class="sidebar">
    <div class="sidebar-brand">
        <h2>Warehouse Staff</h2>
        <small>Quản lý kho</small>
    </div>

    <nav>
        <div class="sidebar-section-title">Menu Staff</div>
        <a href="staff_dashboard?tab=warranty" class="${tab == 'warranty' ? 'active' : ''}">Yeu cau bao hanh</a>
        <a href="staff_dashboard?tab=returns" class="${tab == 'returns' ? 'active' : ''}">Yeu cau tra hang</a>
        <a href="staff_dashboard?tab=products" class="${tab == 'products' ? 'active' : ''}">Danh sach san pham</a>
    </nav>

    <div class="sidebar-footer">
        <span>Trang thái: Online</span><br><br>
        <a href="logout">Dang xuat</a>
    </div>
</aside>

<div class="main">
    <div class="topbar">
        <div>
            <h1>Trang quản lý Warehouse Staff</h1>
            <small>Warehouse Staff > ${tab == 'returns' ? 'Yeu cau tra hang' : (tab == 'products' ? 'Danh sach san pham' : 'Yeu cau bao hanh')}</small>
        </div>
        <div>Xin chao, <strong>${sessionScope.acc.fullName}</strong></div>
    </div>

    <div class="content">
        <c:choose>
            <c:when test="${tab == 'returns'}">
                <div class="box">
                    <div class="box-header"><h3>Danh sach yeu cau tra hang</h3></div>
                    <div class="box-body">
                        <table>
                            <tr>
                                <th>Ma yeu cau</th>
                                <th>SKU</th>
                                <th>San pham</th>
                                <th>Khach hang</th>
                                <th>Ly do</th>
                                <th>Trang thai</th>
                                <th>Hanh dong</th>
                            </tr>
                            <c:forEach items="${returns}" var="r">
                                <tr>
                                    <td>${r.returnCode}</td>
                                    <td>${r.sku}</td>
                                    <td>${r.productName}</td>
                                    <td>${r.customerName}</td>
                                    <td>${r.reason}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.status == 'COMPLETED'}"><span class="tag-done">Da tra hang</span></c:when>
                                            <c:when test="${r.status == 'APPROVED'}">Da xac nhan</c:when>
                                            <c:when test="${r.status == 'REJECTED'}">Tu choi</c:when>
                                            <c:when test="${r.status == 'NEW'}">Dang xu ly</c:when>
                                            <c:otherwise>${r.status}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.status == 'COMPLETED' || r.status == 'REJECTED'}">-</c:when>
                                            <c:otherwise>
                                                <div class="action-row">
                                                    <form action="staff_dashboard" method="post">
                                                        <input type="hidden" name="action" value="completeReturn">
                                                        <input type="hidden" name="id" value="${r.id}">
                                                        <button type="submit" class="btn" onclick="return confirm('Xac nhan da tra hang?');">Xac nhan da tra hang</button>
                                                    </form>
                                                    <form action="staff_dashboard" method="post">
                                                        <input type="hidden" name="action" value="rejectReturn">
                                                        <input type="hidden" name="id" value="${r.id}">
                                                        <button type="submit" class="btn btn-reject" onclick="return confirm('Ban muon tu choi yeu cau nay?');">Tu choi</button>
                                                    </form>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty returns}">
                                <tr><td colspan="7">Chua co yeu cau tra hang.</td></tr>
                            </c:if>
                        </table>
                    </div>
                </div>
            </c:when>
            <c:when test="${tab == 'products'}">
                <div class="box">
                    <div class="box-header"><h3>Danh sach san pham</h3></div>
                    <div class="box-body">
                        <p style="margin-bottom:10px;">
                            <a href="addProduct">+ Add san pham</a>
                        </p>
                        <c:if test="${not empty error}">
                            <p style="color: red;">${error}</p>
                        </c:if>
                        <table>
                            <tr>
                                <th>ID</th>
                                <th>Ten san pham</th>
                                <th>SKU</th>
                                <th>Gia</th>
                                <th>So luong</th>
                                <th>Trang thai</th>
                                <th>Hanh dong</th>
                            </tr>
                            <c:forEach items="${products}" var="p">
                                <tr>
                                    <td>${p.id}</td>
                                    <td>${p.name}</td>
                                    <td>${p.sku}</td>
                                    <td>${p.price}</td>
                                    <td>${p.quantity}</td>
                                    <td>${p.status}</td>
                                    <td>
                                        <a href="staff_dashboard?tab=products&editId=${p.id}">Sua</a> |
                                        <a href="deleteProduct?id=${p.id}" onclick="return confirm('Ban chac chan muon xoa san pham nay?');">Xoa</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty products}">
                                <tr><td colspan="7">Khong co san pham nao.</td></tr>
                            </c:if>
                        </table>

                        <c:if test="${not empty editProduct}">
                            <div style="margin-top: 16px;">
                                <h4>Sua san pham: ${editProduct.name}</h4>
                                <form action="editProduct" method="post">
                                    <input type="hidden" name="id" value="${editProduct.id}">
                                    <table>
                                        <tr>
                                            <td>Category</td>
                                            <td>
                                                <select name="categoryId" required>
                                                    <c:forEach items="${categories}" var="c">
                                                        <option value="${c.id}" ${editProduct.categoryId == c.id ? 'selected' : ''}>${c.name}</option>
                                                    </c:forEach>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr><td>Name</td><td><input type="text" name="name" value="${editProduct.name}" required></td></tr>
                                        <tr><td>SKU</td><td><input type="text" name="sku" value="${editProduct.sku}" required></td></tr>
                                        <tr><td>Cost</td><td><input type="number" step="0.01" name="cost" value="${editProduct.cost}" required></td></tr>
                                        <tr><td>Price</td><td><input type="number" step="0.01" name="price" value="${editProduct.price}" required></td></tr>
                                        <tr><td>Quantity</td><td><input type="number" name="quantity" value="${editProduct.quantity}" required></td></tr>
                                        <tr><td>Unit</td><td><input type="text" name="unit" value="${editProduct.unit}" required></td></tr>
                                        <tr>
                                            <td>Status</td>
                                            <td>
                                                <select name="status">
                                                    <option value="Active" ${editProduct.status == 'Active' ? 'selected' : ''}>Active</option>
                                                    <option value="Deactivated" ${editProduct.status == 'Deactivated' ? 'selected' : ''}>Deactivated</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr><td>Image URL</td><td><input type="text" name="imageURL" value="${editProduct.imageURL}"></td></tr>
                                        <tr><td>Description</td><td><textarea name="description" rows="3" cols="40">${editProduct.description}</textarea></td></tr>
                                        <tr>
                                            <td colspan="2">
                                                <button type="submit" class="btn">Cap nhat</button>
                                                <a href="staff_dashboard?tab=products">Huy</a>
                                            </td>
                                        </tr>
                                    </table>
                                </form>
                            </div>
                        </c:if>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="box">
                    <div class="box-header"><h3>Danh sach yeu cau bao hanh</h3></div>
                    <div class="box-body">
                        <table>
                            <tr>
                                <th>Ma yeu cau</th>
                                <th>SKU</th>
                                <th>San pham</th>
                                <th>Khach hang</th>
                                <th>Mo ta loi</th>
                                <th>Trang thai</th>
                                <th>Hanh dong</th>
                            </tr>
                            <c:forEach items="${claims}" var="c">
                                <tr>
                                    <td>${c.claimCode}</td>
                                    <td>${c.sku}</td>
                                    <td>${c.productName}</td>
                                    <td>${c.customerName}</td>
                                    <td>${c.issueDescription}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.status == 'COMPLETED'}"><span class="tag-done">Da bao hanh</span></c:when>
                                            <c:when test="${c.status == 'APPROVED'}">Da xac nhan</c:when>
                                            <c:when test="${c.status == 'REJECTED'}">Tu choi</c:when>
                                            <c:when test="${c.status == 'NEW'}">Dang xu ly</c:when>
                                            <c:otherwise>${c.status}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.status == 'COMPLETED' || c.status == 'REJECTED'}">-</c:when>
                                            <c:otherwise>
                                                <div class="action-row">
                                                    <form action="staff_dashboard" method="post">
                                                        <input type="hidden" name="action" value="completeWarranty">
                                                        <input type="hidden" name="id" value="${c.id}">
                                                        <button type="submit" class="btn" onclick="return confirm('Xac nhan da bao hanh?');">Xac nhan da bao hanh</button>
                                                    </form>
                                                    <form action="staff_dashboard" method="post">
                                                        <input type="hidden" name="action" value="rejectWarranty">
                                                        <input type="hidden" name="id" value="${c.id}">
                                                        <button type="submit" class="btn btn-reject" onclick="return confirm('Ban muon tu choi yeu cau nay?');">Tu choi</button>
                                                    </form>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty claims}">
                                <tr><td colspan="7">Chua co yeu cau bao hanh.</td></tr>
                            </c:if>
                        </table>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</body>
</html>
