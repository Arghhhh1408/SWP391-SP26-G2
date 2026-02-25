package model;

import java.sql.Timestamp;

public class OrderHistory {

    private int stockOutId;
    private Timestamp date;
    private String customerName;
    private String customerPhone;
    private double totalAmount;
    private String createdByName;
    private String note;

   
    
    public int getStockOutId() {
        return stockOutId;
    }

    public void setStockOutId(int stockOutId) {
    // Thêm dòng này vào để kiểm tra xem hàm này có thực sự chạy không
    System.out.println("--> Đang set ID vào object: " + stockOutId); 
    
    this.stockOutId = stockOutId;
}

    public Timestamp getDate() {
        return date;
    }

    public void setDate(Timestamp date) {
        this.date = date;
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

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    
    public static class OrderRow {
        public int stockOutId;
        public String createdAt;
        public String customerName;
        public String customerPhone;
        public double totalAmount;
        public String note;
        public String createdBy; // username (nếu join User)
    }

    public static class OrderItemRow {
        public int productId;
        public String sku;
        public String name;
        public double price;
        public int quantity;
        public double lineTotal;
    }

    
}
