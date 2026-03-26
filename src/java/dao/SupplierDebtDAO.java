package dao;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import model.SupplierDebt;
import utils.DBContext;

public class SupplierDebtDAO extends DBContext {

    public List<SupplierDebt> searchDebts(Integer supplierId, String status, Date fromDate, Date toDate) {
        List<SupplierDebt> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT d.DebtID, d.SupplierID, d.StockInID, d.Amount, d.DueDate, d.Status, s.Name AS SupplierName FROM SupplierDebts d JOIN Suppliers s ON d.SupplierID = s.SupplierID WHERE 1 = 1");
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
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public SupplierDebt getLatestOffsettableDebtBySupplier(int supplierId) {
        String sql = "SELECT TOP 1 d.DebtID, d.SupplierID, d.StockInID, d.Amount, d.DueDate, d.Status, s.Name AS SupplierName FROM SupplierDebts d JOIN Suppliers s ON d.SupplierID = s.SupplierID WHERE d.SupplierID = ? AND d.Status IN ('Partial', 'Pending', 'Overdue') ORDER BY d.DebtID DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return mapDebt(rs); }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public double getOffsettableDebtTotalBySupplier(int supplierId) {
        String sql = "SELECT ISNULL(SUM(Amount),0) AS TotalAmount FROM SupplierDebts WHERE SupplierID = ? AND Status IN ('Pending','Partial','Overdue')";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getDouble("TotalAmount"); }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    public boolean hasEnoughDebtForOffset(int supplierId, double requiredAmount) {
        return getOffsettableDebtTotalBySupplier(supplierId) >= requiredAmount;
    }

    public boolean reduceDebtAmount(int debtId, double reduceAmount) {
        String selectSql = "SELECT Amount FROM SupplierDebts WHERE DebtID = ?";
        try (PreparedStatement ps = connection.prepareStatement(selectSql)) {
            ps.setInt(1, debtId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double currentAmount = rs.getDouble("Amount");
                    double newAmount = Math.max(0, currentAmount - reduceAmount);
                    String newStatus = newAmount == 0 ? "Paid" : "Partial";
                    String updateSql = "UPDATE SupplierDebts SET Amount = ?, Status = ? WHERE DebtID = ?";
                    try (PreparedStatement ups = connection.prepareStatement(updateSql)) {
                        ups.setDouble(1, newAmount);
                        ups.setString(2, newStatus);
                        ups.setInt(3, debtId);
                        return ups.executeUpdate() > 0;
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public double getOutstandingDebtTotalBySupplier(int supplierId) {
        return getOffsettableDebtTotalBySupplier(supplierId);
    }

    public List<SupplierDebt> getDebtsDueWithinDays(Integer supplierId, int days) {
        List<SupplierDebt> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT d.DebtID, d.SupplierID, d.StockInID, d.Amount, d.DueDate, d.Status, s.Name AS SupplierName FROM SupplierDebts d JOIN Suppliers s ON d.SupplierID = s.SupplierID WHERE d.Status IN ('Pending','Partial','Overdue') AND DATEDIFF(DAY, CAST(GETDATE() AS DATE), d.DueDate) BETWEEN 0 AND ?");
        if (supplierId != null) sql.append(" AND d.SupplierID = ?");
        sql.append(" ORDER BY d.DueDate ASC, d.DebtID DESC");
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            ps.setInt(1, days);
            if (supplierId != null) ps.setInt(2, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDebt(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean hasReminderAudit(int debtId, int userId, String reminderType, Date reminderDate) {
        String sql = "SELECT 1 FROM SupplierDebtReminderAudit WHERE DebtID = ? AND UserID = ? AND ReminderType = ? AND ReminderDate = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, debtId);
            ps.setInt(2, userId);
            ps.setString(3, reminderType);
            ps.setDate(4, reminderDate);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) { e.printStackTrace(); }
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
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public SupplierDebt getDebtById(int debtId) {
        String sql = "SELECT d.DebtID, d.SupplierID, d.StockInID, d.Amount, d.DueDate, d.Status, s.Name AS SupplierName FROM SupplierDebts d JOIN Suppliers s ON d.SupplierID = s.SupplierID WHERE d.DebtID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, debtId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return mapDebt(rs); }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean confirmPaid(int debtId, int confirmedBy, String note) {
        SupplierDebt debt = getDebtById(debtId);
        if (debt == null || "Paid".equalsIgnoreCase(debt.getStatus()) || "Cancelled".equalsIgnoreCase(debt.getStatus())) {
            return false;
        }
        try {
            connection.setAutoCommit(false);
            try (PreparedStatement ps = connection.prepareStatement("UPDATE SupplierDebts SET Amount = 0, Status = 'Paid' WHERE DebtID = ?")) {
                ps.setInt(1, debtId);
                if (ps.executeUpdate() <= 0) {
                    connection.rollback();
                    return false;
                }
            }
            try (PreparedStatement ps = connection.prepareStatement("INSERT INTO SupplierDebtPayments (DebtID, SupplierID, Amount, ConfirmedBy, Note) VALUES (?, ?, ?, ?, ?)")) {
                ps.setInt(1, debtId);
                ps.setInt(2, debt.getSupplierID());
                ps.setDouble(3, debt.getAmount());
                ps.setInt(4, confirmedBy);
                if (note == null || note.trim().isEmpty()) ps.setNull(5, Types.NVARCHAR); else ps.setString(5, note.trim());
                ps.executeUpdate();
            }
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

    private SupplierDebt mapDebt(ResultSet rs) throws Exception {
        SupplierDebt d = new SupplierDebt();
        d.setDebtID(rs.getInt("DebtID"));
        d.setSupplierID(rs.getInt("SupplierID"));
        d.setStockInID(rs.getInt("StockInID"));
        d.setAmount(rs.getDouble("Amount"));
        d.setDueDate(rs.getDate("DueDate"));
        d.setStatus(rs.getString("Status"));
        d.setSupplierName(rs.getString("SupplierName"));
        return d;
    }
}
