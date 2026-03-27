package dao;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import model.StockIn;
import model.SupplierDebt;
import model.SupplierDebtPayment;
import utils.DBContext;

public class SupplierDebtDAO extends DBContext {

    public List<SupplierDebt> searchDebts(Integer supplierId, String status, Date fromDate, Date toDate) {
        List<SupplierDebt> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT d.DebtID, d.SupplierID, d.StockInID, d.Amount, d.DueDate, d.Status, s.Name AS SupplierName, "
                + "       ISNULL(si.TotalAmount - ISNULL(si.InitialPaidAmount, 0), d.Amount) AS OriginalAmount, "
                + "       ISNULL((SELECT SUM(p.Amount) FROM SupplierDebtPayment p WHERE p.DebtID = d.DebtID), 0) AS PaidAmount "
                + "FROM SupplierDebts d "
                + "JOIN Suppliers s ON d.SupplierID = s.SupplierID "
                + "LEFT JOIN StockIn si ON d.StockInID = si.StockInID "
                + "WHERE 1 = 1");
        if (supplierId != null) sql.append(" AND d.SupplierID = ?");
        if (status != null && !status.trim().isEmpty()) sql.append(" AND d.Status = ?");
        if (fromDate != null) sql.append(" AND d.DueDate >= ?");
        if (toDate != null) sql.append(" AND d.DueDate <= ?");
        sql.append(" ORDER BY d.DebtID DESC");
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int index = 1;
            if (supplierId != null) ps.setInt(index++, supplierId);
            if (status != null && !status.trim().isEmpty()) ps.setString(index++, status);
            if (fromDate != null) ps.setDate(index++, fromDate);
            if (toDate != null) ps.setDate(index++, toDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDebt(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public SupplierDebt getLatestOffsettableDebtBySupplier(int supplierId) {
        String sql = "SELECT TOP 1 d.DebtID, d.SupplierID, d.StockInID, d.Amount, d.DueDate, d.Status, s.Name AS SupplierName, "
                + "       ISNULL(si.TotalAmount - ISNULL(si.InitialPaidAmount, 0), d.Amount) AS OriginalAmount, "
                + "       ISNULL((SELECT SUM(p.Amount) FROM SupplierDebtPayment p WHERE p.DebtID = d.DebtID), 0) AS PaidAmount "
                + "FROM SupplierDebts d "
                + "JOIN Suppliers s ON d.SupplierID = s.SupplierID "
                + "LEFT JOIN StockIn si ON d.StockInID = si.StockInID "
                + "WHERE d.SupplierID = ? AND d.Status IN ('Partial', 'Pending', 'Overdue') ORDER BY d.DebtID DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapDebt(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public double getOffsettableDebtTotalBySupplier(int supplierId) {
        String sql = "SELECT ISNULL(SUM(Amount),0) AS TotalAmount FROM SupplierDebts WHERE SupplierID = ? AND Status IN ('Pending','Partial','Overdue')";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble("TotalAmount");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean hasEnoughDebtForOffset(int supplierId, double requiredAmount) {
        return getOffsettableDebtTotalBySupplier(supplierId) >= requiredAmount;
    }

    public boolean reduceDebtAmount(int debtId, double reduceAmount) {
        if (reduceAmount <= 0) return false;
        try {
            connection.setAutoCommit(false);
            SupplierDebt debt = getDebtByIdInternal(debtId);
            if (debt == null || debt.getAmount() < reduceAmount) {
                connection.rollback();
                return false;
            }
            double newAmount = Math.max(0, debt.getAmount() - reduceAmount);
            String newStatus = newAmount == 0 ? "Paid" : "Partial";
            try (PreparedStatement ps = connection.prepareStatement("UPDATE SupplierDebts SET Amount = ?, Status = ? WHERE DebtID = ?")) {
                ps.setDouble(1, newAmount);
                ps.setString(2, newStatus);
                ps.setInt(3, debtId);
                if (ps.executeUpdate() <= 0) {
                    connection.rollback();
                    return false;
                }
            }
            syncStockInPaymentStatus(debt.getStockInID(), newAmount);
            connection.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { connection.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
        } finally {
            try { connection.setAutoCommit(true); } catch (Exception ignored) {}
        }
        return false;
    }

    public double getOutstandingDebtTotalBySupplier(int supplierId) {
        return getOffsettableDebtTotalBySupplier(supplierId);
    }

    public List<SupplierDebt> getDebtsDueWithinDays(Integer supplierId, int days) {
        List<SupplierDebt> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT d.DebtID, d.SupplierID, d.StockInID, d.Amount, d.DueDate, d.Status, s.Name AS SupplierName, "
                + "       ISNULL(si.TotalAmount - ISNULL(si.InitialPaidAmount, 0), d.Amount) AS OriginalAmount, "
                + "       ISNULL((SELECT SUM(p.Amount) FROM SupplierDebtPayment p WHERE p.DebtID = d.DebtID), 0) AS PaidAmount "
                + "FROM SupplierDebts d "
                + "JOIN Suppliers s ON d.SupplierID = s.SupplierID "
                + "LEFT JOIN StockIn si ON d.StockInID = si.StockInID "
                + "WHERE d.Status IN ('Pending','Partial','Overdue') AND DATEDIFF(DAY, CAST(GETDATE() AS DATE), d.DueDate) BETWEEN 0 AND ?");
        if (supplierId != null) sql.append(" AND d.SupplierID = ?");
        sql.append(" ORDER BY d.DueDate ASC, d.DebtID DESC");
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            ps.setInt(1, days);
            if (supplierId != null) ps.setInt(2, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDebt(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean hasReminderAudit(int debtId, int userId, String reminderType, Date reminderDate) {
        String sql = "SELECT 1 FROM SupplierDebtReminderAudit WHERE DebtID = ? AND UserID = ? AND ReminderType = ? AND ReminderDate = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, debtId);
            ps.setInt(2, userId);
            ps.setString(3, reminderType);
            ps.setDate(4, reminderDate);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean insertReminderAudit(int debtId, int userId, String reminderType, Date reminderDate) {
        String sql = "INSERT INTO SupplierDebtReminderAudit (DebtID, UserID, ReminderType, ReminderDate) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, debtId);
            ps.setInt(2, userId);
            ps.setString(3, reminderType);
            ps.setDate(4, reminderDate);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public SupplierDebt getDebtById(int debtId) {
        return getDebtByIdInternal(debtId);
    }

    private SupplierDebt getDebtByIdInternal(int debtId) {
        String sql = "SELECT d.DebtID, d.SupplierID, d.StockInID, d.Amount, d.DueDate, d.Status, s.Name AS SupplierName, "
                + "       ISNULL(si.TotalAmount - ISNULL(si.InitialPaidAmount, 0), d.Amount) AS OriginalAmount, "
                + "       ISNULL((SELECT SUM(p.Amount) FROM SupplierDebtPayment p WHERE p.DebtID = d.DebtID), 0) AS PaidAmount "
                + "FROM SupplierDebts d "
                + "JOIN Suppliers s ON d.SupplierID = s.SupplierID "
                + "LEFT JOIN StockIn si ON d.StockInID = si.StockInID "
                + "WHERE d.DebtID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, debtId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapDebt(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<SupplierDebtPayment> getPaymentHistoryByDebtId(int debtId) {
        List<SupplierDebtPayment> list = new ArrayList<>();
        String sql = "SELECT p.PaymentID, p.DebtID, p.Amount, p.PaymentDate, p.Note, p.CreatedBy, u.FullName AS CreatedByName "
                + "FROM SupplierDebtPayment p "
                + "LEFT JOIN [User] u ON p.CreatedBy = u.UserID "
                + "WHERE p.DebtID = ? ORDER BY p.PaymentDate DESC, p.PaymentID DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, debtId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SupplierDebtPayment p = new SupplierDebtPayment();
                    p.setPaymentID(rs.getInt("PaymentID"));
                    p.setDebtID(rs.getInt("DebtID"));
                    p.setAmount(rs.getDouble("Amount"));
                    p.setPaymentDate(rs.getTimestamp("PaymentDate"));
                    p.setNote(rs.getString("Note"));
                    p.setCreatedBy(rs.getInt("CreatedBy"));
                    p.setCreatedByName(rs.getString("CreatedByName"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addInstallmentPayment(int debtId, double paymentAmount, int createdBy, String note) {
        if (paymentAmount <= 0) return false;
        try {
            connection.setAutoCommit(false);
            SupplierDebt debt = getDebtByIdInternal(debtId);
            if (debt == null || "Paid".equalsIgnoreCase(debt.getStatus()) || "Cancelled".equalsIgnoreCase(debt.getStatus())) {
                connection.rollback();
                return false;
            }
            if (paymentAmount > debt.getAmount()) {
                connection.rollback();
                return false;
            }
            try (PreparedStatement ps = connection.prepareStatement("INSERT INTO SupplierDebtPayment (DebtID, Amount, Note, CreatedBy) VALUES (?, ?, ?, ?)")) {
                ps.setInt(1, debtId);
                ps.setDouble(2, paymentAmount);
                if (note == null || note.trim().isEmpty()) ps.setNull(3, Types.NVARCHAR); else ps.setString(3, note.trim());
                ps.setInt(4, createdBy);
                if (ps.executeUpdate() <= 0) {
                    connection.rollback();
                    return false;
                }
            }
            double newAmount = Math.max(0, debt.getAmount() - paymentAmount);
            String newStatus = newAmount == 0 ? "Paid" : "Partial";
            try (PreparedStatement ps = connection.prepareStatement("UPDATE SupplierDebts SET Amount = ?, Status = ? WHERE DebtID = ?")) {
                ps.setDouble(1, newAmount);
                ps.setString(2, newStatus);
                ps.setInt(3, debtId);
                if (ps.executeUpdate() <= 0) {
                    connection.rollback();
                    return false;
                }
            }
            syncStockInPaymentStatus(debt.getStockInID(), newAmount);
            connection.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { connection.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
        } finally {
            try { connection.setAutoCommit(true); } catch (Exception ignored) {}
        }
        return false;
    }

    public boolean confirmPaid(int debtId, int confirmedBy, String note) {
        SupplierDebt debt = getDebtById(debtId);
        if (debt == null || debt.getAmount() <= 0) return false;
        return addInstallmentPayment(debtId, debt.getAmount(), confirmedBy, note);
    }

    private void syncStockInPaymentStatus(int stockInId, double currentDebtAmount) throws Exception {
        String nextStatus = currentDebtAmount <= 0 ? StockIn.PAYMENT_STATUS_PAID : StockIn.PAYMENT_STATUS_PARTIAL;
        try (PreparedStatement ps = connection.prepareStatement("UPDATE StockIn SET PaymentStatus = ? WHERE StockInID = ?")) {
            ps.setString(1, nextStatus);
            ps.setInt(2, stockInId);
            ps.executeUpdate();
        }
    }

    private SupplierDebt mapDebt(ResultSet rs) throws Exception {
        SupplierDebt d = new SupplierDebt();
        d.setDebtID(rs.getInt("DebtID"));
        d.setSupplierID(rs.getInt("SupplierID"));
        d.setStockInID(rs.getInt("StockInID"));
        d.setAmount(rs.getDouble("Amount"));
        d.setDueDate(rs.getDate("DueDate"));
        d.setStatus(rs.getString("Status"));
        d.setSupplierName(rs.getString("SupplierName"));
        try { d.setOriginalAmount(rs.getDouble("OriginalAmount")); } catch (Exception ignored) {}
        try { d.setPaidAmount(rs.getDouble("PaidAmount")); } catch (Exception ignored) {}
        return d;
    }
}
