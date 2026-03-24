package dao;

import java.sql.*;
import java.util.*;
import model.Product;
import utils.DBContext;

public class ProductDAO extends DBContext {

    // Search cho POS
    public List<Product> search(String keyword) {
        List<Product> list = new ArrayList<>();

        String sql = """
            SELECT ProductID, Name, SKU, Price, StockQuantity, Unit, Status
            FROM dbo.Products
            WHERE Status = 'Active'
              AND (Name LIKE ? OR SKU LIKE ?)
        """;

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            String k = "%" + (keyword == null ? "" : keyword.trim()) + "%";
            stm.setString(1, k);
            stm.setString(2, k);

            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Product getBySku(String sku) {
        String sql = """
            SELECT ProductID, Name, SKU, Price, StockQuantity, Unit, Status, WarrantyPeriod
            FROM dbo.Products
            WHERE Status = 'Active' AND SKU = ?
        """;

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, sku == null ? "" : sku.trim());
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Product> searchByName(String keyword) {
        List<Product> list = new ArrayList<>();
        String sql = """
            SELECT ProductID, Name, SKU, Price, StockQuantity, Unit, Status, WarrantyPeriod
            FROM dbo.Products
            WHERE Status = 'Active' AND Name LIKE ?
        """;

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            String k = "%" + (keyword == null ? "" : keyword.trim()) + "%";
            stm.setString(1, k);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getLowStockProducts(int threshold) {
        List<Product> list = new ArrayList<>();
        // Lưu ý: Dùng đúng tên cột StockQuantity và tên bảng Products như các hàm trên của bạn
        String sql = "SELECT * FROM dbo.Products WHERE StockQuantity <= ? AND Status = 'Active'";

        try {
            // Sử dụng biến 'connection' có sẵn từ DBContext (không cần khởi tạo lại conn)
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, threshold);
            ResultSet rs = stm.executeQuery();

            while (rs.next()) {
                // Sử dụng hàm map(rs) bạn đã viết sẵn ở dưới để đồng bộ dữ liệu
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy product theo ID (add vào cart)
    public Product getById(int id) {
        String sql = """
                 SELECT ProductID, Name, SKU, Cost, Price, StockQuantity, Unit, 
                        Status, Description, ImageURL, WarrantyPeriod, CategoryID, 
                        CreatedDate, UpdatedDate
                 FROM dbo.Products
                 WHERE ProductID = ? AND Status = 'Active'
                 """;

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);

            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                return map(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private Product map(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("ProductID"));
        p.setName(rs.getString("Name"));
        p.setSku(rs.getString("SKU"));
        p.setPrice(rs.getDouble("Price"));
        p.setQuantity(rs.getInt("StockQuantity"));
        p.setUnit(rs.getString("Unit"));
        p.setStatus(rs.getString("Status"));
        return p;

    }

    public void increaseQuantity(int productId, int quantity) {
        String sql = "UPDATE Products SET StockQuantity = StockQuantity + ? WHERE ProductID = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, quantity);
            ps.setInt(2, productId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Product> getAllProducts() throws Exception {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Products";
        PreparedStatement st = connection.prepareStatement(sql);
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

    public List<Product> getProductsByCategoryId(int categoryId) throws Exception {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Products WHERE CategoryID = ?";
        PreparedStatement st = connection.prepareStatement(sql);
        st.setInt(1, categoryId);
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

    public int addProduct(Product p) throws Exception {
        String sql = "INSERT INTO Products (Name, SKU, Cost, Price, StockQuantity, Unit, Description, ImageURL, Status, CategoryID, CreatedDate, UpdatedDate) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        java.sql.PreparedStatement st = connection.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
        st.setString(1, p.getName());
        st.setString(2, p.getSku());
        st.setDouble(3, p.getCost());
        st.setDouble(4, p.getPrice());
        st.setInt(5, p.getQuantity());
        st.setString(6, p.getUnit());
        st.setString(7, p.getDescription());
        st.setString(8, p.getImageURL());
        st.setString(9, p.getStatus());
        st.setInt(10, p.getCategoryId());

        int affectedRows = st.executeUpdate();
        if (affectedRows > 0) {
            java.sql.ResultSet rs = st.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return -1;
    }

    public boolean updateProduct(Product p) throws Exception {
        String sql = "UPDATE Products SET Name=?, SKU=?, Cost=?, Price=?, StockQuantity=?, Unit=?, Description=?, ImageURL=?, Status=?, CategoryID=?, UpdatedDate=GETDATE() WHERE ProductID=?";
        PreparedStatement st = connection.prepareStatement(sql);
        st.setString(1, p.getName());
        st.setString(2, p.getSku());
        st.setDouble(3, p.getCost());
        st.setDouble(4, p.getPrice());
        st.setInt(5, p.getQuantity());
        st.setString(6, p.getUnit());
        st.setString(7, p.getDescription());
        st.setString(8, p.getImageURL());
        st.setString(9, p.getStatus());
        st.setInt(10, p.getCategoryId());
        st.setInt(11, p.getId());
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
                return new Product(rs.getInt("ProductID"),
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
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
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
        CategoryDAO catDao = new CategoryDAO();
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
            List<Integer> categoryIds = new ArrayList<>();
            categoryIds.add(categoryId);
            catDao.getAllChildCategoryIds(categoryId.intValue(), categoryIds);

            StringBuilder catSql = new StringBuilder(" AND CategoryID IN (");
            for (int i = 0; i < categoryIds.size(); i++) {
                catSql.append("?");
                if (i < categoryIds.size() - 1) {
                    catSql.append(",");
                }
            }
            catSql.append(")");
            sql.append(catSql);
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
            List<Integer> categoryIds = new ArrayList<>();
            categoryIds.add(categoryId);
            catDao.getAllChildCategoryIds(categoryId.intValue(), categoryIds);
            for (Integer id : categoryIds) {
                st.setInt(paramIndex++, id);
            }
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
        CategoryDAO catDao = new CategoryDAO();
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
            List<Integer> categoryIds = new ArrayList<>();
            categoryIds.add(categoryId);
            catDao.getAllChildCategoryIds(categoryId.intValue(), categoryIds);

            StringBuilder catSql = new StringBuilder(" AND CategoryID IN (");
            for (int i = 0; i < categoryIds.size(); i++) {
                catSql.append("?");
                if (i < categoryIds.size() - 1) {
                    catSql.append(",");
                }
            }
            catSql.append(")");
            sql.append(catSql);
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
            List<Integer> categoryIds = new ArrayList<>();
            categoryIds.add(categoryId);
            catDao.getAllChildCategoryIds(categoryId.intValue(), categoryIds);
            for (Integer id : categoryIds) {
                st.setInt(paramIndex++, id);
            }
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
        CategoryDAO catDao = new CategoryDAO();
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
            List<Integer> categoryIds = new ArrayList<>();
            categoryIds.add(categoryId);
            catDao.getAllChildCategoryIds(categoryId.intValue(), categoryIds);

            StringBuilder catSql = new StringBuilder(" AND CategoryID IN (");
            for (int i = 0; i < categoryIds.size(); i++) {
                catSql.append("?");
                if (i < categoryIds.size() - 1) {
                    catSql.append(",");
                }
            }
            catSql.append(")");
            sql.append(catSql);
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
            List<Integer> categoryIds = new ArrayList<>();
            categoryIds.add(categoryId);
            catDao.getAllChildCategoryIds(categoryId.intValue(), categoryIds);
            for (Integer id : categoryIds) {
                st.setInt(paramIndex++, id);
            }
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

    public boolean bulkSoftDelete(int[] ids) {
        if (ids == null || ids.length == 0) {
            return false;
        }
        StringBuilder sql = new StringBuilder("UPDATE Products SET Status = 'Inactive', UpdatedDate = GETDATE() WHERE ProductID IN (");
        for (int i = 0; i < ids.length; i++) {
            sql.append("?");
            if (i < ids.length - 1) {
                sql.append(",");
            }
        }
        sql.append(")");

        try {
            PreparedStatement st = connection.prepareStatement(sql.toString());
            for (int i = 0; i < ids.length; i++) {
                st.setInt(i + 1, ids[i]);
            }
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean bulkHardDelete(int[] ids) {
        if (ids == null || ids.length == 0) {
            return false;
        }
        StringBuilder sql = new StringBuilder("DELETE FROM Products WHERE ProductID IN (");
        for (int i = 0; i < ids.length; i++) {
            sql.append("?");
            if (i < ids.length - 1) {
                sql.append(",");
            }
        }
        sql.append(")");

        try {
            PreparedStatement st = connection.prepareStatement(sql.toString());
            for (int i = 0; i < ids.length; i++) {
                st.setInt(i + 1, ids[i]);
            }
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void decreaseQuantity(int productId, int quantity) {
        String sql = "UPDATE Products SET StockQuantity = StockQuantity - ? WHERE ProductID = ? AND StockQuantity >= ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, quantity);
            ps.setInt(2, productId);
            ps.setInt(3, quantity); // Đảm bảo không trừ quá số lượng đang có
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
