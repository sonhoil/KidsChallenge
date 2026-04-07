package com.kidspoint.api.organization.domain;

import java.time.Instant;
import java.util.UUID;

public class OrganizationMember {
    private UUID id;
    private UUID organizationId;
    private UUID userId;
    private OrgRole role;
    private Boolean isFavorite;
    private Instant joinedAt;
    private Instant lastActive;

    public enum OrgRole {
        admin, member
    }

    // Constructors
    public OrganizationMember() {
    }

    public OrganizationMember(UUID id, UUID organizationId, UUID userId, OrgRole role) {
        this.id = id;
        this.organizationId = organizationId;
        this.userId = userId;
        this.role = role;
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

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public OrgRole getRole() {
        return role;
    }

    public void setRole(OrgRole role) {
        this.role = role;
    }

    public Boolean getIsFavorite() {
        return isFavorite;
    }

    public void setIsFavorite(Boolean isFavorite) {
        this.isFavorite = isFavorite;
    }

    public Instant getJoinedAt() {
        return joinedAt;
    }

    public void setJoinedAt(Instant joinedAt) {
        this.joinedAt = joinedAt;
    }

    public Instant getLastActive() {
        return lastActive;
    }

    public void setLastActive(Instant lastActive) {
        this.lastActive = lastActive;
    }
}
