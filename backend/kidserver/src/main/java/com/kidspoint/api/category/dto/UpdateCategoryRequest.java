package com.kidspoint.api.category.dto;

import jakarta.validation.constraints.Size;

public class UpdateCategoryRequest {
    @Size(min = 1, max = 20, message = "Name must be between 1 and 20 characters")
    private String name;

    @Size(max = 500, message = "Description must be less than 500 characters")
    private String description;

    @Size(max = 7, message = "Color must be a valid hex color code")
    private String color;

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

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }
}
