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

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    public String getSupplierNameById(int supplierId) {
        String sql = "SELECT Name FROM Suppliers WHERE SupplierID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("Name");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

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
        return checkDuplicate(supplierName, email, phone, true);
    }

    public String checkDuplicate(String supplierName, String email, String phone, boolean targetActive) {
        String sqlName = "SELECT 1 FROM Suppliers WHERE Name = ?";
        String sqlEmail = "SELECT 1 FROM Suppliers WHERE LOWER(LTRIM(RTRIM(Email))) = LOWER(?)";
        String sqlPhone = "SELECT 1 FROM Suppliers WHERE LTRIM(RTRIM(Phone)) = ?";

        String normalizedName = normalize(supplierName);
        String normalizedEmail = normalize(email);
        String normalizedPhone = normalize(phone);

        try (
                PreparedStatement psName = connection.prepareStatement(sqlName);
                PreparedStatement psEmail = connection.prepareStatement(sqlEmail);
                PreparedStatement psPhone = connection.prepareStatement(sqlPhone)) {

            psName.setString(1, normalizedName);
            if (psName.executeQuery().next()) {
                return "Tên nhà cung cấp đã tồn tại!";
            }

            if (normalizedEmail != null) {
                psEmail.setString(1, normalizedEmail);
                if (psEmail.executeQuery().next()) {
                    return "Email nhà cung cấp đã tồn tại!";
                }
            }

            if (normalizedPhone != null) {
                psPhone.setString(1, normalizedPhone);
                if (psPhone.executeQuery().next()) {
                    return "Số điện thoại nhà cung cấp đã tồn tại!";
                }
            }

            if (targetActive) {
                ContactIdentityDAO identityDAO = new ContactIdentityDAO();
                String crossConflict = identityDAO.validateSupplierAgainstActiveUsers(normalizedEmail, normalizedPhone);
                if (crossConflict != null) {
                    return crossConflict;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return "Lỗi kiểm tra trùng dữ liệu: " + e.getMessage();
        }
        return null;
    }

    public String checkDuplicateForUpdate(int id, String supplierName, String email, String phone) {
        return checkDuplicateForUpdate(id, supplierName, email, phone, true);
    }

    public String checkDuplicateForUpdate(int id, String supplierName, String email, String phone, boolean targetActive) {
        String sqlName = "SELECT 1 FROM Suppliers WHERE Name = ? AND SupplierID <> ?";
        String sqlEmail = "SELECT 1 FROM Suppliers WHERE LOWER(LTRIM(RTRIM(Email))) = LOWER(?) AND SupplierID <> ?";
        String sqlPhone = "SELECT 1 FROM Suppliers WHERE LTRIM(RTRIM(Phone)) = ? AND SupplierID <> ?";

        String normalizedName = normalize(supplierName);
        String normalizedEmail = normalize(email);
        String normalizedPhone = normalize(phone);

        try (
                PreparedStatement psName = connection.prepareStatement(sqlName);
                PreparedStatement psEmail = connection.prepareStatement(sqlEmail);
                PreparedStatement psPhone = connection.prepareStatement(sqlPhone)) {

            psName.setString(1, normalizedName);
            psName.setInt(2, id);
            if (psName.executeQuery().next()) {
                return "Tên nhà cung cấp đã tồn tại!";
            }

            if (normalizedEmail != null) {
                psEmail.setString(1, normalizedEmail);
                psEmail.setInt(2, id);
                if (psEmail.executeQuery().next()) {
                    return "Email nhà cung cấp đã tồn tại!";
                }
            }

            if (normalizedPhone != null) {
                psPhone.setString(1, normalizedPhone);
                psPhone.setInt(2, id);
                if (psPhone.executeQuery().next()) {
                    return "Số điện thoại nhà cung cấp đã tồn tại!";
                }
            }

            if (targetActive) {
                ContactIdentityDAO identityDAO = new ContactIdentityDAO();
                String crossConflict = identityDAO.validateSupplierAgainstActiveUsers(normalizedEmail, normalizedPhone);
                if (crossConflict != null) {
                    return crossConflict;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return "Lỗi kiểm tra trùng dữ liệu: " + e.getMessage();
        }
        return null;
    }

    public List<Supplier> getAllActiveSuppliers() {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT SupplierID, Name, Phone, Address, Email, IsActive "
                + "FROM Suppliers WHERE IsActive = 1 ORDER BY Name";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Supplier s = new Supplier();
                s.setId(rs.getInt("SupplierID"));
                s.setSupplierName(rs.getString("Name"));
                s.setPhone(rs.getString("Phone"));
                s.setAddress(rs.getString("Address"));
                s.setEmail(rs.getString("Email"));
                s.setStatus(rs.getBoolean("IsActive"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Supplier getSupplierById(int supplierId) {
        String sql = "SELECT SupplierID, Name, Phone, Address, Email, IsActive "
                + "FROM Suppliers WHERE SupplierID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Supplier s = new Supplier();
                    s.setId(rs.getInt("SupplierID"));
                    s.setSupplierName(rs.getString("Name"));
                    s.setPhone(rs.getString("Phone"));
                    s.setAddress(rs.getString("Address"));
                    s.setEmail(rs.getString("Email"));
                    s.setStatus(rs.getBoolean("IsActive"));
                    return s;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isActiveSupplier(int supplierId) {
        String sql = "SELECT 1 FROM Suppliers WHERE SupplierID = ? AND IsActive = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
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
        return addSupplier(supplierName, supplierPhone, supplierAddress, supplierEmail, true);
    }

    public boolean addSupplier(String supplierName, String supplierPhone, String supplierAddress, String supplierEmail, boolean isActive) {
        String sql = "INSERT INTO Suppliers (Name, Phone, Address, Email, IsActive) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, normalize(supplierName));
            ps.setString(2, normalize(supplierPhone));
            ps.setString(3, normalize(supplierAddress));
            ps.setString(4, normalize(supplierEmail));
            ps.setBoolean(5, isActive);
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
            ps.setString(1, normalize(name));
            ps.setString(2, normalize(phone));
            ps.setString(3, normalize(email));
            ps.setString(4, normalize(address));
            ps.setBoolean(5, isActive);
            ps.setInt(6, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Supplier> searchActiveSuppliersForLookup(String keyword, int page, int pageSize) {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT SupplierID, Name, Phone, Address, Email, IsActive "
                + "FROM Suppliers "
                + "WHERE IsActive = 1 AND Name LIKE ? "
                + "ORDER BY Name ASC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "%" + (keyword == null ? "" : keyword.trim()) + "%");
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToSupplier(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public String validateActivationConflict(int supplierId) {
        Supplier supplier = getSupplierById(supplierId);
        if (supplier == null) {
            return "Không tìm thấy nhà cung cấp để kích hoạt.";
        }
        ContactIdentityDAO identityDAO = new ContactIdentityDAO();
        return identityDAO.validateSupplierAgainstActiveUsers(supplier.getEmail(), supplier.getPhone());
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
        String conflict = validateActivationConflict(id);
        if (conflict != null) {
            return false;
        }
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
