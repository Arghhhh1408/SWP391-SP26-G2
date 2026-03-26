package model;

import java.sql.Timestamp;

public class SupplierUpdateRequest {
    private int requestID;
    private int supplierID;
    private Integer requestedBy;
    private String pendingName;
    private String pendingPhone;
    private String pendingAddress;
    private String pendingEmail;
    private boolean pendingIsActive;
    private String requestToken;
    private String status;
    private Timestamp requestedAt;
    private Timestamp respondedAt;
    private String decisionNote;

    public int getRequestID() { return requestID; }
    public void setRequestID(int requestID) { this.requestID = requestID; }
    public int getSupplierID() { return supplierID; }
    public void setSupplierID(int supplierID) { this.supplierID = supplierID; }
    public Integer getRequestedBy() { return requestedBy; }
    public void setRequestedBy(Integer requestedBy) { this.requestedBy = requestedBy; }
    public String getPendingName() { return pendingName; }
    public void setPendingName(String pendingName) { this.pendingName = pendingName; }
    public String getPendingPhone() { return pendingPhone; }
    public void setPendingPhone(String pendingPhone) { this.pendingPhone = pendingPhone; }
    public String getPendingAddress() { return pendingAddress; }
    public void setPendingAddress(String pendingAddress) { this.pendingAddress = pendingAddress; }
    public String getPendingEmail() { return pendingEmail; }
    public void setPendingEmail(String pendingEmail) { this.pendingEmail = pendingEmail; }
    public boolean isPendingIsActive() { return pendingIsActive; }
    public void setPendingIsActive(boolean pendingIsActive) { this.pendingIsActive = pendingIsActive; }
    public String getRequestToken() { return requestToken; }
    public void setRequestToken(String requestToken) { this.requestToken = requestToken; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getRequestedAt() { return requestedAt; }
    public void setRequestedAt(Timestamp requestedAt) { this.requestedAt = requestedAt; }
    public Timestamp getRespondedAt() { return respondedAt; }
    public void setRespondedAt(Timestamp respondedAt) { this.respondedAt = respondedAt; }
    public String getDecisionNote() { return decisionNote; }
    public void setDecisionNote(String decisionNote) { this.decisionNote = decisionNote; }
}
