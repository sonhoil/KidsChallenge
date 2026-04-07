package com.kidspoint.api.kids.mission.dto;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;
import java.util.UUID;

public class AssignMissionRequest {
    @NotNull(message = "Mission ID is required")
    private UUID missionId;

    @NotNull(message = "Assignee ID is required")
    private UUID assigneeId;

    @NotNull(message = "Family ID is required")
    private UUID familyId;

    private LocalDate dueDate;

    private Integer points; // Optional, defaults to mission's defaultPoints

    public UUID getMissionId() {
        return missionId;
    }

    public void setMissionId(UUID missionId) {
        this.missionId = missionId;
    }

    public UUID getAssigneeId() {
        return assigneeId;
    }

    public void setAssigneeId(UUID assigneeId) {
        this.assigneeId = assigneeId;
    }

    public UUID getFamilyId() {
        return familyId;
    }

    public void setFamilyId(UUID familyId) {
        this.familyId = familyId;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public void setDueDate(LocalDate dueDate) {
        this.dueDate = dueDate;
    }

    public Integer getPoints() {
        return points;
    }

    public void setPoints(Integer points) {
        this.points = points;
    }
}
