package com.kidspoint.api.kids.mission.controller;

import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import com.kidspoint.api.kids.mission.dto.*;
import com.kidspoint.api.kids.mission.service.MissionService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/kids/missions")
public class MissionController extends ApiControllerBase {

    private final MissionService missionService;

    @Autowired
    public MissionController(MissionService missionService) {
        this.missionService = missionService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<MissionResponse>> createMission(
            @Valid @RequestBody CreateMissionRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            MissionResponse response = missionService.createMission(userId, request);
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Mission created successfully"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/family/{familyId}")
    public ResponseEntity<ApiResponse<List<MissionResponse>>> listMissions(
            @PathVariable UUID familyId,
            @RequestParam(required = false, defaultValue = "true") Boolean activeOnly) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            List<MissionResponse> missions = missionService.listMissionsByFamily(familyId, activeOnly);
            return ResponseEntity.ok(ApiResponse.ok(missions));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PutMapping("/{missionId}")
    public ResponseEntity<ApiResponse<MissionResponse>> updateMission(
            @PathVariable UUID missionId,
            @Valid @RequestBody CreateMissionRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            MissionResponse response = missionService.updateMission(userId, missionId, request);
            return ResponseEntity.ok(ApiResponse.ok(response, "Mission updated successfully"));
        } catch (IllegalStateException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/{missionId}")
    public ResponseEntity<ApiResponse<Void>> deleteMission(
            @PathVariable UUID missionId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            missionService.deleteMission(userId, missionId);
            return ResponseEntity.ok(ApiResponse.ok(null, "Mission deleted successfully"));
        } catch (IllegalStateException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{missionId}/visibility")
    public ResponseEntity<ApiResponse<MissionResponse>> updateMissionVisibility(
            @PathVariable UUID missionId,
            @Valid @RequestBody UpdateMissionVisibilityRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            MissionResponse response =
                missionService.updateMissionVisibility(userId, missionId, request.getIsActive());
            return ResponseEntity.ok(ApiResponse.ok(response, "Mission visibility updated successfully"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/assign")
    public ResponseEntity<ApiResponse<MissionAssignmentResponse>> assignMission(
            @Valid @RequestBody AssignMissionRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            MissionAssignmentResponse response = missionService.assignMission(userId, request);
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Mission assigned successfully"));
        } catch (IllegalStateException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{assignmentId}/complete")
    public ResponseEntity<ApiResponse<MissionAssignmentResponse>> completeMission(
            @PathVariable UUID assignmentId) {
        System.out.println("[MissionController] POST /api/kids/missions/" + assignmentId + "/complete");
        UUID userId = getCurrentUserId();
        System.out.println("[MissionController] completeMission: current userId=" + userId);
        if (userId == null) {
            System.out.println("[MissionController] completeMission: not authenticated");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            MissionAssignmentResponse response = missionService.completeMission(userId, assignmentId);
            System.out.println("[MissionController] completeMission: ok assignmentId=" + assignmentId
                + " newStatus=" + (response.getStatus() != null ? response.getStatus() : "?"));
            return ResponseEntity.ok(ApiResponse.ok(response, "Mission completed successfully"));
        } catch (IllegalStateException | IllegalArgumentException e) {
            System.out.println("[MissionController] completeMission: failed: " + e.getClass().getSimpleName() + " " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{assignmentId}/approve")
    public ResponseEntity<ApiResponse<MissionAssignmentResponse>> approveMission(
            @PathVariable UUID assignmentId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            MissionAssignmentResponse response = missionService.approveMission(userId, assignmentId);
            return ResponseEntity.ok(ApiResponse.ok(response, "Mission approved successfully"));
        } catch (IllegalStateException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{assignmentId}/reject")
    public ResponseEntity<ApiResponse<MissionAssignmentResponse>> rejectMission(
            @PathVariable UUID assignmentId,
            @Valid @RequestBody(required = false) RejectMissionRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        if (request == null) {
            request = new RejectMissionRequest();
        }

        try {
            MissionAssignmentResponse response = missionService.rejectMission(userId, assignmentId, request);
            return ResponseEntity.ok(ApiResponse.ok(response, "Mission rejected"));
        } catch (IllegalStateException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<List<MissionAssignmentResponse>>> getMyMissions(
            @RequestParam(required = false) String dueDate) {
        System.out.println("[MissionController] GET /me - dueDate: " + dueDate);
        UUID userId = getCurrentUserId();
        System.out.println("[MissionController] Current user ID: " + userId);
        if (userId == null) {
            System.out.println("[MissionController] User not authenticated");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            LocalDate dueDateParsed = dueDate != null ? LocalDate.parse(dueDate) : null;
            List<MissionAssignmentResponse> missions = missionService.getMyMissions(userId, dueDateParsed);
            return ResponseEntity.ok(ApiResponse.ok(missions));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/me/approved")
    public ResponseEntity<ApiResponse<List<MissionAssignmentResponse>>> getMyApprovedMissions(
            @RequestParam(required = false) String dueDate,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }
        try {
            if (startDate != null || endDate != null) {
                LocalDate start = startDate != null ? LocalDate.parse(startDate) : null;
                LocalDate end = endDate != null ? LocalDate.parse(endDate) : null;
                List<MissionAssignmentResponse> missions = missionService.getMyApprovedMissionsInRange(userId, start, end);
                return ResponseEntity.ok(ApiResponse.ok(missions));
            }
            LocalDate due = dueDate != null ? LocalDate.parse(dueDate) : null;
            List<MissionAssignmentResponse> missions = missionService.getMyApprovedMissionsByDate(userId, due);
            return ResponseEntity.ok(ApiResponse.ok(missions));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(e.getMessage()));
        }
    }
    @GetMapping("/pending/{familyId}")
    public ResponseEntity<ApiResponse<List<MissionAssignmentResponse>>> getPendingMissions(
            @PathVariable UUID familyId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            List<MissionAssignmentResponse> missions = missionService.getPendingMissions(userId, familyId);
            return ResponseEntity.ok(ApiResponse.ok(missions));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/family/{familyId}/assignments")
    public ResponseEntity<ApiResponse<List<MissionAssignmentResponse>>> getAssignmentsByFamily(
            @PathVariable UUID familyId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            List<MissionAssignmentResponse> missions = missionService.getAssignmentsByFamily(userId, familyId);
            return ResponseEntity.ok(ApiResponse.ok(missions));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/family/{familyId}/user/{targetUserId}")
    public ResponseEntity<ApiResponse<List<MissionAssignmentResponse>>> getMissionsByFamilyAndUser(
            @PathVariable UUID familyId,
            @PathVariable UUID targetUserId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            List<MissionAssignmentResponse> missions =
                missionService.getMissionsByFamilyAndUser(userId, familyId, targetUserId);
            return ResponseEntity.ok(ApiResponse.ok(missions));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }
}
