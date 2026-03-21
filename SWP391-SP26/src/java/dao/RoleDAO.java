/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.util.ArrayList;
import java.util.List;
import utils.DBContext;
import java.sql.*;
import model.Role;

/**
 *
 * @author minhtuan
 */
public class RoleDAO extends DBContext {

    public List<Role> getAllRole() {
        List<Role> list = new ArrayList();
        String sql = "SELECT *\n"
                + "FROM Role\n"
                + "WHERE RoleID BETWEEN 1 AND 4";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while(rs.next()){
                Role r = new Role(rs.getInt("RoleID"),
                rs.getString("RoleName"));
                
                list.add(r);
            }
            return list;
        } catch (Exception e) {
        }
        return null;
    }
    
    public String getRoleNameByID(int id){
       String sql = "select RoleName from Role where RoleID = ?";
        try {
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            while(rs.next()){
                return rs.getString("RoleName");
            }
        } catch (Exception e) {
        }
        return null;
    }
}
