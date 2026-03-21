package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import model.ReturnEvent;
import model.ReturnRequest;
import model.ReturnStatus;
import utils.DBContext;

public class ReturnDAO extends DBContext {

    public List<ReturnRequest> listAll() {
        List<ReturnRequest> list = new ArrayList<>();
        try {
            PreparedStatement stm = connection.prepareStatement("""
                SELECT ReturnID, ReturnCode, SKU, ProductName, CustomerName, CustomerPhone,
                       Reason, ConditionNote, Status,
                       RefundAmount, RefundMethod, RefundReference, RefundedAt,
                       CreatedAt, UpdatedAt
                FROM dbo.ReturnRequests
                ORDER BY UpdatedAt DESC, ReturnID DESC
            """);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(mapReturn(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ReturnRequest> listByCreator(String actor, String keyword) {
        List<ReturnRequest> list = new ArrayList<>();
        if (actor == null || actor.isBlank()) {
            return list;
        }

        String normalizedKeyword = keyword == null ? null : keyword.trim();
        boolean hasKeyword = normalizedKeyword != null && !normalizedKeyword.isEmpty();

        StringBuilder sql = new StringBuilder("""
            SELECT r.ReturnID, r.ReturnCode, r.SKU, r.ProductName, r.CustomerName, r.CustomerPhone,
                   r.Reason, r.ConditionNote, r.Status,
                   r.RefundAmount, r.RefundMethod, r.RefundReference, r.RefundedAt,
                   r.CreatedAt, r.UpdatedAt
            FROM dbo.ReturnRequests r
            INNER JOIN dbo.ReturnEvents e ON r.ReturnID = e.ReturnID
            WHERE e.Action = 'CREATE' AND e.Actor = ?
        """);

        if (hasKeyword) {
            sql.append("""
                 AND (r.ReturnCode LIKE ? OR r.SKU LIKE ? OR r.CustomerName LIKE ? OR r.CustomerPhone LIKE ?)
            """);
        }
        sql.append(" ORDER BY r.UpdatedAt DESC, r.ReturnID DESC");

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
                list.add(mapReturn(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ReturnRequest getById(int id) {
        ReturnRequest r = null;
        try {
            PreparedStatement stm = connection.prepareStatement("""
                SELECT ReturnID, ReturnCode, SKU, ProductName, CustomerName, CustomerPhone,
                       Reason, ConditionNote, Status,
                       RefundAmount, RefundMethod, RefundReference, RefundedAt,
                       CreatedAt, UpdatedAt
                FROM dbo.ReturnRequests
                WHERE ReturnID = ?
            """);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                r = mapReturn(rs);
            } else {
                return null;
            }

            PreparedStatement ev = connection.prepareStatement("""
                SELECT EventID, ReturnID, EventTime, Actor, Action, Note
                FROM dbo.ReturnEvents
                WHERE ReturnID = ?
                ORDER BY EventTime DESC, EventID DESC
            """);
            ev.setInt(1, id);
            ResultSet ers = ev.executeQuery();
            while (ers.next()) {
                r.getEvents().add(mapEvent(ers));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return r;
    }

    public ReturnRequest create(
            String sku,
            String productName,
            String customerName,
            String customerPhone,
            String reason,
            String conditionNote,
            String actor
    ) {
        try {
            PreparedStatement stm = connection.prepareStatement("""
                INSERT INTO dbo.ReturnRequests (ReturnCode, SKU, ProductName, CustomerName, CustomerPhone, Reason, ConditionNote, Status)
                VALUES (NULL, ?, ?, ?, ?, ?, ?, ?)
            """, Statement.RETURN_GENERATED_KEYS);

            stm.setString(1, sku);
            stm.setString(2, productName);
            stm.setString(3, customerName);
            stm.setString(4, customerPhone);
            stm.setString(5, reason);
            stm.setString(6, conditionNote);
            stm.setString(7, ReturnStatus.NEW.name());

            stm.executeUpdate();
            ResultSet keys = stm.getGeneratedKeys();
            if (!keys.next()) {
                return null;
            }
            int id = keys.getInt(1);
            String code = "RT-" + id;

            PreparedStatement up = connection.prepareStatement("""
                UPDATE dbo.ReturnRequests
                SET ReturnCode = ?, UpdatedAt = SYSUTCDATETIME()
                WHERE ReturnID = ?
            """);
            up.setString(1, code);
            up.setInt(2, id);
            up.executeUpdate();

            insertEvent(id, actor, "CREATE", "Tạo yêu cầu trả hàng/hoàn tiền");
            return getById(id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public boolean updateStatus(int returnId, ReturnStatus newStatus, String note, String actor) {
        try {
            ReturnRequest current = getById(returnId);
            if (current == null) {
                return false;
            }

            PreparedStatement stm = connection.prepareStatement("""
                UPDATE dbo.ReturnRequests
                SET Status = ?, UpdatedAt = SYSUTCDATETIME()
                WHERE ReturnID = ?
            """);
            stm.setString(1, newStatus.name());
            stm.setInt(2, returnId);
            stm.executeUpdate();

            String old = current.getStatus() == null ? "" : current.getStatus().name();
            String msg = "Trạng thái: " + old + " -> " + newStatus.name()
                    + (note == null || note.isBlank() ? "" : (" | " + note));
            insertEvent(returnId, actor, "STATUS", msg);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addNote(int returnId, String note, String actor) {
        try {
            PreparedStatement stm = connection.prepareStatement("""
                UPDATE dbo.ReturnRequests
                SET UpdatedAt = SYSUTCDATETIME()
                WHERE ReturnID = ?
            """);
            stm.setInt(1, returnId);
            stm.executeUpdate();

            insertEvent(returnId, actor, "NOTE", note);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean recordRefund(int returnId, Double amount, String method, String reference, String note, String actor) {
        try {
            PreparedStatement stm = connection.prepareStatement("""
                UPDATE dbo.ReturnRequests
                SET RefundAmount = ?,
                    RefundMethod = ?,
                    RefundReference = ?,
                    RefundedAt = SYSUTCDATETIME(),
                    Status = ?,
                    UpdatedAt = SYSUTCDATETIME()
                WHERE ReturnID = ?
            """);
            if (amount == null) {
                stm.setNull(1, java.sql.Types.DECIMAL);
            } else {
                stm.setDouble(1, amount);
            }
            stm.setString(2, method);
            stm.setString(3, reference);
            stm.setString(4, ReturnStatus.REFUNDED.name());
            stm.setInt(5, returnId);
            stm.executeUpdate();

            String msg = "Hoàn tiền: " + (amount == null ? "" : amount)
                    + (method == null || method.isBlank() ? "" : (" | " + method))
                    + (reference == null || reference.isBlank() ? "" : (" | ref=" + reference))
                    + (note == null || note.isBlank() ? "" : (" | " + note));
            insertEvent(returnId, actor, "REFUND", msg);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void insertEvent(int returnId, String actor, String action, String note) throws Exception {
        PreparedStatement stm = connection.prepareStatement("""
            INSERT INTO dbo.ReturnEvents (ReturnID, Actor, Action, Note)
            VALUES (?, ?, ?, ?)
        """);
        stm.setInt(1, returnId);
        stm.setString(2, actor == null || actor.isBlank() ? "system" : actor);
        stm.setString(3, action);
        stm.setString(4, note);
        stm.executeUpdate();
    }

    private ReturnRequest mapReturn(ResultSet rs) throws Exception {
        ReturnRequest r = new ReturnRequest();
        r.setId(rs.getInt("ReturnID"));
        r.setReturnCode(rs.getString("ReturnCode"));
        r.setSku(rs.getString("SKU"));
        r.setProductName(rs.getString("ProductName"));
        r.setCustomerName(rs.getString("CustomerName"));
        r.setCustomerPhone(rs.getString("CustomerPhone"));
        r.setReason(rs.getString("Reason"));
        r.setConditionNote(rs.getString("ConditionNote"));

        String st = rs.getString("Status");
        if (st != null) {
            try {
                r.setStatus(ReturnStatus.valueOf(st));
            } catch (IllegalArgumentException ignored) {
                r.setStatus(ReturnStatus.NEW);
            }
        }

        double amt = rs.getDouble("RefundAmount");
        if (!rs.wasNull()) {
            r.setRefundAmount(amt);
        }
        r.setRefundMethod(rs.getString("RefundMethod"));
        r.setRefundReference(rs.getString("RefundReference"));

        Timestamp refunded = rs.getTimestamp("RefundedAt");
        if (refunded != null) {
            r.setRefundedAt(refunded.toLocalDateTime());
        }

        Timestamp created = rs.getTimestamp("CreatedAt");
        Timestamp updated = rs.getTimestamp("UpdatedAt");
        if (created != null) {
            r.setCreatedAt(created.toLocalDateTime());
        }
        if (updated != null) {
            r.setUpdatedAt(updated.toLocalDateTime());
        }
        return r;
    }

    private ReturnEvent mapEvent(ResultSet rs) throws Exception {
        ReturnEvent e = new ReturnEvent();
        e.setId(rs.getInt("EventID"));
        e.setReturnId(rs.getInt("ReturnID"));
        Timestamp t = rs.getTimestamp("EventTime");
        e.setTime(t == null ? LocalDateTime.now() : t.toLocalDateTime());
        e.setActor(rs.getString("Actor"));
        e.setAction(rs.getString("Action"));
        e.setNote(rs.getString("Note"));
        return e;
    }
}

