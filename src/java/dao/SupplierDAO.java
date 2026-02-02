/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.*;
import java.util.*;
import model.Supplier;
import utils.DBContext;

/**
 *
 * @author dotha
 */
public class SupplierDAO extends DBContext{
    
    public List<Supplier> getAllSupllier(){
        List<Supplier> list = new ArrayList();
        String sql = "select * from [Suppliers]";
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
    
    public List<Supplier> searchUsers(String supplierName, String supplierPhone, String supplierAddress, String supplierEmail) {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT * FROM [Supplier]";

        if (supplierName != null && !supplierName.trim().isEmpty()) {
            sql += " AND Name LIKE ?";
        }
        if (supplierPhone != null && !supplierPhone.trim().isEmpty()) {
            sql += " AND Phone LIKE ?";
        }
        if (supplierAddress != null && !supplierAddress.trim().isEmpty()) {
            sql += " AND Address LIKE ?";
        }
        if (supplierEmail != null && !supplierEmail.equals("All")) {
            sql += " AND Email LIKE ?";
        }

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            int index = 1;
            if (supplierName != null && !supplierName.trim().isEmpty()) {
                stm.setString(index++, "%" + supplierName + "%");
                stm.setString(index++, "%" + supplierName + "%");
            }
            if (supplierPhone != null && !supplierPhone.trim().isEmpty()) {
                stm.setString(index++, "%" + supplierPhone + "%");
            }
            if (supplierAddress != null && !supplierAddress.trim().isEmpty()) {
                stm.setString(index++, "%" + supplierAddress + "%");
            }
            if (supplierEmail != null && !supplierEmail.equals("All")) {
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
