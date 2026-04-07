package com.kidspoint.api.kids.family.domain;

import java.time.Instant;
import java.util.UUID;

public class FamilyMember {
    private UUID id;
    private UUID familyId;
    private UUID userId;
    private FamilyRole role;
    private String nickname;
    private String avatarUrl;
    private Instant createdAt;
    private Instant updatedAt;

    public enum FamilyRole {
        parent, child
    }

    public FamilyMember() {
    }

    public FamilyMember(UUID id, UUID familyId, UUID userId, FamilyRole role, String nickname) {
        this.id = id;
        this.familyId = familyId;
        this.userId = userId;
        this.role = role;
        this.nickname = nickname;
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

    public FamilyRole getRole() {
        return role;
    }

    public void setRole(FamilyRole role) {
        this.role = role;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
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
