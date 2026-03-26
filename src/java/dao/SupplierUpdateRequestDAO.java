package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import model.Supplier;
import model.SupplierUpdateRequest;
import utils.DBContext;

public class SupplierUpdateRequestDAO extends DBContext {

    public boolean createRequest(SupplierUpdateRequest req) {
        String sql = "INSERT INTO SupplierUpdateRequests (SupplierID, RequestedBy, PendingName, PendingPhone, PendingAddress, PendingEmail, PendingIsActive, RequestToken, Status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Pending')";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, req.getSupplierID());
            if (req.getRequestedBy() == null) ps.setNull(2, java.sql.Types.INTEGER); else ps.setInt(2, req.getRequestedBy());
            ps.setString(3, req.getPendingName());
            ps.setString(4, req.getPendingPhone());
            ps.setString(5, req.getPendingAddress());
            ps.setString(6, req.getPendingEmail());
            ps.setBoolean(7, req.isPendingIsActive());
            ps.setString(8, req.getRequestToken());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public SupplierUpdateRequest getByToken(String token) {
        String sql = "SELECT * FROM SupplierUpdateRequests WHERE RequestToken = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    SupplierUpdateRequest r = new SupplierUpdateRequest();
                    r.setRequestID(rs.getInt("RequestID"));
                    r.setSupplierID(rs.getInt("SupplierID"));
                    Object requestedBy = rs.getObject("RequestedBy");
                    r.setRequestedBy(requestedBy == null ? null : ((Number) requestedBy).intValue());
                    r.setPendingName(rs.getString("PendingName"));
                    r.setPendingPhone(rs.getString("PendingPhone"));
                    r.setPendingAddress(rs.getString("PendingAddress"));
                    r.setPendingEmail(rs.getString("PendingEmail"));
                    r.setPendingIsActive(rs.getBoolean("PendingIsActive"));
                    r.setRequestToken(rs.getString("RequestToken"));
                    r.setStatus(rs.getString("Status"));
                    r.setRequestedAt(rs.getTimestamp("RequestedAt"));
                    r.setRespondedAt(rs.getTimestamp("RespondedAt"));
                    r.setDecisionNote(rs.getString("DecisionNote"));
                    return r;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean approveRequest(String token) {
        SupplierUpdateRequest req = getByToken(token);
        if (req == null || !"Pending".equalsIgnoreCase(req.getStatus())) return false;

        SupplierDAO supplierDAO = new SupplierDAO();
        Supplier current = supplierDAO.getSupplierById(req.getSupplierID());
        if (current == null) return false;

        boolean emailChanged = !safeEquals(current.getEmail(), req.getPendingEmail());
        boolean updated = supplierDAO.updateSupplier(req.getSupplierID(), req.getPendingName(), req.getPendingPhone(), req.getPendingEmail(), req.getPendingAddress(), req.isPendingIsActive());
        if (!updated) return false;

        if (emailChanged) {
            supplierDAO.resetEmailVerification(req.getSupplierID());
        }

        String sql = "UPDATE SupplierUpdateRequests SET Status = 'Approved', RespondedAt = GETDATE() WHERE RequestToken = ? AND Status = 'Pending'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, token);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean rejectRequest(String token, String note) {
        String sql = "UPDATE SupplierUpdateRequests SET Status = 'Rejected', RespondedAt = GETDATE(), DecisionNote = ? WHERE RequestToken = ? AND Status = 'Pending'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, note);
            ps.setString(2, token);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean safeEquals(String a, String b) {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        return a.trim().equalsIgnoreCase(b.trim());
    }
}
