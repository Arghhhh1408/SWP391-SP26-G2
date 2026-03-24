package model;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

/**
 * Một dòng hàng đã bán (StockOut + Detail) phục vụ tra cứu trả hàng.
 */
public class ReturnLookupResult {

    /** Số ngày tối đa kể từ ngày mua để còn được trả hàng (0 = ngày mua, 7 = đủ 7 ngày sau ngày mua). */
    public static final int RETURN_WINDOW_DAYS = 7;

    private static final DateTimeFormatter DATE_VI = DateTimeFormatter.ofPattern("d/M/yyyy");

    public static boolean isPurchaseWithinReturnWindow(LocalDate purchaseDate) {
        if (purchaseDate == null) {
            return false;
        }
        long days = ChronoUnit.DAYS.between(purchaseDate, LocalDate.now());
        return days >= 0 && days <= RETURN_WINDOW_DAYS;
    }

    private final int stockOutId;
    private final int detailId;
    private final String productCode;
    private final String productName;
    private final String customerName;
    private final String customerPhone;
    private final String customerEmail;
    private final String serialNumber;
    private final String imageUrl;
    private final int quantity;
    private final LocalDate purchaseDate;
    private final double unitPrice;

    public ReturnLookupResult(
            int stockOutId,
            int detailId,
            String productCode,
            String productName,
            String customerName,
            String customerPhone,
            String customerEmail,
            String serialNumber,
            String imageUrl,
            int quantity,
            LocalDate purchaseDate,
            double unitPrice
    ) {
        this.stockOutId = stockOutId;
        this.detailId = detailId;
        this.productCode = productCode;
        this.productName = productName;
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.customerEmail = customerEmail;
        this.serialNumber = serialNumber;
        this.imageUrl = imageUrl;
        this.quantity = quantity;
        this.purchaseDate = purchaseDate;
        this.unitPrice = unitPrice;
    }

    public int getStockOutId() {
        return stockOutId;
    }

    public int getDetailId() {
        return detailId;
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

    public String getCustomerEmail() {
        return customerEmail;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public int getQuantity() {
        return quantity;
    }

    public LocalDate getPurchaseDate() {
        return purchaseDate;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public String getPurchaseDateVi() {
        return purchaseDate == null ? "" : purchaseDate.format(DATE_VI);
    }

    /** Còn trong cửa sổ trả hàng 7 ngày kể từ ngày mua (theo dòng phiếu xuất này). */
    public boolean isReturnEligible() {
        return isPurchaseWithinReturnWindow(purchaseDate);
    }
}
