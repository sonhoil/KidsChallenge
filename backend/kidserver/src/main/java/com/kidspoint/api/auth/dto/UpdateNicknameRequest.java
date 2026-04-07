package com.kidspoint.api.auth.dto;

import jakarta.validation.constraints.Size;

public class UpdateNicknameRequest {
    @Size(max = 50, message = "Nickname must not exceed 50 characters")
    private String nickname;

    public UpdateNicknameRequest() {
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
}
