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
    public User login(String username, String password) {
        String sql = "select * from [User] where Username = ? and PasswordHash = ? and IsActive = 1";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);

            stm.setString(2, SecurityUtils.hashPassword(password));

            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setUserID(rs.getInt("UserID"));
                u.setUsername(rs.getString("Username"));
                u.setFullName(rs.getString("FullName"));
                u.setRoleID(rs.getInt("RoleID")); // Chú ý: Admin có thể là 0 hoặc 1 tùy DB của bạn
                u.setEmail(rs.getString("Email"));
                u.setPhone(rs.getString("Phone"));
                u.setCreateDate(rs.getDate("CreateDate"));
                return u;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<User> getAllUsers() {
        List<User> list = new ArrayList();
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
            stm.setString(1, u.getUsername());
            stm.setString(2, SecurityUtils.hashPassword(u.getPasswordHash()));
            stm.setString(3, u.getFullName());
            stm.setInt(4, u.getRoleID());
            stm.setString(5, u.getEmail());
            stm.setString(6, u.getPhone());
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
            String sql = "SELECT * FROM [User] WHERE Username = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            if (stm.executeQuery().next()) {
                return "Username already exists";
            }

            sql = "SELECT * FROM [User] WHERE Email = ?";
            stm = connection.prepareStatement(sql);
            stm.setString(1, email);
            if (stm.executeQuery().next()) {
                return "Email already exists";
            }

            sql = "SELECT * FROM [User] WHERE Phone = ?";
            stm = connection.prepareStatement(sql);
            stm.setString(1, phone);
            if (stm.executeQuery().next()) {
                return "Phone number already exists";
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // No duplicate
    }

    public String checkDuplicateForUpdate(int userID, String username, String email, String phone) {
        try {
            String sql = "SELECT * FROM [User] WHERE Username = ? AND UserID != ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            stm.setInt(2, userID);
            if (stm.executeQuery().next()) {
                return "Username already exists";
            }

            sql = "SELECT * FROM [User] WHERE Email = ? AND UserID != ?";
            stm = connection.prepareStatement(sql);
            stm.setString(1, email);
            stm.setInt(2, userID);
            if (stm.executeQuery().next()) {
                return "Email already exists";
            }

            sql = "SELECT * FROM [User] WHERE Phone = ? AND UserID != ?";
            stm = connection.prepareStatement(sql);
            stm.setString(1, phone);
            stm.setInt(2, userID);
            if (stm.executeQuery().next()) {
                return "Phone number already exists";
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null; // No duplicate
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
                list.add(u);
            }
            return list;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new ArrayList<>();
    }

    public boolean restoreUser(int userID) {
        String sql = "UPDATE [User] SET IsActive = 1 WHERE UserID = ?";
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
                return user;
            }
        } catch (Exception e) {
        }
        return null;
    }

    public boolean updateUser(User user) {
        String sql = "UPDATE [User] SET Username = ?, FullName = ?, RoleID = ?, Email = ?, Phone = ? WHERE UserID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, user.getUsername());
            stm.setString(2, user.getFullName());
            stm.setInt(3, user.getRoleID());
            stm.setString(4, user.getEmail());
            stm.setString(5, user.getPhone());
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
        }
        return null;
    }
}
