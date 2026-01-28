package model;

public class LowStockAlert {
    private int alertID;
    private int productID;
    private int minStockLevel;
    private boolean notified;

    public LowStockAlert() {
    }

    public LowStockAlert(int alertID, int productID, int minStockLevel, boolean notified) {
        this.alertID = alertID;
        this.productID = productID;
        this.minStockLevel = minStockLevel;
        this.notified = notified;
    }

    public int getAlertID() {
        return alertID;
    }

    public void setAlertID(int alertID) {
        this.alertID = alertID;
    }

    public int getProductID() {
        return productID;
    }

    public void setProductID(int productID) {
        this.productID = productID;
    }

    public int getMinStockLevel() {
        return minStockLevel;
    }

    public void setMinStockLevel(int minStockLevel) {
        this.minStockLevel = minStockLevel;
    }

    public boolean isNotified() {
        return notified;
    }

    public void setNotified(boolean notified) {
        this.notified = notified;
    }

    @Override
    public String toString() {
        return "LowStockAlert{" + "alertID=" + alertID + ", productID=" + productID + ", minStockLevel=" + minStockLevel + ", notified=" + notified + '}';
    }
}
