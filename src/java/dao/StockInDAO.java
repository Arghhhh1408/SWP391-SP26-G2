/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.StockIn;
import model.StockInDetail;
import utils.DBContext;

public class StockInDAO extends DBContext {

    public List<StockIn> getAllStockIn() {
        List<StockIn> list = new ArrayList<>();

        String sql = "SELECT v.StockInID, v.SupplierID, v.SupplierName, v.Date, v.CreatedBy, "
                + "       u.Username AS StaffName, v.Note, v.StockStatus, v.PaymentStatus, "
                + "       v.CancelRequestNote, v.CancelRequestedBy, v.CancelRequestedAt, "
                + "       v.CancelApprovedBy, v.CancelApprovedAt, "
                + "       v.TotalOrderedQuantity, v.TotalReceivedQuantity, v.TotalRemainingQuantity, "
                + "       v.TotalAmountCalculated, "
                + "       ISNULL(s.InitialPaidAmount, 0) AS InitialPaidAmount "
                + "FROM vw_StockInProgress v "
                + "LEFT JOIN [User] u ON v.CreatedBy = u.UserID "
                + "LEFT JOIN StockIn s ON v.StockInID = s.StockInID "
                + "ORDER BY v.StockInID DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                StockIn s = new StockIn();
                s.setStockInId(rs.getInt("StockInID"));
                s.setSupplierId(rs.getInt("SupplierID"));
                s.setSupplierName(rs.getString("SupplierName"));
                s.setDate(rs.getTimestamp("Date"));
                s.setCreatedBy(rs.getInt("CreatedBy"));
                s.setStaffName(rs.getString("StaffName"));
                s.setNote(rs.getString("Note"));
                s.setStockStatus(rs.getString("StockStatus"));
                s.setPaymentStatus(rs.getString("PaymentStatus"));
                s.setCancelRequestNote(rs.getString("CancelRequestNote"));
                s.setInitialPaidAmount(rs.getDouble("InitialPaidAmount"));

                int cancelRequestedBy = rs.getInt("CancelRequestedBy");
                if (!rs.wasNull()) {
                    s.setCancelRequestedBy(cancelRequestedBy);
                }

                s.setCancelRequestedAt(rs.getTimestamp("CancelRequestedAt"));

                int cancelApprovedBy = rs.getInt("CancelApprovedBy");
                if (!rs.wasNull()) {
                    s.setCancelApprovedBy(cancelApprovedBy);
                }

                s.setCancelApprovedAt(rs.getTimestamp("CancelApprovedAt"));
                s.setTotalOrderedQuantity(rs.getInt("TotalOrderedQuantity"));
                s.setTotalReceivedQuantity(rs.getInt("TotalReceivedQuantity"));
                s.setTotalRemainingQuantity(rs.getInt("TotalRemainingQuantity"));
                s.setTotalAmountCalculated(rs.getDouble("TotalAmountCalculated"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public StockIn getStockInByIdBasic(int stockInId) {
        String sql = "SELECT s.StockInID, s.SupplierID, sup.Name AS SupplierName, s.Date, s.CreatedBy, "
                + "       u.Username AS StaffName, s.Note, s.StockStatus, s.PaymentStatus, "
                + "       s.CancelRequestNote, s.CancelRequestedBy, s.CancelRequestedAt, "
                + "       s.CancelApprovedBy, s.CancelApprovedAt "
                + "FROM StockIn s "
                + "LEFT JOIN [User] u ON s.CreatedBy = u.UserID "
                + "LEFT JOIN Suppliers sup ON s.SupplierID = sup.SupplierID "
                + "WHERE s.StockInID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, stockInId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    StockIn s = new StockIn();
                    s.setStockInId(rs.getInt("StockInID"));
                    s.setSupplierId(rs.getInt("SupplierID"));
                    s.setSupplierName(rs.getString("SupplierName"));
                    s.setDate(rs.getTimestamp("Date"));
                    s.setCreatedBy(rs.getInt("CreatedBy"));
                    s.setStaffName(rs.getString("StaffName"));
                    s.setNote(rs.getString("Note"));
                    s.setStockStatus(rs.getString("StockStatus"));
                    s.setPaymentStatus(rs.getString("PaymentStatus"));
                    s.setCancelRequestNote(rs.getString("CancelRequestNote"));

                    int cancelRequestedBy = rs.getInt("CancelRequestedBy");
                    if (!rs.wasNull()) {
                        s.setCancelRequestedBy(cancelRequestedBy);
                    }

                    s.setCancelRequestedAt(rs.getTimestamp("CancelRequestedAt"));

                    int cancelApprovedBy = rs.getInt("CancelApprovedBy");
                    if (!rs.wasNull()) {
                        s.setCancelApprovedBy(cancelApprovedBy);
                    }

                    s.setCancelApprovedAt(rs.getTimestamp("CancelApprovedAt"));
                    return s;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public StockIn getStockInById(int stockInId) {
        String sql = "SELECT v.StockInID, v.SupplierID, v.SupplierName, v.Date, v.CreatedBy, "
                + "       u.Username AS StaffName, v.Note, v.StockStatus, v.PaymentStatus, "
                + "       v.CancelRequestNote, v.CancelRequestedBy, v.CancelRequestedAt, "
                + "       v.CancelApprovedBy, v.CancelApprovedAt, "
                + "       v.TotalOrderedQuantity, v.TotalReceivedQuantity, v.TotalRemainingQuantity, "
                + "       v.TotalAmountCalculated, "
                + "       ISNULL(s.InitialPaidAmount, 0) AS InitialPaidAmount "
                + "FROM vw_StockInProgress v "
                + "LEFT JOIN [User] u ON v.CreatedBy = u.UserID "
                + "LEFT JOIN StockIn s ON v.StockInID = s.StockInID "
                + "WHERE v.StockInID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, stockInId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    StockIn s = new StockIn();
                    s.setStockInId(rs.getInt("StockInID"));
                    s.setSupplierId(rs.getInt("SupplierID"));
                    s.setSupplierName(rs.getString("SupplierName"));
                    s.setDate(rs.getTimestamp("Date"));
                    s.setCreatedBy(rs.getInt("CreatedBy"));
                    s.setStaffName(rs.getString("StaffName"));
                    s.setNote(rs.getString("Note"));
                    s.setStockStatus(rs.getString("StockStatus"));
                    s.setPaymentStatus(rs.getString("PaymentStatus"));
                    s.setCancelRequestNote(rs.getString("CancelRequestNote"));
                    s.setInitialPaidAmount(rs.getDouble("InitialPaidAmount"));

                    int cancelRequestedBy = rs.getInt("CancelRequestedBy");
                    if (!rs.wasNull()) {
                        s.setCancelRequestedBy(cancelRequestedBy);
                    }

                    s.setCancelRequestedAt(rs.getTimestamp("CancelRequestedAt"));

                    int cancelApprovedBy = rs.getInt("CancelApprovedBy");
                    if (!rs.wasNull()) {
                        s.setCancelApprovedBy(cancelApprovedBy);
                    }

                    s.setCancelApprovedAt(rs.getTimestamp("CancelApprovedAt"));
                    s.setTotalOrderedQuantity(rs.getInt("TotalOrderedQuantity"));
                    s.setTotalReceivedQuantity(rs.getInt("TotalReceivedQuantity"));
                    s.setTotalRemainingQuantity(rs.getInt("TotalRemainingQuantity"));
                    s.setTotalAmountCalculated(rs.getDouble("TotalAmountCalculated"));
                    return s;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<StockInDetail> getStockInDetailsByStockInId(int stockInId) {
        List<StockInDetail> list = new ArrayList<>();

        String sql = "SELECT d.DetailID, d.StockInID, d.ProductID, d.Quantity, d.ReceivedQuantity, "
                + "       d.UnitCost, d.SubTotal, "
                + "       p.Name AS ProductName, p.SKU, p.Unit "
                + "FROM StockInDetails d "
                + "INNER JOIN Products p ON d.ProductID = p.ProductID "
                + "WHERE d.StockInID = ? "
                + "ORDER BY d.DetailID";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, stockInId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StockInDetail d = new StockInDetail();
                    d.setDetailId(rs.getInt("DetailID"));
                    d.setStockInId(rs.getInt("StockInID"));
                    d.setProductId(rs.getInt("ProductID"));
                    d.setQuantity(rs.getInt("Quantity"));
                    d.setReceivedQuantity(rs.getInt("ReceivedQuantity"));
                    d.setUnitCost(rs.getDouble("UnitCost"));
                    d.setSubTotal(rs.getDouble("SubTotal"));
                    d.setProductName(rs.getString("ProductName"));
                    d.setSku(rs.getString("SKU"));
                    d.setUnit(rs.getString("Unit"));
                    list.add(d);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int insertStockInWithDetailsAndDebt(StockIn stockIn, List<StockInDetail> details, double paidNow) {
        String insertStockInSql = """
        INSERT INTO StockIn (SupplierID, CreatedBy, Note, StockStatus, PaymentStatus, TotalAmount, InitialPaidAmount, Date)
        VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())
    """;

        String insertDetailSql = """
        INSERT INTO StockInDetails (StockInID, ProductID, Quantity, ReceivedQuantity, UnitCost)
        VALUES (?, ?, ?, ?, ?)
    """;

        String insertDebtSql = """
        INSERT INTO SupplierDebts (SupplierID, StockInID, Amount, DueDate, Status)
        VALUES (?, ?, ?, DATEADD(DAY, 30, GETDATE()), ?)
    """;

        try {
            connection.setAutoCommit(false);

            PreparedStatement psStock = connection.prepareStatement(insertStockInSql, PreparedStatement.RETURN_GENERATED_KEYS);
            psStock.setInt(1, stockIn.getSupplierId());
            psStock.setInt(2, stockIn.getCreatedBy());
            psStock.setString(3, stockIn.getNote());
            psStock.setString(4, stockIn.getStockStatus());
            psStock.setString(5, stockIn.getPaymentStatus());
            psStock.setDouble(6, stockIn.getTotalAmount());
            psStock.setDouble(7, stockIn.getInitialPaidAmount());

            int affected = psStock.executeUpdate();
            if (affected <= 0) {
                connection.rollback();
                return -1;
            }

            ResultSet rs = psStock.getGeneratedKeys();
            int stockInId = -1;
            if (rs.next()) {
                stockInId = rs.getInt(1);
            }

            if (stockInId <= 0) {
                connection.rollback();
                return -1;
            }

            PreparedStatement psDetail = connection.prepareStatement(insertDetailSql);
            for (StockInDetail d : details) {
                psDetail.setInt(1, stockInId);
                psDetail.setInt(2, d.getProductId());
                psDetail.setInt(3, d.getQuantity());
                psDetail.setInt(4, d.getReceivedQuantity());
                psDetail.setDouble(5, d.getUnitCost());
                psDetail.addBatch();
            }
            psDetail.executeBatch();

            double debtAmount = stockIn.getTotalAmount() - stockIn.getInitialPaidAmount();

            if (debtAmount > 0) {
                SupplierDebtDAO debtDAO = new SupplierDebtDAO();
                double existingDebt = debtDAO.getOutstandingDebtTotalBySupplier(stockIn.getSupplierId());
                if (existingDebt + debtAmount > 1000000000D) {
                    connection.rollback();
                    return -1;
                }
                PreparedStatement psDebt = connection.prepareStatement(insertDebtSql);
                psDebt.setInt(1, stockIn.getSupplierId());
                psDebt.setInt(2, stockInId);
                psDebt.setDouble(3, debtAmount);

                if (StockIn.PAYMENT_STATUS_PARTIAL.equals(stockIn.getPaymentStatus())) {
                    psDebt.setString(4, "Partial");
                } else {
                    psDebt.setString(4, "Pending");
                }

                psDebt.executeUpdate();
            }

            connection.commit();
            return stockInId;

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
            closeConnection();
        }

        return -1;
    }

    public boolean receiveStockInDetail(int detailId, int receiveQty) {
        String sql = "{CALL sp_ReceiveStockInDetail(?, ?)}";
        try (CallableStatement cs = connection.prepareCall(sql)) {
            cs.setInt(1, detailId);
            cs.setInt(2, receiveQty);
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean requestCancelStockIn(int stockInId, int userId, String reason) {
        String sql = "{CALL sp_RequestCancelStockIn(?, ?, ?)}";
        try (CallableStatement cs = connection.prepareCall(sql)) {
            cs.setInt(1, stockInId);
            cs.setInt(2, userId);
            cs.setString(3, reason);
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean canRequestCancelStockIn(int stockInId) {
        String sql = """
        SELECT 
        ISNULL(SUM(ISNULL(d.ReceivedQuantity, 0)), 0) AS TotalReceived,
        ISNULL(s.InitialPaidAmount, 0) AS InitialPaidAmount,
        s.StockStatus
        FROM StockIn s
        LEFT JOIN StockInDetails d ON s.StockInID = d.StockInID
        WHERE s.StockInID = ?
        GROUP BY s.InitialPaidAmount, s.StockStatus
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, stockInId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalReceived = rs.getInt("TotalReceived");
                    double initialPaidAmount = rs.getDouble("InitialPaidAmount");
                    String stockStatus = rs.getString("StockStatus");

                    if (stockStatus == null) {
                        stockStatus = "";
                    }

                    return totalReceived == 0
                            && initialPaidAmount <= 0
                            && "Pending".equalsIgnoreCase(stockStatus);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean approveCancelStockIn(int stockInId, int managerId) {
        String sql = "{CALL sp_ApproveCancelStockIn(?, ?)}";
        try (CallableStatement cs = connection.prepareCall(sql)) {
            cs.setInt(1, stockInId);
            cs.setInt(2, managerId);
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean rejectCancelStockIn(int stockInId) {
        String sql = "{CALL sp_RejectCancelStockIn(?)}";
        try (CallableStatement cs = connection.prepareCall(sql)) {
            cs.setInt(1, stockInId);
            cs.execute();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateNoteAndPaymentStatus(int stockInId, String note, String paymentStatus) {
        String sql = "UPDATE StockIn SET Note = ?, PaymentStatus = ? WHERE StockInID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, note);
            ps.setString(2, paymentStatus);
            ps.setInt(3, stockInId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public StockInDetail getStockInDetailByDetailId(int detailId) {
        String sql = "SELECT d.DetailID, d.StockInID, d.ProductID, d.Quantity, d.ReceivedQuantity, "
                + "d.UnitCost, d.SubTotal, p.Name AS ProductName, p.SKU, p.Unit "
                + "FROM StockInDetails d "
                + "INNER JOIN Products p ON d.ProductID = p.ProductID "
                + "WHERE d.DetailID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, detailId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    StockInDetail d = new StockInDetail();
                    d.setDetailId(rs.getInt("DetailID"));
                    d.setStockInId(rs.getInt("StockInID"));
                    d.setProductId(rs.getInt("ProductID"));
                    d.setQuantity(rs.getInt("Quantity"));
                    d.setReceivedQuantity(rs.getInt("ReceivedQuantity"));
                    d.setUnitCost(rs.getDouble("UnitCost"));
                    d.setSubTotal(rs.getDouble("SubTotal"));
                    d.setProductName(rs.getString("ProductName"));
                    d.setSku(rs.getString("SKU"));
                    d.setUnit(rs.getString("Unit"));
                    return d;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<StockInDetail> searchReturnableStockInDetails(int supplierId, int productId, String keyword, int page, int pageSize) {
        List<StockInDetail> list = new ArrayList<>();

        String sql = "SELECT d.DetailID, d.StockInID, d.ProductID, d.Quantity, d.ReceivedQuantity, "
                + "d.UnitCost, d.SubTotal, p.Name AS ProductName, p.SKU, p.Unit "
                + "FROM StockInDetails d "
                + "INNER JOIN StockIn s ON d.StockInID = s.StockInID "
                + "INNER JOIN Products p ON d.ProductID = p.ProductID "
                + "WHERE s.SupplierID = ? "
                + "AND d.ProductID = ? "
                + "AND ISNULL(d.ReceivedQuantity, 0) > 0 "
                + "AND (CAST(d.DetailID AS NVARCHAR) LIKE ? OR CAST(d.StockInID AS NVARCHAR) LIKE ?) "
                + "AND (ISNULL(d.ReceivedQuantity, 0) - ISNULL(( "
                + "    SELECT SUM(rtd.Quantity) "
                + "    FROM ReturnToVendorDetails rtd "
                + "    INNER JOIN ReturnToVendors rtv ON rtd.RTVID = rtv.RTVID "
                + "    WHERE rtd.StockInDetailID = d.DetailID "
                + "      AND rtv.Status IN ('Pending', 'Approved', 'Completed') "
                + "), 0)) > 0 "
                + "ORDER BY d.DetailID DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String likeKeyword = "%" + (keyword == null ? "" : keyword.trim()) + "%";
            ps.setInt(1, supplierId);
            ps.setInt(2, productId);
            ps.setString(3, likeKeyword);
            ps.setString(4, likeKeyword);
            ps.setInt(5, (page - 1) * pageSize);
            ps.setInt(6, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StockInDetail d = new StockInDetail();
                    d.setDetailId(rs.getInt("DetailID"));
                    d.setStockInId(rs.getInt("StockInID"));
                    d.setProductId(rs.getInt("ProductID"));
                    d.setQuantity(rs.getInt("Quantity"));
                    d.setReceivedQuantity(rs.getInt("ReceivedQuantity"));
                    d.setUnitCost(rs.getDouble("UnitCost"));
                    d.setSubTotal(rs.getDouble("SubTotal"));
                    d.setProductName(rs.getString("ProductName"));
                    d.setSku(rs.getString("SKU"));
                    d.setUnit(rs.getString("Unit"));
                    list.add(d);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean isValidStockInDetailForReturn(int detailId, int supplierId, int productId) {
        String sql = "SELECT 1 "
                + "FROM StockInDetails d "
                + "INNER JOIN StockIn s ON d.StockInID = s.StockInID "
                + "WHERE d.DetailID = ? "
                + "AND s.SupplierID = ? "
                + "AND d.ProductID = ? "
                + "AND ISNULL(d.ReceivedQuantity, 0) > 0";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, detailId);
            ps.setInt(2, supplierId);
            ps.setInt(3, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getRemainingReturnableQuantity(int detailId) {
        String sql = "SELECT CASE "
                + "    WHEN (ISNULL(d.ReceivedQuantity, 0) - ISNULL(("
                + "        SELECT SUM(rtd.Quantity) "
                + "        FROM ReturnToVendorDetails rtd "
                + "        INNER JOIN ReturnToVendors rtv ON rtd.RTVID = rtv.RTVID "
                + "        WHERE rtd.StockInDetailID = d.DetailID "
                + "          AND rtv.Status IN ('Pending', 'Approved', 'Completed')"
                + "    ), 0)) < 0 THEN 0 "
                + "    ELSE (ISNULL(d.ReceivedQuantity, 0) - ISNULL(("
                + "        SELECT SUM(rtd.Quantity) "
                + "        FROM ReturnToVendorDetails rtd "
                + "        INNER JOIN ReturnToVendors rtv ON rtd.RTVID = rtv.RTVID "
                + "        WHERE rtd.StockInDetailID = d.DetailID "
                + "          AND rtv.Status IN ('Pending', 'Approved', 'Completed')"
                + "    ), 0)) "
                + "END AS RemainingQty "
                + "FROM StockInDetails d "
                + "WHERE d.DetailID = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, detailId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("RemainingQty");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<StockInDetailReport> getStockInDetailsReport(String fromDate, String toDate) {
        List<StockInDetailReport> list = new ArrayList<>();
        String sql = """
            SELECT 
                si.Date, si.StockInID, s.Name as SupplierName,
                p.Name as ProductName, sd.Quantity, sd.UnitCost,
                (sd.Quantity * sd.UnitCost) as TotalCost
            FROM dbo.StockIn si
            JOIN dbo.StockInDetails sd ON si.StockInID = sd.StockInID
            JOIN dbo.Products p ON sd.ProductID = p.ProductID
            JOIN dbo.Suppliers s ON si.SupplierID = s.SupplierID
            WHERE CAST(si.Date AS DATE) BETWEEN ? AND ?
            ORDER BY si.Date DESC
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, fromDate);
            ps.setString(2, toDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StockInDetailReport r = new StockInDetailReport();
                    r.setDate(rs.getTimestamp("Date"));
                    r.setStockInId(rs.getInt("StockInID"));
                    r.setSupplierName(rs.getString("SupplierName"));
                    r.setProductName(rs.getString("ProductName"));
                    r.setQuantity(rs.getInt("Quantity"));
                    r.setUnitCost(rs.getDouble("UnitCost"));
                    r.setTotalCost(rs.getDouble("TotalCost"));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public static class StockInDetailReport {

        private java.sql.Timestamp date;
        private int stockInId;
        private String supplierName, productName;
        private int quantity;
        private double unitCost, totalCost;

        // Getters/Setters
        public java.sql.Timestamp getDate() {
            return date;
        }

        public void setDate(java.sql.Timestamp date) {
            this.date = date;
        }

        public int getStockInId() {
            return stockInId;
        }

        public void setStockInId(int stockInId) {
            this.stockInId = stockInId;
        }

        public String getSupplierName() {
            return supplierName;
        }

        public void setSupplierName(String supplierName) {
            this.supplierName = supplierName;
        }

        public String getProductName() {
            return productName;
        }

        public void setProductName(String productName) {
            this.productName = productName;
        }

        public int getQuantity() {
            return quantity;
        }

        public void setQuantity(int quantity) {
            this.quantity = quantity;
        }

        public double getUnitCost() {
            return unitCost;
        }

        public void setUnitCost(double unitCost) {
            this.unitCost = unitCost;
        }

        public double getTotalCost() {
            return totalCost;
        }

        public void setTotalCost(double totalCost) {
            this.totalCost = totalCost;
        }
    }
}
