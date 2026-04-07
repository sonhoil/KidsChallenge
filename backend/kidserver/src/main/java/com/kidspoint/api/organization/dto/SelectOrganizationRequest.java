package com.kidspoint.api.organization.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public class SelectOrganizationRequest {
    @NotNull(message = "Organization ID is required")
    private UUID organizationId;

    // Getters and Setters
    public UUID getOrganizationId() {
        return organizationId;
    }

    public void setOrganizationId(UUID organizationId) {
        this.organizationId = organizationId;
    }
}
