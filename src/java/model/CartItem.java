package model;

public class CartItem {
    private int productId;
    private String sku;
    private String name;
    private double price;
    private int qty;
    private String unit;
    private double lineTotal;
    
    public double getLineTotal() {
        return price * qty;
    }

    public void setLineTotal(double lineTotal) {
    this.lineTotal = lineTotal;
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
