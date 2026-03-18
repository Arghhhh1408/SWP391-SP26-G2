package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Category;
import utils.DBContext;

public class CategoryDAO extends DBContext {

    public List<Category> getAllCategories() throws Exception {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM Categories ORDER BY CategoryName ASC";
        PreparedStatement st = connection.prepareStatement(sql);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            int id = rs.getInt("CategoryID");
            String name = rs.getString("CategoryName");
            Integer parentId = (Integer) rs.getObject("ParentID");
            list.add(new Category(id, name, parentId));
        }
        return list;
    }

    public List<Category> searchCategories(Integer parentIdFilter, String sortBy) throws Exception {
        List<Category> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM Categories WHERE 1=1");
        if (parentIdFilter != null) {
            if (parentIdFilter == 0) {
                sql.append(" AND ParentID IS NULL");
            } else {
                sql.append(" AND ParentID = ?");
            }
        }

        // Dynamic sorting
        String orderBy = "CategoryName ASC"; // Default
        if (sortBy != null && !sortBy.trim().isEmpty()) {
            if (sortBy.equals("name_desc")) {
                orderBy = "CategoryName DESC";
            } else if (sortBy.equals("id_asc")) {
                orderBy = "CategoryID ASC";
            } else if (sortBy.equals("structural")) {
                // Keep the original structural sorting as an option if needed
                orderBy = "(CASE WHEN ParentID IS NULL THEN 0 ELSE 1 END) ASC, CategoryName ASC";
            }
        }
        sql.append(" ORDER BY ").append(orderBy);

        PreparedStatement st = connection.prepareStatement(sql.toString());
        if (parentIdFilter != null && parentIdFilter > 0) {
            st.setInt(1, parentIdFilter);
        }

        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            list.add(new Category(rs.getInt("CategoryID"), rs.getString("CategoryName"),
                    (Integer) rs.getObject("ParentID")));
        }
        return list;
    }

    public List<Category> getCategoryTree() throws Exception {
        List<Category> allCategories = getAllCategories();
        List<Category> rootCategories = new ArrayList<>();
        for (Category c : allCategories) {
            if (c.getParentId() == null || c.getParentId() == 0) {
                rootCategories.add(c);
            } else {
                for (Category parent : allCategories) {
                    if (parent.getId() == c.getParentId()) {
                        parent.getChildren().add(c);
                        break;
                    }
                }
            }
        }
        return rootCategories;
    }

    public void getAllChildCategoryIds(int parentId, List<Integer> ids) throws Exception {
        String sql = "SELECT CategoryID FROM Categories WHERE ParentID = ?";
        PreparedStatement st = connection.prepareStatement(sql);
        st.setInt(1, parentId);
        ResultSet rs = st.executeQuery();
        while (rs.next()) {
            int childId = rs.getInt("CategoryID");
            ids.add(childId);
            getAllChildCategoryIds(childId, ids);
        }
    }

    public boolean addCategory(Category c) {
        String sql = "INSERT INTO Categories (CategoryName, ParentID) VALUES (?, ?)";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, c.getName());
            if (c.getParentId() != null && c.getParentId() > 0) {
                st.setInt(2, c.getParentId());
            } else {
                st.setNull(2, java.sql.Types.INTEGER);
            }
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateCategory(Category c) {
        String sql = "UPDATE Categories SET CategoryName = ?, ParentID = ? WHERE CategoryID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, c.getName());
            if (c.getParentId() != null && c.getParentId() > 0) {
                st.setInt(2, c.getParentId());
            } else {
                st.setNull(2, java.sql.Types.INTEGER);
            }
            st.setInt(3, c.getId());
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
                return new Category(rs.getInt("CategoryID"), rs.getString("CategoryName"),
                        (Integer) rs.getObject("ParentID"));
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

    public List<Category> getHierarchicalList() throws Exception {
        List<Category> tree = getCategoryTree();
        List<Category> result = new ArrayList<>();
        flattenTree(tree, 0, result);
        return result;
    }

    private void flattenTree(List<Category> tree, int level, List<Category> result) {
        for (Category c : tree) {
            StringBuilder name = new StringBuilder();
            for (int i = 0; i < level; i++) {
                name.append("\u00A0\u00A0");
            }
            if (level > 0) {
                name.append("└─ ");
            }
            Category copy = new Category(c.getId(), name.toString() + c.getName(), c.getParentId());
            result.add(copy);
            if (c.getChildren() != null && !c.getChildren().isEmpty()) {
                flattenTree(c.getChildren(), level + 1, result);
            }
        }
    }

    public boolean hasSubCategories(int parentId) {
        String sql = "SELECT CategoryID FROM Categories WHERE ParentID = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, parentId);
            ResultSet rs = st.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
