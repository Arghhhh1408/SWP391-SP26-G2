/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import utils.DBContext;
import utils.SecurityUtils;

/**
 *
 * @author minhtuan
 */
public class UserDAO extends DBContext {

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    public User login(String username, String password) {
        User u = getUserByUsername(username);
        if (u == null || !u.isIsActive()) {
            return null;
        }

        // Check if currently locked
        if (u.getLockoutEnd() != null && u.getLockoutEnd().after(new java.util.Date())) {
            return null; // Controller will handle the message by checking User object again
        }

        if (u.getPasswordHash().equals(SecurityUtils.hashPassword(password))) {
            // Success: Reset attempts
            resetFailedAttempts(username);
            return u;
        } else {
            // Failure: Increment attempts
            incrementFailedAttempts(username);
            return null;
        }
    }

    public User getUserByUsername(String username) {
        String sql = "SELECT * FROM [User] WHERE Username = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setUserID(rs.getInt("UserID"));
                u.setUsername(rs.getString("Username"));
                u.setPasswordHash(rs.getString("PasswordHash"));
                u.setFullName(rs.getString("FullName"));
                u.setRoleID(rs.getInt("RoleID"));
                u.setEmail(rs.getString("Email"));
                u.setPhone(rs.getString("Phone"));
                u.setCreateDate(rs.getDate("CreateDate"));
                u.setIsActive(rs.getBoolean("IsActive"));
                u.setFailedAttempts(rs.getInt("FailedAttempts"));
                u.setLockoutEnd(rs.getTimestamp("LockoutEnd"));
                return u;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void incrementFailedAttempts(String username) {
        String sql = "UPDATE [User] SET FailedAttempts = FailedAttempts + 1 WHERE Username = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            stm.executeUpdate();

            // Check if should lock
            User u = getUserByUsername(username);
            if (u != null && u.getFailedAttempts() == 5) {
                setLockout(username, 30);
                notifyAdminsOfLockout(username);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void notifyAdminsOfLockout(String username) {
        NotificationDAO nDAO = new NotificationDAO();
        List<Integer> adminIds = nDAO.getAdminIds();
        for (Integer adminId : adminIds) {
            model.Notification n = new model.Notification();
            n.setUserId(adminId);
            n.setTitle("⚠️ Cảnh báo bảo mật");
            n.setMessage("Tài khoản <strong>" + username + "</strong> đã bị khóa tự động sau 5 lần nhập sai mật khẩu.");
            n.setType("ACCOUNT_LOCKOUT");
            nDAO.insert(n);
        }
    }

    public void resetFailedAttempts(String username) {
        String sql = "UPDATE [User] SET FailedAttempts = 0, LockoutEnd = NULL WHERE Username = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            stm.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void setLockout(String username, int minutes) {
        String sql = "UPDATE [User] SET LockoutEnd = DATEADD(minute, ?, GETDATE()) WHERE Username = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, minutes);
            stm.setString(2, username);
            stm.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<User> getLockedUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM [User] WHERE IsActive = 1 AND LockoutEnd > GETDATE()";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserID(rs.getInt("UserID"));
                u.setUsername(rs.getString("Username"));
                u.setFullName(rs.getString("FullName"));
                u.setRoleID(rs.getInt("RoleID"));
                u.setIsActive(rs.getBoolean("IsActive"));
                u.setFailedAttempts(rs.getInt("FailedAttempts"));
                u.setLockoutEnd(rs.getTimestamp("LockoutEnd"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean unlockUser(int userId) {
        String sql = "UPDATE [User] SET IsActive = 1, FailedAttempts = 0, LockoutEnd = NULL WHERE UserID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, userId);
            return stm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "select * from [User] where IsActive = 1";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserID(rs.getInt("UserID"));
                u.setUsername(rs.getString("Username"));
                u.setFullName(rs.getString("FullName"));
                u.setRoleID(rs.getInt("RoleID"));
                u.setEmail(rs.getString("Email"));
                u.setPhone(rs.getString("Phone"));
                u.setCreateDate(rs.getDate("CreateDate"));
                u.setIsActive(rs.getBoolean("IsActive"));
                list.add(u);
            }
            return list;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addUser(User u) {
        String sql = "insert into [User] (Username, PasswordHash, FullName, RoleID, Email, Phone, IsActive) "
                + "VALUES (?, ?, ?, ?, ?, ?, 1)";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, normalize(u.getUsername()));
            stm.setString(2, SecurityUtils.hashPassword(u.getPasswordHash()));
            stm.setString(3, normalize(u.getFullName()));
            stm.setInt(4, u.getRoleID());
            stm.setString(5, normalize(u.getEmail()));
            stm.setString(6, normalize(u.getPhone()));
            int rows = stm.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<User> searchUsers(String name, String email, String phone, String roleName) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM [User] WHERE IsActive = 1";

        if (name != null && !name.trim().isEmpty()) {
            sql += " AND (Username LIKE ? OR FullName LIKE ?)";
        }
        if (email != null && !email.trim().isEmpty()) {
            sql += " AND Email LIKE ?";
        }
        if (phone != null && !phone.trim().isEmpty()) {
            sql += " AND Phone LIKE ?";
        }
        if (roleName != null && !roleName.equals("All")) {
            sql += " AND RoleID IN (SELECT RoleID FROM Role WHERE RoleName = ?)";
        }

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            int index = 1;
            if (name != null && !name.trim().isEmpty()) {
                stm.setString(index++, "%" + name + "%");
                stm.setString(index++, "%" + name + "%");
            }
            if (email != null && !email.trim().isEmpty()) {
                stm.setString(index++, "%" + email + "%");
            }
            if (phone != null && !phone.trim().isEmpty()) {
                stm.setString(index++, "%" + phone + "%");
            }
            if (roleName != null && !roleName.equals("All")) {
                stm.setString(index++, roleName);
            }

            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserID(rs.getInt("UserID"));
                u.setUsername(rs.getString("Username"));
                u.setFullName(rs.getString("FullName"));
                u.setRoleID(rs.getInt("RoleID"));
                u.setEmail(rs.getString("Email"));
                u.setPhone(rs.getString("Phone"));
                u.setCreateDate(rs.getDate("CreateDate"));
                u.setIsActive(rs.getBoolean("IsActive"));
                list.add(u);
            }
            return list;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new ArrayList<>();
    }

    public boolean deleteUser(int userID) {
        String sql = "UPDATE [User] SET IsActive = 0 WHERE UserID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, userID);
            int rows = stm.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public String checkDuplicate(String username, String email, String phone) {
        try {
            String normalizedUsername = normalize(username);
            String normalizedEmail = normalize(email);
            String normalizedPhone = normalize(phone);

            String sql = "SELECT * FROM [User] WHERE Username = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, normalizedUsername);
            if (stm.executeQuery().next()) {
                return "Username đã tồn tại";
            }

            if (normalizedEmail != null) {
                sql = "SELECT * FROM [User] WHERE LOWER(LTRIM(RTRIM(Email))) = LOWER(?)";
                stm = connection.prepareStatement(sql);
                stm.setString(1, normalizedEmail);
                if (stm.executeQuery().next()) {
                    return "Email đã được sử dụng bởi một tài khoản khác";
                }
            }

            if (normalizedPhone != null) {
                sql = "SELECT * FROM [User] WHERE LTRIM(RTRIM(Phone)) = ?";
                stm = connection.prepareStatement(sql);
                stm.setString(1, normalizedPhone);
                if (stm.executeQuery().next()) {
                    return "Số điện thoại đã được sử dụng bởi một tài khoản khác";
                }
            }

            ContactIdentityDAO identityDAO = new ContactIdentityDAO();
            String supplierConflict = identityDAO.validateUserAgainstActiveSuppliers(normalizedEmail, normalizedPhone);
            if (supplierConflict != null) {
                return supplierConflict;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public String checkDuplicateForUpdate(int userID, String username, String email, String phone) {
        try {
            String normalizedUsername = normalize(username);
            String normalizedEmail = normalize(email);
            String normalizedPhone = normalize(phone);

            String sql = "SELECT * FROM [User] WHERE Username = ? AND UserID != ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, normalizedUsername);
            stm.setInt(2, userID);
            if (stm.executeQuery().next()) {
                return "Username đã tồn tại";
            }

            if (normalizedEmail != null) {
                sql = "SELECT * FROM [User] WHERE LOWER(LTRIM(RTRIM(Email))) = LOWER(?) AND UserID != ?";
                stm = connection.prepareStatement(sql);
                stm.setString(1, normalizedEmail);
                stm.setInt(2, userID);
                if (stm.executeQuery().next()) {
                    return "Email đã được sử dụng bởi một tài khoản khác";
                }
            }

            if (normalizedPhone != null) {
                sql = "SELECT * FROM [User] WHERE LTRIM(RTRIM(Phone)) = ? AND UserID != ?";
                stm = connection.prepareStatement(sql);
                stm.setString(1, normalizedPhone);
                stm.setInt(2, userID);
                if (stm.executeQuery().next()) {
                    return "Số điện thoại đã được sử dụng bởi một tài khoản khác";
                }
            }

            ContactIdentityDAO identityDAO = new ContactIdentityDAO();
            String supplierConflict = identityDAO.validateUserAgainstActiveSuppliers(normalizedEmail, normalizedPhone);
            if (supplierConflict != null) {
                return supplierConflict;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<User> getDeletedUsers() {
        return getDeletedUsers(null, null, null, -1);
    }

    public List<User> getDeletedUsers(String name, String email, String phone, Integer roleID) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM [User] WHERE IsActive = 0";

        if (name != null && !name.trim().isEmpty()) {
            sql += " AND (Username LIKE ? OR FullName LIKE ?)";
        }
        if (email != null && !email.trim().isEmpty()) {
            sql += " AND Email LIKE ?";
        }
        if (phone != null && !phone.trim().isEmpty()) {
            sql += " AND Phone LIKE ?";
        }
        if (roleID != null && roleID != -1) {
            sql += " AND RoleID = ?";
        }

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            int index = 1;
            if (name != null && !name.trim().isEmpty()) {
                stm.setString(index++, "%" + name + "%");
                stm.setString(index++, "%" + name + "%");
            }
            if (email != null && !email.trim().isEmpty()) {
                stm.setString(index++, "%" + email + "%");
            }
            if (phone != null && !phone.trim().isEmpty()) {
                stm.setString(index++, "%" + phone + "%");
            }
            if (roleID != null && roleID != -1) {
                stm.setInt(index++, roleID);
            }

            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserID(rs.getInt("UserID"));
                u.setUsername(rs.getString("Username"));
                u.setFullName(rs.getString("FullName"));
                u.setRoleID(rs.getInt("RoleID"));
                u.setEmail(rs.getString("Email"));
                u.setPhone(rs.getString("Phone"));
                u.setCreateDate(rs.getDate("CreateDate"));
                u.setIsActive(rs.getBoolean("IsActive"));
                list.add(u);
            }
            return list;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new ArrayList<>();
    }

    public String validateRestoreConflict(int userID) {
        ContactIdentityDAO identityDAO = new ContactIdentityDAO();
        return identityDAO.validateUserActivationAgainstActiveSuppliers(userID);
    }

    public boolean restoreUser(int userID) {
        String sql = "UPDATE [User] SET IsActive = 1, FailedAttempts = 0, LockoutEnd = NULL WHERE UserID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, userID);
            int rows = stm.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public User searchUserByID(int id) {
        String sql = "select * from [User] where UserID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                User user = new User(rs.getString("Username"),
                        rs.getString("PasswordHash"),
                        rs.getString("FullName"),
                        rs.getInt("RoleID"),
                        rs.getString("Email"),
                        rs.getString("Phone"),
                        rs.getBoolean("IsActive"));
                user.setUserID(rs.getInt("UserID"));
                user.setCreateDate(rs.getDate("CreateDate"));
                return user;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateUser(User user) {
        String sql = "UPDATE [User] SET Username = ?, FullName = ?, RoleID = ?, Email = ?, Phone = ? WHERE UserID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, normalize(user.getUsername()));
            stm.setString(2, normalize(user.getFullName()));
            stm.setInt(3, user.getRoleID());
            stm.setString(4, normalize(user.getEmail()));
            stm.setString(5, normalize(user.getPhone()));
            stm.setInt(6, user.getUserID());
            int rows = stm.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean resetPassword(int userID, String passwordHash) {
        String sql = "UPDATE [User] SET PasswordHash = ? WHERE UserID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, passwordHash);
            stm.setInt(2, userID);
            int rows = stm.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public String getNameByID(int id) {
        String sql = "select FullName from [User] where UserID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                return rs.getString("FullName");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public java.util.List<String> getActiveManagerEmails() {
        java.util.List<String> list = new java.util.ArrayList<>();
        String sql = "SELECT Email FROM [User] WHERE IsActive = 1 AND RoleID = 2 AND Email IS NOT NULL AND LTRIM(RTRIM(Email)) <> ''";
        try (PreparedStatement stm = connection.prepareStatement(sql); ResultSet rs = stm.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("Email"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public java.util.List<Integer> getActiveManagerIds() {
        java.util.List<Integer> list = new java.util.ArrayList<>();
        String sql = "SELECT UserID FROM [User] WHERE IsActive = 1 AND RoleID = 2";
        try (PreparedStatement stm = connection.prepareStatement(sql); ResultSet rs = stm.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getInt("UserID"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
