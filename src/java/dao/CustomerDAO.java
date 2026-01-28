package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Customer;
import utils.DBContext;

public class CustomerDAO extends DBContext {

    public List<Customer> getAllCustomers() throws Exception {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT * FROM Customers";
        PreparedStatement st = connection.prepareStatement(sql);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            Customer c = new Customer(
                    rs.getInt("CustomerID"),
                    rs.getString("Name"),
                    rs.getString("Phone"),
                    rs.getString("Address"),
                    rs.getString("Email")
            );
            list.add(c);
        }
        return list;
    }

    public Customer getCustomerById(int id) throws Exception {
        String sql = "SELECT * FROM Customers WHERE CustomerID = ?";
        PreparedStatement st = connection.prepareStatement(sql);
        st.setInt(1, id);
        ResultSet rs = st.executeQuery();
        if (rs.next()) {
            return new Customer(
                    rs.getInt("CustomerID"),
                    rs.getString("Name"),
                    rs.getString("Phone"),
                    rs.getString("Address"),
                    rs.getString("Email")
            );
        }
        return null;
    }

    public Customer getCustomerByPhone(String phone) throws Exception {
        String sql = "SELECT * FROM Customers WHERE Phone = ?";
        PreparedStatement st = connection.prepareStatement(sql);
        st.setString(1, phone);
        ResultSet rs = st.executeQuery();
        if (rs.next()) {
            return new Customer(
                    rs.getInt("CustomerID"),
                    rs.getString("Name"),
                    rs.getString("Phone"),
                    rs.getString("Address"),
                    rs.getString("Email")
            );
        }
        return null;
    }

    public boolean addCustomer(Customer c) {
        String sql = "INSERT INTO Customers (Name, Phone, Address, Email) VALUES (?, ?, ?, ?)";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, c.getName());
            st.setString(2, c.getPhone());
            st.setString(3, c.getAddress());
            st.setString(4, c.getEmail());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCustomer(Customer c) {
        String sql = "UPDATE Customers SET Name = ?, Phone = ?, Address = ?, Email = ? WHERE CustomerID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, c.getName());
            st.setString(2, c.getPhone());
            st.setString(3, c.getAddress());
            st.setString(4, c.getEmail());
            st.setInt(5, c.getCustomerID());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteCustomer(int id) {
        String sql = "DELETE FROM Customers WHERE CustomerID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Customer> searchCustomers(String keyword) throws Exception {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT * FROM Customers WHERE Name LIKE ? OR Phone LIKE ?";
        PreparedStatement st = connection.prepareStatement(sql);
        String searchPattern = "%" + keyword + "%";
        st.setString(1, searchPattern);
        st.setString(2, searchPattern);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            Customer c = new Customer(
                    rs.getInt("CustomerID"),
                    rs.getString("Name"),
                    rs.getString("Phone"),
                    rs.getString("Address"),
                    rs.getString("Email")
            );
            list.add(c);
        }
        return list;
    }
}
