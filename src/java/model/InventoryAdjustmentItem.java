package model;

import java.math.BigDecimal;

/**
 * Một dòng trong phiếu điều chỉnh tồn kho
 */
public class InventoryAdjustmentItem {

    private int itemId;
    private int adjustmentId;
    private int productId;
    private String sku;
    private String productName;
    private String unit;
    private String imageUrl;
    private int oldQuantity;      // Tồn kho cũ (hệ thống)
    private int newQuantity;      // Số lượng thực tế nhập vào
    private int variance;         // newQuantity - oldQuantity
    private String reason;        // Lý do riêng cho dòng này
    private String itemNote;      // Ghi chú dòng
    private BigDecimal unitCost;  // Giá vốn để tính giá trị thay đổi

    public InventoryAdjustmentItem() {}

    // ---- Getters & Setters ----

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public int getAdjustmentId() { return adjustmentId; }
    public void setAdjustmentId(int adjustmentId) { this.adjustmentId = adjustmentId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public int getOldQuantity() { return oldQuantity; }
    public void setOldQuantity(int oldQuantity) { this.oldQuantity = oldQuantity; }

    public int getNewQuantity() { return newQuantity; }
    public void setNewQuantity(int newQuantity) { this.newQuantity = newQuantity; }

    public int getVariance() { return variance; }
    public void setVariance(int variance) { this.variance = variance; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getItemNote() { return itemNote; }
    public void setItemNote(String itemNote) { this.itemNote = itemNote; }

    public BigDecimal getUnitCost() { return unitCost; }
    public void setUnitCost(BigDecimal unitCost) { this.unitCost = unitCost; }
}
