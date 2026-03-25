package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import utils.DBContext;

public class ContactIdentityDAO extends DBContext {

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String buildUserLabel(ResultSet rs) throws Exception {
        String fullName = rs.getString("FullName");
        String username = rs.getString("Username");
        int userId = rs.getInt("UserID");

        if (fullName != null && !fullName.trim().isEmpty()) {
            return fullName + " (User ID: " + userId + ")";
        }
        if (username != null && !username.trim().isEmpty()) {
            return username + " (User ID: " + userId + ")";
        }
        return "User ID: " + userId;
    }

    private String buildSupplierLabel(ResultSet rs) throws Exception {
        String name = rs.getString("Name");
        int supplierId = rs.getInt("SupplierID");
        if (name != null && !name.trim().isEmpty()) {
            return name + " (Supplier ID: " + supplierId + ")";
        }
        return "Supplier ID: " + supplierId;
    }

    private String findActiveUserPhoneConflict(String phone) {
        String normalizedPhone = normalize(phone);
        if (normalizedPhone == null) {
            return null;
        }

        String sql = "SELECT TOP 1 UserID, Username, FullName FROM [User] "
                + "WHERE IsActive = 1 AND LTRIM(RTRIM(Phone)) = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, normalizedPhone);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "Số điện thoại đã được sử dụng.";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private String findActiveUserEmailConflict(String email) {
        String normalizedEmail = normalize(email);
        if (normalizedEmail == null) {
            return null;
        }

        String sql = "SELECT TOP 1 UserID, Username, FullName FROM [User] "
                + "WHERE IsActive = 1 AND LOWER(LTRIM(RTRIM(Email))) = LOWER(?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, normalizedEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "Email đã được sử dụng";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private String findActiveSupplierPhoneConflict(String phone) {
        String normalizedPhone = normalize(phone);
        if (normalizedPhone == null) {
            return null;
        }

        String sql = "SELECT TOP 1 SupplierID, Name FROM Suppliers "
                + "WHERE IsActive = 1 AND LTRIM(RTRIM(Phone)) = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, normalizedPhone);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "Số điện thoại đã được sử dụng.";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private String findActiveSupplierEmailConflict(String email) {
        String normalizedEmail = normalize(email);
        if (normalizedEmail == null) {
            return null;
        }

        String sql = "SELECT TOP 1 SupplierID, Name FROM Suppliers "
                + "WHERE IsActive = 1 AND LOWER(LTRIM(RTRIM(Email))) = LOWER(?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, normalizedEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "Email đã được sử dụng.";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public String validateSupplierAgainstActiveUsers(String email, String phone) {
        try {
            String phoneConflict = findActiveUserPhoneConflict(phone);
            if (phoneConflict != null) {
                return phoneConflict;
            }
            return findActiveUserEmailConflict(email);
        } finally {
            closeConnection();
        }
    }

    public String validateUserAgainstActiveSuppliers(String email, String phone) {
        try {
            String phoneConflict = findActiveSupplierPhoneConflict(phone);
            if (phoneConflict != null) {
                return phoneConflict;
            }
            return findActiveSupplierEmailConflict(email);
        } finally {
            closeConnection();
        }
    }

    public String validateUserActivationAgainstActiveSuppliers(int userId) {
        String sql = "SELECT Email, Phone FROM [User] WHERE UserID = ?";
        try {
            String email = null;
            String phone = null;

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        email = rs.getString("Email");
                        phone = rs.getString("Phone");
                    } else {
                        return "Không tìm thấy tài khoản để khôi phục.";
                    }
                }
            }

            String phoneConflict = findActiveSupplierPhoneConflict(phone);
            if (phoneConflict != null) {
                return phoneConflict;
            }
            return findActiveSupplierEmailConflict(email);
        } catch (Exception e) {
            e.printStackTrace();
            return "Không thể kiểm tra xung đột dữ liệu với nhà cung cấp.";
        } finally {
            closeConnection();
        }
    }
}
