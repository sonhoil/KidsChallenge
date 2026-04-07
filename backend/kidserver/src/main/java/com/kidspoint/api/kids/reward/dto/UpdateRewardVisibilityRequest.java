package com.kidspoint.api.kids.reward.dto;

import jakarta.validation.constraints.NotNull;

public class UpdateRewardVisibilityRequest {
    @NotNull(message = "isActive is required")
    private Boolean isActive;

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
}
