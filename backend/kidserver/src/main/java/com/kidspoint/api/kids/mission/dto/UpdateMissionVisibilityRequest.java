package com.kidspoint.api.kids.mission.dto;

import jakarta.validation.constraints.NotNull;

public class UpdateMissionVisibilityRequest {
    @NotNull(message = "isActive is required")
    private Boolean isActive;

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
}
