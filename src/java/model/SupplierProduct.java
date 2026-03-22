/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author dotha
 */
public class SupplierProduct {

    private int supplierProductID;
    private int supplierID;
    private int productID;
    private double supplyPrice;
    private boolean active;

    private String supplierName;
    private String productName;

    public SupplierProduct() {
    }

    public int getSupplierProductID() {
        return supplierProductID;
    }

    public void setSupplierProductID(int supplierProductID) {
        this.supplierProductID = supplierProductID;
    }

    public int getSupplierID() {
        return supplierID;
    }

    public void setSupplierID(int supplierID) {
        this.supplierID = supplierID;
    }

    public int getProductID() {
        return productID;
    }

    public void setProductID(int productID) {
        this.productID = productID;
    }

    public double getSupplyPrice() {
        return supplyPrice;
    }

    public void setSupplyPrice(double supplyPrice) {
        this.supplyPrice = supplyPrice;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }
}
