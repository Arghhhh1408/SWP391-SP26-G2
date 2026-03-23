package model;

import java.time.LocalDate;

public class ReturnLookupResult {
    private final String productCode;
    private final String productName;
    private final String customerName;
    private final String customerPhone;
    private final LocalDate purchaseDate;

    public ReturnLookupResult(
            String productCode,
            String productName,
            String customerName,
            String customerPhone,
            LocalDate purchaseDate
    ) {
        this.productCode = productCode;
        this.productName = productName;
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.purchaseDate = purchaseDate;
    }

    public String getProductCode() {
        return productCode;
    }

    public String getProductName() {
        return productName;
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
}

