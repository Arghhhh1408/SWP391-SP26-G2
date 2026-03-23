package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.WarrantyLookupResult;
import utils.DBContext;

public class WarrantyLookupDAO extends DBContext {

    public List<WarrantyLookupResult> lookupByStockOutId(int stockOutId) {
        List<WarrantyLookupResult> list = new ArrayList<>();

        String sql = """
            SELECT DISTINCT
                p.SKU AS ProductCode,
                p.Name AS ProductName,
                c.Name AS CustomerName,
                c.Phone AS CustomerPhone,
                CAST(o.[Date] AS date) AS PurchaseDate,
                p.WarrantyPeriod AS WarrantyMonths,
                CAST(DATEADD(month, p.WarrantyPeriod, o.[Date]) AS date) AS WarrantyEndDate,
                CASE
                    WHEN p.WarrantyPeriod IS NULL OR p.WarrantyPeriod <= 0 THEN N'Không có bảo hành'
                    WHEN DATEADD(month, p.WarrantyPeriod, o.[Date]) >= GETDATE() THEN N'Còn bảo hành'
                    ELSE N'Hết bảo hành'
                END AS Status
            FROM dbo.StockOut o
            INNER JOIN dbo.StockOutDetails d ON o.StockOutID = d.StockOutID
            INNER JOIN dbo.Products p ON d.ProductID = p.ProductID
            LEFT JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
            WHERE o.StockOutID = ?
            """;

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, stockOutId);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                String productCode = rs.getString("ProductCode");
                String productName = rs.getString("ProductName");

                String customerName = rs.getString("CustomerName");
                String customerPhone = rs.getString("CustomerPhone");

                LocalDate purchaseDate = rs.getDate("PurchaseDate").toLocalDate();
                int warrantyMonths = rs.getInt("WarrantyMonths");
                LocalDate warrantyEndDate = rs.getDate("WarrantyEndDate").toLocalDate();

                String status = rs.getString("Status");

                list.add(new WarrantyLookupResult(
                        "stockOutId",
                        String.valueOf(stockOutId),
                        productCode,
                        productName,
                        null,
                        customerName,
                        customerPhone,
                        purchaseDate,
                        warrantyMonths,
                        warrantyEndDate,
                        status
                ));
            }
        } catch (Exception e) {
            // ignore
        }
        return list;
    }

    public WarrantyLookupResult lookupItemByStockOutIdAndSku(int stockOutId, String sku) {
        if (sku == null || sku.trim().isEmpty()) {
            return null;
        }

        String sql = """
            SELECT TOP 1
                p.SKU AS ProductCode,
                p.Name AS ProductName,
                c.Name AS CustomerName,
                c.Phone AS CustomerPhone,
                CAST(o.[Date] AS date) AS PurchaseDate,
                p.WarrantyPeriod AS WarrantyMonths,
                CAST(DATEADD(month, p.WarrantyPeriod, o.[Date]) AS date) AS WarrantyEndDate,
                CASE
                    WHEN p.WarrantyPeriod IS NULL OR p.WarrantyPeriod <= 0 THEN N'Không có bảo hành'
                    WHEN DATEADD(month, p.WarrantyPeriod, o.[Date]) >= GETDATE() THEN N'Còn bảo hành'
                    ELSE N'Hết bảo hành'
                END AS Status
            FROM dbo.StockOut o
            INNER JOIN dbo.StockOutDetails d ON o.StockOutID = d.StockOutID
            INNER JOIN dbo.Products p ON d.ProductID = p.ProductID
            LEFT JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
            WHERE o.StockOutID = ?
              AND p.SKU = ?
            """;

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, stockOutId);
            stm.setString(2, sku.trim());
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                String productCode = rs.getString("ProductCode");
                String productName = rs.getString("ProductName");
                String customerName = rs.getString("CustomerName");
                String customerPhone = rs.getString("CustomerPhone");

                LocalDate purchaseDate = rs.getDate("PurchaseDate").toLocalDate();
                int warrantyMonths = rs.getInt("WarrantyMonths");
                LocalDate warrantyEndDate = rs.getDate("WarrantyEndDate").toLocalDate();
                String status = rs.getString("Status");

                return new WarrantyLookupResult(
                        "stockOutId",
                        String.valueOf(stockOutId),
                        productCode,
                        productName,
                        null,
                        customerName,
                        customerPhone,
                        purchaseDate,
                        warrantyMonths,
                        warrantyEndDate,
                        status
                );
            }
        } catch (Exception e) {
            // ignore
        }
        return null;
    }

    public boolean isItemInWarranty(int stockOutId, String sku) {
        WarrantyLookupResult r = lookupItemByStockOutIdAndSku(stockOutId, sku);
        return r != null && "Còn bảo hành".equals(r.getStatus());
    }
}

