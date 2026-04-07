package com.kidspoint.api.kids.reward.domain;

import java.time.Instant;
import java.util.UUID;

public class RewardPurchase {
    private UUID id;
    private UUID rewardId;
    private UUID buyerId;
    private UUID familyId;
    private UUID pointTransactionId;
    private PurchaseStatus status;
    private String notes;
    private Instant createdAt;
    private Instant updatedAt;

    public enum PurchaseStatus {
        pending, confirmed, used, cancelled
    }

    public RewardPurchase() {
    }

    public RewardPurchase(UUID id, UUID rewardId, UUID buyerId, UUID familyId) {
        this.id = id;
        this.rewardId = rewardId;
        this.buyerId = buyerId;
        this.familyId = familyId;
        this.status = PurchaseStatus.pending;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getRewardId() {
        return rewardId;
    }

    public void setRewardId(UUID rewardId) {
        this.rewardId = rewardId;
    }

    public UUID getBuyerId() {
        return buyerId;
    }

    public void setBuyerId(UUID buyerId) {
        this.buyerId = buyerId;
    }

    public UUID getFamilyId() {
        return familyId;
    }

    public void setFamilyId(UUID familyId) {
        this.familyId = familyId;
    }

    public UUID getPointTransactionId() {
        return pointTransactionId;
    }

    public void setPointTransactionId(UUID pointTransactionId) {
        this.pointTransactionId = pointTransactionId;
    }

    public PurchaseStatus getStatus() {
        return status;
    }

    public void setStatus(PurchaseStatus status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
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
