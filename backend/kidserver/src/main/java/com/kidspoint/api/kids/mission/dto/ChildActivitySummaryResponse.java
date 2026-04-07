package com.kidspoint.api.kids.mission.dto;

public class ChildActivitySummaryResponse {
    private int totalMissions;
    private int todoCount;
    private int pendingCount;
    private int approvedCount;
    private int rejectedCount;
    private int totalApprovedPoints;

    public int getTotalMissions() {
        return totalMissions;
    }

    public void setTotalMissions(int totalMissions) {
        this.totalMissions = totalMissions;
    }

    public int getTodoCount() {
        return todoCount;
    }

    public void setTodoCount(int todoCount) {
        this.todoCount = todoCount;
    }

    public int getPendingCount() {
        return pendingCount;
    }

    public void setPendingCount(int pendingCount) {
        this.pendingCount = pendingCount;
    }

    public int getApprovedCount() {
        return approvedCount;
    }

    public void setApprovedCount(int approvedCount) {
        this.approvedCount = approvedCount;
    }

    public int getRejectedCount() {
        return rejectedCount;
    }

    public void setRejectedCount(int rejectedCount) {
        this.rejectedCount = rejectedCount;
    }

    public int getTotalApprovedPoints() {
        return totalApprovedPoints;
    }

    public void setTotalApprovedPoints(int totalApprovedPoints) {
        this.totalApprovedPoints = totalApprovedPoints;
    }
}

