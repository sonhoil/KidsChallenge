package com.kidspoint.api.kids.family.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public class CreateFamilyMemberRequest {

    // 소셜/이메일 계정과 아직 연결되지 않은 아이 멤버를 허용하기 위해
    // userId 는 선택값으로 변경한다 (NULL 허용).
    private UUID userId;

    @NotNull(message = "Role is required")
    private String role; // parent or child

    @Size(max = 100, message = "Nickname must be less than 100 characters")
    private String nickname;

    @Size(max = 500, message = "Avatar URL must be less than 500 characters")
    private String avatarUrl;

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
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
}

