package com.kidspoint.api.kids.point.domain;

import java.time.Instant;
import java.util.UUID;

public class PointTransaction {
    private UUID id;
    private UUID pointAccountId;
    private Integer amount;
    private String type;
    private String referenceType;
    private UUID referenceId;
    private String description;
    private Instant createdAt;

    public PointTransaction() {
    }

    public PointTransaction(UUID pointAccountId, Integer amount, String type, String referenceType, UUID referenceId) {
        this.pointAccountId = pointAccountId;
        this.amount = amount;
        this.type = type;
        this.referenceType = referenceType;
        this.referenceId = referenceId;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getPointAccountId() {
        return pointAccountId;
    }

    public void setPointAccountId(UUID pointAccountId) {
        this.pointAccountId = pointAccountId;
    }

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getReferenceType() {
        return referenceType;
    }

    public void setReferenceType(String referenceType) {
        this.referenceType = referenceType;
    }

    public UUID getReferenceId() {
        return referenceId;
    }

    public void setReferenceId(UUID referenceId) {
        this.referenceId = referenceId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }
}
