/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author dotha
 */
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.LowStock;
import model.Product;
import utils.DBContext;

public class LowStockDAO extends DBContext {

    public List<LowStock> getAllAlerts() {
        List<LowStock> list = new ArrayList<>();
        String sql = """
                SELECT l.AlertID,
                       l.ProductID,
                       p.Name,
                       p.SKU,
                       p.StockQuantity,
                       l.MinStockLevel,
                       l.Notified,
                       c.CategoryName
                FROM dbo.LowStockAlerts l
                INNER JOIN dbo.Products p ON p.ProductID = l.ProductID
                LEFT JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
                ORDER BY CASE WHEN p.StockQuantity <= l.MinStockLevel THEN 0 ELSE 1 END,
                         (l.MinStockLevel - p.StockQuantity) DESC,
                         p.Name ASC
                """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<LowStock> getTriggeredAlerts() {
        List<LowStock> list = new ArrayList<>();
        String sql = """
                SELECT l.AlertID,
                       l.ProductID,
                       p.Name,
                       p.SKU,
                       p.StockQuantity,
                       l.MinStockLevel,
                       l.Notified,
                       c.CategoryName
                FROM dbo.LowStockAlerts l
                INNER JOIN dbo.Products p ON p.ProductID = l.ProductID
                LEFT JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
                WHERE p.StockQuantity <= l.MinStockLevel
                ORDER BY (l.MinStockLevel - p.StockQuantity) DESC, p.Name ASC
                """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public LowStock getByProductId(int productId) {
        String sql = """
                SELECT l.AlertID,
                       l.ProductID,
                       p.Name,
                       p.SKU,
                       p.StockQuantity,
                       l.MinStockLevel,
                       l.Notified,
                       c.CategoryName
                FROM dbo.LowStockAlerts l
                INNER JOIN dbo.Products p ON p.ProductID = l.ProductID
                LEFT JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
                WHERE l.ProductID = ?
                """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, productId);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean saveOrUpdateAlert(int productId, int minStockLevel) {
        String updateSql = "UPDATE dbo.LowStockAlerts SET MinStockLevel = ?, Notified = 0 WHERE ProductID = ?";
        String insertSql = "INSERT INTO dbo.LowStockAlerts(ProductID, MinStockLevel, Notified) VALUES (?, ?, 0)";
        try {
            PreparedStatement updateStm = connection.prepareStatement(updateSql);
            updateStm.setInt(1, minStockLevel);
            updateStm.setInt(2, productId);
            int affected = updateStm.executeUpdate();
            if (affected > 0) {
                return true;
            }

            PreparedStatement insertStm = connection.prepareStatement(insertSql);
            insertStm.setInt(1, productId);
            insertStm.setInt(2, minStockLevel);
            return insertStm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateNotified(int alertId, boolean notified) {
        String sql = "UPDATE dbo.LowStockAlerts SET Notified = ? WHERE AlertID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setBoolean(1, notified);
            stm.setInt(2, alertId);
            return stm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteAlert(int alertId) {
        String sql = "DELETE FROM dbo.LowStockAlerts WHERE AlertID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, alertId);
            return stm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Product> getProductsWithoutAlert() {
        List<Product> list = new ArrayList<>();
        String sql = """
                SELECT p.ProductID, p.Name, p.SKU, p.Price, p.StockQuantity, p.Unit, p.Status
                FROM dbo.Products p
                WHERE p.Status = 'Active'
                  AND NOT EXISTS (
                        SELECT 1
                        FROM dbo.LowStockAlerts l
                        WHERE l.ProductID = p.ProductID
                  )
                ORDER BY p.Name ASC
                """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("ProductID"));
                p.setName(rs.getString("Name"));
                p.setSku(rs.getString("SKU"));
                p.setPrice(rs.getDouble("Price"));
                p.setQuantity(rs.getInt("StockQuantity"));
                p.setUnit(rs.getString("Unit"));
                p.setStatus(rs.getString("Status"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countTriggeredAlerts() {
        String sql = """
                SELECT COUNT(*)
                FROM dbo.LowStockAlerts l
                INNER JOIN dbo.Products p ON p.ProductID = l.ProductID
                LEFT JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
                WHERE p.StockQuantity <= l.MinStockLevel
                """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private LowStock map(ResultSet rs) throws Exception {
        LowStock item = new LowStock();
        item.setAlertId(rs.getInt("AlertID"));
        item.setProductId(rs.getInt("ProductID"));
        item.setProductName(rs.getString("Name"));
        item.setSku(rs.getString("SKU"));
        item.setStockQuantity(rs.getInt("StockQuantity"));
        item.setMinStockLevel(rs.getInt("MinStockLevel"));
        item.setNotified(rs.getBoolean("Notified"));
        try {
            item.setCategoryName(rs.getString("CategoryName"));
        } catch (Exception ignore) {
        }
        return item;
    }
}
