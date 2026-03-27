/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.util.Date;

/**
 *
 * @author minhtuan
 */
public class User {
    private int userID;
    private String username;
    private String passwordHash;
    private String fullName;
    private int roleID;
    private String email;
    private String phone;       
    private Date createDate;    
    private boolean isActive;

    public User() {} 

    public User(String username, String passwordHash, String fullName, int roleID, String email, String phone, boolean isActive) {
        this.username = username;
        this.passwordHash = passwordHash;
        this.fullName = fullName;
        this.roleID = roleID;
        this.email = email;
        this.phone = phone;
        this.isActive = isActive;
    }

    

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public int getRoleID() {
        return roleID;
    }

    public void setRoleID(int roleID) {
        this.roleID = roleID;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public Date getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    private int failedAttempts;
    private java.sql.Timestamp lockoutEnd;

    public int getFailedAttempts() {
        return failedAttempts;
    }

    public void setFailedAttempts(int failedAttempts) {
        this.failedAttempts = failedAttempts;
    }

    public java.sql.Timestamp getLockoutEnd() {
        return lockoutEnd;
    }

    public void setLockoutEnd(java.sql.Timestamp lockoutEnd) {
        this.lockoutEnd = lockoutEnd;
    }
}
