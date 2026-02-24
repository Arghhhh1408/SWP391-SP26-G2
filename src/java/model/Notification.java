package model;

import java.sql.Timestamp;

public class Notification {
    private int notificationID;
    private int userID;
    private String title;
    private String message;
    private boolean isRead;
    private Timestamp createdAt;
    private String type;  // Info, Warning, Success

    public Notification() {
    }

    public Notification(int notificationID, int userID, String title, String message, boolean isRead, Timestamp createdAt, String type) {
        this.notificationID = notificationID;
        this.userID = userID;
        this.title = title;
        this.message = message;
        this.isRead = isRead;
        this.createdAt = createdAt;
        this.type = type;
    }

    public int getNotificationID() {
        return notificationID;
    }

    public void setNotificationID(int notificationID) {
        this.notificationID = notificationID;
    }

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public boolean isIsRead() {
        return isRead;
    }

    public void setIsRead(boolean isRead) {
        this.isRead = isRead;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    @Override
    public String toString() {
        return "Notification{" + "notificationID=" + notificationID + ", userID=" + userID + ", title=" + title + ", isRead=" + isRead + ", type=" + type + '}';
    }
}
