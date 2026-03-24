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
import utils.DBContext;

public class StaffDashboardDAO extends DBContext {

    public double getPendingSupplierDebtAmount() {
        String sql = "SELECT ISNULL(SUM(Amount), 0) "
                + "FROM dbo.SupplierDebts "
                + "WHERE Status IN ('Partial', 'Unpaid')";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getDouble(1) : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    public int countPendingSupplierDebts() {
        String sql = "SELECT COUNT(*) "
                + "FROM dbo.SupplierDebts "
                + "WHERE Status IN ('Partial', 'Unpaid')";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    public int countOpenRTVCases() {
        String sql = "SELECT COUNT(*) FROM dbo.ReturnToVendors";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    public int countUnreadNotifications(int userId) {
        String sql = "SELECT COUNT(*) FROM dbo.Notifications WHERE UserID = ? AND IsRead = 0";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, userId);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    public List<LowStock> getDashboardWatchlist() {
        List<LowStock> list = new ArrayList<>();
        String sql = """
                SELECT TOP (10)
                       l.AlertID,
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
                WHERE p.StockQuantity < l.MinStockLevel
                ORDER BY (l.MinStockLevel - p.StockQuantity) DESC, p.Name ASC
                """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                LowStock item = new LowStock();
                item.setAlertId(rs.getInt("AlertID"));
                item.setProductId(rs.getInt("ProductID"));
                item.setProductName(rs.getString("Name"));
                item.setSku(rs.getString("SKU"));
                item.setStockQuantity(rs.getInt("StockQuantity"));
                item.setMinStockLevel(rs.getInt("MinStockLevel"));
                item.setNotified(rs.getBoolean("Notified"));
                item.setCategoryName(rs.getString("CategoryName"));
                list.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
