package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import utils.DBContext;

public class DashboardDAO extends DBContext {

    public double getRevenueToday() {
        String sql = """
            SELECT ISNULL(SUM(TotalAmount), 0)
            FROM dbo.StockOut
            WHERE CAST([Date] AS DATE) = CAST(GETDATE() AS DATE)
        """;
        return getSingleRevenue(sql);
    }

    public double getRevenueThisWeek() {
        String sql = """
            SELECT ISNULL(SUM(TotalAmount), 0)
            FROM dbo.StockOut
            WHERE DATEPART(YEAR, [Date]) = DATEPART(YEAR, GETDATE())
              AND DATEPART(WEEK, [Date]) = DATEPART(WEEK, GETDATE())
        """;
        return getSingleRevenue(sql);
    }

    public double getRevenueThisMonth() {
        String sql = """
            SELECT ISNULL(SUM(TotalAmount), 0)
            FROM dbo.StockOut
            WHERE YEAR([Date]) = YEAR(GETDATE())
              AND MONTH([Date]) = MONTH(GETDATE())
        """;
        return getSingleRevenue(sql);
    }

    private double getSingleRevenue(String sql) {
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}