package dao;

import utils.DBContext;

import java.sql.*;

public class CustomerDAO extends DBContext {

    // Lấy CustomerID của khách lẻ (Phone = 0000000000)
    public int getWalkInCustomerId() {
        String sql = "SELECT CustomerID FROM dbo.Customers WHERE Phone = '0000000000'";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt("CustomerID");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1; // không có khách lẻ
    }

    // Lấy hoặc tạo khách theo SĐT / tên
    public int getOrCreateCustomerId(String name, String phone) throws SQLException {
        if (name == null) name = "";
        if (phone == null) phone = "";
        name = name.trim();
        phone = phone.trim();

        // Không nhập gì -> khách lẻ
        if (name.isEmpty() && phone.isEmpty()) {
            return getWalkInCustomerId();
        }

        // 1) Nếu có phone -> tìm theo phone
        if (!phone.isEmpty()) {
            String findSql = "SELECT CustomerID, Name FROM dbo.Customers WHERE Phone = ?";
            try (PreparedStatement ps = connection.prepareStatement(findSql)) {
                ps.setString(1, phone);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int id = rs.getInt("CustomerID");

                        // (tuỳ chọn) cập nhật tên nếu người dùng nhập tên
                        if (!name.isEmpty()) {
                            String upSql = "UPDATE dbo.Customers SET Name = ? WHERE CustomerID = ?";
                            try (PreparedStatement ups = connection.prepareStatement(upSql)) {
                                ups.setString(1, name);
                                ups.setInt(2, id);
                                ups.executeUpdate();
                            }
                        }
                        return id;
                    }
                }
            }
        }

        // 2) Chưa có -> insert mới + lấy ID (SQL Server)
        String insSql =
                "INSERT INTO dbo.Customers (Name, Phone) " +
                "OUTPUT INSERTED.CustomerID " +
                "VALUES (?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(insSql)) {
            ps.setString(1, name.isEmpty() ? "Khách" : name);
            ps.setString(2, phone.isEmpty() ? null : phone);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }

        // fallback
        return getWalkInCustomerId();
    }
}