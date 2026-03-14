package dao;

import java.sql.*;
import java.util.*;
import model.Product;
import utils.DBContext;

public class ProductDAO extends DBContext {

    // 1. Lấy danh sách cho trang quản lý sản phẩm
    public List<model.Product> getAllProducts(String keyword) {
        List<model.Product> list = new ArrayList<>();
        String sql = """
                 SELECT [ProductID], [Name], [SKU], [Price], [StockQuantity], [Unit], [Description], [ImageURL]
                 FROM [dbo].[Products]
                 WHERE [Name] LIKE ? OR [SKU] LIKE ?
                 ORDER BY [ProductID] DESC
                 """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.Product p = new model.Product();
                    p.setId(rs.getInt("ProductID"));
                    p.setName(rs.getString("Name"));
                    p.setSku(rs.getString("SKU"));
                    p.setPrice(rs.getDouble("Price"));
                    p.setQuantity(rs.getInt("StockQuantity"));
                    p.setUnit(rs.getString("Unit"));
                    p.setDescription(rs.getString("Description"));
                    p.setImageURL(rs.getString("ImageURL")); // Đảm bảo model có hàm setImageURL
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Hàm quan trọng: Lấy chi tiết đầy đủ (Dùng cho trang productDetail.jsp)
    public Product getProductById(int id) {
        String sql = """
                 SELECT [ProductID], [Name], [SKU], [Price], [StockQuantity], [Unit], [Description], [ImageURL], [Status]
                 FROM [dbo].[Products]
                 WHERE [ProductID] = ?
                 """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("ProductID"));
                    p.setName(rs.getString("Name"));
                    p.setSku(rs.getString("SKU"));
                    p.setPrice(rs.getDouble("Price"));
                    p.setQuantity(rs.getInt("StockQuantity"));
                    p.setUnit(rs.getString("Unit"));
                    p.setDescription(rs.getString("Description"));
                    p.setImageURL(rs.getString("ImageURL"));
                    p.setStatus(rs.getString("Status"));
                    return p;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 3. Search cho POS (Giữ nguyên logic của bạn)
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

    // 4. Lấy product để add vào cart (Dùng hàm map thu gọn)
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
            if (rs.next()) {
                return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Hàm map dữ liệu nhanh cho các hàm phụ
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

    // 5. Trừ kho khi thanh toán thành công
    public boolean decreaseStock(Connection conn, int productId, int qty) throws Exception {
        String sql = "UPDATE dbo.Products SET StockQuantity = StockQuantity - ? "
                + "WHERE ProductID = ? AND Status = 'Active' AND StockQuantity >= ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, qty);
            ps.setInt(2, productId);
            ps.setInt(3, qty);
            return ps.executeUpdate() == 1;
        }
    }

    // 6. Lấy tồn kho hiện tại theo ID
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
    // Hàm lấy danh sách sản phẩm tồn kho thấp

    public List<Product> getLowStockProducts(int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Products WHERE StockQuantity < ? AND Status = 'Active'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("ProductID"));
                p.setName(rs.getString("Name"));
                p.setSku(rs.getString("SKU"));
                p.setQuantity(rs.getInt("StockQuantity"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
