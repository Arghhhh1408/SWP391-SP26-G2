/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author dotha
 */

import java.sql.Date;

public class InventoryCheckItem {

    private int countId;
    private int productId;
    private String sku;
    private String productName;
    private String unit;
    private int systemQuantity;
    private Integer physicalQuantity;
    private int variance;
    private String status;
    private Integer approvedBy;
    private Date date;

    public InventoryCheckItem() {
    }

    public InventoryCheckItem(int countId, int productId, String sku, String productName, String unit,
            int systemQuantity, Integer physicalQuantity, int variance,
            String status, Integer approvedBy, Date date) {
        this.countId = countId;
        this.productId = productId;
        this.sku = sku;
        this.productName = productName;
        this.unit = unit;
        this.systemQuantity = systemQuantity;
        this.physicalQuantity = physicalQuantity;
        this.variance = variance;
        this.status = status;
        this.approvedBy = approvedBy;
        this.date = date;
    }

    public int getCountId() {
        return countId;
    }

    public void setCountId(int countId) {
        this.countId = countId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
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

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public int getSystemQuantity() {
        return systemQuantity;
    }

    public void setSystemQuantity(int systemQuantity) {
        this.systemQuantity = systemQuantity;
    }

    public Integer getPhysicalQuantity() {
        return physicalQuantity;
    }

    public void setPhysicalQuantity(Integer physicalQuantity) {
        this.physicalQuantity = physicalQuantity;
    }

    public int getVariance() {
        return variance;
    }

    public void setVariance(int variance) {
        this.variance = variance;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }
}
