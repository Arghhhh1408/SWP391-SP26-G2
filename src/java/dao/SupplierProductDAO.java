/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author dotha
 */
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.SupplierProduct;
import utils.DBContext;

public class SupplierProductDAO extends DBContext {

    public List<SupplierProduct> getProductsBySupplier(int supplierId) {
        List<SupplierProduct> list = new ArrayList<>();
        String sql = """
        SELECT sp.SupplierProductID, sp.SupplierID, sp.ProductID,
               sp.SupplyPrice, sp.IsActive,
               s.Name AS SupplierName,
               p.Name AS ProductName
        FROM SupplierProduct sp
        JOIN Suppliers s ON sp.SupplierID = s.SupplierID
        JOIN Products p ON sp.ProductID = p.ProductID
        WHERE sp.SupplierID = ?
        ORDER BY sp.SupplierProductID DESC
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                SupplierProduct sp = new SupplierProduct();
                sp.setSupplierProductID(rs.getInt("SupplierProductID"));
                sp.setSupplierID(rs.getInt("SupplierID"));
                sp.setProductID(rs.getInt("ProductID"));
                sp.setSupplyPrice(rs.getDouble("SupplyPrice"));
                sp.setActive(rs.getBoolean("IsActive"));
                sp.setSupplierName(rs.getString("SupplierName"));
                sp.setProductName(rs.getString("ProductName"));
                list.add(sp);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<SupplierProduct> searchProductsBySupplier(int supplierId, String keyword) {
        List<SupplierProduct> list = new ArrayList<>();
        String sql = """
        SELECT sp.SupplierProductID, sp.SupplierID, sp.ProductID,
               sp.SupplyPrice, sp.IsActive,
               s.Name AS SupplierName,
               p.Name AS ProductName
        FROM SupplierProduct sp
        JOIN Suppliers s ON sp.SupplierID = s.SupplierID
        JOIN Products p ON sp.ProductID = p.ProductID
        WHERE sp.SupplierID = ?
          AND (
                p.Name LIKE ?
                OR CAST(sp.SupplierProductID AS NVARCHAR) LIKE ?
                OR CAST(sp.SupplyPrice AS NVARCHAR) LIKE ?
                OR (
                    CASE 
                        WHEN sp.IsActive = 1 THEN N'Hoạt động'
                        ELSE N'Ngừng'
                    END
                ) LIKE ?
              )
        ORDER BY sp.SupplierProductID DESC
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchValue = "%" + keyword.trim() + "%";

            ps.setInt(1, supplierId);
            ps.setString(2, searchValue);
            ps.setString(3, searchValue);
            ps.setString(4, searchValue);
            ps.setString(5, searchValue);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                SupplierProduct sp = new SupplierProduct();
                sp.setSupplierProductID(rs.getInt("SupplierProductID"));
                sp.setSupplierID(rs.getInt("SupplierID"));
                sp.setProductID(rs.getInt("ProductID"));
                sp.setSupplyPrice(rs.getDouble("SupplyPrice"));
                sp.setActive(rs.getBoolean("IsActive"));
                sp.setSupplierName(rs.getString("SupplierName"));
                sp.setProductName(rs.getString("ProductName"));
                list.add(sp);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<SupplierProduct> searchProductsBySupplierPaged(int supplierId, String keyword, int page, int pageSize) {
        List<SupplierProduct> list = new ArrayList<>();
        String sql = """
        SELECT sp.SupplierProductID, sp.SupplierID, sp.ProductID,
               sp.SupplyPrice, sp.IsActive,
               s.Name AS SupplierName,
               p.Name AS ProductName
        FROM SupplierProduct sp
        JOIN Suppliers s ON sp.SupplierID = s.SupplierID
        JOIN Products p ON sp.ProductID = p.ProductID
        WHERE sp.SupplierID = ?
          AND sp.IsActive = 1
          AND p.Name LIKE ?
        ORDER BY p.Name ASC
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ps.setString(2, "%" + (keyword == null ? "" : keyword.trim()) + "%");
            ps.setInt(3, (page - 1) * pageSize);
            ps.setInt(4, pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SupplierProduct sp = new SupplierProduct();
                sp.setSupplierProductID(rs.getInt("SupplierProductID"));
                sp.setSupplierID(rs.getInt("SupplierID"));
                sp.setProductID(rs.getInt("ProductID"));
                sp.setSupplyPrice(rs.getDouble("SupplyPrice"));
                sp.setActive(rs.getBoolean("IsActive"));
                sp.setSupplierName(rs.getString("SupplierName"));
                sp.setProductName(rs.getString("ProductName"));
                list.add(sp);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean isValidSupplierProduct(int supplierId, int productId) {
        String sql = "SELECT 1 FROM SupplierProduct WHERE SupplierID = ? AND ProductID = ? AND IsActive = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ps.setInt(2, productId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addSupplierProduct(int supplierId, int productId, double supplyPrice) {
        String sql = """
            INSERT INTO SupplierProduct (SupplierID, ProductID, SupplyPrice, IsActive)
            VALUES (?, ?, ?, 1)
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ps.setInt(2, productId);
            ps.setDouble(3, supplyPrice);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateSupplierProduct(int supplierProductId, double supplyPrice, boolean isActive) {
        String sql = """
            UPDATE SupplierProduct
            SET SupplyPrice = ?, IsActive = ?
            WHERE SupplierProductID = ?
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDouble(1, supplyPrice);
            ps.setBoolean(2, isActive);
            ps.setInt(3, supplierProductId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean checkDuplicate(int supplierId, int productId) {
        String sql = "SELECT 1 FROM SupplierProduct WHERE SupplierID = ? AND ProductID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ps.setInt(2, productId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
