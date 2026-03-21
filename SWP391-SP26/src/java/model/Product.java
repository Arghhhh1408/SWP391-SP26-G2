package model;

import java.sql.Timestamp;

public class Product {
    private int id;
    private String name;
    private String sku;
    private int warrantyPeriod;
    private double cost;
    private double price;
    private int quantity;
    private String unit;
    private String description;
    private String imageURL;
    private String status;
    private int categoryId;
    private Timestamp createDate;
    private Timestamp updateDate;
    
    public Product() {
    }

    public Product(int id, String name, String sku, double cost, double price, int quantity, String unit,
            String description, String imageURL, String status, int categoryId, Timestamp createDate,
            Timestamp updateDate) {
        this.id = id;
        this.name = name;
        this.sku = sku;
        this.cost = cost;
        this.price = price;
        this.quantity = quantity;
        this.unit = unit;
        this.description = description;
        this.imageURL = imageURL;
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

    public int getWarrantyPeriod() {
        return warrantyPeriod;
    }

    public void setWarrantyPeriod(int warrantyPeriod) {
        this.warrantyPeriod = warrantyPeriod;
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

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
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

    public Timestamp getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Timestamp createDate) {
        this.createDate = createDate;
    }

    public Timestamp getUpdateDate() {
        return updateDate;
    }

    public void setUpdateDate(Timestamp updateDate) {
        this.updateDate = updateDate;
    }

}
