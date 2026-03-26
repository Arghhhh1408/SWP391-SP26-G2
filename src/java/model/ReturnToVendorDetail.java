package model;

public class ReturnToVendorDetail {

    private int rtvDetailID;
    private int rtvID;
    private int stockInDetailID;
    private int stockInID;
    private int productID;
    private int quantity;
    private double unitCost;
    private double lineTotal;
    private String reasonDetail;
    private String itemCondition;
    private String productName;
    private int availableQuantity;
    private int replacementReceivedQuantity;

    public int getRtvDetailID() { return rtvDetailID; }
    public void setRtvDetailID(int rtvDetailID) { this.rtvDetailID = rtvDetailID; }
    public int getRtvID() { return rtvID; }
    public void setRtvID(int rtvID) { this.rtvID = rtvID; }
    public int getStockInDetailID() { return stockInDetailID; }
    public void setStockInDetailID(int stockInDetailID) { this.stockInDetailID = stockInDetailID; }
    public int getStockInID() { return stockInID; }
    public void setStockInID(int stockInID) { this.stockInID = stockInID; }
    public int getProductID() { return productID; }
    public void setProductID(int productID) { this.productID = productID; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public double getUnitCost() { return unitCost; }
    public void setUnitCost(double unitCost) { this.unitCost = unitCost; }
    public double getLineTotal() { return lineTotal; }
    public void setLineTotal(double lineTotal) { this.lineTotal = lineTotal; }
    public String getReasonDetail() { return reasonDetail; }
    public void setReasonDetail(String reasonDetail) { this.reasonDetail = reasonDetail; }
    public String getItemCondition() { return itemCondition; }
    public void setItemCondition(String itemCondition) { this.itemCondition = itemCondition; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public int getAvailableQuantity() { return availableQuantity; }
    public void setAvailableQuantity(int availableQuantity) { this.availableQuantity = availableQuantity; }
    public int getReplacementReceivedQuantity() { return replacementReceivedQuantity; }
    public void setReplacementReceivedQuantity(int replacementReceivedQuantity) { this.replacementReceivedQuantity = replacementReceivedQuantity; }
    public int getReplacementRemainingQuantity() { return Math.max(0, quantity - replacementReceivedQuantity); }
}
