package com.kidspoint.api.organization.dto;

import jakarta.validation.constraints.NotBlank;

public class JoinByTokenRequest {
    @NotBlank(message = "Token is required")
    private String token;

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}
