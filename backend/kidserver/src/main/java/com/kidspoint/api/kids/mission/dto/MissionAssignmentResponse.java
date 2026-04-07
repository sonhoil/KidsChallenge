package com.kidspoint.api.kids.mission.dto;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class MissionAssignmentResponse {
    private UUID id;
    private UUID missionId;
    private String missionTitle;
    private String missionIconType;
    private UUID assigneeId;
    private String assigneeNickname;
    private UUID assignedBy;
    private UUID familyId;
    private LocalDate dueDate;
    private String status;
    private Integer points;
    private Instant createdAt;
    private Instant updatedAt;
    private Boolean oneOff; // 스페셜(한번만) 여부
    private Boolean recentlyRejected; // 최근 반려되어 다시 수행 가능한지 여부

    public MissionAssignmentResponse() {
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

    public String getMissionTitle() {
        return missionTitle;
    }

    public void setMissionTitle(String missionTitle) {
        this.missionTitle = missionTitle;
    }

    public String getMissionIconType() {
        return missionIconType;
    }

    public void setMissionIconType(String missionIconType) {
        this.missionIconType = missionIconType;
    }

    public UUID getAssigneeId() {
        return assigneeId;
    }

    public void setAssigneeId(UUID assigneeId) {
        this.assigneeId = assigneeId;
    }

    public String getAssigneeNickname() {
        return assigneeNickname;
    }

    public void setAssigneeNickname(String assigneeNickname) {
        this.assigneeNickname = assigneeNickname;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
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

    public Boolean getOneOff() {
        return oneOff;
    }

    public void setOneOff(Boolean oneOff) {
        this.oneOff = oneOff;
    }

    public Boolean getRecentlyRejected() {
        return recentlyRejected;
    }

    public void setRecentlyRejected(Boolean recentlyRejected) {
        this.recentlyRejected = recentlyRejected;
    }
}
