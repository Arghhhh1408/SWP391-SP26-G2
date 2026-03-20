package dao;

import utils.DBContext;

import java.sql.*;
import java.util.Collection;
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
    // CHỈ CÓ 4 CỘT: StockOutID, ProductID, Quantity, UnitPrice
    String sql = """
    INSERT INTO dbo.StockOutDetails(StockOutID, ProductID, Quantity, UnitPrice)
    VALUES(?, ?, ?, ?)
    """;

    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        for (CartItem it : items) {
            ps.setInt(1, stockOutId);         // ? số 1
            ps.setInt(2, it.getProductId());   // ? số 2
            ps.setInt(3, it.getQty());         // ? số 3
            ps.setDouble(4, it.getPrice());     // ? số 4
            
            // TUYỆT ĐỐI KHÔNG có dòng ps.set... thứ 5 ở đây
            
            ps.addBatch();
        }
        ps.executeBatch();
    }

}

}
