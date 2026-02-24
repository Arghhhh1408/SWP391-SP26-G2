
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
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
}
