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
                + "       v.TotalAmountCalculated "
                + "FROM vw_StockInProgress v "
                + "LEFT JOIN [User] u ON v.CreatedBy = u.UserID "
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

    public StockIn getStockInById(int stockInId) {
        String sql = "SELECT v.StockInID, v.SupplierID, v.SupplierName, v.Date, v.CreatedBy, "
                + "       u.Username AS StaffName, v.Note, v.StockStatus, v.PaymentStatus, "
                + "       v.CancelRequestNote, v.CancelRequestedBy, v.CancelRequestedAt, "
                + "       v.CancelApprovedBy, v.CancelApprovedAt, "
                + "       v.TotalOrderedQuantity, v.TotalReceivedQuantity, v.TotalRemainingQuantity, "
                + "       v.TotalAmountCalculated "
                + "FROM vw_StockInProgress v "
                + "LEFT JOIN [User] u ON v.CreatedBy = u.UserID "
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
        String insertStockIn = """
        INSERT INTO StockIn (SupplierID, TotalAmount, CreatedBy, Note, StockStatus, PaymentStatus)
        OUTPUT INSERTED.StockInID
        VALUES (?, ?, ?, ?, ?, ?)
        """;

        String insertDetail = """
        INSERT INTO StockInDetails (StockInID, ProductID, Quantity, ReceivedQuantity, UnitCost)
        VALUES (?, ?, ?, 0, ?)
        """;

        String insertDebt = """
        INSERT INTO SupplierDebts (SupplierID, StockInID, Amount, DueDate, Status)
        OUTPUT INSERTED.DebtID
        VALUES (?, ?, ?, DATEADD(DAY, 45, CAST(GETDATE() AS DATE)), ?)
        """;

        String insertDebtPayment = """
        INSERT INTO SupplierDebtPayment (DebtID, Amount, PaymentDate, Note, CreatedBy)
        VALUES (?, ?, GETDATE(), ?, ?)
        """;

        int stockInId = -1;

        try {
            connection.setAutoCommit(false);

            BigDecimal total = BigDecimal.valueOf(stockIn.getTotalAmount()).setScale(2, RoundingMode.HALF_UP);
            BigDecimal paid = BigDecimal.valueOf(Math.max(0, paidNow)).setScale(2, RoundingMode.HALF_UP);

            if (paid.compareTo(total) > 0) {
                paid = total;
            }

            // 1. Insert StockIn
            try (PreparedStatement ps = connection.prepareStatement(insertStockIn)) {
                ps.setInt(1, stockIn.getSupplierId());
                ps.setBigDecimal(2, total);
                ps.setInt(3, stockIn.getCreatedBy());
                ps.setString(4, stockIn.getNote());
                ps.setString(5, stockIn.getStockStatus());
                ps.setString(6, stockIn.getPaymentStatus());

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stockInId = rs.getInt(1);
                    } else {
                        throw new RuntimeException("Không lấy được StockInID.");
                    }
                }
            }

            // 2. Insert StockInDetails
            try (PreparedStatement ps = connection.prepareStatement(insertDetail)) {
                for (StockInDetail d : details) {
                    ps.setInt(1, stockInId);
                    ps.setInt(2, d.getProductId());
                    ps.setInt(3, d.getQuantity());
                    ps.setBigDecimal(4, BigDecimal.valueOf(d.getUnitCost()).setScale(2, RoundingMode.HALF_UP));
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            // 3. Insert SupplierDebts
            String debtStatus = paid.compareTo(BigDecimal.ZERO) <= 0
                    ? "Pending"
                    : (paid.compareTo(total) < 0 ? "Partial" : "Paid");

            int debtId = -1;
            try (PreparedStatement ps = connection.prepareStatement(insertDebt)) {
                ps.setInt(1, stockIn.getSupplierId());
                ps.setInt(2, stockInId);
                ps.setBigDecimal(3, total);
                ps.setString(4, debtStatus);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        debtId = rs.getInt(1);
                    }
                }
            }

            // 4. Insert lịch sử thanh toán nếu có
            if (debtId > 0 && paid.compareTo(BigDecimal.ZERO) > 0) {
                try (PreparedStatement ps = connection.prepareStatement(insertDebtPayment)) {
                    ps.setInt(1, debtId);
                    ps.setBigDecimal(2, paid);
                    ps.setString(3, "Thanh toán ban đầu khi tạo phiếu nhập");
                    ps.setInt(4, stockIn.getCreatedBy());
                    ps.executeUpdate();
                }
            }

            connection.commit();
            return stockInId;

        } catch (Exception e) {
            try {
                connection.rollback();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            throw new RuntimeException("insertStockInWithDetailsAndDebt failed: " + e.getMessage(), e);
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
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
