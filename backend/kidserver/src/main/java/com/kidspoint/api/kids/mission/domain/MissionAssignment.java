package com.kidspoint.api.kids.mission.domain;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class MissionAssignment {
    private UUID id;
    private UUID missionId;
    private UUID assigneeId;
    private UUID assignedBy;
    private UUID familyId;
    private LocalDate dueDate;
    private MissionStatus status;
    private Integer points;
    private Instant createdAt;
    private Instant updatedAt;

    public enum MissionStatus {
        todo, pending, approved, rejected, cancelled
    }

    public MissionAssignment() {
    }

    public MissionAssignment(UUID id, UUID missionId, UUID assigneeId, UUID assignedBy, UUID familyId, Integer points) {
        this.id = id;
        this.missionId = missionId;
        this.assigneeId = assigneeId;
        this.assignedBy = assignedBy;
        this.familyId = familyId;
        this.points = points;
        this.status = MissionStatus.todo;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

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

    public UUID getAssignedBy() {
        return assignedBy;
    }

    public void setAssignedBy(UUID assignedBy) {
        this.assignedBy = assignedBy;
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

    public MissionStatus getStatus() {
        return status;
    }

    public void setStatus(MissionStatus status) {
        this.status = status;
    }

    public Integer getPoints() {
        return points;
    }

    public void setPoints(Integer points) {
        this.points = points;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }
}
