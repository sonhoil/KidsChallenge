package com.kidspoint.api.organization.dto;

import java.time.Instant;
import java.util.UUID;

public class OrganizationResponse {
    private UUID id;
    private String name;
    private String description;
    private String plan;
    private Integer boxLimit;
    private Boolean allowPublicJoin; // QR 스캔으로 누구나 가입 허용 여부
    private Integer boxCount; // 단체의 상자 개수
    private String role; // 사용자의 역할 (admin 또는 member)
    private Instant createdAt;
    private Instant updatedAt;

    public OrganizationResponse() {
    }

    public OrganizationResponse(UUID id, String name, String description, String plan, Integer boxLimit) {
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

    public String getPlan() {
        return plan;
    }

    public void setPlan(String plan) {
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

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Integer getBoxCount() {
        return boxCount;
    }

    public void setBoxCount(Integer boxCount) {
        this.boxCount = boxCount;
    }

    public Boolean getAllowPublicJoin() {
        return allowPublicJoin;
    }

    public void setAllowPublicJoin(Boolean allowPublicJoin) {
        this.allowPublicJoin = allowPublicJoin;
    }
}
