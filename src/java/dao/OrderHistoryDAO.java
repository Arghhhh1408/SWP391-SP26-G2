package dao;

import utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.OrderHistory;
import model.OrderHistory.OrderItemRow;
import model.OrderHistory.OrderRow;

public class OrderHistoryDAO extends DBContext {

    // 1. Danh sách TẤT CẢ đơn hàng
    public List<OrderHistory> getAllOrders(String sort) {
        List<OrderHistory> list = new ArrayList<>();

        String orderBy = "old".equalsIgnoreCase(sort)
                ? " ORDER BY so.Date ASC, so.StockOutID ASC "
                : " ORDER BY so.Date DESC, so.StockOutID DESC ";

        // Đã sửa: Name và Phone (khớp với ảnh SQL bạn gửi)
        String sql = """
        SELECT so.StockOutID,
               so.Date,
               so.TotalAmount,
               so.Note,
               c.Name AS CustomerName,
               c.Phone AS CustomerPhone,
               u.Username AS CreatedByName
        FROM dbo.StockOut so
        LEFT JOIN dbo.Customers c ON c.CustomerID = so.CustomerID
        LEFT JOIN dbo.[User] u ON u.UserID = so.CreatedBy
        """ + orderBy;

        try (PreparedStatement ps = connection.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                OrderHistory o = new OrderHistory();
                o.setStockOutId(rs.getInt("StockOutID"));
                o.setDate(rs.getTimestamp("Date"));
                o.setTotalAmount(rs.getDouble("TotalAmount"));
                o.setNote(rs.getString("Note"));
                o.setCustomerName(rs.getString("CustomerName"));
                o.setCustomerPhone(rs.getString("CustomerPhone"));
                o.setCreatedByName(rs.getString("CreatedByName"));
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy thông tin Header của 1 hóa đơn (Dùng cho trang chi tiết)
    public OrderRow getOrderHeader(int stockOutId) {
        String sql = """
        SELECT so.StockOutID,
               so.Date,
               so.TotalAmount,
               so.Note,
               c.Name  AS CustomerName,
               c.Phone AS CustomerPhone,
               u.Username AS CreatedBy
        FROM dbo.StockOut so
        LEFT JOIN dbo.Customers c ON c.CustomerID = so.CustomerID
        LEFT JOIN dbo.[User] u ON u.UserID = so.CreatedBy
        WHERE so.StockOutID = ?
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, stockOutId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    OrderRow r = new OrderRow();
                    r.setStockOutId(rs.getInt("StockOutID"));
                    r.setCreatedAt(String.valueOf(rs.getTimestamp("Date")));
                    r.setTotalAmount(rs.getDouble("TotalAmount"));
                    r.setNote(rs.getString("Note"));
                    r.setCustomerName(rs.getString("CustomerName"));
                    r.setCustomerPhone(rs.getString("CustomerPhone"));
                    r.setCreatedBy(rs.getString("CreatedBy"));
                    return r;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 3. Lấy danh sách sản phẩm của 1 hóa đơn
    public List<OrderItemRow> getOrderItems(int stockOutId) {
        List<OrderItemRow> items = new ArrayList<>();
        String sql = """
            SELECT d.ProductID,
                   p.SKU,
                   p.Name,
                   d.UnitPrice AS Price,
                   d.Quantity,
                   (d.UnitPrice * d.Quantity) AS LineTotal
            FROM dbo.StockOutDetails d
            JOIN dbo.Products p ON p.ProductID = d.ProductID
            WHERE d.StockOutID = ?
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, stockOutId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItemRow it = new OrderItemRow();
                    it.setProductId(rs.getInt("ProductID"));
                    it.setSku(rs.getString("SKU"));
                    it.setName(rs.getString("Name"));
                    it.setPrice(rs.getDouble("Price"));
                    it.setQuantity(rs.getInt("Quantity"));
                    it.setLineTotal(rs.getDouble("LineTotal"));
                    items.add(it);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return items;
    }

    // 4. Lọc đơn hàng theo mốc thời gian (Ngày/Tuần/Tháng)
    public List<OrderHistory> getOrdersByRange(String range, String sort) {
        List<OrderHistory> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("""
        SELECT so.StockOutID,
               so.Date,
               so.TotalAmount,
               so.Note,
               c.Name AS CustomerName,
               c.Phone AS CustomerPhone,
               u.Username AS CreatedByName
        FROM dbo.StockOut so
        LEFT JOIN dbo.Customers c ON c.CustomerID = so.CustomerID
        LEFT JOIN dbo.[User] u ON u.UserID = so.CreatedBy
        """);

        switch (range) {
            case "day" -> sql.append(" WHERE CAST(so.Date AS DATE) = CAST(GETDATE() AS DATE) ");
            case "week" -> sql.append(" WHERE DATEPART(YEAR, so.Date) = DATEPART(YEAR, GETDATE()) AND DATEPART(WEEK, so.Date) = DATEPART(WEEK, GETDATE()) ");
            case "month" -> sql.append(" WHERE YEAR(so.Date) = YEAR(GETDATE()) AND MONTH(so.Date) = MONTH(GETDATE()) ");
        }

        sql.append("old".equalsIgnoreCase(sort) 
            ? " ORDER BY so.Date ASC, so.StockOutID ASC " 
            : " ORDER BY so.Date DESC, so.StockOutID DESC ");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString()); 
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                OrderHistory o = new OrderHistory();
                o.setStockOutId(rs.getInt("StockOutID"));
                o.setDate(rs.getTimestamp("Date"));
                o.setTotalAmount(rs.getDouble("TotalAmount"));
                o.setNote(rs.getString("Note"));
                o.setCustomerName(rs.getString("CustomerName"));
                o.setCustomerPhone(rs.getString("CustomerPhone"));
                o.setCreatedByName(rs.getString("CreatedByName"));
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 5. Tìm kiếm đơn hàng theo Mã hoặc Số điện thoại
    public List<OrderHistory> searchOrders(String keyword, String sort) {
    List<OrderHistory> list = new ArrayList<>();
    String orderBy = "old".equalsIgnoreCase(sort)
            ? " ORDER BY so.Date ASC, so.StockOutID ASC "
            : " ORDER BY so.Date DESC, so.StockOutID DESC ";

    // Kiểm tra xem keyword có phải là số (Mã HĐ hoặc SĐT) không
    boolean isNumber = keyword != null && keyword.trim().matches("\\d+");
    String cleanKeyword = (keyword == null) ? "" : keyword.trim();

    String sql = """
    SELECT so.StockOutID, so.Date, so.TotalAmount, so.Note,
           c.Name AS CustomerName, c.Phone AS CustomerPhone,
           u.Username AS CreatedByName
    FROM dbo.StockOut so
    LEFT JOIN dbo.Customers c ON c.CustomerID = so.CustomerID
    LEFT JOIN dbo.[User] u ON u.UserID = so.CreatedBy
    WHERE 
    """;

    // Sửa logic điều kiện WHERE cho khớp với tên cột thực tế
    if (isNumber) {
        // Tìm chính xác Mã HĐ hoặc tìm gần đúng theo Số điện thoại
        sql += " (so.StockOutID = ? OR c.Phone LIKE ?) ";
    } else {
        // Tìm gần đúng theo Tên khách hàng
        sql += " (c.Name LIKE ?) ";
    }
    sql += orderBy;

    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        if (isNumber) {
            ps.setInt(1, Integer.parseInt(cleanKeyword));
            ps.setString(2, "%" + cleanKeyword + "%");
        } else {
            ps.setString(1, "%" + cleanKeyword + "%");
        }

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                OrderHistory o = new OrderHistory();
                o.setStockOutId(rs.getInt("StockOutID"));
                o.setDate(rs.getTimestamp("Date"));
                o.setTotalAmount(rs.getDouble("TotalAmount"));
                o.setCustomerName(rs.getString("CustomerName"));
                o.setCustomerPhone(rs.getString("CustomerPhone"));
                o.setCreatedByName(rs.getString("CreatedByName"));
                list.add(o);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}
}