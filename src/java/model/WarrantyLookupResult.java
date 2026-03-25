package model;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

public class WarrantyLookupResult {
    public static final int STANDARD_WARRANTY_MONTHS = 12;
    private static final DateTimeFormatter DATE_VI = DateTimeFormatter.ofPattern("d/M/yyyy");

    private final String lookupType;
    private final String query;
    private final int stockOutId;
    private final Integer customerId;
    private final int detailId;

    private final String productCode;
    private final String productName;
    private final String serialNumber;
    private final String imageUrl;
    private final int quantity;
    /** Đơn giá bán trên dòng phiếu xuất (StockOutDetails.UnitPrice). */
    private final double unitPrice;
    private final String customerEmail;

    private final String customerName;
    private final String customerPhone;

    private final LocalDate purchaseDate;
    private final int warrantyMonths;
    private final LocalDate warrantyEndDate;
    /** Chuỗi tiếng Việt dùng logic cũ: Còn bảo hành / Hết bảo hành */
    private final String status;
    /** PROCESSING | EXPIRED | EXPIRING_SOON | ACTIVE */
    private final String uiStatus;

    public WarrantyLookupResult(
            String lookupType,
            String query,
            int stockOutId,
            Integer customerId,
            int detailId,
            String productCode,
            String productName,
            String serialNumber,
            String imageUrl,
            int quantity,
            double unitPrice,
            String customerEmail,
            String customerName,
            String customerPhone,
            LocalDate purchaseDate,
            int warrantyMonths,
            LocalDate warrantyEndDate,
            String status,
            String uiStatus
    ) {
        this.lookupType = lookupType;
        this.query = query;
        this.stockOutId = stockOutId;
        this.customerId = customerId;
        this.detailId = detailId;
        this.productCode = productCode;
        this.productName = productName;
        this.serialNumber = serialNumber;
        this.imageUrl = imageUrl;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.customerEmail = customerEmail;
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.purchaseDate = purchaseDate;
        this.warrantyMonths = warrantyMonths;
        this.warrantyEndDate = warrantyEndDate;
        this.status = status;
        this.uiStatus = uiStatus != null ? uiStatus : deriveUiStatus(false, warrantyEndDate);
    }

    private static String deriveUiStatus(boolean hasOpenClaim, LocalDate warrantyEndDate) {
        if (hasOpenClaim) {
            return "PROCESSING";
        }
        LocalDate today = LocalDate.now();
        if (warrantyEndDate == null) {
            return "EXPIRED";
        }
        if (warrantyEndDate.isBefore(today)) {
            return "EXPIRED";
        }
        long daysLeft = ChronoUnit.DAYS.between(today, warrantyEndDate);
        if (daysLeft <= 30) {
            return "EXPIRING_SOON";
        }
        return "ACTIVE";
    }

    public static String computeUiStatus(boolean hasOpenClaim, LocalDate warrantyEndDate) {
        return deriveUiStatus(hasOpenClaim, warrantyEndDate);
    }

    public int getDetailId() {
        return detailId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public int getQuantity() {
        return quantity;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    /** Thành tiền dòng bán (đơn giá × SL) — dùng làm số tiền hoàn tham chiếu khi trả hàng. */
    public double getLineSaleTotal() {
        return unitPrice * quantity;
    }

    public String getCustomerEmail() {
        return customerEmail == null ? "" : customerEmail;
    }

    public String getUiStatus() {
        return uiStatus;
    }

    public String getLookupType() {
        return lookupType;
    }

    public String getQuery() {
        return query;
    }

    public int getStockOutId() {
        return stockOutId;
    }

    public Integer getCustomerId() {
        return customerId;
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

    public String getPurchaseDateVi() {
        return purchaseDate == null ? "" : purchaseDate.format(DATE_VI);
    }

    public String getWarrantyEndDateVi() {
        return warrantyEndDate == null ? "" : warrantyEndDate.format(DATE_VI);
    }

    public String getStatus() {
        return status;
    }

    public boolean isInWarranty() {
        return "Còn bảo hành".equals(status);
    }

    /** Trả hàng chỉ trong 7 ngày kể từ ngày mua (khác chính sách bảo hành 12 tháng). */
    public boolean isReturnEligible() {
        return ReturnLookupResult.isPurchaseWithinReturnWindow(purchaseDate);
    }
}
