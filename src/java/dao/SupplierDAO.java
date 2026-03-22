/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Supplier;
import utils.DBContext;

public class SupplierDAO extends DBContext {

    private Supplier mapResultSetToSupplier(ResultSet rs) throws SQLException {
        Supplier s = new Supplier();
        s.setId(rs.getInt("SupplierID"));
        s.setSupplierName(rs.getString("Name"));
        s.setPhone(rs.getString("Phone"));
        s.setAddress(rs.getString("Address"));
        s.setEmail(rs.getString("Email"));
        s.setStatus(rs.getBoolean("IsActive"));
        return s;
    }

    public String checkDuplicate(String supplierName, String email, String phone) {
        String sqlName = "SELECT 1 FROM Suppliers WHERE Name = ?";
        String sqlEmail = "SELECT 1 FROM Suppliers WHERE Email = ?";
        String sqlPhone = "SELECT 1 FROM Suppliers WHERE Phone = ?";

        try (
                PreparedStatement psName = connection.prepareStatement(sqlName); PreparedStatement psEmail = connection.prepareStatement(sqlEmail); PreparedStatement psPhone = connection.prepareStatement(sqlPhone)) {
            psName.setString(1, supplierName);
            if (psName.executeQuery().next()) {
                return "Tên nhà cung cấp đã tồn tại!";
            }

            if (email != null && !email.trim().isEmpty()) {
                psEmail.setString(1, email);
                if (psEmail.executeQuery().next()) {
                    return "Email đã tồn tại!";
                }
            }

            if (phone != null && !phone.trim().isEmpty()) {
                psPhone.setString(1, phone);
                if (psPhone.executeQuery().next()) {
                    return "Số điện thoại đã tồn tại!";
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return "Lỗi kiểm tra trùng dữ liệu: " + e.getMessage();
        }
        return null;
    }

    public String checkDuplicateForUpdate(int id, String supplierName, String email, String phone) {
        String sqlName = "SELECT 1 FROM Suppliers WHERE Name = ? AND SupplierID <> ?";
        String sqlEmail = "SELECT 1 FROM Suppliers WHERE Email = ? AND SupplierID <> ?";
        String sqlPhone = "SELECT 1 FROM Suppliers WHERE Phone = ? AND SupplierID <> ?";

        try (
                PreparedStatement psName = connection.prepareStatement(sqlName); PreparedStatement psEmail = connection.prepareStatement(sqlEmail); PreparedStatement psPhone = connection.prepareStatement(sqlPhone)) {
            psName.setString(1, supplierName);
            psName.setInt(2, id);
            if (psName.executeQuery().next()) {
                return "Tên nhà cung cấp đã tồn tại!";
            }

            if (email != null && !email.trim().isEmpty()) {
                psEmail.setString(1, email);
                psEmail.setInt(2, id);
                if (psEmail.executeQuery().next()) {
                    return "Email đã tồn tại!";
                }
            }

            if (phone != null && !phone.trim().isEmpty()) {
                psPhone.setString(1, phone);
                psPhone.setInt(2, id);
                if (psPhone.executeQuery().next()) {
                    return "Số điện thoại đã tồn tại!";
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return "Lỗi kiểm tra trùng dữ liệu: " + e.getMessage();
        }
        return null;
    }

    public Supplier getSupplierById(int id) {
        String sql = "SELECT SupplierID, Name, Phone, Address, Email, IsActive FROM Suppliers WHERE SupplierID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSupplier(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Supplier> getAllSupplier() {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT SupplierID, Name, Phone, Address, Email, IsActive FROM Suppliers ORDER BY SupplierID DESC";

        try (
                PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToSupplier(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Supplier> searchSupplier(String supplierName, String supplierPhone,
            String supplierAddress, String supplierEmail,
            String status) {
        List<Supplier> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT SupplierID, Name, Phone, Address, Email, IsActive
            FROM Suppliers
            WHERE 1 = 1
        """);

        if (supplierName != null && !supplierName.trim().isEmpty()) {
            sql.append(" AND Name LIKE ?");
        }
        if (supplierPhone != null && !supplierPhone.trim().isEmpty()) {
            sql.append(" AND Phone LIKE ?");
        }
        if (supplierAddress != null && !supplierAddress.trim().isEmpty()) {
            sql.append(" AND Address LIKE ?");
        }
        if (supplierEmail != null && !supplierEmail.trim().isEmpty()) {
            sql.append(" AND Email LIKE ?");
        }
        if ("active".equalsIgnoreCase(status)) {
            sql.append(" AND IsActive = 1");
        } else if ("inactive".equalsIgnoreCase(status)) {
            sql.append(" AND IsActive = 0");
        }

        sql.append(" ORDER BY SupplierID DESC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int index = 1;

            if (supplierName != null && !supplierName.trim().isEmpty()) {
                ps.setString(index++, "%" + supplierName.trim() + "%");
            }
            if (supplierPhone != null && !supplierPhone.trim().isEmpty()) {
                ps.setString(index++, "%" + supplierPhone.trim() + "%");
            }
            if (supplierAddress != null && !supplierAddress.trim().isEmpty()) {
                ps.setString(index++, "%" + supplierAddress.trim() + "%");
            }
            if (supplierEmail != null && !supplierEmail.trim().isEmpty()) {
                ps.setString(index++, "%" + supplierEmail.trim() + "%");
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSupplier(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean addSupplier(String supplierName, String supplierPhone, String supplierAddress, String supplierEmail) {
        String sql = "INSERT INTO Suppliers (Name, Phone, Address, Email, IsActive) VALUES (?, ?, ?, ?, 1)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, supplierName);
            ps.setString(2, supplierPhone);
            ps.setString(3, supplierAddress);
            ps.setString(4, supplierEmail);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateSupplier(int id, String name, String phone, String email, String address, boolean isActive) {
        String sql = """
            UPDATE Suppliers
            SET Name = ?, Phone = ?, Email = ?, Address = ?, IsActive = ?
            WHERE SupplierID = ?
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, phone);
            ps.setString(3, email);
            ps.setString(4, address);
            ps.setBoolean(5, isActive);
            ps.setInt(6, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa mềm theo DB mới
    public boolean deactivateSupplier(int id) {
        String sql = "UPDATE Suppliers SET IsActive = 0 WHERE SupplierID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean activateSupplier(int id) {
        String sql = "UPDATE Suppliers SET IsActive = 1 WHERE SupplierID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
