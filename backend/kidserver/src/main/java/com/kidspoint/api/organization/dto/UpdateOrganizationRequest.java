package com.kidspoint.api.organization.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class UpdateOrganizationRequest {
    @NotBlank(message = "Name is required")
    @Size(max = 100, message = "Name must not exceed 100 characters")
    private String name;

    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    private Boolean allowPublicJoin; // QR 스캔으로 누구나 가입 허용 여부

    public UpdateOrganizationRequest() {
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

    public Boolean getAllowPublicJoin() {
        return allowPublicJoin;
    }

    public void setAllowPublicJoin(Boolean allowPublicJoin) {
        this.allowPublicJoin = allowPublicJoin;
    }
}
