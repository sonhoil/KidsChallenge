package com.kidspoint.api.category.domain;

import java.time.Instant;
import java.util.UUID;

public class Category {
    private UUID id;
    private UUID organizationId;
    private String name;
    private String description;
    private String color;
    private Instant createdAt;

    public Category() {
    }

    public Category(UUID id, UUID organizationId, String name, String description, String color) {
        this.id = id;
        this.organizationId = organizationId;
        this.name = name;
        this.description = description;
        this.color = color;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getOrganizationId() {
        return organizationId;
    }

    public void setOrganizationId(UUID organizationId) {
        this.organizationId = organizationId;
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

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }
}
