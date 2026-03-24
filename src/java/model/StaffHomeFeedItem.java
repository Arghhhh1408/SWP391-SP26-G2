package model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Một dòng trên bảng tổng hợp bảo hành + đổi trả (dashboard staff).
 */
public class StaffHomeFeedItem {

    public static final String TYPE_WARRANTY = "WARRANTY";
    public static final String TYPE_RETURN = "RETURN";

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private String type;
    private int refId;
    private String code;
    private String productLine;
    private String customerLine;
    private String statusLabel;
    private LocalDateTime activityTime;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getRefId() {
        return refId;
    }

    public void setRefId(int refId) {
        this.refId = refId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getProductLine() {
        return productLine;
    }

    public void setProductLine(String productLine) {
        this.productLine = productLine;
    }

    public String getCustomerLine() {
        return customerLine;
    }

    public void setCustomerLine(String customerLine) {
        this.customerLine = customerLine;
    }

    public String getStatusLabel() {
        return statusLabel;
    }

    public void setStatusLabel(String statusLabel) {
        this.statusLabel = statusLabel;
    }

    public LocalDateTime getActivityTime() {
        return activityTime;
    }

    public void setActivityTime(LocalDateTime activityTime) {
        this.activityTime = activityTime;
    }

    public String getActivityTimeVi() {
        return activityTime == null ? "" : activityTime.format(FMT);
    }

    public boolean isWarranty() {
        return TYPE_WARRANTY.equals(type);
    }

    public boolean isReturn() {
        return TYPE_RETURN.equals(type);
    }

    public String getTypeLabelVi() {
        if (isWarranty()) {
            return "Bảo hành";
        }
        if (isReturn()) {
            return "Đổi / trả hàng";
        }
        return "";
    }
}
