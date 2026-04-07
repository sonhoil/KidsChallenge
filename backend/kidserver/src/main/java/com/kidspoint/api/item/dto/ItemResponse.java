package com.kidspoint.api.item.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class ItemResponse {
    private UUID id;
    private UUID boxId;
    private String boxName;
    private String boxLocation;
    private String name;
    private String description;
    private String imageUrl;
    private String qrCode;
    private Instant createdAt;
    private Instant updatedAt;
    private UUID inUseByUserId;
    private String inUseByUserName;
    private Instant inUseAt;
    private Instant deletedAt;
    private List<String> categories;

    public ItemResponse() {
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

    public String getBoxName() {
        return boxName;
    }

    public void setBoxName(String boxName) {
        this.boxName = boxName;
    }

    public String getBoxLocation() {
        return boxLocation;
    }

    public void setBoxLocation(String boxLocation) {
        this.boxLocation = boxLocation;
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

    public UUID getInUseByUserId() {
        return inUseByUserId;
    }

    public void setInUseByUserId(UUID inUseByUserId) {
        this.inUseByUserId = inUseByUserId;
    }

    public String getInUseByUserName() {
        return inUseByUserName;
    }

    public void setInUseByUserName(String inUseByUserName) {
        this.inUseByUserName = inUseByUserName;
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

    public List<String> getCategories() {
        return categories;
    }

    public void setCategories(List<String> categories) {
        this.categories = categories;
    }
}
