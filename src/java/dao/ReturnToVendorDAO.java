/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author dotha
 */
import model.ReturnToVendor;
import model.ReturnToVendorDetail;
import model.StockInDetail;
import model.SupplierDebt;
import utils.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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

    private boolean isOffsetDebtSettlement(String settlementType) {
        return SETTLEMENT_OFFSET_DEBT.equalsIgnoreCase(normalizeSettlementType(settlementType));
    }

    private boolean isReplacementSettlement(String settlementType) {
        return SETTLEMENT_REPLACEMENT.equalsIgnoreCase(normalizeSettlementType(settlementType));
    }

    private boolean hasEnoughStock(int productId, int requiredQty) {
        String sql = "SELECT StockQuantity FROM Products WHERE ProductID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("StockQuantity") >= requiredQty;
                }
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

        String sql = "UPDATE Products "
                + "SET StockQuantity = StockQuantity - ?, UpdatedDate = GETDATE() "
                + "WHERE ProductID = ? AND StockQuantity >= ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, productId);
            ps.setInt(3, quantity);

            if (ps.executeUpdate() <= 0) {
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        String deactivateSql = "UPDATE Products "
                + "SET Status = 'Deactivated', UpdatedDate = GETDATE() "
                + "WHERE ProductID = ? AND StockQuantity = 0";

        try (PreparedStatement ps = connection.prepareStatement(deactivateSql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

        return true;
    }

    private boolean increaseProductStock(int productId, int quantity) {
        if (quantity <= 0) {
            return false;
        }

        String sql = "UPDATE Products "
                + "SET StockQuantity = StockQuantity + ?, "
                + "    UpdatedDate = GETDATE(), "
                + "    Status = CASE WHEN Status = 'Deactivated' THEN 'Active' ELSE Status END "
                + "WHERE ProductID = ?";

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
        if (delta > 0) {
            return increaseProductStock(productId, delta);
        }
        return decreaseProductStock(productId, -delta);
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
            connection.setAutoCommit(false);

            String insertHeaderSql = "INSERT INTO ReturnToVendors "
                    + "(ReturnCode, SupplierID, CreatedBy, Status, Reason, Note, SettlementType, TotalAmount) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement psHeader = connection.prepareStatement(insertHeaderSql, Statement.RETURN_GENERATED_KEYS)) {
                psHeader.setString(1, rtv.getReturnCode());
                psHeader.setInt(2, rtv.getSupplierID());
                psHeader.setInt(3, rtv.getCreatedBy());
                psHeader.setString(4, rtv.getStatus());
                psHeader.setString(5, rtv.getReason());
                psHeader.setString(6, rtv.getNote());
                psHeader.setString(7, rtv.getSettlementType());
                psHeader.setDouble(8, 0);

                int affected = psHeader.executeUpdate();
                if (affected <= 0) {
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

            String insertDetailSql = "INSERT INTO ReturnToVendorDetails "
                    + "(RTVID, DetailID, StockInID, ProductID, Quantity, UnitCost, LineTotal, ReasonDetail, ItemCondition) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            double totalAmount = 0;

            for (ReturnToVendorDetail d : details) {
                if (!supplierProductDAO.isValidSupplierProduct(rtv.getSupplierID(), d.getProductID())) {
                    connection.rollback();
                    return -1;
                }

                if (!stockInDAO.isValidStockInDetailForReturn(d.getStockInDetailID(), rtv.getSupplierID(), d.getProductID())) {
                    connection.rollback();
                    return -1;
                }

                int remainingQty = stockInDAO.getRemainingReturnableQuantity(d.getStockInDetailID());
                if (d.getQuantity() <= 0 || d.getQuantity() > remainingQty) {
                    connection.rollback();
                    return -1;
                }

                StockInDetail sid = stockInDAO.getStockInDetailByDetailId(d.getStockInDetailID());
                if (sid == null) {
                    connection.rollback();
                    return -1;
                }

                d.setStockInID(sid.getStockInId());
                d.setUnitCost(sid.getUnitCost());
                d.setLineTotal(d.getQuantity() * d.getUnitCost());

                try (PreparedStatement psDetail = connection.prepareStatement(insertDetailSql)) {
                    psDetail.setInt(1, rtvID);
                    psDetail.setInt(2, d.getStockInDetailID());
                    psDetail.setInt(3, d.getStockInID());
                    psDetail.setInt(4, d.getProductID());
                    psDetail.setInt(5, d.getQuantity());
                    psDetail.setDouble(6, d.getUnitCost());
                    psDetail.setDouble(7, d.getLineTotal());
                    psDetail.setString(8, d.getReasonDetail());
                    psDetail.setString(9, d.getItemCondition());

                    if (psDetail.executeUpdate() <= 0) {
                        connection.rollback();
                        return -1;
                    }
                }

                totalAmount += d.getLineTotal();
            }

            String updateTotalSql = "UPDATE ReturnToVendors SET TotalAmount = ? WHERE RTVID = ?";
            try (PreparedStatement psTotal = connection.prepareStatement(updateTotalSql)) {
                psTotal.setDouble(1, totalAmount);
                psTotal.setInt(2, rtvID);
                psTotal.executeUpdate();
            }

            insertSystemLog(
                    rtv.getCreatedBy(),
                    "CREATE_RETURN_VENDOR",
                    "ReturnToVendor ID: " + rtvID,
                    "Created return to vendor. ReturnCode: " + rtv.getReturnCode() + ", SettlementType: " + rtv.getSettlementType() + ", TotalAmount: " + totalAmount,
                    ipAddress
            );

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
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return -1;
    }

    public List<ReturnToVendor> getAllReturns() {
        List<ReturnToVendor> list = new ArrayList<>();

        String sql = "SELECT rtv.*, s.Name AS SupplierName, u.FullName AS CreatedByName "
                + "FROM ReturnToVendors rtv "
                + "LEFT JOIN Suppliers s ON rtv.SupplierID = s.SupplierID "
                + "LEFT JOIN [User] u ON rtv.CreatedBy = u.UserID "
                + "ORDER BY rtv.CreatedDate DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ReturnToVendor rtv = new ReturnToVendor();
                rtv.setRtvID(rs.getInt("RTVID"));
                rtv.setReturnCode(rs.getString("ReturnCode"));
                rtv.setSupplierID(rs.getInt("SupplierID"));
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
                list.add(rtv);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public ReturnToVendor getById(int rtvID) {
        String sql = "SELECT rtv.*, s.Name AS SupplierName, u.FullName AS CreatedByName "
                + "FROM ReturnToVendors rtv "
                + "LEFT JOIN Suppliers s ON rtv.SupplierID = s.SupplierID "
                + "LEFT JOIN [User] u ON rtv.CreatedBy = u.UserID "
                + "WHERE rtv.RTVID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, rtvID);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ReturnToVendor rtv = new ReturnToVendor();
                    rtv.setRtvID(rs.getInt("RTVID"));
                    rtv.setReturnCode(rs.getString("ReturnCode"));
                    rtv.setSupplierID(rs.getInt("SupplierID"));
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

        String sql = "SELECT d.RTVDetailID, d.RTVID, d.DetailID AS StockInDetailID, d.StockInID, d.ProductID, "
                + "d.Quantity, d.UnitCost, d.LineTotal, d.ReasonDetail, d.ItemCondition, p.Name AS ProductName "
                + "FROM ReturnToVendorDetails d "
                + "LEFT JOIN Products p ON d.ProductID = p.ProductID "
                + "WHERE d.RTVID = ? "
                + "ORDER BY d.RTVDetailID ASC";

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
                    list.add(d);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
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

            String sql = "UPDATE ReturnToVendors "
                    + "SET Status = 'Approved', ApprovedBy = ?, ApprovedDate = GETDATE(), IsInventoryAdjusted = ? "
                    + "WHERE RTVID = ? AND Status = 'Pending'";

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, approvedBy);
                ps.setBoolean(2, inventoryAdjustedOnApprove);
                ps.setInt(3, rtvID);

                if (ps.executeUpdate() <= 0) {
                    connection.rollback();
                    return false;
                }
            }

            insertSystemLog(
                    approvedBy,
                    "APPROVE_RETURN_VENDOR",
                    "ReturnToVendor ID: " + rtvID,
                    isReplacementSettlement(settlementType)
                            ? "Approved replacement return. Inventory deducted immediately while waiting for replacement goods."
                            : "Approved return to vendor request.",
                    ipAddress
            );

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
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return false;
    }

    public boolean rejectReturn(int rtvID, int approvedBy, String rejectNote, String ipAddress) {
        String sql = "UPDATE ReturnToVendors "
                + "SET Status = 'Rejected', ApprovedBy = ?, ApprovedDate = GETDATE(), Note = ? "
                + "WHERE RTVID = ? AND Status = 'Pending'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, approvedBy);
            ps.setString(2, rejectNote);
            ps.setInt(3, rtvID);

            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                insertSystemLog(
                        approvedBy,
                        "REJECT_RETURN_VENDOR",
                        "ReturnToVendor ID: " + rtvID,
                        "Rejected return to vendor request.",
                        ipAddress
                );
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
                if (rtv.isInventoryAdjusted()) {
                    for (ReturnToVendorDetail d : details) {
                        if (!adjustProductStock(d.getProductID(), d.getQuantity())) {
                            connection.rollback();
                            return false;
                        }
                    }
                }
                inventoryAdjustedFlag = rtv.isInventoryAdjusted();
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
                }
                inventoryAdjustedFlag = true;
            }

            if (!financialAdjustedFlag && isOffsetDebtSettlement(settlementType)) {
                SupplierDebtDAO debtDAO = new SupplierDebtDAO();
                SupplierDebt debt = debtDAO.getLatestOffsettableDebtBySupplier(rtv.getSupplierID());

                if (debt != null) {
                    boolean updated = debtDAO.reduceDebtAmount(debt.getDebtID(), rtv.getTotalAmount());
                    if (updated) {
                        relatedDebtID = debt.getDebtID();
                        financialAdjustedFlag = true;
                    }
                }
            }

            String completeSql = "UPDATE ReturnToVendors "
                    + "SET Status = 'Completed', CompletedBy = ?, CompletedDate = GETDATE(), "
                    + "    IsInventoryAdjusted = ?, IsFinancialAdjusted = ?, RelatedDebtID = ? "
                    + "WHERE RTVID = ? AND Status = 'Approved'";

            try (PreparedStatement psComplete = connection.prepareStatement(completeSql)) {
                psComplete.setInt(1, completedBy);
                psComplete.setBoolean(2, inventoryAdjustedFlag);
                psComplete.setBoolean(3, financialAdjustedFlag);
                if (relatedDebtID == null) {
                    psComplete.setNull(4, Types.INTEGER);
                } else {
                    psComplete.setInt(4, relatedDebtID);
                }
                psComplete.setInt(5, rtvID);

                if (psComplete.executeUpdate() <= 0) {
                    connection.rollback();
                    return false;
                }
            }

            insertSystemLog(
                    completedBy,
                    "COMPLETE_RETURN_VENDOR",
                    "ReturnToVendor ID: " + rtvID,
                    isReplacementSettlement(settlementType)
                            ? "Completed replacement return. Replacement goods were added back to inventory."
                            : "Completed return to vendor. ReturnCode: " + rtv.getReturnCode() + ", TotalAmount: " + rtv.getTotalAmount(),
                    ipAddress
            );

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
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        return false;
    }

    private void insertSystemLog(int userId, String action, String targetObject, String description, String ipAddress) {
        String sql = "INSERT INTO SystemLog (UserID, Action, TargetObject, Description, LogDate, IPAddress) "
                + "VALUES (?, ?, ?, ?, GETDATE(), ?)";

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
