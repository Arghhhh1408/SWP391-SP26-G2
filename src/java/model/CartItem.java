package model;

public class CartItem {
    private int productId;
    private String sku;
    private String name;
    private double price;
    private int qty;
    private String unit;
private int stockQuantity;
private int productTotalStock;   // Tổng tồn kho hiện tại
private int minStockThreshold;   // Ngưỡng kho thấp (lowStockThreshold)

    public int getProductTotalStock() {
        return productTotalStock;
    }

    public void setProductTotalStock(int productTotalStock) {
        this.productTotalStock = productTotalStock;
    }

    public int getMinStockThreshold() {
        return minStockThreshold;
    }

    public void setMinStockThreshold(int minStockThreshold) {
        this.minStockThreshold = minStockThreshold;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }
    public double getLineTotal() {
        return price * qty;
    }

    // getters/setters
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getQty() { return qty; }
    public void setQty(int qty) { this.qty = qty; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
}
