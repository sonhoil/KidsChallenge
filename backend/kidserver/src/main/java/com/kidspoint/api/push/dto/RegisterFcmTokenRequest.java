package com.kidspoint.api.push.dto;

import jakarta.validation.constraints.NotBlank;

public class RegisterFcmTokenRequest {
    @NotBlank
    private String fcmToken;
    /** ios, android, web */
    private String platform;

    public String getFcmToken() {
        return fcmToken;
    }

    public void setFcmToken(String fcmToken) {
        this.fcmToken = fcmToken;
    }

    public String getPlatform() {
        return platform;
    }

    public void setPlatform(String platform) {
        this.platform = platform;
    }
}
