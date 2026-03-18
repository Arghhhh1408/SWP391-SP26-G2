package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.WarrantyClaim;
import model.WarrantyClaimEvent;
import model.WarrantyClaimStatus;
import utils.DBContext;

public class WarrantyClaimDAO extends DBContext {

    public WarrantyClaim create(String sku, String productName, String customerName, String customerPhone, String issueDescription, String actor) {
        String insertSql = """
            INSERT INTO dbo.WarrantyClaims (ClaimCode, SKU, ProductName, CustomerName, CustomerPhone, IssueDescription, Status)
            VALUES (NULL, ?, ?, ?, ?, ?, ?)
        """;
        try {
            PreparedStatement stm = connection.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            stm.setString(1, sku);
            stm.setString(2, productName);
            stm.setString(3, customerName);
            stm.setString(4, customerPhone);
            stm.setString(5, issueDescription);
            stm.setString(6, WarrantyClaimStatus.NEW.name());
            stm.executeUpdate();

            ResultSet keys = stm.getGeneratedKeys();
            if (!keys.next()) {
                return null;
            }
            int id = keys.getInt(1);
            String claimCode = "WC-" + id;

            PreparedStatement up = connection.prepareStatement("""
                UPDATE dbo.WarrantyClaims
                SET ClaimCode = ?, UpdatedAt = SYSUTCDATETIME()
                WHERE ClaimID = ?
            """);
            up.setString(1, claimCode);
            up.setInt(2, id);
            up.executeUpdate();

            insertEvent(id, actor, "CREATE", "Tạo yêu cầu bảo hành");
            return getById(id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public WarrantyClaim getById(int id) {
        WarrantyClaim claim = null;
        try {
            PreparedStatement stm = connection.prepareStatement("""
                SELECT ClaimID, ClaimCode, SKU, ProductName, CustomerName, CustomerPhone, IssueDescription,
                       Status, CreatedAt, UpdatedAt
                FROM dbo.WarrantyClaims
                WHERE ClaimID = ?
            """);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                claim = mapClaim(rs);
            } else {
                return null;
            }

            PreparedStatement ev = connection.prepareStatement("""
                SELECT EventID, ClaimID, EventTime, Actor, Action, Note
                FROM dbo.WarrantyClaimEvents
                WHERE ClaimID = ?
                ORDER BY EventTime DESC, EventID DESC
            """);
            ev.setInt(1, id);
            ResultSet ers = ev.executeQuery();
            while (ers.next()) {
                claim.getEvents().add(mapEvent(ers));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return claim;
    }

    public List<WarrantyClaim> listAll() {
        List<WarrantyClaim> list = new ArrayList<>();
        try {
            PreparedStatement stm = connection.prepareStatement("""
                SELECT ClaimID, ClaimCode, SKU, ProductName, CustomerName, CustomerPhone, IssueDescription,
                       Status, CreatedAt, UpdatedAt
                FROM dbo.WarrantyClaims
                ORDER BY UpdatedAt DESC, ClaimID DESC
            """);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(mapClaim(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<WarrantyClaim> listByCreator(String actor, String keyword) {
        List<WarrantyClaim> list = new ArrayList<>();
        if (actor == null || actor.isBlank()) {
            return list;
        }

        StringBuilder sql = new StringBuilder("""
            SELECT c.ClaimID, c.ClaimCode, c.SKU, c.ProductName, c.CustomerName, c.CustomerPhone, c.IssueDescription,
                   c.Status, c.CreatedAt, c.UpdatedAt
            FROM dbo.WarrantyClaims c
            INNER JOIN dbo.WarrantyClaimEvents e ON c.ClaimID = e.ClaimID
            WHERE e.Action = 'CREATE' AND e.Actor = ?
        """);

        String normalizedKeyword = keyword == null ? null : keyword.trim();
        boolean hasKeyword = normalizedKeyword != null && !normalizedKeyword.isEmpty();
        if (hasKeyword) {
            sql.append("""
                 AND (c.ClaimCode LIKE ? OR c.SKU LIKE ? OR c.CustomerName LIKE ? OR c.CustomerPhone LIKE ?)
            """);
        }
        sql.append(" ORDER BY c.UpdatedAt DESC, c.ClaimID DESC");

        try {
            PreparedStatement stm = connection.prepareStatement(sql.toString());
            int idx = 1;
            stm.setString(idx++, actor);
            if (hasKeyword) {
                String like = "%" + normalizedKeyword + "%";
                stm.setString(idx++, like);
                stm.setString(idx++, like);
                stm.setString(idx++, like);
                stm.setString(idx++, like);
            }
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(mapClaim(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateStatus(int claimId, WarrantyClaimStatus newStatus, String note, String actor) {
        try {
            WarrantyClaim current = getById(claimId);
            if (current == null) {
                return false;
            }

            PreparedStatement stm = connection.prepareStatement("""
                UPDATE dbo.WarrantyClaims
                SET Status = ?, UpdatedAt = SYSUTCDATETIME()
                WHERE ClaimID = ?
            """);
            stm.setString(1, newStatus.name());
            stm.setInt(2, claimId);
            stm.executeUpdate();

            String old = current.getStatus() == null ? "" : current.getStatus().name();
            String msg = "Trạng thái: " + old + " -> " + newStatus.name()
                    + (note == null || note.isBlank() ? "" : (" | " + note));
            insertEvent(claimId, actor, "STATUS", msg);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addNote(int claimId, String note, String actor) {
        try {
            PreparedStatement stm = connection.prepareStatement("""
                UPDATE dbo.WarrantyClaims
                SET UpdatedAt = SYSUTCDATETIME()
                WHERE ClaimID = ?
            """);
            stm.setInt(1, claimId);
            stm.executeUpdate();

            insertEvent(claimId, actor, "NOTE", note);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void insertEvent(int claimId, String actor, String action, String note) throws Exception {
        PreparedStatement stm = connection.prepareStatement("""
            INSERT INTO dbo.WarrantyClaimEvents (ClaimID, Actor, Action, Note)
            VALUES (?, ?, ?, ?)
        """);
        stm.setInt(1, claimId);
        stm.setString(2, actor == null || actor.isBlank() ? "system" : actor);
        stm.setString(3, action);
        stm.setString(4, note);
        stm.executeUpdate();
    }

    private WarrantyClaim mapClaim(ResultSet rs) throws Exception {
        WarrantyClaim c = new WarrantyClaim();
        c.setId(rs.getInt("ClaimID"));
        c.setClaimCode(rs.getString("ClaimCode"));
        c.setSku(rs.getString("SKU"));
        c.setProductName(rs.getString("ProductName"));
        c.setCustomerName(rs.getString("CustomerName"));
        c.setCustomerPhone(rs.getString("CustomerPhone"));
        c.setIssueDescription(rs.getString("IssueDescription"));
        String st = rs.getString("Status");
        if (st != null) {
            try {
                c.setStatus(WarrantyClaimStatus.valueOf(st));
            } catch (IllegalArgumentException ignored) {
                c.setStatus(WarrantyClaimStatus.NEW);
            }
        }
        Timestamp created = rs.getTimestamp("CreatedAt");
        Timestamp updated = rs.getTimestamp("UpdatedAt");
        if (created != null) {
            c.setCreatedAt(created.toLocalDateTime());
        }
        if (updated != null) {
            c.setUpdatedAt(updated.toLocalDateTime());
        }
        return c;
    }

    private WarrantyClaimEvent mapEvent(ResultSet rs) throws Exception {
        WarrantyClaimEvent e = new WarrantyClaimEvent();
        e.setId(rs.getInt("EventID"));
        e.setClaimId(rs.getInt("ClaimID"));
        Timestamp t = rs.getTimestamp("EventTime");
        if (t != null) {
            e.setTime(t.toLocalDateTime());
        } else {
            e.setTime(LocalDateTime.now());
        }
        e.setActor(rs.getString("Actor"));
        e.setAction(rs.getString("Action"));
        e.setNote(rs.getString("Note"));
        return e;
    }
}

