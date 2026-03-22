package dao;

import utils.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import model.CartItem;

public class StockOutDAO{
    private final Connection connection;
    public StockOutDAO(Connection conn) {
        this.connection = conn;
    }
    public int insertStockOut(int customerId, int createdByUserId,
            double totalAmount, String note) throws Exception {

        String sql = """
        INSERT INTO dbo.StockOut(CustomerID, Date, TotalAmount, CreatedBy, Note, Status)
        VALUES(?, SYSDATETIME(), ?, ?, ?, 'Completed')
    """;

        try (PreparedStatement ps
                = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, customerId);
            ps.setDouble(2, totalAmount);
            ps.setInt(3, createdByUserId); // vì CreatedBy là int
            ps.setString(4, note);

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Không lấy được StockOutID");
    }

    public void insertDetails(int stockOutId, Collection<CartItem> items) throws Exception {
        String sql = """
        INSERT INTO dbo.StockOutDetails(StockOutID, ProductID, Quantity, UnitPrice)
        VALUES(?, ?, ?, ?)
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            for (CartItem it : items) {
                ps.setInt(1, stockOutId);
                ps.setInt(2, it.getProductId());
                ps.setInt(3, it.getQty());
                ps.setDouble(4, it.getPrice());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }
    public List<model.OrderHistory> getAllOrdersForHistory(String keyword, String sort) throws Exception {
    List<model.OrderHistory> list = new ArrayList<>();
    // SQL dùng LEFT JOIN để không làm mất đơn hàng khách vãng lai (NULL)
    String sql = "SELECT s.StockOutID, s.Date, s.TotalAmount, s.Status, " +
                 "c.FullName AS CustomerName, u.FullName AS StaffName " +
                 "FROM dbo.StockOut s " +
                 "LEFT JOIN dbo.Customers c ON s.CustomerID = c.CustomerID " +
                 "LEFT JOIN dbo.Users u ON s.CreatedBy = u.UserID " +
                 "WHERE c.FullName LIKE ? OR s.StockOutID LIKE ? " +
                 "ORDER BY s.Date " + (sort.equals("old") ? "ASC" : "DESC");

    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setString(1, "%" + keyword + "%");
        ps.setString(2, "%" + keyword + "%");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            // Tạo object và add vào list ở đây
            // model.OrderHistory o = new model.OrderHistory(...);
            // list.add(o);
        }
    }
    return list;
}

}
