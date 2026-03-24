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

        // Thêm logic sắp xếp theo giá trị
        String orderBy;
        if ("total_desc".equalsIgnoreCase(sort)) {
            orderBy = " ORDER BY so.TotalAmount DESC, so.Date DESC ";
        } else if ("old".equalsIgnoreCase(sort)) {
            orderBy = " ORDER BY so.Date ASC ";
        } else {
            orderBy = " ORDER BY so.Date DESC ";
        }

        String sql = "SELECT so.StockOutID, so.Date, so.TotalAmount, so.Note, "
                + "c.Name AS CustomerName, c.Phone AS CustomerPhone, "
                + "u.Username AS CreatedByName "
                + "FROM dbo.StockOut so "
                + "LEFT JOIN dbo.Customers c ON so.CustomerID = c.CustomerID "
                + "LEFT JOIN dbo.[User] u ON so.CreatedBy = u.UserID "
                + orderBy;

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                OrderHistory o = new OrderHistory();
                o.setStockOutId(rs.getInt("StockOutID"));
                o.setDate(rs.getTimestamp("Date"));
                o.setTotalAmount(rs.getDouble("TotalAmount"));
                o.setNote(rs.getString("Note"));
                // Xử lý null để không hiện chữ "null" ra giao diện
                o.setCustomerName(rs.getString("CustomerName") != null ? rs.getString("CustomerName") : "Khách lẻ");
                o.setCustomerPhone(rs.getString("CustomerPhone") != null ? rs.getString("CustomerPhone") : "---");
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
    SELECT so.StockOutID, so.Date, so.TotalAmount, so.Note,
           c.Name AS CustomerName, c.Phone AS CustomerPhone,
           u.Username AS CreatedByName
    FROM dbo.StockOut so
    LEFT JOIN dbo.Customers c ON c.CustomerID = so.CustomerID
    LEFT JOIN dbo.[User] u ON u.UserID = so.CreatedBy
    """);

        if (range != null) {
            switch (range.toLowerCase()) {
                case "today", "day" ->
                    sql.append(" WHERE CAST(so.Date AS DATE) = CAST(GETDATE() AS DATE) ");
                case "yesterday" ->
                    sql.append(" WHERE CAST(so.Date AS DATE) = CAST(DATEADD(day, -1, GETDATE()) AS DATE) ");
                case "this_week", "week" ->
                    sql.append(" WHERE so.Date >= DATEADD(day, -7, GETDATE()) ");
                case "this_month", "month" ->
                    sql.append(" WHERE YEAR(so.Date) = YEAR(GETDATE()) AND MONTH(so.Date) = MONTH(GETDATE()) ");
            }
        }

        // Thêm logic sắp xếp
        if ("total_desc".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY so.TotalAmount DESC, so.Date DESC ");
        } else if ("old".equalsIgnoreCase(sort)) {
            sql.append(" ORDER BY so.Date ASC, so.StockOutID ASC ");
        } else {
            sql.append(" ORDER BY so.Date DESC, so.StockOutID DESC ");
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString()); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                OrderHistory o = new OrderHistory();
                o.setStockOutId(rs.getInt("StockOutID"));
                o.setDate(rs.getTimestamp("Date"));
                o.setTotalAmount(rs.getDouble("TotalAmount"));
                o.setNote(rs.getString("Note"));
                o.setCustomerName(rs.getString("CustomerName") != null ? rs.getString("CustomerName") : "Khách lẻ");
                o.setCustomerPhone(rs.getString("CustomerPhone") != null ? rs.getString("CustomerPhone") : "---");
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
        String cleanKeyword = (keyword == null) ? "" : keyword.trim();

        String orderBy;
        if ("total_desc".equalsIgnoreCase(sort)) {
            orderBy = " ORDER BY so.TotalAmount DESC ";
        } else if ("old".equalsIgnoreCase(sort)) {
            orderBy = " ORDER BY so.Date ASC ";
        } else {
            orderBy = " ORDER BY so.Date DESC ";
        }

        // Dùng CAST sang VARCHAR để tìm kiếm LIKE cho cả Mã HĐ và SĐT không bị lỗi kiểu dữ liệu
        String sql = """
    SELECT so.StockOutID, so.Date, so.TotalAmount, so.Note,
           c.Name AS CustomerName, c.Phone AS CustomerPhone,
           u.Username AS CreatedByName
    FROM dbo.StockOut so
    LEFT JOIN dbo.Customers c ON c.CustomerID = so.CustomerID
    LEFT JOIN dbo.[User] u ON u.UserID = so.CreatedBy
    WHERE (CAST(so.StockOutID AS VARCHAR) LIKE ? OR c.Phone LIKE ? OR c.Name LIKE ?)
    """ + orderBy;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String p = "%" + cleanKeyword + "%";
            ps.setString(1, p);
            ps.setString(2, p);
            ps.setString(3, p);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderHistory o = new OrderHistory();
                    o.setStockOutId(rs.getInt("StockOutID"));
                    o.setDate(rs.getTimestamp("Date"));
                    o.setTotalAmount(rs.getDouble("TotalAmount"));
                    o.setCustomerName(rs.getString("CustomerName") != null ? rs.getString("CustomerName") : "Khách lẻ");
                    o.setCustomerPhone(rs.getString("CustomerPhone") != null ? rs.getString("CustomerPhone") : "---");
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
