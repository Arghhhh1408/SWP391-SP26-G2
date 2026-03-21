package model;

import java.util.Date;
import java.util.List;

public class StockIn {

    public static final String STOCK_STATUS_PENDING = "Pending";
    public static final String STOCK_STATUS_COMPLETED = "Completed";
    public static final String STOCK_STATUS_CANCELLED = "Cancelled";

    public static final String PAYMENT_STATUS_UNPAID = "Unpaid";
    public static final String PAYMENT_STATUS_PARTIAL = "Partial";
    public static final String PAYMENT_STATUS_PAID = "Paid";
    public static final String PAYMENT_STATUS_CANCELLED = "Cancelled";

    private int stockInId;
    private int supplierId;
    private String supplierName;
    private double totalAmount;
    private int createdBy;
    private String staffName;
    private Date date;
    private String note;

    private String stockStatus;
    private String paymentStatus;

    private List<StockInDetail> details;

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

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
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

    public List<StockInDetail> getDetails() {
        return details;
    }

    public void setDetails(List<StockInDetail> details) {
        this.details = details;
    }

    public int getTotalQuantity() {
        if (details == null) {
            return 0;
        }

        int total = 0;
        for (StockInDetail d : details) {
            total += d.getQuantity();
        }
        return total;
    }

    public double getTotalAmountCalculated() {
        if (totalAmount > 0) {
            return totalAmount;
        }
        if (details == null) {
            return 0;
        }

        double total = 0;
        for (StockInDetail d : details) {
            total += d.getQuantity() * d.getUnitCost();
        }
        return total;
    }
}
