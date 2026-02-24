package model;

import java.sql.Timestamp;

public class ReturnToVendor {
    private int rtvID;
    private int stockInID;
    private int productID;
    private int quantity;
    private String reason;
    private Timestamp date;

    public ReturnToVendor() {
    }

    public ReturnToVendor(int rtvID, int stockInID, int productID, int quantity, String reason, Timestamp date) {
        this.rtvID = rtvID;
        this.stockInID = stockInID;
        this.productID = productID;
        this.quantity = quantity;
        this.reason = reason;
        this.date = date;
    }

    public int getRtvID() {
        return rtvID;
    }

    public void setRtvID(int rtvID) {
        this.rtvID = rtvID;
    }

    public int getStockInID() {
        return stockInID;
    }

    public void setStockInID(int stockInID) {
        this.stockInID = stockInID;
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

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Timestamp getDate() {
        return date;
    }

    public void setDate(Timestamp date) {
        this.date = date;
    }

    @Override
    public String toString() {
        return "ReturnToVendor{" + "rtvID=" + rtvID + ", stockInID=" + stockInID + ", productID=" + productID + ", quantity=" + quantity + ", reason=" + reason + '}';
    }
}
