package com.kidspoint.api.kids.mission.domain;

import java.time.Instant;
import java.util.UUID;

public class MissionLog {
    private UUID id;
    private UUID missionAssignmentId;
    private MissionAssignment.MissionStatus fromStatus;
    private MissionAssignment.MissionStatus toStatus;
    private UUID changedBy;
    private String comment;
    private Instant createdAt;

    public MissionLog() {
    }

    public MissionLog(UUID missionAssignmentId, MissionAssignment.MissionStatus fromStatus, 
                     MissionAssignment.MissionStatus toStatus, UUID changedBy) {
        this.missionAssignmentId = missionAssignmentId;
        this.fromStatus = fromStatus;
        this.toStatus = toStatus;
        this.changedBy = changedBy;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getMissionAssignmentId() {
        return missionAssignmentId;
    }

    public void setMissionAssignmentId(UUID missionAssignmentId) {
        this.missionAssignmentId = missionAssignmentId;
    }

    public MissionAssignment.MissionStatus getFromStatus() {
        return fromStatus;
    }

    public void setFromStatus(MissionAssignment.MissionStatus fromStatus) {
        this.fromStatus = fromStatus;
    }

    public MissionAssignment.MissionStatus getToStatus() {
        return toStatus;
    }

    public void setToStatus(MissionAssignment.MissionStatus toStatus) {
        this.toStatus = toStatus;
    }

    public UUID getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(UUID changedBy) {
        this.changedBy = changedBy;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }
}
