/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author minhtuan
 */
public class SystemLog {
    private int logID;
    private int userID;
    private String action;
    private String targetObject;
    private String description;
    private java.sql.Timestamp logDate; // Using Timestamp for datetime
    private String ipAddress;

    public SystemLog() {
    }

    public SystemLog(int logID, int userID, String action, String targetObject, String description,
            java.sql.Timestamp logDate, String ipAddress) {
        this.logID = logID;
        this.userID = userID;
        this.action = action;
        this.targetObject = targetObject;
        this.description = description;
        this.logDate = logDate;
        this.ipAddress = ipAddress;
    }

    public int getLogID() {
        return logID;
    }

    public void setLogID(int logID) {
        this.logID = logID;
    }

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getTargetObject() {
        return targetObject;
    }

    public void setTargetObject(String targetObject) {
        this.targetObject = targetObject;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public java.sql.Timestamp getLogDate() {
        return logDate;
    }

    public void setLogDate(java.sql.Timestamp logDate) {
        this.logDate = logDate;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    private String name; // Transient field for Actor Name
    private String targetName; // Transient field for Target User Name
    private String productName; // Transient field for Product Name

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getTargetName() {
        return targetName;
    }

    public void setTargetName(String targetName) {
        this.targetName = targetName;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }
}
