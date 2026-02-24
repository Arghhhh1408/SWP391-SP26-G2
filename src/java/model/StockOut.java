package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class StockOut {
    private int stockOutID;
    private Integer customerID;  // Nullable for walk-in customers
    private Timestamp date;
    private BigDecimal totalAmount;
    private int createdBy;
    private String note;
    private String status;

    public StockOut() {
    }

    public StockOut(int stockOutID, Integer customerID, Timestamp date, BigDecimal totalAmount, int createdBy, String note, String status) {
        this.stockOutID = stockOutID;
        this.customerID = customerID;
        this.date = date;
        this.totalAmount = totalAmount;
        this.createdBy = createdBy;
        this.note = note;
        this.status = status;
    }

    public int getStockOutID() {
        return stockOutID;
    }

    public void setStockOutID(int stockOutID) {
        this.stockOutID = stockOutID;
    }

    public Integer getCustomerID() {
        return customerID;
    }

    public void setCustomerID(Integer customerID) {
        this.customerID = customerID;
    }

    public Timestamp getDate() {
        return date;
    }

    public void setDate(Timestamp date) {
        this.date = date;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "StockOut{" + "stockOutID=" + stockOutID + ", customerID=" + customerID + ", date=" + date + ", totalAmount=" + totalAmount + ", status=" + status + '}';
    }
}
