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

    // Danh sách TẤT CẢ đơn
    public List<OrderHistory> getAllOrders(String sort) {
        List<OrderHistory> list = new ArrayList<>();

        String orderBy = "old".equalsIgnoreCase(sort)
                ? " ORDER BY so.Date ASC, so.StockOutID ASC "
                : " ORDER BY so.Date DESC, so.StockOutID DESC ";

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

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

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
                    r.setCreatedBy(rs.getString("CreatedBy")); // alias u.Username AS CreatedBy
                    return r;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<OrderItemRow> getOrderItems(int stockOutId) {
        List<OrderItemRow> items = new ArrayList<>();

        String sql = """
            SELECT d.ProductID,
                   p.SKU,
                   p.Name,
                   p.Price,
                   d.Quantity,
                   (p.Price * d.Quantity) AS LineTotal
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
            case "day":
                sql.append(" WHERE CAST(so.Date AS DATE) = CAST(GETDATE() AS DATE) ");
                break;
            case "week":
                sql.append("""
                WHERE DATEPART(YEAR, so.Date) = DATEPART(YEAR, GETDATE())
                AND DATEPART(WEEK, so.Date) = DATEPART(WEEK, GETDATE())
            """);
                break;
            case "month":
                sql.append("""
                WHERE YEAR(so.Date) = YEAR(GETDATE())
                AND MONTH(so.Date) = MONTH(GETDATE())
            """);
                break;
            default:
                break;
        }

        if ("old".equalsIgnoreCase(sort)) {
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

    public List<OrderHistory> searchOrders(String keyword, String sort) {
        List<OrderHistory> list = new ArrayList<>();

        String orderBy = "old".equalsIgnoreCase(sort)
                ? " ORDER BY so.Date ASC, so.StockOutID ASC "
                : " ORDER BY so.Date DESC, so.StockOutID DESC ";

        boolean isNumber = keyword != null && keyword.trim().matches("\\d+");
        keyword = (keyword == null) ? "" : keyword.trim();

        String sql = """
        SELECT so.StockOutID,
               so.Date,
               so.TotalAmount,
               so.Note,
               c.Name  AS CustomerName,
               c.Phone AS CustomerPhone,
               u.Username AS CreatedByName
        FROM dbo.StockOut so
        LEFT JOIN dbo.Customers c ON c.CustomerID = so.CustomerID
        LEFT JOIN dbo.[User] u ON u.UserID = so.CreatedBy
        WHERE
    """;

        // Nếu keyword toàn số: ưu tiên tìm theo mã đơn exact, hoặc sđt LIKE
        // Nếu không: tìm theo sđt LIKE hoặc tên LIKE
        if (isNumber) {
            sql += " (so.StockOutID = ? OR c.Phone LIKE ?) ";
        } else {
            sql += " (c.Phone LIKE ? OR c.Name LIKE ?) ";
        }

        sql += orderBy;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            if (isNumber) {
                ps.setInt(idx++, Integer.parseInt(keyword));
                ps.setString(idx++, "%" + keyword + "%");
            } else {
                ps.setString(idx++, "%" + keyword + "%");
                ps.setString(idx++, "%" + keyword + "%");
            }

            try (ResultSet rs = ps.executeQuery()) {
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
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
