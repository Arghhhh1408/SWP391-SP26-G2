package model;

public class Product {
    private int id;
    private String name;
    private String sku;
    private double cost;
    private double price;
    private int stockQuantity;
    private String unit;
    private String description;
    private String imageURL;
    private int warrantyPeriod;
    private String status;
    private int categoryId;
    private java.sql.Timestamp createDate;
    private java.sql.Timestamp updateDate;

    public Product() {
    }

    public Product(int id, String name, String sku, double cost, double price, int stockQuantity, String unit,
            String description, String imageURL, int warrantyPeriod, String status, int categoryId, 
            java.sql.Timestamp createDate, java.sql.Timestamp updateDate) {
        this.id = id;
        this.name = name;
        this.sku = sku;
        this.cost = cost;
        this.price = price;
        this.stockQuantity = stockQuantity;
        this.unit = unit;
        this.description = description;
        this.imageURL = imageURL;
        this.warrantyPeriod = warrantyPeriod;
        this.status = status;
        this.categoryId = categoryId;
        this.createDate = createDate;
        this.updateDate = updateDate;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public double getCost() {
        return cost;
    }

    public void setCost(double cost) {
        this.cost = cost;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public int getWarrantyPeriod() {
        return warrantyPeriod;
    }

    public void setWarrantyPeriod(int warrantyPeriod) {
        this.warrantyPeriod = warrantyPeriod;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public java.sql.Timestamp getCreateDate() {
        return createDate;
    }

    public void setCreateDate(java.sql.Timestamp createDate) {
        this.createDate = createDate;
    }

    public java.sql.Timestamp getUpdateDate() {
        return updateDate;
    }

    public void setUpdateDate(java.sql.Timestamp updateDate) {
        this.updateDate = updateDate;
    }

    @Override
    public String toString() {
        return "Product{" + "id=" + id + ", name=" + name + ", sku=" + sku + ", price=" + price + '}';
    }
}
