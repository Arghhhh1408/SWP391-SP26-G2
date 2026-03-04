package model;

import java.time.LocalDateTime;

public class WarrantyEvent {
    private final LocalDateTime time;
    private final String action;
    private final String description;

    public WarrantyEvent(LocalDateTime time, String action, String description) {
        this.time = time;
        this.action = action;
        this.description = description;
    }

    public LocalDateTime getTime() {
        return time;
    }

    public String getAction() {
        return action;
    }

    public String getDescription() {
        return description;
    }
}
