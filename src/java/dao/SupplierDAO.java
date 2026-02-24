package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Supplier;
import utils.DBContext;

public class SupplierDAO extends DBContext {

    public List<Supplier> getAllSuppliers() throws Exception {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT * FROM Suppliers WHERE IsActive = 1";
        PreparedStatement st = connection.prepareStatement(sql);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            Supplier s = new Supplier(
                    rs.getInt("SupplierID"),
                    rs.getString("Name"),
                    rs.getString("Phone"),
                    rs.getString("Address"),
                    rs.getString("Email"),
                    rs.getBoolean("IsActive")
            );
            list.add(s);
        }
        return list;
    }

    public Supplier getSupplierById(int id) throws Exception {
        String sql = "SELECT * FROM Suppliers WHERE SupplierID = ?";
        PreparedStatement st = connection.prepareStatement(sql);
        st.setInt(1, id);
        ResultSet rs = st.executeQuery();
        if (rs.next()) {
            return new Supplier(
                    rs.getInt("SupplierID"),
                    rs.getString("Name"),
                    rs.getString("Phone"),
                    rs.getString("Address"),
                    rs.getString("Email"),
                    rs.getBoolean("IsActive")
            );
        }
        return null;
    }

    public boolean addSupplier(Supplier s) {
        String sql = "INSERT INTO Suppliers (Name, Phone, Address, Email, IsActive) VALUES (?, ?, ?, ?, 1)";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, s.getName());
            st.setString(2, s.getPhone());
            st.setString(3, s.getAddress());
            st.setString(4, s.getEmail());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateSupplier(Supplier s) {
        String sql = "UPDATE Suppliers SET Name = ?, Phone = ?, Address = ?, Email = ? WHERE SupplierID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, s.getName());
            st.setString(2, s.getPhone());
            st.setString(3, s.getAddress());
            st.setString(4, s.getEmail());
            st.setInt(5, s.getSupplierID());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteSupplier(int id) {
        String sql = "UPDATE Suppliers SET IsActive = 0 WHERE SupplierID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Supplier> searchSuppliers(String keyword) throws Exception {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT * FROM Suppliers WHERE IsActive = 1 AND (Name LIKE ? OR Phone LIKE ?)";
        PreparedStatement st = connection.prepareStatement(sql);
        String searchPattern = "%" + keyword + "%";
        st.setString(1, searchPattern);
        st.setString(2, searchPattern);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            Supplier s = new Supplier(
                    rs.getInt("SupplierID"),
                    rs.getString("Name"),
                    rs.getString("Phone"),
                    rs.getString("Address"),
                    rs.getString("Email"),
                    rs.getBoolean("IsActive")
            );
            list.add(s);
        }
        return list;
    }
}
