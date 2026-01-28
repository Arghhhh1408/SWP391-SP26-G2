package model;

import java.sql.Timestamp;

public class InventoryCount {
    private int countID;
    private int productID;
    private int physicalQuantity;
    private int systemQuantity;
    private Timestamp date;
    private Integer approvedBy;  // Nullable
    private String status;  // Pending, Approved

    public InventoryCount() {
    }

    public InventoryCount(int countID, int productID, int physicalQuantity, int systemQuantity, Timestamp date, Integer approvedBy, String status) {
        this.countID = countID;
        this.productID = productID;
        this.physicalQuantity = physicalQuantity;
        this.systemQuantity = systemQuantity;
        this.date = date;
        this.approvedBy = approvedBy;
        this.status = status;
    }

    public int getCountID() {
        return countID;
    }

    public void setCountID(int countID) {
        this.countID = countID;
    }

    public int getProductID() {
        return productID;
    }

    public void setProductID(int productID) {
        this.productID = productID;
    }

    public int getPhysicalQuantity() {
        return physicalQuantity;
    }

    public void setPhysicalQuantity(int physicalQuantity) {
        this.physicalQuantity = physicalQuantity;
    }

    public int getSystemQuantity() {
        return systemQuantity;
    }

    public void setSystemQuantity(int systemQuantity) {
        this.systemQuantity = systemQuantity;
    }

    public Timestamp getDate() {
        return date;
    }

    public void setDate(Timestamp date) {
        this.date = date;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getDiscrepancy() {
        return physicalQuantity - systemQuantity;
    }

    @Override
    public String toString() {
        return "InventoryCount{" + "countID=" + countID + ", productID=" + productID + ", physicalQuantity=" + physicalQuantity + ", systemQuantity=" + systemQuantity + ", status=" + status + '}';
    }
}
