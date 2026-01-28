package model;

import java.sql.Timestamp;

public class ProductHistory {
    private int historyID;
    private int productID;
    private String transactionType;  // IN, OUT, ADJUST, RETURN
    private int quantity;  // Can be positive or negative
    private Timestamp date;
    private Integer referenceID;  // Nullable - links to StockIn/StockOut ID

    public ProductHistory() {
    }

    public ProductHistory(int historyID, int productID, String transactionType, int quantity, Timestamp date, Integer referenceID) {
        this.historyID = historyID;
        this.productID = productID;
        this.transactionType = transactionType;
        this.quantity = quantity;
        this.date = date;
        this.referenceID = referenceID;
    }

    public int getHistoryID() {
        return historyID;
    }

    public void setHistoryID(int historyID) {
        this.historyID = historyID;
    }

    public int getProductID() {
        return productID;
    }

    public void setProductID(int productID) {
        this.productID = productID;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Timestamp getDate() {
        return date;
    }

    public void setDate(Timestamp date) {
        this.date = date;
    }

    public Integer getReferenceID() {
        return referenceID;
    }

    public void setReferenceID(Integer referenceID) {
        this.referenceID = referenceID;
    }

    @Override
    public String toString() {
        return "ProductHistory{" + "historyID=" + historyID + ", productID=" + productID + ", transactionType=" + transactionType + ", quantity=" + quantity + ", date=" + date + '}';
    }
}
