package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.ReturnLookupResult;
import utils.DBContext;

/**
 * Tra cứu dòng bán hàng để lập yêu cầu trả hàng (từ khóa giống tra cứu bảo hành).
 */
public class ReturnLookupDAO extends DBContext {

    private static final String CORE_FROM = """
            FROM dbo.StockOut o
            INNER JOIN dbo.StockOutDetails d ON o.StockOutID = d.StockOutID
            INNER JOIN dbo.Products p ON d.ProductID = p.ProductID
            LEFT JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
            """;

    private String buildSelectList() {
        return """
                SELECT
                    o.StockOutID,
                    d.DetailID,
                    d.Quantity,
                    d.UnitPrice,
                    p.SKU AS ProductCode,
                    p.Name AS ProductName,
                    p.ImageURL AS ImageURL,
                    c.Name AS CustomerName,
                    c.Phone AS CustomerPhone,
                    c.Email AS Email,
                    (N'SN-' + CAST(o.StockOutID AS varchar(20)) + N'-' + CAST(d.DetailID AS varchar(20))) AS SerialNumber,
                    CAST(o.[Date] AS date) AS PurchaseDate
                """;
    }

    private void appendKeywordFilter(StringBuilder sql, List<Object> params, String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return;
        }
        String raw = keyword.trim();
        String k = "%" + raw + "%";
        // Chỉ search theo: SKU, tên sản phẩm, và SĐT khách hàng.
        sql.append("""
                 AND (
                    p.SKU LIKE ?
                    OR p.Name LIKE ?
                    OR (c.Phone IS NOT NULL AND c.Phone LIKE ?)
                 )
                """);
        params.add(k);
        params.add(k);
        params.add(k);
    }

    private void appendOrderBy(StringBuilder sql, String sortKey) {
        if (sortKey == null) {
            sortKey = "purchase_date";
        }
        switch (sortKey.trim().toLowerCase()) {
            case "sku" -> sql.append(" ORDER BY p.SKU ASC, o.[Date] DESC, o.StockOutID DESC, d.DetailID ");
            case "serial" -> sql.append(" ORDER BY o.StockOutID DESC, d.DetailID DESC ");
            default -> sql.append(" ORDER BY o.[Date] DESC, o.StockOutID DESC, d.DetailID ");
        }
    }

    private ReturnLookupResult mapRow(ResultSet rs) throws Exception {
        return new ReturnLookupResult(
                rs.getInt("StockOutID"),
                rs.getInt("DetailID"),
                rs.getString("ProductCode"),
                rs.getString("ProductName"),
                rs.getString("CustomerName"),
                rs.getString("CustomerPhone"),
                rs.getString("Email"),
                rs.getString("SerialNumber"),
                rs.getString("ImageURL"),
                rs.getInt("Quantity"),
                rs.getDate("PurchaseDate").toLocalDate(),
                rs.getDouble("UnitPrice")
        );
    }

    private void bindParams(PreparedStatement stm, List<Object> params) throws Exception {
        int idx = 1;
        for (Object p : params) {
            if (p instanceof String) {
                stm.setNString(idx++, (String) p);
            } else {
                stm.setObject(idx++, p);
            }
        }
    }

    public int countUnifiedSearch(String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS cnt ").append(CORE_FROM).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendKeywordFilter(sql, params, keyword);
        try {
            PreparedStatement stm = connection.prepareStatement(sql.toString());
            bindParams(stm, params);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<ReturnLookupResult> searchUnified(String keyword, String sortKey, int page, int pageSize) {
        List<ReturnLookupResult> list = new ArrayList<>();
        if (page < 1) {
            page = 1;
        }
        if (pageSize < 1) {
            pageSize = 10;
        }
        if (pageSize > 50) {
            pageSize = 50;
        }
        int offset = (page - 1) * pageSize;

        StringBuilder sql = new StringBuilder(buildSelectList()).append(CORE_FROM).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendKeywordFilter(sql, params, keyword);
        appendOrderBy(sql, sortKey);
        sql.append(" OFFSET ").append(offset).append(" ROWS FETCH NEXT ").append(pageSize).append(" ROWS ONLY");

        try {
            PreparedStatement stm = connection.prepareStatement(sql.toString());
            bindParams(stm, params);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Tra theo đúng một StockOutID (mọi dòng trong phiếu). */
    public List<ReturnLookupResult> lookupByStockOutId(int stockOutId) {
        List<ReturnLookupResult> list = new ArrayList<>();
        String sql = buildSelectList() + CORE_FROM + " WHERE o.StockOutID = ? ORDER BY d.DetailID";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, stockOutId);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
