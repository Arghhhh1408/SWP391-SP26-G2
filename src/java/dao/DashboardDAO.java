package dao;
import model.TopProductSales;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.TopProductSales;
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
    public List<TopProductSales> getTopSellingProducts() {
    List<TopProductSales> list = new ArrayList<>();
    String sql = "SELECT TOP 5 p.Name, SUM(sd.Quantity) as TotalSold, "
               + "SUM(sd.Quantity * sd.UnitPrice) as TotalRevenue "
               + "FROM StockOutDetails sd "
               + "JOIN Products p ON sd.ProductID = p.ProductID "
               + "JOIN StockOut s ON sd.StockOutID = s.StockOutID "
               + "WHERE MONTH(s.Date) = MONTH(GETDATE()) AND YEAR(s.Date) = YEAR(GETDATE()) "
               + "GROUP BY p.Name "
               + "ORDER BY TotalSold DESC";

    // Sử dụng biến connection có sẵn của class DAO
    try (PreparedStatement ps = connection.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
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
        e.printStackTrace();
    }
    return list;
}
}