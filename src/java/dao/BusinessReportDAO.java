package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.DailySales;
import model.StatusCount;
import model.TopProductSales;
import utils.DBContext;

public class BusinessReportDAO extends DBContext {

    public Integer countProducts() {
        return queryInt("SELECT COUNT(*) FROM dbo.Products");
    }

    public Integer countActiveProducts() {
        return queryInt("SELECT COUNT(*) FROM dbo.Products WHERE Status = 'Active'");
    }

    public Integer countLowStockProducts(int threshold) {
        try {
            PreparedStatement stm = connection.prepareStatement(
                    "SELECT COUNT(*) FROM dbo.Products WHERE StockQuantity <= ?");
            stm.setInt(1, threshold);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getInt(1) : null;
        } catch (Exception e) {
            return null;
        }
    }

    public Double inventoryValueByCost() {
        return queryDouble("SELECT SUM(CAST(StockQuantity AS float) * CAST(Cost AS float)) FROM dbo.Products");
    }

    public Double inventoryValueByPrice() {
        return queryDouble("SELECT SUM(CAST(StockQuantity AS float) * CAST(Price AS float)) FROM dbo.Products");
    }

    public Double revenueToday() {
        return queryDouble("""
            SELECT SUM(CAST(TotalAmount AS float))
            FROM dbo.StockOut
            WHERE CAST([Date] AS date) = CAST(GETDATE() AS date)
        """);
    }

    public Integer ordersToday() {
        return queryInt("""
            SELECT COUNT(*)
            FROM dbo.StockOut
            WHERE CAST([Date] AS date) = CAST(GETDATE() AS date)
        """);
    }

    public Double revenueThisMonth() {
        return queryDouble("""
            SELECT SUM(CAST(TotalAmount AS float))
            FROM dbo.StockOut
            WHERE YEAR([Date]) = YEAR(GETDATE()) AND MONTH([Date]) = MONTH(GETDATE())
        """);
    }

    public Double stockInThisMonth() {
        // StockIn table is referenced without dbo in existing code; dbo.* usually works in SQL Server
        return queryDouble("""
            SELECT SUM(CAST(TotalAmount AS float))
            FROM dbo.StockIn
            WHERE YEAR([Date]) = YEAR(GETDATE()) AND MONTH([Date]) = MONTH(GETDATE())
        """);
    }

    public Double refundedThisMonth() {
        return queryDouble("""
            SELECT SUM(CAST(RefundAmount AS float))
            FROM dbo.ReturnRequests
            WHERE RefundedAt IS NOT NULL
              AND YEAR(RefundedAt) = YEAR(GETDATE()) AND MONTH(RefundedAt) = MONTH(GETDATE())
        """);
    }

    public List<DailySales> salesLast7Days() {
        List<DailySales> list = new ArrayList<>();
        String sql = """
            SELECT CAST([Date] AS date) AS Day,
                   COUNT(*) AS Orders,
                   SUM(CAST(TotalAmount AS float)) AS Revenue
            FROM dbo.StockOut
            WHERE [Date] >= DATEADD(day, -6, CAST(GETDATE() AS date))
            GROUP BY CAST([Date] AS date)
            ORDER BY Day
        """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                LocalDate day = rs.getDate("Day").toLocalDate();
                int orders = rs.getInt("Orders");
                double revenue = rs.getDouble("Revenue");
                list.add(new DailySales(day, orders, revenue));
            }
        } catch (Exception e) {
            // ignore: return empty list if missing table
        }
        return list;
    }

    public List<TopProductSales> topProductsLast30Days(int limit) {
        List<TopProductSales> list = new ArrayList<>();
        String sql = """
            SELECT TOP (?)
                   p.ProductID,
                   p.SKU,
                   p.Name,
                   SUM(d.Quantity) AS Qty,
                   SUM(CAST(d.SubTotal AS float)) AS Revenue
            FROM dbo.StockOutDetails d
            JOIN dbo.StockOut o ON o.StockOutID = d.StockOutID
            JOIN dbo.Products p ON p.ProductID = d.ProductID
            WHERE o.[Date] >= DATEADD(day, -30, GETDATE())
            GROUP BY p.ProductID, p.SKU, p.Name
            ORDER BY Revenue DESC
        """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, limit);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                TopProductSales t = new TopProductSales();
                t.setProductId(rs.getInt("ProductID"));
                t.setSku(rs.getString("SKU"));
                t.setName(rs.getString("Name"));
                t.setQuantity(rs.getInt("Qty"));
                t.setRevenue(rs.getDouble("Revenue"));
                list.add(t);
            }
        } catch (Exception e) {
            // ignore
        }
        return list;
    }

    public List<StatusCount> warrantyClaimsByStatus() {
        List<StatusCount> list = new ArrayList<>();
        String sql = """
            SELECT Status, COUNT(*) AS Cnt
            FROM dbo.WarrantyClaims
            GROUP BY Status
            ORDER BY Cnt DESC
        """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(new StatusCount(rs.getString("Status"), rs.getInt("Cnt")));
            }
        } catch (Exception e) {
            // ignore
        }
        return list;
    }

    public List<StatusCount> returnsByStatus() {
        List<StatusCount> list = new ArrayList<>();
        String sql = """
            SELECT Status, COUNT(*) AS Cnt
            FROM dbo.ReturnRequests
            GROUP BY Status
            ORDER BY Cnt DESC
        """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(new StatusCount(rs.getString("Status"), rs.getInt("Cnt")));
            }
        } catch (Exception e) {
            // ignore
        }
        return list;
    }

    private Integer queryInt(String sql) {
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getInt(1) : null;
        } catch (Exception e) {
            return null;
        }
    }

    private Double queryDouble(String sql) {
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            if (!rs.next()) {
                return null;
            }
            double v = rs.getDouble(1);
            if (rs.wasNull()) {
                return 0.0;
            }
            return v;
        } catch (Exception e) {
            return null;
        }
    }
}

