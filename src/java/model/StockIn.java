package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class StockIn {
    private int stockInID;
    private int supplierID;
    private Timestamp date;
    private BigDecimal totalAmount;
    private int createdBy;
    private String note;
    private String status;

    public StockIn() {
    }

    public StockIn(int stockInID, int supplierID, Timestamp date, BigDecimal totalAmount, int createdBy, String note, String status) {
        this.stockInID = stockInID;
        this.supplierID = supplierID;
        this.date = date;
        this.totalAmount = totalAmount;
        this.createdBy = createdBy;
        this.note = note;
        this.status = status;
    }

    public int getStockInID() {
        return stockInID;
    }

    public void setStockInID(int stockInID) {
        this.stockInID = stockInID;
    }

    public int getSupplierID() {
        return supplierID;
    }

    public void setSupplierID(int supplierID) {
        this.supplierID = supplierID;
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
        return "StockIn{" + "stockInID=" + stockInID + ", supplierID=" + supplierID + ", date=" + date + ", totalAmount=" + totalAmount + ", status=" + status + '}';
    }
}
