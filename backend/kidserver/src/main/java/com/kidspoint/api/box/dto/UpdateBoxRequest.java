package com.kidspoint.api.box.dto;

import jakarta.validation.constraints.Size;

public class UpdateBoxRequest {
    @Size(max = 200, message = "Name must be less than 200 characters")
    private String name;

    @Size(max = 200, message = "Location must be less than 200 characters")
    private String location;

    @Size(max = 1000, message = "Description must be less than 1000 characters")
    private String description;

    // Getters and Setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
