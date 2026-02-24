package model;

import java.math.BigDecimal;

public class StockOutDetails {
    private int detailID;
    private int stockOutID;
    private int productID;
    private int quantity;
    private BigDecimal unitPrice;

    public StockOutDetails() {
    }

    public StockOutDetails(int detailID, int stockOutID, int productID, int quantity, BigDecimal unitPrice) {
        this.detailID = detailID;
        this.stockOutID = stockOutID;
        this.productID = productID;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    public int getDetailID() {
        return detailID;
    }

    public void setDetailID(int detailID) {
        this.detailID = detailID;
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

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public BigDecimal getSubTotal() {
        return unitPrice.multiply(new BigDecimal(quantity));
    }

    @Override
    public String toString() {
        return "StockOutDetails{" + "detailID=" + detailID + ", stockOutID=" + stockOutID + ", productID=" + productID + ", quantity=" + quantity + ", unitPrice=" + unitPrice + '}';
    }
}
