package model;

public class Customer {
    private int customerID;
    private String name;
    private String phone;
    private String address;
    private String email;

    public Customer() {
    }

    public Customer(int customerID, String name, String phone, String address, String email) {
        this.customerID = customerID;
        this.name = name;
        this.phone = phone;
        this.address = address;
        this.email = email;
    }

    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
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

    @Override
    public String toString() {
        return "Customer{" + "customerID=" + customerID + ", name=" + name + ", phone=" + phone + '}';
    }
}
