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
