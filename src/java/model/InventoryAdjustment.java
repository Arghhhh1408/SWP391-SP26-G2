package model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

/**
 * Phiếu điều chỉnh tồn kho (Inventory Adjustment)
 */
public class InventoryAdjustment {

    private int adjustmentId;
    private String adjustmentCode;   // ADJ-2026-XXXX
    private String adjustmentDate;   // yyyy-MM-dd
    private String warehouse;        // Kho hàng
    private int createdBy;
    private String createdByName;
    private String generalReason;    // Lý do chung: Kiểm kê định kỳ, Hàng hỏng...
    private String note;             // Ghi chú tự do
    private String status;           // Draft / Confirmed
    private Timestamp createdAt;

    // Thống kê tổng hợp (tính từ items)
    private int totalProducts;
    private int totalIncrease;
    private int totalDecrease;
    private BigDecimal totalValueChange;

    // Danh sách dòng điều chỉnh
    private List<InventoryAdjustmentItem> items;

    public InventoryAdjustment() {}

    // ---- Getters & Setters ----

    public int getAdjustmentId() { return adjustmentId; }
    public void setAdjustmentId(int adjustmentId) { this.adjustmentId = adjustmentId; }

    public String getAdjustmentCode() { return adjustmentCode; }
    public void setAdjustmentCode(String adjustmentCode) { this.adjustmentCode = adjustmentCode; }

    public String getAdjustmentDate() { return adjustmentDate; }
    public void setAdjustmentDate(String adjustmentDate) { this.adjustmentDate = adjustmentDate; }

    public String getWarehouse() { return warehouse; }
    public void setWarehouse(String warehouse) { this.warehouse = warehouse; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    public String getGeneralReason() { return generalReason; }
    public void setGeneralReason(String generalReason) { this.generalReason = generalReason; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getTotalProducts() { return totalProducts; }
    public void setTotalProducts(int totalProducts) { this.totalProducts = totalProducts; }

    public int getTotalIncrease() { return totalIncrease; }
    public void setTotalIncrease(int totalIncrease) { this.totalIncrease = totalIncrease; }

    public int getTotalDecrease() { return totalDecrease; }
    public void setTotalDecrease(int totalDecrease) { this.totalDecrease = totalDecrease; }

    public BigDecimal getTotalValueChange() { return totalValueChange; }
    public void setTotalValueChange(BigDecimal totalValueChange) { this.totalValueChange = totalValueChange; }

    public List<InventoryAdjustmentItem> getItems() { return items; }
    public void setItems(List<InventoryAdjustmentItem> items) { this.items = items; }
}
