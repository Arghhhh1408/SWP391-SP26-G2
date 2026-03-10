package model;

import java.time.LocalDate;

public class DailySales {
    private LocalDate day;
    private int orders;
    private double revenue;

    public DailySales() {
    }

    public DailySales(LocalDate day, int orders, double revenue) {
        this.day = day;
        this.orders = orders;
        this.revenue = revenue;
    }

    public LocalDate getDay() {
        return day;
    }

    public void setDay(LocalDate day) {
        this.day = day;
    }

    public int getOrders() {
        return orders;
    }

    public void setOrders(int orders) {
        this.orders = orders;
    }

    public double getRevenue() {
        return revenue;
    }

    public void setRevenue(double revenue) {
        this.revenue = revenue;
    }
}

