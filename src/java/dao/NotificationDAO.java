package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Notification;
import utils.DBContext;

public class NotificationDAO extends DBContext {

    public boolean insertNotification(Notification notification) {
        String sql = "INSERT INTO Notifications (UserID, Title, Message, IsRead, CreatedAt, Type) VALUES (?, ?, ?, 0, GETDATE(), ?)";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, notification.getUserId());
            stm.setString(2, notification.getTitle());
            stm.setString(3, notification.getMessage());
            stm.setString(4, notification.getType());
            int rows = stm.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Notification> getNotificationsByUserId(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM Notifications WHERE UserID = ? ORDER BY CreatedAt DESC";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, userId);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                Notification notif = new Notification();
                notif.setNotificationId(rs.getInt("NotificationID"));
                notif.setUserId(rs.getInt("UserID"));
                notif.setTitle(rs.getString("Title"));
                notif.setMessage(rs.getString("Message"));
                notif.setRead(rs.getBoolean("IsRead"));
                notif.setCreatedAt(rs.getTimestamp("CreatedAt"));
                notif.setType(rs.getString("Type"));
                list.add(notif);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getUnreadCount(int userId) {
        String sql = "SELECT COUNT(*) FROM Notifications WHERE UserID = ? AND IsRead = 0";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, userId);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean markAsRead(int notificationId) {
        String sql = "UPDATE Notifications SET IsRead = 1 WHERE NotificationID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, notificationId);
            int rows = stm.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE Notifications SET IsRead = 1 WHERE UserID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, userId);
            int rows = stm.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
