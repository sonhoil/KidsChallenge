package com.kidspoint.api.kids.mission.dto;

import jakarta.validation.constraints.Size;

public class RejectMissionRequest {
    @Size(max = 500, message = "Comment must be less than 500 characters")
    private String comment;

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }
}
