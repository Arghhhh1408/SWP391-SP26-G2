package model;

import java.sql.Timestamp;

public class WarrantyTicket {
    private int ticketID;
    private int stockOutID;
    private int productID;
    private int customerID;
    private Timestamp receiveDate;
    private Timestamp returnDate;
    private String issueDescription;
    private String solution;
    private String status;  // Received, Processing, Done, Returned
    private int createdBy;

    public WarrantyTicket() {
    }

    public WarrantyTicket(int ticketID, int stockOutID, int productID, int customerID, Timestamp receiveDate, 
                          Timestamp returnDate, String issueDescription, String solution, String status, int createdBy) {
        this.ticketID = ticketID;
        this.stockOutID = stockOutID;
        this.productID = productID;
        this.customerID = customerID;
        this.receiveDate = receiveDate;
        this.returnDate = returnDate;
        this.issueDescription = issueDescription;
        this.solution = solution;
        this.status = status;
        this.createdBy = createdBy;
    }

    public int getTicketID() {
        return ticketID;
    }

    public void setTicketID(int ticketID) {
        this.ticketID = ticketID;
    }

    public int getStockOutID() {
        return stockOutID;
    }

    public void setStockOutID(int stockOutID) {
        this.stockOutID = stockOutID;
    }

    public int getProductID() {
        return productID;
    }

    public void setProductID(int productID) {
        this.productID = productID;
    }

    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public Timestamp getReceiveDate() {
        return receiveDate;
    }

    public void setReceiveDate(Timestamp receiveDate) {
        this.receiveDate = receiveDate;
    }

    public Timestamp getReturnDate() {
        return returnDate;
    }

    public void setReturnDate(Timestamp returnDate) {
        this.returnDate = returnDate;
    }

    public String getIssueDescription() {
        return issueDescription;
    }

    public void setIssueDescription(String issueDescription) {
        this.issueDescription = issueDescription;
    }

    public String getSolution() {
        return solution;
    }

    public void setSolution(String solution) {
        this.solution = solution;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    @Override
    public String toString() {
        return "WarrantyTicket{" + "ticketID=" + ticketID + ", productID=" + productID + ", customerID=" + customerID + ", status=" + status + '}';
    }
}
