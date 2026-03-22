/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author dotha
 */
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.SupplierDebt;
import utils.DBContext;

public class SupplierDebtDAO extends DBContext {

    public List<SupplierDebt> searchDebts(Integer supplierId, String status, Date fromDate, Date toDate) {
        List<SupplierDebt> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT d.DebtID, d.SupplierID, d.StockInID, d.Amount, d.DueDate, d.Status,
                   s.Name AS SupplierName
            FROM SupplierDebts d
            JOIN Suppliers s ON d.SupplierID = s.SupplierID
            WHERE 1 = 1
        """);

        if (supplierId != null) {
            sql.append(" AND d.SupplierID = ?");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND d.Status = ?");
        }
        if (fromDate != null) {
            sql.append(" AND d.DueDate >= ?");
        }
        if (toDate != null) {
            sql.append(" AND d.DueDate <= ?");
        }

        sql.append(" ORDER BY d.DebtID DESC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int index = 1;

            if (supplierId != null) {
                ps.setInt(index++, supplierId);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(index++, status);
            }
            if (fromDate != null) {
                ps.setDate(index++, fromDate);
            }
            if (toDate != null) {
                ps.setDate(index++, toDate);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SupplierDebt d = new SupplierDebt();
                    d.setDebtID(rs.getInt("DebtID"));
                    d.setSupplierID(rs.getInt("SupplierID"));
                    d.setStockInID(rs.getInt("StockInID"));
                    d.setAmount(rs.getDouble("Amount"));
                    d.setDueDate(rs.getDate("DueDate"));
                    d.setStatus(rs.getString("Status"));
                    d.setSupplierName(rs.getString("SupplierName"));
                    list.add(d);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
