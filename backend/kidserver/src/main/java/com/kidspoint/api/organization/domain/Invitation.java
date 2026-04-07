package com.kidspoint.api.organization.domain;

import java.time.Instant;
import java.util.UUID;

public class Invitation {
    private UUID id;
    private UUID organizationId;
    private String email;
    private OrganizationMember.OrgRole role;
    private String token;
    private Instant expiresAt;
    private UUID createdBy;
    private Instant createdAt;
    private Instant acceptedAt;

    // Constructors
    public Invitation() {
    }

    public Invitation(UUID id, UUID organizationId, String email, OrganizationMember.OrgRole role, 
                     String token, Instant expiresAt, UUID createdBy) {
        this.id = id;
        this.organizationId = organizationId;
        this.email = email;
        this.role = role;
        this.token = token;
        this.expiresAt = expiresAt;
        this.createdBy = createdBy;
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public OrganizationMember.OrgRole getRole() {
        return role;
    }

    public void setRole(OrganizationMember.OrgRole role) {
        this.role = role;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Instant getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Instant expiresAt) {
        this.expiresAt = expiresAt;
    }

    public UUID getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(UUID createdBy) {
        this.createdBy = createdBy;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getAcceptedAt() {
        return acceptedAt;
    }

    public void setAcceptedAt(Instant acceptedAt) {
        this.acceptedAt = acceptedAt;
    }
}
