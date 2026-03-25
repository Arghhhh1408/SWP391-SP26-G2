package model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class WarrantyClaim {
    private int id;
    private String claimCode;

    private String sku;
    private String productName;

    private String customerName;
    private String customerPhone;

    private String issueDescription;

    private WarrantyClaimStatus status;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private final List<WarrantyClaimEvent> events = new ArrayList<>();

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getClaimCode() {
        return claimCode;
    }

    public void setClaimCode(String claimCode) {
        this.claimCode = claimCode;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getIssueDescription() {
        return issueDescription;
    }

    public void setIssueDescription(String issueDescription) {
        this.issueDescription = issueDescription;
    }

    public WarrantyClaimStatus getStatus() {
        return status;
    }

    public void setStatus(WarrantyClaimStatus status) {
        this.status = status;
    }

    /** Trạng thái hiển thị cho người dùng (EL: statusLabelVi). */
    public String getStatusLabelVi() {
        return status != null ? status.getLabelVi() : "";
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<WarrantyClaimEvent> getEvents() {
        return events;
    }
}

