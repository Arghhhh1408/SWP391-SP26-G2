package model;

public class Supplier {
    private int supplierID;
    private String name;
    private String phone;
    private String address;
    private String email;
    private boolean isActive;

    public Supplier() {
    }

    public Supplier(int supplierID, String name, String phone, String address, String email, boolean isActive) {
        this.supplierID = supplierID;
        this.name = name;
        this.phone = phone;
        this.address = address;
        this.email = email;
        this.isActive = isActive;
    }

    public int getSupplierID() {
        return supplierID;
    }

    public void setSupplierID(int supplierID) {
        this.supplierID = supplierID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    @Override
    public String toString() {
        return "Supplier{" + "supplierID=" + supplierID + ", name=" + name + ", phone=" + phone + ", isActive=" + isActive + '}';
    }
}
