package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class CustomerReturn {
    private int returnID;
    private int stockOutID;
    private int productID;
    private int quantity;
    private String reason;
    private Timestamp date;
    private BigDecimal refundAmount;  // Nullable

    public CustomerReturn() {
    }

    public CustomerReturn(int returnID, int stockOutID, int productID, int quantity, String reason, Timestamp date, BigDecimal refundAmount) {
        this.returnID = returnID;
        this.stockOutID = stockOutID;
        this.productID = productID;
        this.quantity = quantity;
        this.reason = reason;
        this.date = date;
        this.refundAmount = refundAmount;
    }

    public int getReturnID() {
        return returnID;
    }

    public void setReturnID(int returnID) {
        this.returnID = returnID;
    }

    public int getStockOutID() {
        return stockOutID;
    }

    public void setStockOutID(int stockOutID) {
        this.stockOutID = stockOutID;
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

    public BigDecimal getRefundAmount() {
        return refundAmount;
    }

    public void setRefundAmount(BigDecimal refundAmount) {
        this.refundAmount = refundAmount;
    }

    @Override
    public String toString() {
        return "CustomerReturn{" + "returnID=" + returnID + ", stockOutID=" + stockOutID + ", productID=" + productID + ", quantity=" + quantity + ", reason=" + reason + '}';
    }
}
