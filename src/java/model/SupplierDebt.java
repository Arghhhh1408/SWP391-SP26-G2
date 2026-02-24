package model;

import java.math.BigDecimal;
import java.sql.Date;

public class SupplierDebt {
    private int debtID;
    private int supplierID;
    private int stockInID;
    private BigDecimal amount;
    private Date dueDate;  // Nullable
    private String status;  // Pending, Paid

    public SupplierDebt() {
    }

    public SupplierDebt(int debtID, int supplierID, int stockInID, BigDecimal amount, Date dueDate, String status) {
        this.debtID = debtID;
        this.supplierID = supplierID;
        this.stockInID = stockInID;
        this.amount = amount;
        this.dueDate = dueDate;
        this.status = status;
    }

    public int getDebtID() {
        return debtID;
    }

    public void setDebtID(int debtID) {
        this.debtID = debtID;
    }

    public int getSupplierID() {
        return supplierID;
    }

    public void setSupplierID(int supplierID) {
        this.supplierID = supplierID;
    }

    public int getStockInID() {
        return stockInID;
    }

    public void setStockInID(int stockInID) {
        this.stockInID = stockInID;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public Date getDueDate() {
        return dueDate;
    }

    public void setDueDate(Date dueDate) {
        this.dueDate = dueDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "SupplierDebt{" + "debtID=" + debtID + ", supplierID=" + supplierID + ", amount=" + amount + ", dueDate=" + dueDate + ", status=" + status + '}';
    }
}
