/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author dotha
 */
import java.sql.Timestamp;
import java.util.List;

public class ReturnToVendor {

    private int rtvID;
    private String returnCode;
    private int supplierID;
    private int createdBy;
    private Integer approvedBy;
    private Integer completedBy;
    private Timestamp createdDate;
    private Timestamp approvedDate;
    private Timestamp completedDate;
    private String status;
    private String reason;
    private String note;
    private double totalAmount;
    private String settlementType;
    private Integer relatedDebtID;
    private boolean inventoryAdjusted;
    private boolean financialAdjusted;

    private String supplierName;
    private String createdByName;
    private List<ReturnToVendorDetail> details;

    public int getRtvID() {
        return rtvID;
    }

    public void setRtvID(int rtvID) {
        this.rtvID = rtvID;
    }

    public String getReturnCode() {
        return returnCode;
    }

    public void setReturnCode(String returnCode) {
        this.returnCode = returnCode;
    }

    public int getSupplierID() {
        return supplierID;
    }

    public void setSupplierID(int supplierID) {
        this.supplierID = supplierID;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public Integer getCompletedBy() {
        return completedBy;
    }

    public void setCompletedBy(Integer completedBy) {
        this.completedBy = completedBy;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    public Timestamp getApprovedDate() {
        return approvedDate;
    }

    public void setApprovedDate(Timestamp approvedDate) {
        this.approvedDate = approvedDate;
    }

    public Timestamp getCompletedDate() {
        return completedDate;
    }

    public void setCompletedDate(Timestamp completedDate) {
        this.completedDate = completedDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getSettlementType() {
        return settlementType;
    }

    public void setSettlementType(String settlementType) {
        this.settlementType = settlementType;
    }

    public Integer getRelatedDebtID() {
        return relatedDebtID;
    }

    public void setRelatedDebtID(Integer relatedDebtID) {
        this.relatedDebtID = relatedDebtID;
    }

    public boolean isInventoryAdjusted() {
        return inventoryAdjusted;
    }

    public void setInventoryAdjusted(boolean inventoryAdjusted) {
        this.inventoryAdjusted = inventoryAdjusted;
    }

    public boolean isFinancialAdjusted() {
        return financialAdjusted;
    }

    public void setFinancialAdjusted(boolean financialAdjusted) {
        this.financialAdjusted = financialAdjusted;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public List<ReturnToVendorDetail> getDetails() {
        return details;
    }

    public void setDetails(List<ReturnToVendorDetail> details) {
        this.details = details;
    }
}
