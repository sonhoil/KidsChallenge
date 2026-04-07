package com.kidspoint.api.kids.point.dto;

import java.util.UUID;

public class PointBalanceResponse {
    private UUID familyId;
    private UUID userId;
    private Integer balance;

    public PointBalanceResponse() {
    }

    public PointBalanceResponse(UUID familyId, UUID userId, Integer balance) {
        this.familyId = familyId;
        this.userId = userId;
        this.balance = balance;
    }

    public UUID getFamilyId() {
        return familyId;
    }

    public void setFamilyId(UUID familyId) {
        this.familyId = familyId;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public Integer getBalance() {
        return balance;
    }

    public void setBalance(Integer balance) {
        this.balance = balance;
    }
}
