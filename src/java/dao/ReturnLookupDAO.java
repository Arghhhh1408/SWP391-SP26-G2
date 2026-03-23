package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.ReturnLookupResult;
import utils.DBContext;

public class ReturnLookupDAO extends DBContext {

    public List<ReturnLookupResult> lookupByStockOutId(int stockOutId) {
        List<ReturnLookupResult> list = new ArrayList<>();

        String sql = """
            SELECT
                p.SKU AS ProductCode,
                p.Name AS ProductName,
                c.Name AS CustomerName,
                c.Phone AS CustomerPhone,
                CAST(o.[Date] AS date) AS PurchaseDate
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
                list.add(new ReturnLookupResult(
                        rs.getString("ProductCode"),
                        rs.getString("ProductName"),
                        rs.getString("CustomerName"),
                        rs.getString("CustomerPhone"),
                        rs.getDate("PurchaseDate").toLocalDate()
                ));
            }
        } catch (Exception e) {
            // ignore
        }

        return list;
    }
}

