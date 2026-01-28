package model;

import java.math.BigDecimal;

public class StockInDetails {
    private int detailID;
    private int stockInID;
    private int productID;
    private int quantity;
    private BigDecimal unitCost;

    public StockInDetails() {
    }

    public StockInDetails(int detailID, int stockInID, int productID, int quantity, BigDecimal unitCost) {
        this.detailID = detailID;
        this.stockInID = stockInID;
        this.productID = productID;
        this.quantity = quantity;
        this.unitCost = unitCost;
    }

    public int getDetailID() {
        return detailID;
    }

    public void setDetailID(int detailID) {
        this.detailID = detailID;
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

    public BigDecimal getUnitCost() {
        return unitCost;
    }

    public void setUnitCost(BigDecimal unitCost) {
        this.unitCost = unitCost;
    }

    public BigDecimal getSubTotal() {
        return unitCost.multiply(new BigDecimal(quantity));
    }

    @Override
    public String toString() {
        return "StockInDetails{" + "detailID=" + detailID + ", stockInID=" + stockInID + ", productID=" + productID + ", quantity=" + quantity + ", unitCost=" + unitCost + '}';
    }
}
