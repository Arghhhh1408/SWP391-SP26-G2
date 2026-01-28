package model;

import java.sql.Timestamp;

public class StockAdjustment {
    private int adjustmentID;
    private int productID;
    private int quantity;  // Can be negative
    private String reasonCode;  // DAMAGED, LOST, EXPIRED
    private Timestamp date;
    private int createdBy;
    private String status;

    public StockAdjustment() {
    }

    public StockAdjustment(int adjustmentID, int productID, int quantity, String reasonCode, Timestamp date, int createdBy, String status) {
        this.adjustmentID = adjustmentID;
        this.productID = productID;
        this.quantity = quantity;
        this.reasonCode = reasonCode;
        this.date = date;
        this.createdBy = createdBy;
        this.status = status;
    }

    public int getAdjustmentID() {
        return adjustmentID;
    }

    public void setAdjustmentID(int adjustmentID) {
        this.adjustmentID = adjustmentID;
    }

    public int getProductID() {
        return productID;
    }

    public void setProductID(int productID) {
        this.productID = productID;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getReasonCode() {
        return reasonCode;
    }

    public void setReasonCode(String reasonCode) {
        this.reasonCode = reasonCode;
    }

    public Timestamp getDate() {
        return date;
    }

    public void setDate(Timestamp date) {
        this.date = date;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "StockAdjustment{" + "adjustmentID=" + adjustmentID + ", productID=" + productID + ", quantity=" + quantity + ", reasonCode=" + reasonCode + ", status=" + status + '}';
    }
}
