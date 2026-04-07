package com.kidspoint.api.item.domain;

import java.time.Instant;
import java.util.UUID;

public class Item {
    private UUID id;
    private UUID boxId;
    private String name;
    private String description;
    private String imageUrl;
    private String qrCode;
    private Instant createdAt;
    private Instant updatedAt;
    private UUID createdBy;
    private UUID inUseByUserId;
    private Instant inUseAt;
    private Instant deletedAt;

    // Constructors
    public Item() {
    }

    public Item(UUID id, UUID boxId, String name, String description) {
        this.id = id;
        this.boxId = boxId;
        this.name = name;
        this.description = description;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getBoxId() {
        return boxId;
    }

    public void setBoxId(UUID boxId) {
        this.boxId = boxId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getQrCode() {
        return qrCode;
    }

    public void setQrCode(String qrCode) {
        this.qrCode = qrCode;
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

    public UUID getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(UUID createdBy) {
        this.createdBy = createdBy;
    }

    public UUID getInUseByUserId() {
        return inUseByUserId;
    }

    public void setInUseByUserId(UUID inUseByUserId) {
        this.inUseByUserId = inUseByUserId;
    }

    public Instant getInUseAt() {
        return inUseAt;
    }

    public void setInUseAt(Instant inUseAt) {
        this.inUseAt = inUseAt;
    }

    public Instant getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(Instant deletedAt) {
        this.deletedAt = deletedAt;
    }
}
