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
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.LowStock;
import model.ReturnStatus;
import model.StaffHomeFeedItem;
import model.WarrantyClaimStatus;
import utils.DBContext;

public class StaffDashboardDAO extends DBContext {

    public double getPendingSupplierDebtAmount() {
        String sql = "SELECT ISNULL(SUM(Amount), 0) "
                + "FROM dbo.SupplierDebts "
                + "WHERE Status IN ('Partial', 'Pending')";
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
                + "WHERE Status IN ('Partial', 'Pending')";
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

    /** Số dòng sản phẩm đang Active trong danh mục. */
    public int countActiveProductsInCatalog() {
        String sql = "SELECT COUNT(*) FROM dbo.Products WHERE Status = N'Active'";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /** Tổng tiền các phiếu xuất/bán đã hoàn thành (StockOut.TotalAmount). */
    public double getTotalCompletedStockOutRevenue() {
        String sql = """
                SELECT ISNULL(SUM(TotalAmount), 0)
                FROM dbo.StockOut
                WHERE Status = N'Completed'
                """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getDouble(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /** Tổng số lượng sản phẩm đã bán (chi tiết phiếu xuất hoàn thành). */
    public long getTotalSoldUnitsFromStockOut() {
        String sql = """
                SELECT ISNULL(SUM(CAST(d.Quantity AS BIGINT)), 0)
                FROM dbo.StockOutDetails d
                INNER JOIN dbo.StockOut s ON s.StockOutID = d.StockOutID
                WHERE s.Status = N'Completed'
                """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getLong(1) : 0L;
        } catch (Exception e) {
            e.printStackTrace();
            return 0L;
        }
    }

    /**
     * Gộp yêu cầu bảo hành + đổi trả, sắp xếp theo thời gian cập nhật mới nhất.
     */
    public List<StaffHomeFeedItem> getWarrantyAndReturnFeed(int maxRows) {
        List<StaffHomeFeedItem> list = new ArrayList<>();
        if (maxRows < 1) {
            maxRows = 50;
        }
        if (maxRows > 200) {
            maxRows = 200;
        }
        String sql = """
                SELECT TOP (?) *
                FROM (
                    SELECT N'WARRANTY' AS TypeName,
                           ClaimID AS RefId,
                           ISNULL(ClaimCode, N'') AS Code,
                           ISNULL(ProductName, N'') AS ProductLine,
                           ISNULL(CustomerName, N'') AS CustLine,
                           ISNULL(Status, N'') AS RawStatus,
                           UpdatedAt AS ActivityAt
                    FROM dbo.WarrantyClaims
                    UNION ALL
                    SELECT N'RETURN',
                           ReturnID,
                           ISNULL(ReturnCode, N''),
                           ISNULL(ProductName, N''),
                           ISNULL(CustomerName, N''),
                           ISNULL(Status, N''),
                           UpdatedAt
                    FROM dbo.ReturnRequests
                ) AS u
                ORDER BY ActivityAt DESC
                """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, maxRows);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                StaffHomeFeedItem it = new StaffHomeFeedItem();
                String tn = rs.getString("TypeName");
                it.setType(StaffHomeFeedItem.TYPE_RETURN.equals(tn) ? StaffHomeFeedItem.TYPE_RETURN : StaffHomeFeedItem.TYPE_WARRANTY);
                it.setRefId(rs.getInt("RefId"));
                it.setCode(rs.getString("Code"));
                it.setProductLine(rs.getString("ProductLine"));
                it.setCustomerLine(rs.getString("CustLine"));
                String raw = rs.getString("RawStatus");
                if (StaffHomeFeedItem.TYPE_WARRANTY.equals(it.getType())) {
                    it.setStatusLabel(mapWarrantyStatusVi(raw));
                } else {
                    it.setStatusLabel(mapReturnStatusVi(raw));
                }
                Timestamp ts = rs.getTimestamp("ActivityAt");
                if (ts != null) {
                    it.setActivityTime(ts.toLocalDateTime());
                }
                list.add(it);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private static String mapWarrantyStatusVi(String raw) {
        if (raw == null || raw.isBlank()) {
            return "";
        }
        try {
            return WarrantyClaimStatus.valueOf(raw.trim()).getLabelVi();
        } catch (Exception e) {
            return raw;
        }
    }

    private static String mapReturnStatusVi(String raw) {
        if (raw == null || raw.isBlank()) {
            return "";
        }
        try {
            ReturnStatus s = ReturnStatus.valueOf(raw.trim());
            return switch (s) {
                case NEW -> "Đang xử lý";
                case RECEIVED -> "Đã tiếp nhận";
                case INSPECTING -> "Đang kiểm tra";
                case APPROVED -> "Đã xác nhận";
                case REJECTED -> "Từ chối";
                case REFUNDED -> "Đã hoàn tiền";
                case COMPLETED -> "Hoàn thành";
                case CANCELLED -> "Đã hủy";
            };
        } catch (Exception e) {
            return raw;
        }
    }
}
