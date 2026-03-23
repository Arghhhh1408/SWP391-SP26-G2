package model;

import java.sql.Timestamp;

public class DebtPayment {
    private int id;
    private int customerId;
    private double amount;
    private int staffId;
    private String note;
    private Timestamp paymentDate;
    
    // Thêm trường này để hiển thị tên nhân viên thay vì chỉ hiện ID số
    private String staffName; 

    public DebtPayment() {
    }

    public DebtPayment(int id, int customerId, double amount, int staffId, String note, Timestamp paymentDate) {
        this.id = id;
        this.customerId = customerId;
        this.amount = amount;
        this.staffId = staffId;
        this.note = note;
        this.paymentDate = paymentDate;
    }

    // Getter và Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public int getStaffId() {
        return staffId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Timestamp getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(Timestamp paymentDate) {
        this.paymentDate = paymentDate;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }
}