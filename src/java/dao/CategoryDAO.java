package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Category;
import model.Product;
import utils.DBContext;

public class CategoryDAO extends DBContext {

    public List<Category> getAllCategories() throws Exception {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM Categories";
        PreparedStatement st = connection.prepareStatement(sql);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            // Trying "CategoryID" and "CategoryName" based on naming convention
            // If "CategoryName" fails, might be "Name"
            int id = rs.getInt("CategoryID");
            String name = rs.getString("CategoryName");
            list.add(new Category(id, name));
        }
        return list;
    }

    public List<Product> getAllProducts() throws Exception {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Products";
        PreparedStatement st = connection.prepareStatement(sql);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            Product p = new Product(rs.getInt("ProductID"),
                    rs.getString("Name"),
                    rs.getString("SKU"),
                    rs.getDouble("Cost"),
                    rs.getDouble("Price"),
                    rs.getInt("StockQuantity"),
                    rs.getString("Unit"),
                    rs.getString("Description"),
                    rs.getString("ImageURL"),
                    rs.getString("Status") != null ? rs.getString("Status").trim() : null,
                    rs.getInt("CategoryID"),
                    rs.getTimestamp("CreatedDate"),
                    rs.getTimestamp("UpdatedDate"));
            try {
                p.setWarrantyPeriod(rs.getInt("WarrantyPeriod"));
            } catch (Exception ignored) {
            }
            list.add(p);
        }
        return list;
    }

    public List<Product> getProductsByCategoryId(int categoryId) throws Exception {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Products WHERE CategoryID = ?";
        PreparedStatement st = connection.prepareStatement(sql);
        st.setInt(1, categoryId);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            Product p = new Product(rs.getInt("ProductID"),
                    rs.getString("Name"),
                    rs.getString("SKU"),
                    rs.getDouble("Cost"),
                    rs.getDouble("Price"),
                    rs.getInt("StockQuantity"),
                    rs.getString("Unit"),
                    rs.getString("Description"),
                    rs.getString("ImageURL"),
                    rs.getString("Status") != null ? rs.getString("Status").trim() : null,
                    rs.getInt("CategoryID"),
                    rs.getTimestamp("CreatedDate"),
                    rs.getTimestamp("UpdatedDate"));
            try {
                p.setWarrantyPeriod(rs.getInt("WarrantyPeriod"));
            } catch (Exception ignored) {
            }
            list.add(p);
        }
        return list;
    }

    public boolean addCategory(Category c) {
        String sql = "INSERT INTO Categories (CategoryName) VALUES (?)";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, c.getName());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCategory(Category c) {
        String sql = "UPDATE Categories SET CategoryName = ? WHERE CategoryID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, c.getName());
            st.setInt(2, c.getId());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteCategory(int id) {
        String sql = "DELETE FROM Categories WHERE CategoryID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Category getCategoryById(int id) {
        String sql = "SELECT * FROM Categories WHERE CategoryID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, id);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return new Category(rs.getInt("CategoryID"), rs.getString("CategoryName"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addProduct(Product p) {
        String sql = "INSERT INTO Products (Name, SKU, Cost, Price, StockQuantity, Unit, Description, ImageURL, WarrantyPeriod, Status, CategoryID, CreatedDate, UpdatedDate) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, p.getName());
            st.setString(2, p.getSku());
            st.setDouble(3, p.getCost());
            st.setDouble(4, p.getPrice());
            st.setInt(5, p.getQuantity());
            st.setString(6, p.getUnit());
            st.setString(7, p.getDescription());
            st.setString(8, p.getImageURL());
            st.setInt(9, p.getWarrantyPeriod());
            st.setString(10, p.getStatus());
            st.setInt(11, p.getCategoryId());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateProduct(Product p) throws Exception {
        String sql = "UPDATE Products SET Name=?, SKU=?, Cost=?, Price=?, StockQuantity=?, Unit=?, Description=?, ImageURL=?, WarrantyPeriod=?, Status=?, CategoryID=?, UpdatedDate=GETDATE() WHERE ProductID=?";
        PreparedStatement st = connection.prepareStatement(sql);
        st.setString(1, p.getName());
        st.setString(2, p.getSku());
        st.setDouble(3, p.getCost());
        st.setDouble(4, p.getPrice());
        st.setInt(5, p.getQuantity());
        st.setString(6, p.getUnit());
        st.setString(7, p.getDescription());
        st.setString(8, p.getImageURL());
        st.setInt(9, p.getWarrantyPeriod());
        st.setString(10, p.getStatus());
        st.setInt(11, p.getCategoryId());
        st.setInt(12, p.getId());
        return st.executeUpdate() > 0;
    }

    public boolean deleteProduct(int id) {
        String sql = "DELETE FROM Products WHERE ProductID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Product getProductById(int id) {
        String sql = "SELECT * FROM Products WHERE ProductID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, id);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                Product p = new Product(rs.getInt("ProductID"),
                        rs.getString("Name"),
                        rs.getString("SKU"),
                        rs.getDouble("Cost"),
                        rs.getDouble("Price"),
                        rs.getInt("StockQuantity"),
                        rs.getString("Unit"),
                        rs.getString("Description"),
                        rs.getString("ImageURL"),
                        rs.getString("Status") != null ? rs.getString("Status").trim() : null,
                        rs.getInt("CategoryID"),
                        rs.getTimestamp("CreatedDate"),
                        rs.getTimestamp("UpdatedDate"));
                try {
                    p.setWarrantyPeriod(rs.getInt("WarrantyPeriod"));
                } catch (Exception ignored) {
                }
                return p;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isCategoryExists(String name) {
        String sql = "SELECT CategoryID FROM Categories WHERE CategoryName = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, name);
            ResultSet rs = st.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isProductSkuExists(String sku) {
        String sql = "SELECT ProductID FROM Products WHERE SKU = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, sku);
            ResultSet rs = st.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isProductNameExists(String name) {
        String sql = "SELECT ProductID FROM Products WHERE Name = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, name);
            ResultSet rs = st.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Product> searchProducts(String keyword, Double minPrice, Double maxPrice, Integer categoryId)
            throws Exception {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Products WHERE 1=1");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (Name LIKE ? OR SKU LIKE ?)");
        }
        if (minPrice != null) {
            sql.append(" AND Price >= ?");
        }
        if (maxPrice != null) {
            sql.append(" AND Price <= ?");
        }
        if (categoryId != null) {
            sql.append(" AND CategoryID = ?");
        }

        PreparedStatement st = connection.prepareStatement(sql.toString());
        int paramIndex = 1;

        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchPattern = "%" + keyword.trim() + "%";
            st.setString(paramIndex++, searchPattern);
            st.setString(paramIndex++, searchPattern);
        }
        if (minPrice != null) {
            st.setDouble(paramIndex++, minPrice);
        }
        if (maxPrice != null) {
            st.setDouble(paramIndex++, maxPrice);
        }
        if (categoryId != null) {
            st.setInt(paramIndex++, categoryId);
        }

        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            list.add(new Product(rs.getInt("ProductID"),
                    rs.getString("Name"),
                    rs.getString("SKU"),
                    rs.getDouble("Cost"),
                    rs.getDouble("Price"),
                    rs.getInt("StockQuantity"),
                    rs.getString("Unit"),
                    rs.getString("Description"),
                    rs.getString("ImageURL"),
                    rs.getString("Status") != null ? rs.getString("Status").trim() : null,
                    rs.getInt("CategoryID"),
                    rs.getTimestamp("CreatedDate"),
                    rs.getTimestamp("UpdatedDate")));
        }
        return list;
    }

    public int countProducts(String keyword, Double minPrice, Double maxPrice, Integer categoryId) throws Exception {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Products WHERE 1=1");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (Name LIKE ? OR SKU LIKE ?)");
        }
        if (minPrice != null) {
            sql.append(" AND Price >= ?");
        }
        if (maxPrice != null) {
            sql.append(" AND Price <= ?");
        }
        if (categoryId != null) {
            sql.append(" AND CategoryID = ?");
        }

        PreparedStatement st = connection.prepareStatement(sql.toString());
        int paramIndex = 1;

        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchPattern = "%" + keyword.trim() + "%";
            st.setString(paramIndex++, searchPattern);
            st.setString(paramIndex++, searchPattern);
        }
        if (minPrice != null) {
            st.setDouble(paramIndex++, minPrice);
        }
        if (maxPrice != null) {
            st.setDouble(paramIndex++, maxPrice);
        }
        if (categoryId != null) {
            st.setInt(paramIndex++, categoryId);
        }

        ResultSet rs = st.executeQuery();
        if (rs.next()) {
            return rs.getInt(1);
        }
        return 0;
    }

    public List<Product> searchProductsPaginated(String keyword, Double minPrice, Double maxPrice, Integer categoryId,
            int page, int pageSize) throws Exception {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Products WHERE 1=1");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (Name LIKE ? OR SKU LIKE ?)");
        }
        if (minPrice != null) {
            sql.append(" AND Price >= ?");
        }
        if (maxPrice != null) {
            sql.append(" AND Price <= ?");
        }
        if (categoryId != null) {
            sql.append(" AND CategoryID = ?");
        }

        // Add pagination using SQL Server OFFSET/FETCH
        sql.append(" ORDER BY ProductID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        PreparedStatement st = connection.prepareStatement(sql.toString());
        int paramIndex = 1;

        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchPattern = "%" + keyword.trim() + "%";
            st.setString(paramIndex++, searchPattern);
            st.setString(paramIndex++, searchPattern);
        }
        if (minPrice != null) {
            st.setDouble(paramIndex++, minPrice);
        }
        if (maxPrice != null) {
            st.setDouble(paramIndex++, maxPrice);
        }
        if (categoryId != null) {
            st.setInt(paramIndex++, categoryId);
        }

        // Calculate offset
        int offset = (page - 1) * pageSize;
        st.setInt(paramIndex++, offset);
        st.setInt(paramIndex++, pageSize);

        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            list.add(new Product(rs.getInt("ProductID"),
                    rs.getString("Name"),
                    rs.getString("SKU"),
                    rs.getDouble("Cost"),
                    rs.getDouble("Price"),
                    rs.getInt("StockQuantity"),
                    rs.getString("Unit"),
                    rs.getString("Description"),
                    rs.getString("ImageURL"),
                    rs.getString("Status") != null ? rs.getString("Status").trim() : null,
                    rs.getInt("CategoryID"),
                    rs.getTimestamp("CreatedDate"),
                    rs.getTimestamp("UpdatedDate")));
        }
        return list;
    }
}
