
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.SystemLog;
import utils.DBContext;

public class SystemLogDAO extends DBContext {

    public boolean insertLog(SystemLog log) {
        String sql = "INSERT INTO [dbo].[SystemLog] ([UserID], [Action], [TargetObject], [Description], [LogDate], [IPAddress]) VALUES (?, ?, ?, ?, GETDATE(), ?)";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, log.getUserID());
            stm.setString(2, log.getAction());
            stm.setString(3, log.getTargetObject());
            stm.setString(4, log.getDescription());
            stm.setString(5, log.getIpAddress());
            return stm.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<SystemLog> getLogs() {
        return getLogs(null, null, null);
    }

    public List<SystemLog> getLogs(Integer userId, String action, String date) {
        List<SystemLog> list = new ArrayList<>();
        String sql = "SELECT * FROM [dbo].[SystemLog] WHERE 1=1";

        List<Object> params = new ArrayList<>();

        if (userId != null) {
            sql += " AND UserID = ?";
            params.add(userId);
        }

        if (action != null && !action.trim().isEmpty()) {
            sql += " AND Action LIKE ?";
            params.add("%" + action + "%");
        }

        if (date != null && !date.trim().isEmpty()) {
            sql += " AND CONVERT(DATE, LogDate) = ?";
            params.add(date);
        }

        sql += " ORDER BY LogDate DESC";

        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            for (int i = 0; i < params.size(); i++) {
                stm.setObject(i + 1, params.get(i));
            }
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                SystemLog log = new SystemLog();
                log.setLogID(rs.getInt("LogID"));
                log.setUserID(rs.getInt("UserID"));
                log.setAction(rs.getString("Action"));
                log.setTargetObject(rs.getString("TargetObject"));
                log.setDescription(rs.getString("Description"));
                log.setLogDate(rs.getTimestamp("LogDate"));
                log.setIpAddress(rs.getString("IPAddress"));
                list.add(log);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<SystemLog> getWarehouseStaffLogs(int limit) {
        List<SystemLog> list = new ArrayList<>();

        String sql = "SELECT TOP (?) l.*, u.FullName "
                + "FROM [dbo].[SystemLog] l "
                + "LEFT JOIN [dbo].[User] u ON l.UserID = u.UserID "
                + "WHERE l.Action IN (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) "
                + "ORDER BY l.LogDate DESC";
 
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, limit);
 
            stm.setString(2, "CREATE_STOCKIN");
            stm.setString(3, "UPDATE_STOCKIN");
            stm.setString(4, "DELETE_STOCKIN");
            stm.setString(5, "INVENTORY_CHECK");
            stm.setString(6, "INVENTORY_CHECK_SAVE");
            stm.setString(7, "INVENTORY_CHECK_UPDATE");
            stm.setString(8, "INVENTORY_CHECK_APPROVE");
            stm.setString(9, "INVENTORY_CHECK_REJECT");
            stm.setString(10, "VIEW_SUPPLIER_DEBT");
            stm.setString(11, "VIEW_SUPPLIER_PRODUCT");
            stm.setString(12, "COMPLETE_WARRANTY");
            stm.setString(13, "REJECT_WARRANTY");
            stm.setString(14, "COMPLETE_RETURN");
            stm.setString(15, "REJECT_RETURN");
            stm.setString(16, "NOTIFY_LOW_STOCK");
            stm.setString(17, "UNNOTIFY_LOW_STOCK");

            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                SystemLog log = new SystemLog();
                log.setLogID(rs.getInt("LogID"));
                log.setUserID(rs.getInt("UserID"));
                log.setAction(rs.getString("Action"));
                log.setTargetObject(rs.getString("TargetObject"));
                log.setDescription(rs.getString("Description"));
                log.setLogDate(rs.getTimestamp("LogDate"));
                log.setIpAddress(rs.getString("IPAddress"));
                log.setName(rs.getString("FullName"));
                list.add(log);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<SystemLog> getRecentLogs(int limit) {
        List<SystemLog> list = new ArrayList<>();
        String sql = "SELECT TOP (?) * FROM [dbo].[SystemLog] ORDER BY LogDate DESC";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, limit);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                SystemLog log = new SystemLog();
                log.setLogID(rs.getInt("LogID"));
                log.setUserID(rs.getInt("UserID"));
                log.setAction(rs.getString("Action"));
                log.setTargetObject(rs.getString("TargetObject"));
                log.setDescription(rs.getString("Description"));
                log.setLogDate(rs.getTimestamp("LogDate"));
                log.setIpAddress(rs.getString("IPAddress"));
                list.add(log);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<SystemLog> getProductHistory(int productId) {
        List<SystemLog> list = new ArrayList<>();
        // Query both updated Product records and relevant StockIn records if they exist
        String sql = "SELECT l.*, u.FullName "
                + "FROM [dbo].[SystemLog] l "
                + "LEFT JOIN [dbo].[User] u ON l.UserID = u.UserID "
                + "WHERE (l.TargetObject = 'Product' AND (l.Description LIKE ? OR l.Description LIKE ?)) "
                + "OR (l.TargetObject = 'StockIn' AND l.Description LIKE ?) "
                + "ORDER BY l.LogDate DESC";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            String idSearch = "%ID: " + productId + "%";
            stm.setString(1, idSearch);
            stm.setString(2, "Product ID: " + productId + "%");
            stm.setString(3, "%Product ID: " + productId + "%");

            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                SystemLog log = new SystemLog();
                log.setLogID(rs.getInt("LogID"));
                log.setUserID(rs.getInt("UserID"));
                log.setAction(rs.getString("Action"));
                log.setTargetObject(rs.getString("TargetObject"));
                log.setDescription(rs.getString("Description"));
                log.setLogDate(rs.getTimestamp("LogDate"));
                log.setIpAddress(rs.getString("IPAddress"));
                log.setName(rs.getString("FullName"));
                list.add(log);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<SystemLog> getAllProductHistory() {
        List<SystemLog> list = new ArrayList<>();
        // 1. Fetch products into a map for quick lookup
        Map<Integer, String> productMap = new HashMap<>();
        try {
            String productSql = "SELECT ProductID, Name FROM Products";
            PreparedStatement pst = connection.prepareStatement(productSql);
            ResultSet prs = pst.executeQuery();
            while (prs.next()) {
                productMap.put(prs.getInt("ProductID"), prs.getString("Name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 2. Fetch logs
        String sql = "SELECT l.*, u.FullName "
                + "FROM [dbo].[SystemLog] l "
                + "LEFT JOIN [dbo].[User] u ON l.UserID = u.UserID "
                + "WHERE l.TargetObject = 'Product' OR l.TargetObject = 'StockIn' "
                + "ORDER BY l.LogDate DESC";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                SystemLog log = new SystemLog();
                log.setLogID(rs.getInt("LogID"));
                log.setUserID(rs.getInt("UserID"));
                log.setAction(rs.getString("Action"));
                log.setTargetObject(rs.getString("TargetObject"));
                log.setDescription(rs.getString("Description"));
                log.setLogDate(rs.getTimestamp("LogDate"));
                log.setIpAddress(rs.getString("IPAddress"));
                log.setName(rs.getString("FullName"));

                // 3. Resolve Product Name from Description
                String desc = log.getDescription();
                Integer pid = null;
                if (desc.contains("ID: ")) {
                    try {
                        String idStr = desc.substring(desc.indexOf("ID: ") + 4);
                        // Find first non-digit to end the ID
                        int end = 0;
                        while (end < idStr.length() && Character.isDigit(idStr.charAt(end))) {
                            end++;
                        }
                        if (end > 0) {
                            pid = Integer.parseInt(idStr.substring(0, end));
                        }
                    } catch (Exception e) {
                    }
                }

                if (pid != null) {
                    log.setProductName(productMap.get(pid));
                }

                list.add(log);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
