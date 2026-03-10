/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.StockIn;
import model.StockInDetail;
import utils.DBContext;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class StockInDAO extends DBContext {

    public boolean insertStockInWithDetails(StockIn stockIn, List<StockInDetail> details) {

        String insertStockInSQL
                = "INSERT INTO StockIn (SupplierID, TotalAmount, CreatedBy, Note, Status) "
                + "VALUES (?, ?, ?, ?, ?)";

        String insertDetailSQL
                = "INSERT INTO StockInDetails (StockInID, ProductID, Quantity, UnitCost) "
                + "VALUES (?, ?, ?, ?)";

        try {

            connection.setAutoCommit(false); // 🔥 bắt đầu transaction

            // ===== 1. Insert StockIn =====
            PreparedStatement psStock
                    = connection.prepareStatement(insertStockInSQL, Statement.RETURN_GENERATED_KEYS);

            psStock.setInt(1, stockIn.getSupplierId());
            psStock.setDouble(2, stockIn.getTotalAmount());
            psStock.setInt(3, stockIn.getCreatedBy());
            psStock.setString(4, stockIn.getNote());
            psStock.setString(5, stockIn.getStatus());

            psStock.executeUpdate();

            // ===== 2. Lấy StockInID vừa tạo =====
            ResultSet rs = psStock.getGeneratedKeys();
            int stockInId = 0;

            if (rs.next()) {
                stockInId = rs.getInt(1);
            }

            // ===== 3. Insert StockInDetails =====
            PreparedStatement psDetail = connection.prepareStatement(insertDetailSQL);

            for (StockInDetail d : details) {
                psDetail.setInt(1, stockInId);
                psDetail.setInt(2, d.getProductId());
                psDetail.setInt(3, d.getQuantity());
                psDetail.setDouble(4, d.getUnitCost());
                psDetail.addBatch();
            }

            psDetail.executeBatch();

            connection.commit(); // ✅ thành công
            connection.setAutoCommit(true);

            return true;

        } catch (Exception e) {
            try {
                connection.rollback(); // ❌ lỗi thì rollback
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            closeConnection(); // đóng connection
        }

        return false;
    }

    public List<StockIn> getAllStockIn() {
        List<StockIn> list = new ArrayList<>();

        String sql = "SELECT "
                + "s.StockInID, "
                + "s.Date, "
                + "s.Note, "
                + "s.Status, "
                + "sup.Name AS SupplierName, "
                + "u.FullName, "
                + "d.ProductID, "
                + "p.Name AS ProductName, "
                + "d.Quantity, "
                + "d.UnitCost "
                + "FROM StockIn s "
                + "JOIN StockInDetails d ON s.StockInID = d.StockInID "
                + "JOIN Products p ON d.ProductID = p.ProductID "
                + "JOIN Suppliers sup ON s.SupplierID = sup.SupplierID "
                + "JOIN [User] u ON s.CreatedBy = u.UserID "
                + "ORDER BY s.StockInID DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            Map<Integer, StockIn> map = new LinkedHashMap<>();

            while (rs.next()) {

                int id = rs.getInt("StockInID");

                StockIn stock = map.get(id);

                if (stock == null) {
                    stock = new StockIn();
                    stock.setStockInId(id);
                    stock.setDate(rs.getTimestamp("Date"));
                    stock.setNote(rs.getString("Note"));
                    stock.setStatus(rs.getString("Status"));
                    stock.setSupplierName(rs.getString("SupplierName"));
                    stock.setStaffName(rs.getString("FullName"));
                    stock.setDetails(new ArrayList<>());

                    map.put(id, stock);
                }

                StockInDetail detail = new StockInDetail();
                detail.setProductId(rs.getInt("ProductID"));
                detail.setProductName(rs.getString("ProductName"));
                detail.setQuantity(rs.getInt("Quantity"));
                detail.setUnitCost(rs.getDouble("UnitCost"));

                stock.getDetails().add(detail);
            }

            list.addAll(map.values());

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean deleteStockIn(int id) {
        String deleteDetailsSql = "DELETE FROM StockInDetails WHERE StockInID = ?";
        String deleteStockInSql = "DELETE FROM StockIn WHERE StockInID = ?";

        try {
            connection.setAutoCommit(false);

            PreparedStatement psDetail = connection.prepareStatement(deleteDetailsSql);
            psDetail.setInt(1, id);
            psDetail.executeUpdate();

            PreparedStatement psStockIn = connection.prepareStatement(deleteStockInSql);
            psStockIn.setInt(1, id);

            int rows = psStockIn.executeUpdate();

            connection.commit();
            connection.setAutoCommit(true);

            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                connection.rollback();
                connection.setAutoCommit(true);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }

        return false;
    }

    public StockIn getStockInById(int id) {
        String sql = "SELECT "
                + "s.StockInID, "
                + "s.Date, "
                + "s.Note, "
                + "s.Status, "
                + "s.TotalAmount, "
                + "sup.Name AS SupplierName, "
                + "u.FullName, "
                + "d.ProductID, "
                + "p.Name AS ProductName, "
                + "d.Quantity, "
                + "d.UnitCost "
                + "FROM StockIn s "
                + "JOIN StockInDetails d ON s.StockInID = d.StockInID "
                + "JOIN Products p ON d.ProductID = p.ProductID "
                + "JOIN Suppliers sup ON s.SupplierID = sup.SupplierID "
                + "JOIN [User] u ON s.CreatedBy = u.UserID "
                + "WHERE s.StockInID = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            StockIn stock = null;

            while (rs.next()) {
                if (stock == null) {
                    stock = new StockIn();
                    stock.setStockInId(rs.getInt("StockInID"));
                    stock.setDate(rs.getTimestamp("Date"));
                    stock.setNote(rs.getString("Note"));
                    stock.setStatus(rs.getString("Status"));
                    stock.setTotalAmount(rs.getDouble("TotalAmount"));
                    stock.setSupplierName(rs.getString("SupplierName"));
                    stock.setStaffName(rs.getString("FullName"));
                    stock.setDetails(new ArrayList<>());
                }

                StockInDetail detail = new StockInDetail();
                detail.setProductId(rs.getInt("ProductID"));
                detail.setProductName(rs.getString("ProductName"));
                detail.setQuantity(rs.getInt("Quantity"));
                detail.setUnitCost(rs.getDouble("UnitCost"));

                stock.getDetails().add(detail);
            }

            return stock;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean updateStockIn(StockIn s) {
        String sql = "UPDATE StockIn SET status = ?, note = ? WHERE stockInId = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, s.getStatus());
            ps.setString(2, s.getNote());
            ps.setInt(3, s.getStockInId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}
