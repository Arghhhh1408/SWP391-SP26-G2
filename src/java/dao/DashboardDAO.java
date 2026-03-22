package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import utils.DBContext;

public class DashboardDAO extends DBContext {

    // 1. Doanh thu ngày hôm nay
    public double getRevenueToday() {
        double total = 0;
        // CAST(Date AS DATE) để bỏ qua phần giờ phút giây, so sánh chính xác ngày
        String sql = "SELECT SUM(TotalAmount) FROM dbo.StockOut "
                   + "WHERE CAST(Date AS DATE) = CAST(GETDATE() AS DATE) "
                   + "AND Status = 'Completed'";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) total = rs.getDouble(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }

    // 2. Doanh thu tuần này (7 ngày gần nhất)
    public double getRevenueWeek() {
        double total = 0;
        String sql = "SELECT SUM(TotalAmount) FROM dbo.StockOut "
                   + "WHERE Date >= DATEADD(day, -7, GETDATE()) "
                   + "AND Status = 'Completed'";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) total = rs.getDouble(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }

    // 3. Doanh thu tháng này
    public double getRevenueMonth() {
        double total = 0;
        String sql = "SELECT SUM(TotalAmount) FROM dbo.StockOut "
                   + "WHERE MONTH(Date) = MONTH(GETDATE()) "
                   + "AND YEAR(Date) = YEAR(GETDATE()) "
                   + "AND Status = 'Completed'";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) total = rs.getDouble(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
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