/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.util.Date;
import java.util.List;

public class StockIn {

    public static final String STOCK_STATUS_PENDING = "Pending";
    public static final String STOCK_STATUS_COMPLETED = "Completed";
    public static final String STOCK_STATUS_CANCEL_REQUESTED = "CancelRequested";
    public static final String STOCK_STATUS_CANCELLED = "Cancelled";

    public static final String PAYMENT_STATUS_UNPAID = "Unpaid";
    public static final String PAYMENT_STATUS_PARTIAL = "Partial";
    public static final String PAYMENT_STATUS_PAID = "Paid";
    public static final String PAYMENT_STATUS_CANCELLED = "Cancelled";

    private int stockInId;
    private int supplierId;
    private Date date;
    private double totalAmount;
    private double initialPaidAmount;
    private int createdBy;
    private String note;
    private String stockStatus;
    private String paymentStatus;
    private List<StockInDetail> details;

    private String cancelRequestNote;
    private Integer cancelRequestedBy;
    private Date cancelRequestedAt;
    private Integer cancelApprovedBy;
    private Date cancelApprovedAt;

    // view fields
    private String supplierName;
    private String staffName;
    private int totalOrderedQuantity;
    private int totalReceivedQuantity;
    private int totalRemainingQuantity;
    private double totalAmountCalculated;

    public StockIn() {
    }

    public int getStockInId() {
        return stockInId;
    }

    public void setStockInId(int stockInId) {
        this.stockInId = stockInId;
    }

    public int getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(int supplierId) {
        this.supplierId = supplierId;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public List<StockInDetail> getDetails() {
        return details;
    }

    public void setDetails(List<StockInDetail> details) {
        this.details = details;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public double getInitialPaidAmount() {
        return initialPaidAmount;
    }

    public void setInitialPaidAmount(double initialPaidAmount) {
        this.initialPaidAmount = initialPaidAmount;
    }
    
    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getStockStatus() {
        return stockStatus;
    }

    public void setStockStatus(String stockStatus) {
        this.stockStatus = stockStatus;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getCancelRequestNote() {
        return cancelRequestNote;
    }

    public void setCancelRequestNote(String cancelRequestNote) {
        this.cancelRequestNote = cancelRequestNote;
    }

    public Integer getCancelRequestedBy() {
        return cancelRequestedBy;
    }

    public void setCancelRequestedBy(Integer cancelRequestedBy) {
        this.cancelRequestedBy = cancelRequestedBy;
    }

    public Date getCancelRequestedAt() {
        return cancelRequestedAt;
    }

    public void setCancelRequestedAt(Date cancelRequestedAt) {
        this.cancelRequestedAt = cancelRequestedAt;
    }

    public Integer getCancelApprovedBy() {
        return cancelApprovedBy;
    }

    public void setCancelApprovedBy(Integer cancelApprovedBy) {
        this.cancelApprovedBy = cancelApprovedBy;
    }

    public Date getCancelApprovedAt() {
        return cancelApprovedAt;
    }

    public void setCancelApprovedAt(Date cancelApprovedAt) {
        this.cancelApprovedAt = cancelApprovedAt;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public int getTotalOrderedQuantity() {
        return totalOrderedQuantity;
    }

    public void setTotalOrderedQuantity(int totalOrderedQuantity) {
        this.totalOrderedQuantity = totalOrderedQuantity;
    }

    public int getTotalReceivedQuantity() {
        return totalReceivedQuantity;
    }

    public void setTotalReceivedQuantity(int totalReceivedQuantity) {
        this.totalReceivedQuantity = totalReceivedQuantity;
    }

    public int getTotalRemainingQuantity() {
        return totalRemainingQuantity;
    }

    public void setTotalRemainingQuantity(int totalRemainingQuantity) {
        this.totalRemainingQuantity = totalRemainingQuantity;
    }

    public double getTotalAmountCalculated() {
        return totalAmountCalculated;
    }

    public void setTotalAmountCalculated(double totalAmountCalculated) {
        this.totalAmountCalculated = totalAmountCalculated;
    }
}
