package dao;

import java.sql.*;
import java.util.*;
import model.Product;
import utils.DBContext;

public class ProductDAO extends DBContext {

    // Search cho POS
    public List<Product> search(String keyword) {
        List<Product> list = new ArrayList<>();

        String sql = """
            SELECT ProductID, Name, SKU, Price, StockQuantity, Unit, Status
            FROM dbo.Products
            WHERE Status = 'Active'
              AND (Name LIKE ? OR SKU LIKE ?)
        """;

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            String k = "%" + (keyword == null ? "" : keyword.trim()) + "%";
            stm.setString(1, k);
            stm.setString(2, k);

            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy product theo ID (add vào cart)
    public Product getById(int id) {
        String sql = """
            SELECT ProductID, Name, SKU, Price, StockQuantity, Unit, Status
            FROM dbo.Products
            WHERE ProductID = ? AND Status = 'Active'
        """;

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);

            ResultSet rs = stm.executeQuery();
            if (rs.next()) return map(rs);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private Product map(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("ProductID"));
        p.setName(rs.getString("Name"));
        p.setSku(rs.getString("SKU"));
        p.setPrice(rs.getDouble("Price"));
        p.setQuantity(rs.getInt("StockQuantity"));
        p.setUnit(rs.getString("Unit"));
        p.setStatus(rs.getString("Status"));
        return p;
        
    }
    public boolean decreaseStock(Connection conn, int productId, int qty) throws Exception {
    String sql =
        "UPDATE dbo.Products " +
        "SET StockQuantity = StockQuantity - ? " +
        "WHERE ProductID = ? AND Status = 'Active' AND StockQuantity >= ?";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, qty);
        ps.setInt(2, productId);
        ps.setInt(3, qty);
        return ps.executeUpdate() == 1; // 1 row updated => đủ hàng
    }
}
    public int getStockById(int productId) {
    String sql = "SELECT StockQuantity FROM dbo.Products WHERE ProductID = ?";
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setInt(1, productId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("StockQuantity");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return 0;
}

}
