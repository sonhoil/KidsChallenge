package com.kidspoint.api.organization.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public class JoinByBoxQrRequest {
    @NotNull(message = "Box ID is required")
    private UUID boxId;

    public UUID getBoxId() {
        return boxId;
    }

    public void setBoxId(UUID boxId) {
        this.boxId = boxId;
    }
}
