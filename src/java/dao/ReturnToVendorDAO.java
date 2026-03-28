package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import model.ReturnReplacementReceipt;
import model.ReturnToVendor;
import model.ReturnToVendorDetail;
import model.StockInDetail;
import utils.DBContext;

public class ReturnToVendorDAO extends DBContext {

    private static final String SETTLEMENT_OFFSET_DEBT = "OFFSET_DEBT";
    private static final String SETTLEMENT_REFUND = "REFUND";
    private static final String SETTLEMENT_REPLACEMENT = "REPLACEMENT";

    private String normalizeSettlementType(String settlementType) {
        if (settlementType == null || settlementType.trim().isEmpty()) {
            return SETTLEMENT_OFFSET_DEBT;
        }
        return settlementType.trim().toUpperCase();
    }

    public boolean isReplacementSettlement(String settlementType) {
        return SETTLEMENT_REPLACEMENT.equalsIgnoreCase(normalizeSettlementType(settlementType));
    }

    public boolean isOffsetDebtSettlement(String settlementType) {
        return SETTLEMENT_OFFSET_DEBT.equalsIgnoreCase(normalizeSettlementType(settlementType));
    }

    private boolean hasEnoughStock(int productId, int requiredQty) {
        String sql = "SELECT StockQuantity FROM Products WHERE ProductID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt("StockQuantity") >= requiredQty;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean decreaseProductStock(int productId, int quantity) {
        if (quantity <= 0) {
            return false;
        }
        String sql = "UPDATE Products SET StockQuantity = StockQuantity - ?, UpdatedDate = GETDATE() WHERE ProductID = ? AND StockQuantity >= ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, productId);
            ps.setInt(3, quantity);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                try (PreparedStatement deact = connection.prepareStatement("UPDATE Products SET Status = 'Deactivated', UpdatedDate = GETDATE() WHERE ProductID = ? AND StockQuantity = 0")) {
                    deact.setInt(1, productId);
                    deact.executeUpdate();
                }
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean increaseProductStock(int productId, int quantity) {
        if (quantity <= 0) {
            return false;
        }
        String sql = "UPDATE Products SET StockQuantity = StockQuantity + ?, UpdatedDate = GETDATE(), Status = CASE WHEN Status = 'Deactivated' THEN 'Active' ELSE Status END WHERE ProductID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean adjustProductStock(int productId, int delta) {
        if (delta == 0) {
            return true;
        }
        return delta > 0 ? increaseProductStock(productId, delta) : decreaseProductStock(productId, -delta);
    }

    public int createReturnWithDetails(ReturnToVendor rtv, List<ReturnToVendorDetail> details, String ipAddress) {
        SupplierDAO supplierDAO = new SupplierDAO();
        SupplierProductDAO supplierProductDAO = new SupplierProductDAO();
        StockInDAO stockInDAO = new StockInDAO();
        int rtvID = -1;
        try {
            if (!supplierDAO.isActiveSupplier(rtv.getSupplierID())) {
                return -1;
            }
            if (details == null || details.isEmpty()) {
                return -1;
            }
            rtv.setSettlementType(normalizeSettlementType(rtv.getSettlementType()));

            List<Integer> detailIds = new ArrayList<>();
            Map<Integer, Integer> requestedQtyByDetailId = new HashMap<>();
            for (ReturnToVendorDetail d : details) {
                if (d == null || d.getStockInDetailID() <= 0 || d.getProductID() <= 0 || d.getQuantity() <= 0) {
                    return -1;
                }
                detailIds.add(d.getStockInDetailID());
                requestedQtyByDetailId.merge(d.getStockInDetailID(), d.getQuantity(), Integer::sum);
            }

            Map<Integer, StockInDetail> stockInDetailMap = stockInDAO.getStockInDetailsByIds(detailIds);
            Map<Integer, Integer> remainingQtyMap = stockInDAO.getRemainingReturnableQuantityMap(detailIds);
            if (stockInDetailMap.size() != requestedQtyByDetailId.size()) {
                return -1;
            }

            Integer headerStockInID = rtv.getStockInID() > 0 ? rtv.getStockInID() : null;
            Set<Integer> validatedProductIds = new HashSet<>();
            for (ReturnToVendorDetail d : details) {
                StockInDetail sid = stockInDetailMap.get(d.getStockInDetailID());
                if (sid == null) {
                    return -1;
                }
                if (sid.getProductId() != d.getProductID()) {
                    return -1;
                }
                d.setStockInID(sid.getStockInId());
                d.setUnitCost(sid.getUnitCost());
                d.setLineTotal(d.getQuantity() * d.getUnitCost());

                if (headerStockInID == null) {
                    headerStockInID = sid.getStockInId();
                } else if (headerStockInID != sid.getStockInId()) {
                    return -1;
                }

                if (sid.getReceivedQuantity() <= 0) {
                    return -1;
                }

                if (validatedProductIds.add(d.getProductID())
                        && !supplierProductDAO.isValidSupplierProduct(rtv.getSupplierID(), d.getProductID())) {
                    return -1;
                }
            }

            for (Map.Entry<Integer, Integer> entry : requestedQtyByDetailId.entrySet()) {
                int remainingQty = remainingQtyMap.getOrDefault(entry.getKey(), 0);
                if (entry.getValue() > remainingQty) {
                    return -1;
                }
            }

            if (headerStockInID == null) {
                return -1;
            }
            rtv.setStockInID(headerStockInID);

            connection.setAutoCommit(false);
            String insertHeaderSql = "INSERT INTO ReturnToVendors (ReturnCode, SupplierID, StockInID, CreatedBy, Status, Reason, Note, SettlementType, TotalAmount) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement psHeader = connection.prepareStatement(insertHeaderSql, Statement.RETURN_GENERATED_KEYS)) {
                psHeader.setString(1, rtv.getReturnCode());
                psHeader.setInt(2, rtv.getSupplierID());
                psHeader.setInt(3, rtv.getStockInID());
                psHeader.setInt(4, rtv.getCreatedBy());
                psHeader.setString(5, rtv.getStatus());
                psHeader.setString(6, rtv.getReason());
                psHeader.setString(7, rtv.getNote());
                psHeader.setString(8, rtv.getSettlementType());
                psHeader.setDouble(9, 0);
                if (psHeader.executeUpdate() <= 0) {
                    connection.rollback();
                    return -1;
                }
                try (ResultSet rs = psHeader.getGeneratedKeys()) {
                    if (rs.next()) {
                        rtvID = rs.getInt(1);
                    } else {
                        connection.rollback();
                        return -1;
                    }
                }
            }

            String insertDetailSql = "INSERT INTO ReturnToVendorDetails (RTVID, StockInDetailID, ProductID, Quantity, UnitCost, LineTotal, ReasonDetail, ItemCondition) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            double totalAmount = 0;
            try (PreparedStatement psDetail = connection.prepareStatement(insertDetailSql)) {
                for (ReturnToVendorDetail d : details) {
                    psDetail.setInt(1, rtvID);
                    psDetail.setInt(2, d.getStockInDetailID());
                    psDetail.setInt(3, d.getProductID());
                    psDetail.setInt(4, d.getQuantity());
                    psDetail.setDouble(5, d.getUnitCost());
                    psDetail.setDouble(6, d.getLineTotal());
                    psDetail.setString(7, d.getReasonDetail());
                    psDetail.setString(8, d.getItemCondition());
                    psDetail.addBatch();
                    totalAmount += d.getLineTotal();
                }
                int[] result = psDetail.executeBatch();
                for (int value : result) {
                    if (value == Statement.EXECUTE_FAILED) {
                        connection.rollback();
                        return -1;
                    }
                }
            }

            try (PreparedStatement psTotal = connection.prepareStatement("UPDATE ReturnToVendors SET TotalAmount = ? WHERE RTVID = ?")) {
                psTotal.setDouble(1, totalAmount);
                psTotal.setInt(2, rtvID);
                psTotal.executeUpdate();
            }

            insertSystemLog(rtv.getCreatedBy(), "CREATE_RETURN_VENDOR", "ReturnToVendor ID: " + rtvID,
                    "Created return to vendor. ReturnCode: " + rtv.getReturnCode() + ", TotalAmount: " + totalAmount, ipAddress);

            connection.commit();
            return rtvID;
        } catch (Exception e) {
            e.printStackTrace();
            try {
                connection.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (Exception ignored) {
            }
        }
        return -1;
    }

    public List<ReturnToVendor> getAllReturns() {
        List<ReturnToVendor> list = new ArrayList<>();
        // Lưu ý: tránh phụ thuộc cột ReturnToVendors.SupplierID (có thể bị thiếu ở DB cũ).
        // Lấy SupplierID từ StockInID để JOIN Suppliers và map vào model.
        String sql = """
            SELECT
                rtv.RTVID,
                rtv.ReturnCode,
                si.SupplierID AS SupplierID,
                rtv.StockInID,
                rtv.CreatedBy,
                rtv.ApprovedBy,
                rtv.CompletedBy,
                rtv.CreatedDate,
                rtv.ApprovedDate,
                rtv.CompletedDate,
                rtv.Status,
                rtv.Reason,
                rtv.Note,
                rtv.TotalAmount,
                rtv.SettlementType,
                rtv.RelatedDebtID,
                rtv.IsInventoryAdjusted,
                rtv.IsFinancialAdjusted,
                s.Name AS SupplierName,
                u.FullName AS CreatedByName
            FROM ReturnToVendors rtv
            LEFT JOIN StockIn si ON rtv.StockInID = si.StockInID
            LEFT JOIN Suppliers s ON si.SupplierID = s.SupplierID
            LEFT JOIN [User] u ON rtv.CreatedBy = u.UserID
            ORDER BY rtv.CreatedDate DESC
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ReturnToVendor rtv = mapRtv(rs);
                list.add(rtv);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ReturnToVendor getById(int rtvID) {
        // Tương tự getAllReturns: SupplierID lấy từ StockIn để tránh phụ thuộc cột có thể thiếu.
        String sql = """
            SELECT
                rtv.RTVID,
                rtv.ReturnCode,
                si.SupplierID AS SupplierID,
                rtv.StockInID,
                rtv.CreatedBy,
                rtv.ApprovedBy,
                rtv.CompletedBy,
                rtv.CreatedDate,
                rtv.ApprovedDate,
                rtv.CompletedDate,
                rtv.Status,
                rtv.Reason,
                rtv.Note,
                rtv.TotalAmount,
                rtv.SettlementType,
                rtv.RelatedDebtID,
                rtv.IsInventoryAdjusted,
                rtv.IsFinancialAdjusted,
                s.Name AS SupplierName,
                u.FullName AS CreatedByName
            FROM ReturnToVendors rtv
            LEFT JOIN StockIn si ON rtv.StockInID = si.StockInID
            LEFT JOIN Suppliers s ON si.SupplierID = s.SupplierID
            LEFT JOIN [User] u ON rtv.CreatedBy = u.UserID
            WHERE rtv.RTVID = ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, rtvID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ReturnToVendor rtv = mapRtv(rs);
                    rtv.setDetails(getDetailsByRTVID(rtvID));
                    return rtv;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<ReturnToVendorDetail> getDetailsByRTVID(int rtvID) {
        List<ReturnToVendorDetail> list = new ArrayList<>();
        String sql = "SELECT d.RTVDetailID, d.RTVID, d.StockInDetailID, sid.StockInID, d.ProductID, d.Quantity, d.UnitCost, d.LineTotal, d.ReasonDetail, d.ItemCondition, p.Name AS ProductName, sid.ReceivedQuantity, ISNULL(rr.ReceivedQty, 0) AS ReplacementReceivedQty FROM ReturnToVendorDetails d LEFT JOIN Products p ON d.ProductID = p.ProductID LEFT JOIN StockInDetails sid ON d.StockInDetailID = sid.DetailID LEFT JOIN (SELECT RTVDetailID, SUM(Quantity) AS ReceivedQty FROM ReturnToVendorReplacementReceipts GROUP BY RTVDetailID) rr ON d.RTVDetailID = rr.RTVDetailID WHERE d.RTVID = ? ORDER BY d.RTVDetailID ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, rtvID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReturnToVendorDetail d = new ReturnToVendorDetail();
                    d.setRtvDetailID(rs.getInt("RTVDetailID"));
                    d.setRtvID(rs.getInt("RTVID"));
                    d.setStockInDetailID(rs.getInt("StockInDetailID"));
                    d.setStockInID(rs.getInt("StockInID"));
                    d.setProductID(rs.getInt("ProductID"));
                    d.setQuantity(rs.getInt("Quantity"));
                    d.setUnitCost(rs.getDouble("UnitCost"));
                    d.setLineTotal(rs.getDouble("LineTotal"));
                    d.setReasonDetail(rs.getString("ReasonDetail"));
                    d.setItemCondition(rs.getString("ItemCondition"));
                    d.setProductName(rs.getString("ProductName"));
                    d.setAvailableQuantity(rs.getInt("ReceivedQuantity"));
                    d.setReplacementReceivedQuantity(rs.getInt("ReplacementReceivedQty"));
                    list.add(d);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ReturnReplacementReceipt> getReplacementReceiptsByRTV(int rtvID) {
        List<ReturnReplacementReceipt> list = new ArrayList<>();
        String sql = "SELECT rr.ReceiptID, rr.RTVID, rr.RTVDetailID, rr.Quantity, rr.Note, rr.ReceivedBy, rr.ReceivedAt, u.FullName AS ReceivedByName, p.Name AS ProductName FROM ReturnToVendorReplacementReceipts rr JOIN ReturnToVendorDetails d ON rr.RTVDetailID = d.RTVDetailID LEFT JOIN Products p ON d.ProductID = p.ProductID LEFT JOIN [User] u ON rr.ReceivedBy = u.UserID WHERE rr.RTVID = ? ORDER BY rr.ReceivedAt DESC, rr.ReceiptID DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, rtvID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReturnReplacementReceipt r = new ReturnReplacementReceipt();
                    r.setReceiptID(rs.getInt("ReceiptID"));
                    r.setRtvID(rs.getInt("RTVID"));
                    r.setRtvDetailID(rs.getInt("RTVDetailID"));
                    r.setQuantity(rs.getInt("Quantity"));
                    r.setNote(rs.getString("Note"));
                    r.setReceivedBy(rs.getInt("ReceivedBy"));
                    r.setReceivedByName(rs.getString("ReceivedByName"));
                    r.setReceivedAt(rs.getTimestamp("ReceivedAt"));
                    r.setProductName(rs.getString("ProductName"));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addReplacementReceipt(int rtvID, int rtvDetailID, int quantity, String note, int receivedBy, String ipAddress) {
        try {
            connection.setAutoCommit(false);
            ReturnToVendor rtv = getById(rtvID);
            if (rtv == null || !"Approved".equalsIgnoreCase(rtv.getStatus()) || !isReplacementSettlement(rtv.getSettlementType())) {
                connection.rollback();
                return false;
            }
            ReturnToVendorDetail target = null;
            for (ReturnToVendorDetail d : getDetailsByRTVID(rtvID)) {
                if (d.getRtvDetailID() == rtvDetailID) {
                    target = d;
                    break;
                }
            }
            if (target == null || quantity <= 0 || quantity > target.getReplacementRemainingQuantity()) {
                connection.rollback();
                return false;
            }
            try (PreparedStatement ps = connection.prepareStatement("INSERT INTO ReturnToVendorReplacementReceipts (RTVID, RTVDetailID, Quantity, Note, ReceivedBy) VALUES (?, ?, ?, ?, ?)")) {
                ps.setInt(1, rtvID);
                ps.setInt(2, rtvDetailID);
                ps.setInt(3, quantity);
                ps.setString(4, note);
                ps.setInt(5, receivedBy);
                if (ps.executeUpdate() <= 0) {
                    connection.rollback();
                    return false;
                }
            }
            if (!increaseProductStock(target.getProductID(), quantity)) {
                connection.rollback();
                return false;
            }
            insertSystemLog(receivedBy, "RECORD_RTV_REPLACEMENT_RECEIPT", "ReturnToVendor ID: " + rtvID,
                    "Recorded replacement receipt for RTV detail " + rtvDetailID + " quantity " + quantity, ipAddress);
            connection.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try {
                connection.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (Exception ignored) {
            }
        }
        return false;
    }

    public boolean approveReturn(int rtvID, int approvedBy, String ipAddress) {
        try {
            connection.setAutoCommit(false);
            ReturnToVendor rtv = getById(rtvID);
            if (rtv == null || !"Pending".equalsIgnoreCase(rtv.getStatus())) {
                connection.rollback();
                return false;
            }
            List<ReturnToVendorDetail> details = getDetailsByRTVID(rtvID);
            if (details == null || details.isEmpty()) {
                connection.rollback();
                return false;
            }
            String settlementType = normalizeSettlementType(rtv.getSettlementType());
            boolean inventoryAdjustedOnApprove = false;
            if (isReplacementSettlement(settlementType)) {
                for (ReturnToVendorDetail d : details) {
                    if (!hasEnoughStock(d.getProductID(), d.getQuantity())) {
                        connection.rollback();
                        return false;
                    }
                }
                for (ReturnToVendorDetail d : details) {
                    if (!adjustProductStock(d.getProductID(), -d.getQuantity())) {
                        connection.rollback();
                        return false;
                    }
                }
                inventoryAdjustedOnApprove = true;
            }
            if (isOffsetDebtSettlement(settlementType)) {
                SupplierDebtDAO debtDAO = new SupplierDebtDAO();
                if (!debtDAO.hasEnoughDebtForOffset(rtv.getSupplierID(), rtv.getTotalAmount())) {
                    connection.rollback();
                    return false;
                }
            }
            try (PreparedStatement ps = connection.prepareStatement("UPDATE ReturnToVendors SET Status = 'Approved', ApprovedBy = ?, ApprovedDate = GETDATE(), IsInventoryAdjusted = ? WHERE RTVID = ? AND Status = 'Pending'")) {
                ps.setInt(1, approvedBy);
                ps.setBoolean(2, inventoryAdjustedOnApprove);
                ps.setInt(3, rtvID);
                if (ps.executeUpdate() <= 0) {
                    connection.rollback();
                    return false;
                }
            }
            insertSystemLog(approvedBy, "APPROVE_RETURN_VENDOR", "ReturnToVendor ID: " + rtvID,
                    isReplacementSettlement(settlementType) ? "Approved replacement return. Inventory deducted immediately while waiting for replacement goods." : "Approved return to vendor request.", ipAddress);
            connection.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try {
                connection.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (Exception ignored) {
            }
        }
        return false;
    }

    public boolean rejectReturn(int rtvID, int approvedBy, String rejectNote, String ipAddress) {
        String sql = "UPDATE ReturnToVendors SET Status = 'Rejected', ApprovedBy = ?, ApprovedDate = GETDATE(), Note = ? WHERE RTVID = ? AND Status = 'Pending'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, approvedBy);
            ps.setString(2, rejectNote);
            ps.setInt(3, rtvID);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                insertSystemLog(approvedBy, "REJECT_RETURN_VENDOR", "ReturnToVendor ID: " + rtvID, "Rejected return to vendor request.", ipAddress);
            }
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean completeReturnToVendor(int rtvID, int completedBy, String ipAddress) {
        try {
            connection.setAutoCommit(false);
            ReturnToVendor rtv = getById(rtvID);
            if (rtv == null || !"Approved".equalsIgnoreCase(rtv.getStatus())) {
                connection.rollback();
                return false;
            }
            List<ReturnToVendorDetail> details = getDetailsByRTVID(rtvID);
            if (details == null || details.isEmpty()) {
                connection.rollback();
                return false;
            }
            String settlementType = normalizeSettlementType(rtv.getSettlementType());
            boolean inventoryAdjustedFlag = rtv.isInventoryAdjusted();
            boolean financialAdjustedFlag = rtv.isFinancialAdjusted();
            Integer relatedDebtID = rtv.getRelatedDebtID();

            if (isReplacementSettlement(settlementType)) {
                for (ReturnToVendorDetail d : details) {
                    if (d.getReplacementReceivedQuantity() < d.getQuantity()) {
                        connection.rollback();
                        return false;
                    }
                }
            } else {
                if (!rtv.isInventoryAdjusted()) {
                    for (ReturnToVendorDetail d : details) {
                        if (!hasEnoughStock(d.getProductID(), d.getQuantity())) {
                            connection.rollback();
                            return false;
                        }
                    }
                    for (ReturnToVendorDetail d : details) {
                        if (!adjustProductStock(d.getProductID(), -d.getQuantity())) {
                            connection.rollback();
                            return false;
                        }
                    }
                    inventoryAdjustedFlag = true;
                }
            }

            if (isOffsetDebtSettlement(settlementType) && !financialAdjustedFlag) {
                if (!offsetDebtAcrossSupplier(rtv.getSupplierID(), rtv.getTotalAmount())) {
                    connection.rollback();
                    return false;
                }
                relatedDebtID = getLatestLinkedDebtId(rtv.getSupplierID());
                financialAdjustedFlag = true;
            }

            try (PreparedStatement ps = connection.prepareStatement("UPDATE ReturnToVendors SET Status = 'Completed', CompletedBy = ?, CompletedDate = GETDATE(), IsInventoryAdjusted = ?, IsFinancialAdjusted = ?, RelatedDebtID = ? WHERE RTVID = ?")) {
                ps.setInt(1, completedBy);
                ps.setBoolean(2, inventoryAdjustedFlag);
                ps.setBoolean(3, financialAdjustedFlag);
                if (relatedDebtID == null) {
                    ps.setNull(4, java.sql.Types.INTEGER);
                } else {
                    ps.setInt(4, relatedDebtID);
                }
                ps.setInt(5, rtvID);
                if (ps.executeUpdate() <= 0) {
                    connection.rollback();
                    return false;
                }
            }
            insertSystemLog(completedBy, "COMPLETE_RETURN_VENDOR", "ReturnToVendor ID: " + rtvID,
                    "Completed return to vendor. ReturnCode: " + rtv.getReturnCode() + ", TotalAmount: " + rtv.getTotalAmount(), ipAddress);
            connection.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try {
                connection.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (Exception ignored) {
            }
        }
        return false;
    }

    private boolean offsetDebtAcrossSupplier(int supplierId, double amount) {
        double remaining = amount;
        String sql = "SELECT DebtID, Amount FROM SupplierDebts WHERE SupplierID = ? AND Status IN ('Pending','Partial','Overdue') ORDER BY DebtID DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                List<int[]> debtIds = new ArrayList<>();
                List<Double> debtAmounts = new ArrayList<>();
                while (rs.next()) {
                    debtIds.add(new int[]{rs.getInt("DebtID")});
                    debtAmounts.add(rs.getDouble("Amount"));
                }
                double total = 0;
                for (double d : debtAmounts) {
                    total += d;
                }
                if (total + 0.0001 < amount) {
                    return false;
                }
                for (int i = 0; i < debtIds.size() && remaining > 0; i++) {
                    int debtId = debtIds.get(i)[0];
                    double current = debtAmounts.get(i);
                    double used = Math.min(current, remaining);
                    double newAmount = current - used;
                    String status = newAmount == 0 ? "Paid" : "Partial";
                    try (PreparedStatement ups = connection.prepareStatement("UPDATE SupplierDebts SET Amount = ?, Status = ? WHERE DebtID = ?")) {
                        ups.setDouble(1, newAmount);
                        ups.setString(2, status);
                        ups.setInt(3, debtId);
                        if (ups.executeUpdate() <= 0) {
                            return false;
                        }
                    }
                    remaining -= used;
                }
                return remaining <= 0.0001;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Integer getLatestLinkedDebtId(int supplierId) {
        String sql = "SELECT TOP 1 DebtID FROM SupplierDebts WHERE SupplierID = ? ORDER BY DebtID DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("DebtID");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private ReturnToVendor mapRtv(ResultSet rs) throws Exception {
        ReturnToVendor rtv = new ReturnToVendor();
        rtv.setRtvID(rs.getInt("RTVID"));
        rtv.setReturnCode(rs.getString("ReturnCode"));
        rtv.setSupplierID(rs.getInt("SupplierID"));
        rtv.setStockInID(rs.getInt("StockInID"));
        rtv.setCreatedBy(rs.getInt("CreatedBy"));
        rtv.setApprovedBy((Integer) rs.getObject("ApprovedBy"));
        rtv.setCompletedBy((Integer) rs.getObject("CompletedBy"));
        rtv.setCreatedDate(rs.getTimestamp("CreatedDate"));
        rtv.setApprovedDate(rs.getTimestamp("ApprovedDate"));
        rtv.setCompletedDate(rs.getTimestamp("CompletedDate"));
        rtv.setStatus(rs.getString("Status"));
        rtv.setReason(rs.getString("Reason"));
        rtv.setNote(rs.getString("Note"));
        rtv.setTotalAmount(rs.getDouble("TotalAmount"));
        rtv.setSettlementType(rs.getString("SettlementType"));
        rtv.setRelatedDebtID((Integer) rs.getObject("RelatedDebtID"));
        rtv.setInventoryAdjusted(rs.getBoolean("IsInventoryAdjusted"));
        rtv.setFinancialAdjusted(rs.getBoolean("IsFinancialAdjusted"));
        rtv.setSupplierName(rs.getString("SupplierName"));
        rtv.setCreatedByName(rs.getString("CreatedByName"));
        return rtv;
    }

    private void insertSystemLog(int userId, String action, String targetObject, String description, String ipAddress) {
        String sql = "INSERT INTO SystemLog (UserID, Action, TargetObject, Description, LogDate, IPAddress) VALUES (?, ?, ?, ?, GETDATE(), ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, action);
            ps.setString(3, targetObject);
            ps.setString(4, description);
            ps.setString(5, ipAddress);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
