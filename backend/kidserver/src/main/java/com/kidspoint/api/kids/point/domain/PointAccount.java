package com.kidspoint.api.kids.point.domain;

import java.time.Instant;
import java.util.UUID;

public class PointAccount {
    private UUID id;
    private UUID familyId;
    private UUID userId;
    private Integer balance;
    private Instant createdAt;
    private Instant updatedAt;

    public PointAccount() {
    }

    public PointAccount(UUID id, UUID familyId, UUID userId, Integer balance) {
        this.id = id;
        this.familyId = familyId;
        this.userId = userId;
        this.balance = balance;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
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

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }
}
