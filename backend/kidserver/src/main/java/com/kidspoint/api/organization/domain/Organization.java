package com.kidspoint.api.organization.domain;

import java.time.Instant;
import java.util.UUID;

public class Organization {
    private UUID id;
    private String name;
    private String description;
    private Plan plan;
    private Integer boxLimit;
    private Boolean allowPublicJoin; // QR 스캔으로 누구나 가입 허용 여부
    private Instant createdAt;
    private Instant updatedAt;

    public enum Plan {
        free, premium
    }

    // Constructors
    public Organization() {
    }

    public Organization(UUID id, String name, String description, Plan plan, Integer boxLimit) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.plan = plan;
        this.boxLimit = boxLimit;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
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

    public Plan getPlan() {
        return plan;
    }

    public void setPlan(Plan plan) {
        this.plan = plan;
    }

    public Integer getBoxLimit() {
        return boxLimit;
    }

    public void setBoxLimit(Integer boxLimit) {
        this.boxLimit = boxLimit;
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

    public Boolean getAllowPublicJoin() {
        return allowPublicJoin;
    }

    public void setAllowPublicJoin(Boolean allowPublicJoin) {
        this.allowPublicJoin = allowPublicJoin;
    }
}
