package model;

import java.time.LocalDate;

public class WarrantyLookupResult {
    private final String lookupType;
    private final String query;

    private final String productCode;
    private final String productName;
    private final String serialNumber;

    private final String customerName;
    private final String customerPhone;

    private final LocalDate purchaseDate;
    private final int warrantyMonths;
    private final LocalDate warrantyEndDate;
    private final String status;

    public WarrantyLookupResult(
            String lookupType,
            String query,
            String productCode,
            String productName,
            String serialNumber,
            String customerName,
            String customerPhone,
            LocalDate purchaseDate,
            int warrantyMonths,
            LocalDate warrantyEndDate,
            String status
    ) {
        this.lookupType = lookupType;
        this.query = query;
        this.productCode = productCode;
        this.productName = productName;
        this.serialNumber = serialNumber;
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.purchaseDate = purchaseDate;
        this.warrantyMonths = warrantyMonths;
        this.warrantyEndDate = warrantyEndDate;
        this.status = status;
    }

    public String getLookupType() {
        return lookupType;
    }

    public String getQuery() {
        return query;
    }

    public String getProductCode() {
        return productCode;
    }

    public String getProductName() {
        return productName;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public String getCustomerName() {
        return customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public LocalDate getPurchaseDate() {
        return purchaseDate;
    }

    public int getWarrantyMonths() {
        return warrantyMonths;
    }

    public LocalDate getWarrantyEndDate() {
        return warrantyEndDate;
    }

    public String getStatus() {
        return status;
    }
}
