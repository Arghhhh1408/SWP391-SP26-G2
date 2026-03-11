package dao;

import utils.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Customer;
import model.OrderHistory;

public class CustomerDAO extends DBContext {

    public List<model.Customer> getAllCustomers(String keyword) {
        List<model.Customer> list = new ArrayList<>();

        String sql = """
        SELECT CustomerID, Name, Phone, Address
        FROM dbo.Customers
        WHERE (? = '' OR Name LIKE ? OR Phone LIKE ?)
        ORDER BY CustomerID DESC
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (keyword == null) {
                keyword = "";
            }
            keyword = keyword.trim();

            ps.setString(1, keyword);
            ps.setString(2, "%" + keyword + "%");
            ps.setString(3, "%" + keyword + "%");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.Customer c = new model.Customer();
                    c.setCustomerId(rs.getInt("CustomerID"));
                    c.setName(rs.getString("Name"));
                    c.setPhone(rs.getString("Phone"));
                    c.setAddress(rs.getString("Address"));
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public model.Customer getCustomerById(int customerId) {
        String sql = """
        SELECT CustomerID, Name, Phone, Address
        FROM dbo.Customers
        WHERE CustomerID = ?
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    model.Customer c = new model.Customer();
                    c.setCustomerId(rs.getInt("CustomerID"));
                    c.setName(rs.getString("Name"));
                    c.setPhone(rs.getString("Phone"));
                    c.setAddress(rs.getString("Address"));
                    return c;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // Lấy CustomerID của khách lẻ (Phone = 0000000000)
    public int getWalkInCustomerId() {
        String sql = "SELECT CustomerID FROM dbo.Customers WHERE Phone = '0000000000'";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("CustomerID");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1; // không có khách lẻ
    }

    // Lấy hoặc tạo khách theo SĐT / tên
    public int getOrCreateCustomerId(String name, String phone) throws SQLException {
        if (name == null) {
            name = "";
        }
        if (phone == null) {
            phone = "";
        }
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
        String insSql
                = "INSERT INTO dbo.Customers (Name, Phone) "
                + "OUTPUT INSERTED.CustomerID "
                + "VALUES (?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(insSql)) {
            ps.setString(1, name.isEmpty() ? "Khách" : name);
            ps.setString(2, phone.isEmpty() ? null : phone);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        // fallback
        return getWalkInCustomerId();
    }

    public List<OrderHistory> getPurchaseHistoryByCustomer(int customerId) {

        List<OrderHistory> list = new ArrayList<>();

        String sql = """
        SELECT so.StockOutID,
               so.Date,
               so.TotalAmount,
               so.Note,
               c.Name as CustomerName,
               c.Phone as CustomerPhone,
               u.Username as CreatedByName
        FROM StockOut so
        LEFT JOIN Customers c ON c.CustomerID = so.CustomerID
        LEFT JOIN [User] u ON u.UserID = so.CreatedBy
        WHERE so.CustomerID = ?
        ORDER BY so.Date DESC
    """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, customerId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                OrderHistory o = new OrderHistory();

                o.setStockOutId(rs.getInt("StockOutID"));
                o.setDate(rs.getTimestamp("Date"));
                o.setTotalAmount(rs.getDouble("TotalAmount"));
                o.setNote(rs.getString("Note"));
                o.setCustomerName(rs.getString("CustomerName"));
                o.setCustomerPhone(rs.getString("CustomerPhone"));
                o.setCreatedByName(rs.getString("CreatedByName"));

                list.add(o);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    public Customer getCustomerByPhone(String phone) {

    String sql = """
        SELECT CustomerID, Name, Phone, Address, Email
        FROM Customers
        WHERE Phone = ?
    """;

    try (PreparedStatement ps = connection.prepareStatement(sql)) {

        ps.setString(1, phone);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {

            Customer c = new Customer();

            c.setCustomerId(rs.getInt("CustomerID"));
            c.setName(rs.getString("Name"));
            c.setPhone(rs.getString("Phone"));
            c.setAddress(rs.getString("Address"));
            c.setEmail(rs.getString("Email"));

            return c;
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return null;
}
}
