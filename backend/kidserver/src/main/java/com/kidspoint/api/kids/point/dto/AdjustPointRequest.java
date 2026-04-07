package com.kidspoint.api.kids.point.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public class AdjustPointRequest {

    @NotNull(message = "Family ID is required")
    private UUID familyId;

    @NotNull(message = "Target user ID is required")
    private UUID targetUserId;

    @NotNull(message = "Amount is required")
    private Integer amount;

    @NotNull(message = "isEarn is required")
    private Boolean isEarn;

    @Size(max = 500, message = "Reason must be less than 500 characters")
    private String reason;

    public UUID getFamilyId() {
        return familyId;
    }

    public void setFamilyId(UUID familyId) {
        this.familyId = familyId;
    }

    public UUID getTargetUserId() {
        return targetUserId;
    }

    public void setTargetUserId(UUID targetUserId) {
        this.targetUserId = targetUserId;
    }

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }

    public Boolean getIsEarn() {
        return isEarn;
    }

    public void setIsEarn(Boolean earn) {
        isEarn = earn;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}

