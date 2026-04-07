package com.kidspoint.api.item.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public class MoveItemRequest {
    @NotNull(message = "Target box ID is required")
    private UUID targetBoxId;

    public UUID getTargetBoxId() {
        return targetBoxId;
    }

    public void setTargetBoxId(UUID targetBoxId) {
        this.targetBoxId = targetBoxId;
    }
}
