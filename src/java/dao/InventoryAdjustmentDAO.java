package dao;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.InventoryAdjustment;
import model.InventoryAdjustmentItem;
import utils.DBContext;

public class InventoryAdjustmentDAO extends DBContext {

    // -----------------------------------------------------------------------
    // Tìm kiếm sản phẩm để thêm vào phiếu (dùng cho autocomplete)
    // -----------------------------------------------------------------------
    public List<InventoryAdjustmentItem> searchProducts(String keyword) {
        List<InventoryAdjustmentItem> list = new ArrayList<>();
        String sql = """
            SELECT TOP 20
                p.ProductID, p.SKU, p.Name, p.Unit, p.StockQuantity, p.Cost, p.ImageURL
            FROM Products p
            WHERE p.Status = 'Active'
              AND (
                   p.Name COLLATE Latin1_General_CI_AI LIKE ?
                OR p.SKU  COLLATE Latin1_General_CI_AI LIKE ?
              )
            ORDER BY
                CASE
                    WHEN p.SKU COLLATE Latin1_General_CI_AI LIKE ? THEN 0
                    WHEN p.Name COLLATE Latin1_General_CI_AI LIKE ? THEN 1
                    ELSE 2
                END,
                p.Name
        """;
        try {
            String kw = (keyword == null ? "" : keyword.trim());
            String like = "%" + kw + "%";
            String startsWith = kw + "%";
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, startsWith);
            ps.setString(4, startsWith);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                InventoryAdjustmentItem item = new InventoryAdjustmentItem();
                item.setProductId(rs.getInt("ProductID"));
                item.setSku(rs.getString("SKU"));
                item.setProductName(rs.getString("Name"));
                item.setUnit(rs.getString("Unit"));
                item.setOldQuantity(rs.getInt("StockQuantity"));
                item.setUnitCost(rs.getBigDecimal("Cost"));
                item.setImageUrl(rs.getString("ImageURL"));
                list.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // -----------------------------------------------------------------------
    // Lấy thông tin 1 sản phẩm theo ProductID (để load tồn kho hiện tại)
    // -----------------------------------------------------------------------
    public InventoryAdjustmentItem getProductInfo(int productId) {
        String sql = """
            SELECT p.ProductID, p.SKU, p.Name, p.Unit, p.StockQuantity, p.Cost, p.ImageURL
            FROM Products p WHERE p.ProductID = ?
        """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                InventoryAdjustmentItem item = new InventoryAdjustmentItem();
                item.setProductId(rs.getInt("ProductID"));
                item.setSku(rs.getString("SKU"));
                item.setProductName(rs.getString("Name"));
                item.setUnit(rs.getString("Unit"));
                item.setOldQuantity(rs.getInt("StockQuantity"));
                item.setUnitCost(rs.getBigDecimal("Cost"));
                item.setImageUrl(rs.getString("ImageURL"));
                return item;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // -----------------------------------------------------------------------
    // Lưu phiếu điều chỉnh (Draft hoặc Confirmed)
    // Nếu status = Confirmed → cập nhật StockQuantity ngay
    // -----------------------------------------------------------------------
    public int saveAdjustment(InventoryAdjustment adj, List<InventoryAdjustmentItem> items) {
        String insertAdj = """
            INSERT INTO InventoryAdjustments
              (AdjustmentCode, AdjustmentDate, Warehouse, CreatedBy, GeneralReason, Note, Status, CreatedAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())
        """;
        String insertItem = """
            INSERT INTO InventoryAdjustmentItems
              (AdjustmentID, ProductID, OldQuantity, NewQuantity, Variance, Reason, ItemNote)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """;
        String updateStock = """
            UPDATE Products SET StockQuantity = ?, UpdatedDate = GETDATE() WHERE ProductID = ?
        """;

        try {
            connection.setAutoCommit(false);

            PreparedStatement psAdj = connection.prepareStatement(insertAdj, Statement.RETURN_GENERATED_KEYS);
            psAdj.setString(1, adj.getAdjustmentCode());
            psAdj.setString(2, adj.getAdjustmentDate());
            psAdj.setString(3, adj.getWarehouse());
            psAdj.setInt(4, adj.getCreatedBy());
            psAdj.setString(5, adj.getGeneralReason());
            psAdj.setString(6, adj.getNote());
            psAdj.setString(7, adj.getStatus());
            psAdj.executeUpdate();

            ResultSet keys = psAdj.getGeneratedKeys();
            if (!keys.next()) {
                connection.rollback();
                return -1;
            }
            int adjId = keys.getInt(1);

            PreparedStatement psItem = connection.prepareStatement(insertItem);
            for (InventoryAdjustmentItem item : items) {
                psItem.setInt(1, adjId);
                psItem.setInt(2, item.getProductId());
                psItem.setInt(3, item.getOldQuantity());
                psItem.setInt(4, item.getNewQuantity());
                psItem.setInt(5, item.getVariance());
                psItem.setString(6, item.getReason());
                psItem.setString(7, item.getItemNote());
                psItem.addBatch();
            }
            psItem.executeBatch();

            // Nếu xác nhận → cập nhật tồn kho ngay
            if ("Confirmed".equals(adj.getStatus())) {
                PreparedStatement psStock = connection.prepareStatement(updateStock);
                for (InventoryAdjustmentItem item : items) {
                    psStock.setInt(1, item.getNewQuantity());
                    psStock.setInt(2, item.getProductId());
                    psStock.addBatch();
                }
                psStock.executeBatch();
            }

            connection.commit();
            connection.setAutoCommit(true);
            return adjId;

        } catch (Exception e) {
            e.printStackTrace();
            try { connection.rollback(); connection.setAutoCommit(true); } catch (Exception ex) { ex.printStackTrace(); }
        }
        return -1;
    }

    // -----------------------------------------------------------------------
    // Xác nhận phiếu Draft → Confirmed (cập nhật tồn kho)
    // -----------------------------------------------------------------------
    public boolean confirmAdjustment(int adjustmentId) {
        String sqlConfirm = "UPDATE InventoryAdjustments SET Status = 'Confirmed' WHERE AdjustmentID = ? AND Status = 'Draft'";
        String sqlItems   = "SELECT ProductID, NewQuantity FROM InventoryAdjustmentItems WHERE AdjustmentID = ?";
        String sqlStock   = "UPDATE Products SET StockQuantity = ?, UpdatedDate = GETDATE() WHERE ProductID = ?";
        try {
            connection.setAutoCommit(false);

            PreparedStatement psConfirm = connection.prepareStatement(sqlConfirm);
            psConfirm.setInt(1, adjustmentId);
            int rows = psConfirm.executeUpdate();
            if (rows == 0) { connection.rollback(); connection.setAutoCommit(true); return false; }

            PreparedStatement psItems = connection.prepareStatement(sqlItems);
            psItems.setInt(1, adjustmentId);
            ResultSet rs = psItems.executeQuery();

            PreparedStatement psStock = connection.prepareStatement(sqlStock);
            while (rs.next()) {
                psStock.setInt(1, rs.getInt("NewQuantity"));
                psStock.setInt(2, rs.getInt("ProductID"));
                psStock.addBatch();
            }
            psStock.executeBatch();

            connection.commit();
            connection.setAutoCommit(true);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { connection.rollback(); connection.setAutoCommit(true); } catch (Exception ex) { ex.printStackTrace(); }
        }
        return false;
    }

    // -----------------------------------------------------------------------
    // Lấy danh sách phiếu (phân trang)
    // -----------------------------------------------------------------------
    public List<InventoryAdjustment> listAdjustments(int page, int pageSize) {
        List<InventoryAdjustment> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = """
            SELECT a.AdjustmentID, a.AdjustmentCode, a.AdjustmentDate, a.Warehouse,
                   a.GeneralReason, a.Note, a.Status, a.CreatedAt,
                   u.FullName AS CreatedByName,
                   COUNT(i.ItemID) AS TotalProducts,
                   SUM(CASE WHEN i.Variance > 0 THEN i.Variance ELSE 0 END) AS TotalIncrease,
                   SUM(CASE WHEN i.Variance < 0 THEN ABS(i.Variance) ELSE 0 END) AS TotalDecrease
            FROM InventoryAdjustments a
            LEFT JOIN [User] u ON a.CreatedBy = u.UserID
            LEFT JOIN InventoryAdjustmentItems i ON a.AdjustmentID = i.AdjustmentID
            GROUP BY a.AdjustmentID, a.AdjustmentCode, a.AdjustmentDate, a.Warehouse,
                     a.GeneralReason, a.Note, a.Status, a.CreatedAt, u.FullName
            ORDER BY a.CreatedAt DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapAdjustment(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countAdjustments() {
        try {
            PreparedStatement ps = connection.prepareStatement("SELECT COUNT(*) FROM InventoryAdjustments");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    // -----------------------------------------------------------------------
    // Lấy chi tiết 1 phiếu
    // -----------------------------------------------------------------------
    public InventoryAdjustment getAdjustmentById(int id) {
        String sql = """
            SELECT a.AdjustmentID, a.AdjustmentCode, a.AdjustmentDate, a.Warehouse,
                   a.GeneralReason, a.Note, a.Status, a.CreatedAt,
                   u.FullName AS CreatedByName,
                   COUNT(i.ItemID) AS TotalProducts,
                   SUM(CASE WHEN i.Variance > 0 THEN i.Variance ELSE 0 END) AS TotalIncrease,
                   SUM(CASE WHEN i.Variance < 0 THEN ABS(i.Variance) ELSE 0 END) AS TotalDecrease,
                   SUM(ABS(i.Variance) * ISNULL(p.Cost, 0)) AS TotalValueChange
            FROM InventoryAdjustments a
            LEFT JOIN [User] u ON a.CreatedBy = u.UserID
            LEFT JOIN InventoryAdjustmentItems i ON a.AdjustmentID = i.AdjustmentID
            LEFT JOIN Products p ON i.ProductID = p.ProductID
            WHERE a.AdjustmentID = ?
            GROUP BY a.AdjustmentID, a.AdjustmentCode, a.AdjustmentDate, a.Warehouse,
                     a.GeneralReason, a.Note, a.Status, a.CreatedAt, u.FullName
        """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                InventoryAdjustment adj = mapAdjustment(rs);
                try { adj.setTotalValueChange(rs.getBigDecimal("TotalValueChange")); } catch (Exception ignored) {}
                adj.setItems(getItemsByAdjustmentId(id));
                return adj;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public List<InventoryAdjustmentItem> getItemsByAdjustmentId(int adjustmentId) {
        List<InventoryAdjustmentItem> list = new ArrayList<>();
        String sql = """
            SELECT i.ItemID, i.ProductID, p.SKU, p.Name, p.Unit, p.ImageURL,
                   i.OldQuantity, i.NewQuantity, i.Variance, i.Reason, i.ItemNote, p.Cost
            FROM InventoryAdjustmentItems i
            JOIN Products p ON i.ProductID = p.ProductID
            WHERE i.AdjustmentID = ?
            ORDER BY i.ItemID
        """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, adjustmentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                InventoryAdjustmentItem item = new InventoryAdjustmentItem();
                item.setItemId(rs.getInt("ItemID"));
                item.setAdjustmentId(adjustmentId);
                item.setProductId(rs.getInt("ProductID"));
                item.setSku(rs.getString("SKU"));
                item.setProductName(rs.getString("Name"));
                item.setUnit(rs.getString("Unit"));
                item.setImageUrl(rs.getString("ImageURL"));
                item.setOldQuantity(rs.getInt("OldQuantity"));
                item.setNewQuantity(rs.getInt("NewQuantity"));
                item.setVariance(rs.getInt("Variance"));
                item.setReason(rs.getString("Reason"));
                item.setItemNote(rs.getString("ItemNote"));
                item.setUnitCost(rs.getBigDecimal("Cost"));
                list.add(item);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // -----------------------------------------------------------------------
    // Sinh mã phiếu tự động: ADJ-2026-0001
    // -----------------------------------------------------------------------
    public String generateAdjustmentCode() {
        String year = String.valueOf(java.time.Year.now().getValue());
        String sql = "SELECT COUNT(*) FROM InventoryAdjustments WHERE AdjustmentCode LIKE ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, "ADJ-" + year + "-%");
            ResultSet rs = ps.executeQuery();
            int count = rs.next() ? rs.getInt(1) : 0;
            return String.format("ADJ-%s-%04d", year, count + 1);
        } catch (Exception e) { e.printStackTrace(); }
        return "ADJ-" + year + "-" + System.currentTimeMillis();
    }

    // -----------------------------------------------------------------------
    private InventoryAdjustment mapAdjustment(ResultSet rs) throws Exception {
        InventoryAdjustment a = new InventoryAdjustment();
        a.setAdjustmentId(rs.getInt("AdjustmentID"));
        a.setAdjustmentCode(rs.getString("AdjustmentCode"));
        a.setAdjustmentDate(rs.getString("AdjustmentDate"));
        a.setWarehouse(rs.getString("Warehouse"));
        a.setGeneralReason(rs.getString("GeneralReason"));
        a.setNote(rs.getString("Note"));
        a.setStatus(rs.getString("Status"));
        a.setCreatedAt(rs.getTimestamp("CreatedAt"));
        a.setCreatedByName(rs.getString("CreatedByName"));
        try { a.setTotalProducts(rs.getInt("TotalProducts")); } catch (Exception ignored) {}
        try { a.setTotalIncrease(rs.getInt("TotalIncrease")); } catch (Exception ignored) {}
        try { a.setTotalDecrease(rs.getInt("TotalDecrease")); } catch (Exception ignored) {}
        return a;
    }
}
