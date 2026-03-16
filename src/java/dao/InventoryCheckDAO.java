/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author dotha
 */
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.InventoryCheckItem;
import utils.DBContext;

public class InventoryCheckDAO extends DBContext {

    public List<InventoryCheckItem> getLatestInventoryCountsByProduct() {
        List<InventoryCheckItem> list = new ArrayList<>();

        String sql = """
        SELECT ic.CountID,
               ic.ProductID,
               p.SKU,
               p.Name AS ProductName,
               p.Unit,
               ic.SystemQuantity,
               ic.PhysicalQuantity,
               ic.Status,
               ic.ApprovedBy,
               ic.Date
        FROM InventoryCounts ic
        JOIN Products p ON ic.ProductID = p.ProductID
        WHERE ic.CountID IN (
            SELECT MAX(CountID)
            FROM InventoryCounts
            GROUP BY ProductID
        )
        ORDER BY p.Name
    """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                InventoryCheckItem item = new InventoryCheckItem();
                item.setCountId(rs.getInt("CountID"));
                item.setProductId(rs.getInt("ProductID"));
                item.setSku(rs.getString("SKU"));
                item.setProductName(rs.getString("ProductName"));
                item.setUnit(rs.getString("Unit"));
                item.setSystemQuantity(rs.getInt("SystemQuantity"));
                item.setPhysicalQuantity(rs.getInt("PhysicalQuantity"));
                item.setVariance(rs.getInt("PhysicalQuantity") - rs.getInt("SystemQuantity"));
                item.setStatus(rs.getString("Status"));

                int approvedBy = rs.getInt("ApprovedBy");
                if (rs.wasNull()) {
                    item.setApprovedBy(null);
                } else {
                    item.setApprovedBy(approvedBy);
                }

                item.setDate(rs.getDate("Date"));
                list.add(item);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnection();
        }

        return list;
    }

    public InventoryCheckItem getInventoryCountById(int countId) {
        String sql = """
        SELECT ic.CountID,
               ic.ProductID,
               p.SKU,
               p.Name AS ProductName,
               p.Unit,
               ic.SystemQuantity,
               ic.PhysicalQuantity,
               ic.Status,
               ic.ApprovedBy,
               ic.Date
        FROM InventoryCounts ic
        JOIN Products p ON ic.ProductID = p.ProductID
        WHERE ic.CountID = ?
    """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, countId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                InventoryCheckItem item = new InventoryCheckItem();
                item.setCountId(rs.getInt("CountID"));
                item.setProductId(rs.getInt("ProductID"));
                item.setSku(rs.getString("SKU"));
                item.setProductName(rs.getString("ProductName"));
                item.setUnit(rs.getString("Unit"));
                item.setSystemQuantity(rs.getInt("SystemQuantity"));
                item.setPhysicalQuantity(rs.getInt("PhysicalQuantity"));
                item.setVariance(rs.getInt("PhysicalQuantity") - rs.getInt("SystemQuantity"));
                item.setStatus(rs.getString("Status"));

                int approvedBy = rs.getInt("ApprovedBy");
                if (rs.wasNull()) {
                    item.setApprovedBy(null);
                } else {
                    item.setApprovedBy(approvedBy);
                }

                item.setDate(rs.getDate("Date"));
                return item;
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnection();
        }

        return null;
    }

    public boolean updateInventoryCount(InventoryCheckItem item) {
        String sql = """
        UPDATE InventoryCounts
        SET PhysicalQuantity = ?,
            SystemQuantity = ?,
            Status = ?,
            Date = ?
        WHERE CountID = ?
    """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, item.getPhysicalQuantity());
            ps.setInt(2, item.getSystemQuantity());
            ps.setString(3, item.getStatus());
            ps.setDate(4, item.getDate());
            ps.setInt(5, item.getCountId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnection();
        }

        return false;
    }

    public List<InventoryCheckItem> searchProductsForCounting(String keyword) {
        List<InventoryCheckItem> list = new ArrayList<>();

        String sql = """
            SELECT p.ProductID,
                   p.SKU,
                   p.Name,
                   p.Unit,
                   p.StockQuantity
            FROM Products p
            WHERE p.Status = 'Active'
              AND (? IS NULL OR ? = '' OR p.Name LIKE ? OR p.SKU LIKE ?)
            ORDER BY p.Name
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            String k = keyword == null ? "" : keyword.trim();
            String like = "%" + k + "%";

            ps.setString(1, k);
            ps.setString(2, k);
            ps.setString(3, like);
            ps.setString(4, like);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                InventoryCheckItem item = new InventoryCheckItem();
                item.setProductId(rs.getInt("ProductID"));
                item.setSku(rs.getString("SKU"));
                item.setProductName(rs.getString("Name"));
                item.setUnit(rs.getString("Unit"));
                item.setSystemQuantity(rs.getInt("StockQuantity"));
                item.setPhysicalQuantity(null);
                item.setVariance(0);
                item.setStatus("Pending");
                list.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnection();
        }

        return list;
    }

    public boolean saveInventoryCounts(List<InventoryCheckItem> items) {
        String sql = "INSERT INTO InventoryCounts "
                + "(ProductID, PhysicalQuantity, SystemQuantity, Status, Date) "
                + "VALUES (?, ?, ?, ?, ?)";

        try {
            connection.setAutoCommit(false);
            PreparedStatement ps = connection.prepareStatement(sql);

            for (InventoryCheckItem item : items) {
                if (item.getPhysicalQuantity() == null) {
                    continue;
                }

                ps.setInt(1, item.getProductId());
                ps.setInt(2, item.getPhysicalQuantity());
                ps.setInt(3, item.getSystemQuantity());
                ps.setString(4, "Pending");
                ps.setDate(5, new Date(System.currentTimeMillis()));
                ps.addBatch();
            }

            ps.executeBatch();
            connection.commit();
            connection.setAutoCommit(true);
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                connection.rollback();
                connection.setAutoCommit(true);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } finally {
            closeConnection();
        }

        return false;
    }
}
