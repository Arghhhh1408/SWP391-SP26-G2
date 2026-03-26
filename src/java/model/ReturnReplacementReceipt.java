package model;

import java.sql.Timestamp;

public class ReturnReplacementReceipt {
    private int receiptID;
    private int rtvID;
    private int rtvDetailID;
    private int quantity;
    private String note;
    private int receivedBy;
    private String receivedByName;
    private Timestamp receivedAt;
    private String productName;

    public int getReceiptID() { return receiptID; }
    public void setReceiptID(int receiptID) { this.receiptID = receiptID; }
    public int getRtvID() { return rtvID; }
    public void setRtvID(int rtvID) { this.rtvID = rtvID; }
    public int getRtvDetailID() { return rtvDetailID; }
    public void setRtvDetailID(int rtvDetailID) { this.rtvDetailID = rtvDetailID; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public int getReceivedBy() { return receivedBy; }
    public void setReceivedBy(int receivedBy) { this.receivedBy = receivedBy; }
    public String getReceivedByName() { return receivedByName; }
    public void setReceivedByName(String receivedByName) { this.receivedByName = receivedByName; }
    public Timestamp getReceivedAt() { return receivedAt; }
    public void setReceivedAt(Timestamp receivedAt) { this.receivedAt = receivedAt; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
}
