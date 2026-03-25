package dao;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.WarrantyLookupResult;
import utils.DBContext;

public class WarrantyLookupDAO extends DBContext {

    public static final int WARRANTY_MONTHS_POLICY = WarrantyLookupResult.STANDARD_WARRANTY_MONTHS;

    private static final String OPEN_CLAIM_MATCH = """
            EXISTS (
                SELECT 1 FROM dbo.WarrantyClaims wc
                WHERE wc.SKU = p.SKU
                  AND ISNULL(LTRIM(RTRIM(wc.CustomerPhone)), N'') = ISNULL(LTRIM(RTRIM(c.Phone)), N'')
                  AND wc.Status NOT IN (N'COMPLETED', N'CANCELLED', N'REJECTED')
            )
            """;

    private static final String CORE_FROM = """
            FROM dbo.StockOut o
            INNER JOIN dbo.StockOutDetails d ON o.StockOutID = d.StockOutID
            INNER JOIN dbo.Products p ON d.ProductID = p.ProductID
            LEFT JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
            """;

    private WarrantyLookupResult mapRow(ResultSet rs) throws Exception {
        int stockOutId = rs.getInt("StockOutID");
        int cid = rs.getInt("CustomerID");
        Integer customerId = rs.wasNull() ? null : cid;
        int detailId = rs.getInt("DetailID");

        String productCode = rs.getString("ProductCode");
        String productName = rs.getString("ProductName");
        String customerName = rs.getString("CustomerName");
        String customerPhone = rs.getString("CustomerPhone");
        String serialNumber = rs.getString("SerialNumber");
        String imageUrl = rs.getString("ImageURL");
        int quantity = rs.getInt("Quantity");
        double unitPrice = rs.getDouble("UnitPrice");
        String email = rs.getString("Email");

        LocalDate purchaseDate = rs.getDate("PurchaseDate").toLocalDate();
        int warrantyMonths = rs.getInt("WarrantyMonths");
        LocalDate warrantyEndDate = rs.getDate("WarrantyEndDate").toLocalDate();
        String status = rs.getString("Status");

        boolean hasOpenClaim = rs.getInt("HasOpenClaim") == 1;
        String uiStatus = WarrantyLookupResult.computeUiStatus(hasOpenClaim, warrantyEndDate);

        return new WarrantyLookupResult(
                "line",
                null,
                stockOutId,
                customerId,
                detailId,
                productCode,
                productName,
                serialNumber,
                imageUrl,
                quantity,
                unitPrice,
                email,
                customerName,
                customerPhone,
                purchaseDate,
                warrantyMonths,
                warrantyEndDate,
                status,
                uiStatus
        );
    }

    private String buildSelectList() {
        int m = WARRANTY_MONTHS_POLICY;
        return String.format("""
                SELECT
                    o.StockOutID,
                    o.CustomerID,
                    d.DetailID,
                    d.Quantity,
                    d.UnitPrice AS UnitPrice,
                    p.SKU AS ProductCode,
                    p.Name AS ProductName,
                    p.ImageURL AS ImageURL,
                    c.Name AS CustomerName,
                    c.Phone AS CustomerPhone,
                    c.Email AS Email,
                    (N'SN-' + CAST(o.StockOutID AS varchar(20)) + N'-' + CAST(d.DetailID AS varchar(20))) AS SerialNumber,
                    CAST(o.[Date] AS date) AS PurchaseDate,
                    %d AS WarrantyMonths,
                    CAST(DATEADD(month, %d, CAST(o.[Date] AS date)) AS date) AS WarrantyEndDate,
                    CASE
                        WHEN DATEADD(month, %d, CAST(o.[Date] AS date)) >= CAST(GETDATE() AS date) THEN N'Còn bảo hành'
                        ELSE N'Hết bảo hành'
                    END AS Status,
                    CAST(CASE WHEN %s THEN 1 ELSE 0 END AS int) AS HasOpenClaim
                """, m, m, m, OPEN_CLAIM_MATCH);
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

    private void appendWarrantyFilter(StringBuilder sql, String warrantyFilter) {
        if (warrantyFilter == null || warrantyFilter.isBlank() || "all".equalsIgnoreCase(warrantyFilter)) {
            return;
        }
        String f = warrantyFilter.trim().toLowerCase();
        String endExpr = "CAST(DATEADD(month, " + WARRANTY_MONTHS_POLICY + ", CAST(o.[Date] AS date)) AS date)";
        String today = "CAST(GETDATE() AS date)";
        switch (f) {
            case "in_warranty" ->
                sql.append(" AND ").append(endExpr).append(" >= ").append(today)
                        .append(" AND DATEDIFF(day, ").append(today).append(", ").append(endExpr).append(") > 30 ");
            case "expiring" ->
                sql.append(" AND ").append(endExpr).append(" >= ").append(today)
                        .append(" AND DATEDIFF(day, ").append(today).append(", ").append(endExpr).append(") >= 0 ")
                        .append(" AND DATEDIFF(day, ").append(today).append(", ").append(endExpr).append(") <= 30 ");
            case "expired" ->
                sql.append(" AND ").append(endExpr).append(" < ").append(today).append(" ");
            case "processing" ->
                sql.append(" AND ").append(OPEN_CLAIM_MATCH).append(" ");
            default -> {
            }
        }
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

    public int countUnifiedSearch(String keyword, String warrantyFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS cnt ").append(CORE_FROM).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        appendKeywordFilter(sql, params, keyword);
        appendWarrantyFilter(sql, warrantyFilter);
        try {
            PreparedStatement stm = connection.prepareStatement(sql.toString());
            bindSearchParamsFrom(stm, 1, params);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                return rs.getInt("cnt");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<WarrantyLookupResult> searchUnified(String keyword, String warrantyFilter, String sortKey, int page, int pageSize) {
        List<WarrantyLookupResult> list = new ArrayList<>();
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
        appendWarrantyFilter(sql, warrantyFilter);
        appendOrderBy(sql, sortKey);
        sql.append(" OFFSET ").append(offset).append(" ROWS FETCH NEXT ").append(pageSize).append(" ROWS ONLY");

        try {
            PreparedStatement stm = connection.prepareStatement(sql.toString());
            bindSearchParamsFrom(stm, 1, params);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<WarrantyLookupResult> lookupByStockOutId(int stockOutId) {
        List<WarrantyLookupResult> list = new ArrayList<>();
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

    public WarrantyLookupResult lookupItemByStockOutIdAndSku(int stockOutId, String sku) {
        if (sku == null || sku.trim().isEmpty()) {
            return null;
        }
        String sql = buildSelectList() + CORE_FROM + """
                 WHERE o.StockOutID = ?
                   AND p.SKU = ?
                ORDER BY d.DetailID
                OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY
                """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, stockOutId);
            stm.setString(2, sku.trim());
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isItemInWarranty(int stockOutId, String sku) {
        WarrantyLookupResult r = lookupItemByStockOutIdAndSku(stockOutId, sku);
        return r != null && r.isInWarranty();
    }

    public LocalDate getLatestPurchaseDateForSkuAndPhone(String sku, String customerPhone) {
        if (sku == null || sku.isBlank()) {
            return null;
        }
        String phone = customerPhone == null ? "" : customerPhone.trim();
        String sql = """
                SELECT TOP 1 CAST(o.[Date] AS date) AS PurchaseDate
                FROM dbo.StockOut o
                INNER JOIN dbo.StockOutDetails d ON o.StockOutID = d.StockOutID
                INNER JOIN dbo.Products p ON d.ProductID = p.ProductID
                LEFT JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
                WHERE p.SKU = ?
                  AND (
                        ? = ''
                        OR (c.Phone IS NOT NULL AND LTRIM(RTRIM(c.Phone)) = ?)
                  )
                ORDER BY o.[Date] DESC, o.StockOutID DESC, d.DetailID DESC
                """;
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, sku.trim());
            stm.setString(2, phone);
            stm.setString(3, phone);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                Date d = rs.getDate("PurchaseDate");
                return d == null ? null : d.toLocalDate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isWarrantyExpiredBySkuAndPhone(String sku, String customerPhone) {
        LocalDate purchase = getLatestPurchaseDateForSkuAndPhone(sku, customerPhone);
        if (purchase == null) {
            return true;
        }
        LocalDate end = purchase.plusMonths(WARRANTY_MONTHS_POLICY);
        return LocalDate.now().isAfter(end);
    }

    private void bindSearchParamsFrom(PreparedStatement stm, int idx, List<Object> params) throws Exception {
        for (Object p : params) {
            if (p instanceof String) {
                stm.setNString(idx++, (String) p);
            } else {
                stm.setObject(idx++, p);
            }
        }
    }
}
