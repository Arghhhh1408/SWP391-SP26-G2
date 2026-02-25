/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.*;
import java.util.*;
import model.Supplier;
import utils.DBContext;
import utils.SecurityUtils;

/**
 *
 * @author dotha
 */
public class SupplierDAO extends DBContext {
    
    public String checkDuplicate(String suppliername, String email, String phone) {
        try {
            String sql = "SELECT * FROM [Suppliers] WHERE Name = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, suppliername);
            if (stm.executeQuery().next()) {
                return "Supplier already exists";
            }

            sql = "SELECT * FROM [Supplier] WHERE Email = ?";
            stm = connection.prepareStatement(sql);
            stm.setString(1, email);
            if (stm.executeQuery().next()) {
                return "Email already exists";
            }

            sql = "SELECT * FROM [Supplier] WHERE Phone = ?";
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
    
    public Supplier getSupplierById(int id) {
        Supplier s = null;
        String sql = "SELECT * FROM Suppliers WHERE SupplierID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                s = new Supplier();
                s.setId(rs.getInt("SupplierID"));
                s.setSupplierName(rs.getString("Name"));
                s.setPhone(rs.getString("Phone"));
                s.setAddress(rs.getString("Address"));
                s.setEmail(rs.getString("Email"));
                s.setStatus(rs.getBoolean("IsActive"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return s;
    }
    
    public void deleteSupplier(int id) {
        String sql = "DELETE FROM Suppliers WHERE SupplierID = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateSupplier(int id, String name, String phone, String email, String address, boolean isActive) {
        String sql = """
            UPDATE [Suppliers]
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
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void addSupplier(String supplierName, String supplierPhone, String supplierAddress, String supplierEmail) {
        String sql = "INSERT INTO [Suppliers] (Name, Phone, Address, Email) VALUES (?, ?, ?, ?)";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, supplierName);
            stm.setString(2, supplierPhone);
            stm.setString(3, supplierAddress);
            stm.setString(4, supplierEmail);
            stm.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Supplier> getAllSupllier() {
        List<Supplier> list = new ArrayList();
        String sql = "SELECT * FROM [Suppliers] ORDER BY SupplierID ASC";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
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
            return list;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Supplier> searchSupplier(String supplierName, String supplierPhone, String supplierAddress, String supplierEmail) {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT * FROM [Suppliers] WHERE IsActive = 1";

        if (supplierName != null && !supplierName.trim().isEmpty()) {
            sql += " AND Name LIKE ?";
        }
        if (supplierPhone != null && !supplierPhone.trim().isEmpty()) {
            sql += " AND Phone LIKE ?";
        }
        if (supplierAddress != null && !supplierAddress.trim().isEmpty()) {
            sql += " AND Address LIKE ?";
        }
        if (supplierEmail != null && !supplierEmail.trim().isEmpty()) {
            sql += " AND Email LIKE ?";
        }

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            int index = 1;
            if (supplierName != null && !supplierName.trim().isEmpty()) {
                stm.setString(index++, "%" + supplierName + "%");
            }
            if (supplierPhone != null && !supplierPhone.trim().isEmpty()) {
                stm.setString(index++, "%" + supplierPhone + "%");
            }
            if (supplierAddress != null && !supplierAddress.trim().isEmpty()) {
                stm.setString(index++, "%" + supplierAddress + "%");
            }
            if (supplierEmail != null && !supplierEmail.trim().isEmpty()) {
                stm.setString(index++, supplierEmail);
            }

            ResultSet rs = stm.executeQuery();
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
            return list;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new ArrayList<>();
    }

}
