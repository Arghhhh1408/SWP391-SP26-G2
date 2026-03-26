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

    public List<Product> getLowStockProducts(int defaultThreshold) {
        List<Product> list = new ArrayList<>();
        String sql = """
                    SELECT p.*, l.MinStockLevel
                    FROM dbo.Products p
                    LEFT JOIN dbo.LowStockAlerts l ON p.ProductID = l.ProductID
                    WHERE p.Status = 'Active'
                      AND p.StockQuantity <= ISNULL(l.MinStockLevel, ?)
                """;

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, defaultThreshold);
            ResultSet rs = stm.executeQuery();

            while (rs.next()) {
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

    public List<Product> searchBySupplier(int supplierId, String keyword) {
        List<Product> list = new ArrayList<>();

        String sql = "SELECT p.ProductID, p.Name, p.SKU, p.Cost, p.Price, p.StockQuantity, p.Unit, "
                + "       sp.SupplyPrice "
                + "FROM Products p "
                + "INNER JOIN SupplierProduct sp ON p.ProductID = sp.ProductID "
                + "WHERE sp.SupplierID = ? "
                + "  AND sp.IsActive = 1 "
                + "  AND p.Status = 'Active' "
                + "  AND ( ? = '' OR p.Name LIKE ? OR p.SKU LIKE ? ) "
                + "ORDER BY p.Name";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String kw = keyword == null ? "" : keyword.trim();
            ps.setInt(1, supplierId);
            ps.setString(2, kw);
            ps.setString(3, "%" + kw + "%");
            ps.setString(4, "%" + kw + "%");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("ProductID"));
                    p.setName(rs.getString("Name"));
                    p.setSku(rs.getString("SKU"));
                    p.setCost(rs.getDouble("SupplyPrice") > 0 ? rs.getDouble("SupplyPrice") : rs.getDouble("Cost"));
                    p.setPrice(rs.getDouble("Price"));
                    p.setQuantity(rs.getInt("StockQuantity"));
                    p.setUnit(rs.getString("Unit"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean existsInSupplier(int supplierId, int productId) {
        String sql = "SELECT 1 FROM SupplierProduct WHERE SupplierID = ? AND ProductID = ? AND IsActive = 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, supplierId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Product map(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("ProductID"));
        p.setName(rs.getString("Name"));
        p.setSku(rs.getString("SKU"));
        p.setCost(rs.getDouble("Cost"));
        p.setPrice(rs.getDouble("Price"));
        p.setQuantity(rs.getInt("StockQuantity"));
        p.setUnit(rs.getString("Unit"));
        p.setDescription(rs.getString("Description"));
        p.setImageURL(rs.getString("ImageURL"));
        p.setWarrantyPeriod(rs.getInt("WarrantyPeriod"));
        p.setStatus(rs.getString("Status"));
        p.setCategoryId(rs.getInt("CategoryID"));
        p.setCreateDate(rs.getTimestamp("CreatedDate"));
        p.setUpdateDate(rs.getTimestamp("UpdatedDate"));
        try {
            int threshold = rs.getInt("MinStockLevel");
            if (!rs.wasNull()) {
                p.setLowStockThreshold(threshold);
            }
        } catch (SQLException ignore) {
            // Column might not exist in some simple SELECT * queries without JOIN
        }
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

    public boolean increaseQuantityBySku(String sku, int quantity) {
        if (quantity <= 0) {
            return false;
        }
        String key = sku == null ? "" : sku.trim();
        if (key.isEmpty()) {
            return false;
        }
        String sql = """
                UPDATE dbo.Products
                SET StockQuantity = StockQuantity + ?,
                    Status = CASE WHEN Status = 'Deactivated' THEN 'Active' ELSE Status END,
                    UpdatedDate = GETDATE()
                WHERE UPPER(LTRIM(RTRIM(SKU))) = UPPER(?)
                """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, quantity);
            ps.setString(2, key);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Product> getAllActiveProducts() throws Exception {
        List<Product> list = new ArrayList<>();
        String sql = """
                SELECT p.*, l.MinStockLevel
                FROM Products p
                LEFT JOIN LowStockAlerts l ON p.ProductID = l.ProductID
                WHERE p.Status = 'Active'
                """;
        PreparedStatement st = connection.prepareStatement(sql);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            list.add(map(rs));
        }
        return list;
    }

    public List<Product> getAllProducts() throws Exception {
        List<Product> list = new ArrayList<>();
        String sql = """
                SELECT p.*, l.MinStockLevel
                FROM Products p
                LEFT JOIN LowStockAlerts l ON p.ProductID = l.ProductID
                """;
        PreparedStatement st = connection.prepareStatement(sql);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            list.add(map(rs));
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
        // StockQuantity is NOT set here — it defaults to 0 in the DB and is managed via
        // stock-in
        String sql = "INSERT INTO Products (Name, SKU, Cost, Price, Unit, Description, ImageURL, Status, CategoryID, CreatedDate, UpdatedDate) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        java.sql.PreparedStatement st = connection.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
        st.setString(1, p.getName());
        st.setString(2, p.getSku());
        st.setDouble(3, p.getCost());
        st.setDouble(4, p.getPrice());
        st.setString(5, p.getUnit());
        st.setString(6, p.getDescription());
        st.setString(7, p.getImageURL());
        st.setString(8, p.getStatus());
        st.setInt(9, p.getCategoryId());

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
        // StockQuantity is NOT updated here — it is managed exclusively via stock-in
        String sql = "UPDATE Products SET Name=?, SKU=?, Cost=?, Price=?, Unit=?, Description=?, ImageURL=?, Status=?, CategoryID=?, UpdatedDate=GETDATE() WHERE ProductID=?";
        PreparedStatement st = connection.prepareStatement(sql);
        st.setString(1, p.getName());
        st.setString(2, p.getSku());
        st.setDouble(3, p.getCost());
        st.setDouble(4, p.getPrice());
        st.setString(5, p.getUnit());
        st.setString(6, p.getDescription());
        st.setString(7, p.getImageURL());
        st.setString(8, p.getStatus());
        st.setInt(9, p.getCategoryId());
        st.setInt(10, p.getId());
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
        String sql = """
                    SELECT p.*, l.MinStockLevel
                    FROM Products p
                    LEFT JOIN LowStockAlerts l ON p.ProductID = l.ProductID
                    WHERE p.ProductID = ?
                """;
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, id);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Product getByIdAndSupplier(int productId, int supplierId) {
        String sql = """
                    SELECT p.ProductID, p.Name, p.SKU, p.Cost, p.Price, p.StockQuantity, p.Unit,
                           p.Description, p.ImageURL, p.Status, p.CategoryID, p.CreatedDate, p.UpdatedDate, p.WarrantyPeriod,
                           sp.SupplyPrice
                    FROM dbo.Products p
                    INNER JOIN dbo.SupplierProduct sp ON p.ProductID = sp.ProductID
                    WHERE p.ProductID = ?
                      AND sp.SupplierID = ?
                      AND p.Status = 'Active'
                      AND sp.IsActive = 1
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, supplierId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = map(rs);
                    double supplyPrice = rs.getDouble("SupplyPrice");
                    if (supplyPrice > 0) {
                        p.setCost(supplyPrice);
                    }
                    return p;
                }
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

    public List<Product> searchProducts(String keyword, String sort, String range) {
        List<Product> list = new ArrayList<>();
        // 1. Dùng SELECT * để đảm bảo hàm map(rs) có đủ cột dữ liệu
        StringBuilder sql = new StringBuilder("SELECT * FROM Products WHERE Status = 'Active' ");

        // Lọc theo tên hoặc SKU
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (Name LIKE ? OR SKU LIKE ?) ");
        }

        // Lọc chỉ sản phẩm còn hàng
        if ("available".equals(range)) {
            sql.append(" AND StockQuantity > 0 ");
        }

        // Sắp xếp giá
        if ("total_desc".equals(sort)) {
            sql.append(" ORDER BY Price DESC ");
        } else if ("total_asc".equals(sort)) {
            sql.append(" ORDER BY Price ASC ");
        } else {
            sql.append(" ORDER BY ProductID DESC ");
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            if (keyword != null && !keyword.trim().isEmpty()) {
                String p = "%" + keyword.trim() + "%";
                ps.setString(1, p);
                ps.setString(2, p);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    // Tận dụng hàm map(rs) đã có sẵn của Mạnh Lý ở dòng 156
                    list.add(map(rs));
                }
            }
        } catch (Exception e) {
            System.out.println("Lỗi searchProducts POS: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> searchProducts(String keyword, Double minPrice, Double maxPrice, Integer categoryId,
            String status)
            throws Exception {
        List<Product> list = new ArrayList<>();
        CategoryDAO catDao = new CategoryDAO();
        StringBuilder sql = new StringBuilder("SELECT * FROM Products WHERE 1=1");
        if (status != null && !status.isEmpty() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND Status = ?");
        }

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

        if (status != null && !status.isEmpty() && !"all".equalsIgnoreCase(status)) {
            st.setString(paramIndex++, status);
        }

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

    public int countProducts(String keyword, Double minPrice, Double maxPrice, Integer categoryId, String status)
            throws Exception {
        CategoryDAO catDao = new CategoryDAO();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Products WHERE 1=1");
        if (status != null && !status.isEmpty() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND Status = ?");
        }

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

        if (status != null && !status.isEmpty() && !"all".equalsIgnoreCase(status)) {
            st.setString(paramIndex++, status);
        }

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
            String status,
            int page, int pageSize) throws Exception {
        List<Product> list = new ArrayList<>();
        CategoryDAO catDao = new CategoryDAO();
        StringBuilder sql = new StringBuilder("SELECT * FROM Products WHERE 1=1");
        if (status != null && !status.isEmpty() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND Status = ?");
        }

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

        if (status != null && !status.isEmpty() && !"all".equalsIgnoreCase(status)) {
            st.setString(paramIndex++, status);
        }

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
        StringBuilder sql = new StringBuilder(
                "UPDATE Products SET Status = 'Deactivated', UpdatedDate = GETDATE() WHERE ProductID IN (");
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

            // Auto-deactivate if stock hits zero
            String checkSql = "UPDATE Products SET Status = 'Deactivated', UpdatedDate = GETDATE() WHERE ProductID = ? AND StockQuantity = 0";
            try (PreparedStatement checkPs = connection.prepareStatement(checkSql)) {
                checkPs.setInt(1, productId);
                checkPs.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean bulkActivate(int[] ids) {
        if (ids == null || ids.length == 0) {
            return false;
        }
        StringBuilder sql = new StringBuilder(
                "UPDATE Products SET Status = 'Active', UpdatedDate = GETDATE() WHERE ProductID IN (");
        for (int i = 0; i < ids.length; i++) {
            sql.append("?");
            if (i < ids.length - 1) {
                sql.append(",");
            }
        }
        sql.append(")");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < ids.length; i++) {
                ps.setInt(i + 1, ids[i]);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<ProductPerformance> getTopSellingProducts(int limit) {
        List<ProductPerformance> list = new ArrayList<>();
        String sql = """
                SELECT TOP (?)
                    p.ProductID, p.SKU, p.Name,
                    SUM(sd.Quantity) as TotalQuantity,
                    SUM(sd.Quantity * sd.UnitPrice) as TotalRevenue
                FROM dbo.Products p
                JOIN dbo.StockOutDetails sd ON p.ProductID = sd.ProductID
                GROUP BY p.ProductID, p.SKU, p.Name
                ORDER BY TotalQuantity DESC
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductPerformance pp = new ProductPerformance();
                    pp.setProductId(rs.getInt("ProductID"));
                    pp.setSku(rs.getString("SKU"));
                    pp.setName(rs.getString("Name"));
                    pp.setQuantitySold(rs.getInt("TotalQuantity"));
                    pp.setRevenueGenerated(rs.getDouble("TotalRevenue"));
                    list.add(pp);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public static class ProductPerformance {

        private int productId;
        private String sku, name;
        private int quantitySold;
        private double revenueGenerated;

        // Getters/Setters
        public int getProductId() {
            return productId;
        }

        public void setProductId(int productId) {
            this.productId = productId;
        }

        public String getSku() {
            return sku;
        }

        public void setSku(String sku) {
            this.sku = sku;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getQuantitySold() {
            return quantitySold;
        }

        public void setQuantitySold(int quantitySold) {
            this.quantitySold = quantitySold;
        }

        public double getRevenueGenerated() {
            return revenueGenerated;
        }

        public void setRevenueGenerated(double revenueGenerated) {
            this.revenueGenerated = revenueGenerated;
        }
    }
}
