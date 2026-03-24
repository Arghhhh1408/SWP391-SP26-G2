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

    public int countProductsForCounting(String keyword) {
        String sql = """
            SELECT COUNT(*)
            FROM Products p
            WHERE p.Status = 'Active'
              AND (? IS NULL OR ? = '' OR p.Name LIKE ? OR p.SKU LIKE ?)
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
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnection();
        }
        return 0;
    }

    public List<InventoryCheckItem> searchProductsForCounting(String keyword, int page, int pageSize) {
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
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            String k = keyword == null ? "" : keyword.trim();
            String like = "%" + k + "%";
            int offset = (page - 1) * pageSize;

            ps.setString(1, k);
            ps.setString(2, k);
            ps.setString(3, like);
            ps.setString(4, like);
            ps.setInt(5, offset);
            ps.setInt(6, pageSize);

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

    public List<InventoryCheckItem> getCheckedProductSummaries() {
        List<InventoryCheckItem> list = new ArrayList<>();

        String sql = """
            SELECT 
                p.ProductID,
                p.SKU,
                p.Name AS ProductName,
                p.Unit,
                COUNT(ic.CountID) AS TotalCheckTimes,
                MAX(ic.Date) AS LastCheckDate,
                (
                    SELECT TOP 1 ic2.Status
                    FROM InventoryCounts ic2
                    WHERE ic2.ProductID = p.ProductID
                    ORDER BY ic2.CountID DESC
                ) AS LastStatus
            FROM InventoryCounts ic
            JOIN Products p ON ic.ProductID = p.ProductID
            GROUP BY p.ProductID, p.SKU, p.Name, p.Unit
            ORDER BY MAX(ic.Date) DESC, p.Name
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                InventoryCheckItem item = new InventoryCheckItem();
                item.setProductId(rs.getInt("ProductID"));
                item.setSku(rs.getString("SKU"));
                item.setProductName(rs.getString("ProductName"));
                item.setUnit(rs.getString("Unit"));
                item.setTotalCheckTimes(rs.getInt("TotalCheckTimes"));
                item.setDate(rs.getDate("LastCheckDate"));
                item.setStatus(rs.getString("LastStatus"));
                list.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnection();
        }

        return list;
    }

    public List<InventoryCheckItem> getInventoryHistoryByProductId(int productId) {
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
                   ic.Date,
                   ic.Reason,
                   ic.SessionCode,
                   ic.CreatedBy,
                   u1.FullName AS CreatedByName,
                   ic.ApprovedBy,
                   u2.FullName AS ApprovedByName,
                   ic.ApprovedAt
            FROM InventoryCounts ic
            JOIN Products p ON ic.ProductID = p.ProductID
            LEFT JOIN [User] u1 ON ic.CreatedBy = u1.UserID
            LEFT JOIN [User] u2 ON ic.ApprovedBy = u2.UserID
            WHERE ic.ProductID = ?
            ORDER BY ic.Date DESC, ic.CountID DESC
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, productId);
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
                item.setDate(rs.getDate("Date"));
                item.setReason(rs.getString("Reason"));
                item.setSessionCode(rs.getString("SessionCode"));

                int createdBy = rs.getInt("CreatedBy");
                if (rs.wasNull()) {
                    item.setCreatedBy(null);
                } else {
                    item.setCreatedBy(createdBy);
                }

                int approvedBy = rs.getInt("ApprovedBy");
                if (rs.wasNull()) {
                    item.setApprovedBy(null);
                } else {
                    item.setApprovedBy(approvedBy);
                }

                item.setApprovedAt(rs.getTimestamp("ApprovedAt"));
                item.setCreatedByName(rs.getString("CreatedByName"));
                item.setApprovedByName(rs.getString("ApprovedByName"));
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
                   ic.Date,
                   ic.Reason,
                   ic.SessionCode,
                   ic.CreatedBy,
                   u1.FullName AS CreatedByName,
                   ic.ApprovedBy,
                   u2.FullName AS ApprovedByName,
                   ic.ApprovedAt
            FROM InventoryCounts ic
            JOIN Products p ON ic.ProductID = p.ProductID
            LEFT JOIN [User] u1 ON ic.CreatedBy = u1.UserID
            LEFT JOIN [User] u2 ON ic.ApprovedBy = u2.UserID
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
                item.setDate(rs.getDate("Date"));
                item.setReason(rs.getString("Reason"));
                item.setSessionCode(rs.getString("SessionCode"));

                int createdBy = rs.getInt("CreatedBy");
                if (rs.wasNull()) {
                    item.setCreatedBy(null);
                } else {
                    item.setCreatedBy(createdBy);
                }

                int approvedBy = rs.getInt("ApprovedBy");
                if (rs.wasNull()) {
                    item.setApprovedBy(null);
                } else {
                    item.setApprovedBy(approvedBy);
                }

                item.setApprovedAt(rs.getTimestamp("ApprovedAt"));
                item.setCreatedByName(rs.getString("CreatedByName"));
                item.setApprovedByName(rs.getString("ApprovedByName"));
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
            Date = ?,
            Reason = ?
        WHERE CountID = ?
    """;

        try {
            String finalReason = item.getReason();
            if (item.getPhysicalQuantity() != null
                    && item.getPhysicalQuantity().intValue() == item.getSystemQuantity()) {
                finalReason = null;
            }

            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, item.getPhysicalQuantity());
            ps.setInt(2, item.getSystemQuantity());
            ps.setString(3, item.getStatus());
            ps.setDate(4, item.getDate());
            ps.setString(5, finalReason);
            ps.setInt(6, item.getCountId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnection();
        }

        return false;
    }

    public boolean saveInventoryCounts(List<InventoryCheckItem> items, int createdBy) {
        String sql = """
            INSERT INTO InventoryCounts
            (ProductID, PhysicalQuantity, SystemQuantity, Status, Date, SessionCode, Reason, CreatedBy)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """;

        try {
            connection.setAutoCommit(false);
            PreparedStatement ps = connection.prepareStatement(sql);

            String sessionCode = "IC" + System.currentTimeMillis();

            for (InventoryCheckItem item : items) {
                if (item.getPhysicalQuantity() == null) {
                    continue;
                }

                ps.setInt(1, item.getProductId());
                ps.setInt(2, item.getPhysicalQuantity());
                ps.setInt(3, item.getSystemQuantity());
                ps.setString(4, "Pending");
                ps.setDate(5, new Date(System.currentTimeMillis()));
                ps.setString(6, sessionCode);
                ps.setString(7, item.getReason());
                ps.setInt(8, createdBy);
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

    public List<InventoryCheckItem> getPendingApprovalSessions() {
        List<InventoryCheckItem> list = new ArrayList<>();

        String sql = """
            SELECT 
                SessionCode,
                MIN(ic.Date) AS CreatedDate,
                MIN(ic.CreatedBy) AS CreatedBy,
                MIN(u.FullName) AS CreatedByName,
                COUNT(*) AS TotalItems,
                MAX(ic.Status) AS Status
            FROM InventoryCounts ic
            LEFT JOIN [User] u ON ic.CreatedBy = u.UserID
            WHERE ic.SessionCode IS NOT NULL
              AND ic.Status = 'Pending'
            GROUP BY ic.SessionCode
            ORDER BY MIN(Date) DESC, SessionCode DESC
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                InventoryCheckItem item = new InventoryCheckItem();
                item.setSessionCode(rs.getString("SessionCode"));
                item.setDate(rs.getDate("CreatedDate"));

                int createdBy = rs.getInt("CreatedBy");
                if (rs.wasNull()) {
                    item.setCreatedBy(null);
                } else {
                    item.setCreatedBy(createdBy);
                }

                item.setTotalCheckTimes(rs.getInt("TotalItems"));
                item.setStatus(rs.getString("Status"));
                item.setCreatedByName(rs.getString("CreatedByName"));
                list.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnection();
        }

        return list;
    }

    public List<InventoryCheckItem> getInventoryCountsBySessionCode(String sessionCode) {
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
                   ic.Date,
                   ic.Reason,
                   ic.SessionCode,
                   ic.CreatedBy,
                   u1.FullName AS CreatedByName,
                   ic.ApprovedBy,
                   u2.FullName AS ApprovedByName,
                   ic.ApprovedAt
            FROM InventoryCounts ic
            JOIN Products p ON ic.ProductID = p.ProductID
            LEFT JOIN [User] u1 ON ic.CreatedBy = u1.UserID
            LEFT JOIN [User] u2 ON ic.ApprovedBy = u2.UserID
            WHERE ic.SessionCode = ?
            ORDER BY p.Name, ic.CountID
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, sessionCode);
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
                item.setDate(rs.getDate("Date"));
                item.setReason(rs.getString("Reason"));
                item.setSessionCode(rs.getString("SessionCode"));

                int createdBy = rs.getInt("CreatedBy");
                if (rs.wasNull()) {
                    item.setCreatedBy(null);
                } else {
                    item.setCreatedBy(createdBy);
                }

                int approvedBy = rs.getInt("ApprovedBy");
                if (rs.wasNull()) {
                    item.setApprovedBy(null);
                } else {
                    item.setApprovedBy(approvedBy);
                }

                item.setApprovedAt(rs.getTimestamp("ApprovedAt"));
                item.setCreatedByName(rs.getString("CreatedByName"));
                item.setApprovedByName(rs.getString("ApprovedByName"));
                list.add(item);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnection();
        }

        return list;
    }

    public boolean approveInventorySession(String sessionCode, int managerId) {
        String selectSql = """
            SELECT ProductID, PhysicalQuantity
            FROM InventoryCounts
            WHERE SessionCode = ?
              AND Status = 'Pending'
        """;

        String updateProductSql = """
            UPDATE Products
            SET StockQuantity = ?
            WHERE ProductID = ?
        """;

        String updateCountSql = """
            UPDATE InventoryCounts
            SET Status = 'Approved',
                ApprovedBy = ?,
                ApprovedAt = GETDATE()
            WHERE SessionCode = ?
              AND Status = 'Pending'
        """;

        try {
            connection.setAutoCommit(false);

            PreparedStatement psSelect = connection.prepareStatement(selectSql);
            psSelect.setString(1, sessionCode);
            ResultSet rs = psSelect.executeQuery();

            PreparedStatement psProduct = connection.prepareStatement(updateProductSql);
            boolean hasRows = false;

            while (rs.next()) {
                hasRows = true;
                psProduct.setInt(1, rs.getInt("PhysicalQuantity"));
                psProduct.setInt(2, rs.getInt("ProductID"));
                psProduct.addBatch();
            }

            if (!hasRows) {
                connection.rollback();
                connection.setAutoCommit(true);
                return false;
            }

            psProduct.executeBatch();

            PreparedStatement psUpdate = connection.prepareStatement(updateCountSql);
            psUpdate.setInt(1, managerId);
            psUpdate.setString(2, sessionCode);

            int updated = psUpdate.executeUpdate();

            if (updated <= 0) {
                connection.rollback();
                connection.setAutoCommit(true);
                return false;
            }

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

    public boolean rejectInventorySession(String sessionCode, int managerId, String rejectReason) {
        String sql = """
            UPDATE InventoryCounts
            SET Status = 'Rejected',
                ApprovedBy = ?,
                ApprovedAt = GETDATE(),
                Reason = CASE
                            WHEN Reason IS NULL OR LTRIM(RTRIM(Reason)) = ''
                            THEN ?
                            ELSE Reason + ' | Reject reason: ' + ?
                         END
            WHERE SessionCode = ?
              AND Status = 'Pending'
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, managerId);
            ps.setString(2, rejectReason);
            ps.setString(3, rejectReason);
            ps.setString(4, sessionCode);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnection();
        }
        return false;
    }

    public Integer getCreatorIdBySessionCode(String sessionCode) {
        String sql = "SELECT MIN(CreatedBy) as CreatedBy FROM InventoryCounts WHERE SessionCode = ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, sessionCode);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int id = rs.getInt("CreatedBy");
                return rs.wasNull() ? null : id;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeConnection();
        }
        return null;
    }
}
