package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Notification;
import utils.DBContext;

public class NotificationDAO extends DBContext {

    /** Insert a notification for one receiver */
    public boolean insert(Notification n) {
        String sql = "INSERT INTO Notifications (UserID, Title, Message, IsRead, Type) VALUES (?, ?, ?, 0, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, n.getUserId());
            ps.setString(2, n.getTitle());
            ps.setString(3, n.getMessage());
            ps.setString(4, n.getType() != null ? n.getType() : "Info");
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Get all notifications for a user (newest first, limit 50) */
    public List<Notification> getByReceiver(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT TOP 50 NotificationID, UserID, Title, Message, IsRead, CreatedAt, Type "
                + "FROM Notifications WHERE UserID = ? ORDER BY CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setNotificationId(rs.getInt("NotificationID"));
                    n.setUserId(rs.getInt("UserID"));
                    n.setTitle(rs.getString("Title"));
                    n.setMessage(rs.getString("Message"));
                    n.setRead(rs.getBoolean("IsRead"));
                    n.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    n.setType(rs.getString("Type"));
                    list.add(n);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Count unread notifications for a user */
    public int countUnread(int userId) {
        String sql = "SELECT COUNT(*) FROM Notifications WHERE UserID = ? AND IsRead = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Mark a specific notification as read */
    public void markAsRead(int userId, int notificationId) {
        String sql = "UPDATE Notifications SET IsRead = 1 WHERE UserID = ? AND NotificationID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, notificationId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Mark all notifications as read for a user */
    public void markAllRead(int userId) {
        String sql = "UPDATE Notifications SET IsRead = 1 WHERE UserID = ? AND IsRead = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Get all active manager user IDs (RoleID = 2) */
    public List<Integer> getManagerIds() {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT UserID FROM [User] WHERE RoleID = 2 AND IsActive = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                ids.add(rs.getInt("UserID"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ids;
    }
}
