package model;

import java.sql.Timestamp;

public class SystemLog {
    private int logID;
    private int userID;
    private String action;
    private String targetObject;
    private String description;
    private Timestamp logDate;
    private String ipAddress;

    public SystemLog() {
    }

    public SystemLog(int logID, int userID, String action, String targetObject, String description, Timestamp logDate, String ipAddress) {
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

    public Timestamp getLogDate() {
        return logDate;
    }

    public void setLogDate(Timestamp logDate) {
        this.logDate = logDate;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    @Override
    public String toString() {
        return "SystemLog{" + "logID=" + logID + ", userID=" + userID + ", action=" + action + ", targetObject=" + targetObject + ", logDate=" + logDate + '}';
    }
}
