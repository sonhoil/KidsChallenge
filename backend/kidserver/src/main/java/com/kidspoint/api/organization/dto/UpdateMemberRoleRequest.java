package com.kidspoint.api.organization.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class UpdateMemberRoleRequest {
    @NotBlank(message = "Role is required")
    @Pattern(regexp = "admin|member", message = "Role must be either 'admin' or 'member'")
    private String role;

    public UpdateMemberRoleRequest() {
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}
