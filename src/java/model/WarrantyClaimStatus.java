package model;

public enum WarrantyClaimStatus {
    NEW,
    RECEIVED,
    IN_REPAIR,
    APPROVED,
    REJECTED,
    COMPLETED,
    CANCELLED;

    /** Nhãn hiển thị trên giao diện (Sales / quản lý). */
    public String getLabelVi() {
        return switch (this) {
            case NEW -> "Đang xử lý";
            case RECEIVED -> "Đã tiếp nhận";
            case IN_REPAIR -> "Đang sửa chữa";
            case APPROVED -> "Đã duyệt";
            case REJECTED -> "Từ chối";
            case COMPLETED -> "Hoàn thành";
            case CANCELLED -> "Đã hủy";
        };
    }
}

