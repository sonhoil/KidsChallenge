package com.kidspoint.api.kids.family.controller;

import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import com.kidspoint.api.kids.family.dto.CreateFamilyMemberRequest;
import com.kidspoint.api.kids.family.dto.CreateFamilyRequest;
import com.kidspoint.api.kids.family.dto.FamilyMemberResponse;
import com.kidspoint.api.kids.family.dto.FamilyResponse;
import com.kidspoint.api.kids.family.dto.JoinFamilyRequest;
import com.kidspoint.api.kids.family.dto.UpdateFamilyNameRequest;
import com.kidspoint.api.kids.family.service.FamilyService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/kids/families")
public class FamilyController extends ApiControllerBase {

    private static final Logger logger = LoggerFactory.getLogger(FamilyController.class);
    
    private final FamilyService familyService;

    @Autowired
    public FamilyController(FamilyService familyService) {
        this.familyService = familyService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<FamilyResponse>> createFamily(
            @Valid @RequestBody CreateFamilyRequest request,
            jakarta.servlet.http.HttpServletRequest httpRequest) {
        logger.info("[FamilyController] POST /api/kids/families - name: {}", request.getName());
        logger.info("[FamilyController] Request URI: {}", httpRequest.getRequestURI());
        logger.info("[FamilyController] Request method: {}", httpRequest.getMethod());
        
        jakarta.servlet.http.HttpSession session = httpRequest.getSession(false);
        String sessionId = session != null ? session.getId() : "null";
        logger.info("[FamilyController] Session ID: {}", sessionId);
        
        // 인증 정보 확인
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        logger.info("[FamilyController] Authentication: {}", auth != null ? (auth.isAuthenticated() ? "authenticated as " + auth.getName() : "not authenticated") : "null");
        
        UUID userId = getCurrentUserId();
        logger.info("[FamilyController] Current user ID: {}", userId);
        if (userId == null) {
            logger.warn("[FamilyController] User not authenticated");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            FamilyResponse response = familyService.createFamily(userId, request);
            logger.info("[FamilyController] Family created successfully: {}", response.getId());
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Family created successfully"));
        } catch (Exception e) {
            logger.error("[FamilyController] Error creating family: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("Failed to create family: " + e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<FamilyResponse>>> listMyFamilies() {
        System.out.println("[FamilyController] GET /api/kids/families");
        UUID userId = getCurrentUserId();
        System.out.println("[FamilyController] Current user ID: " + userId);
        if (userId == null) {
            System.out.println("[FamilyController] User not authenticated");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        System.out.println("[FamilyController] Listing families for user: " + userId);
        List<FamilyResponse> families = familyService.listMyFamilies(userId);
        System.out.println("[FamilyController] Found " + families.size() + " families");
        return ResponseEntity.ok(ApiResponse.ok(families));
    }

    @GetMapping("/{familyId}/members")
    public ResponseEntity<ApiResponse<List<FamilyMemberResponse>>> listMembers(
            @PathVariable UUID familyId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            List<FamilyMemberResponse> members = familyService.listMembers(userId, familyId);
            return ResponseEntity.ok(ApiResponse.ok(members));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{familyId}/members")
    public ResponseEntity<ApiResponse<FamilyMemberResponse>> addMember(
            @PathVariable UUID familyId,
            @Valid @RequestBody CreateFamilyMemberRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            FamilyMemberResponse response = familyService.addMember(userId, familyId, request);
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Family member added successfully"));
        } catch (IllegalStateException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/{familyId}/members/{memberId}")
    public ResponseEntity<ApiResponse<Void>> deleteMember(
            @PathVariable UUID familyId,
            @PathVariable UUID memberId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            familyService.deleteMember(userId, familyId, memberId);
            return ResponseEntity.ok(ApiResponse.ok(null, "Family member deleted successfully"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/join")
    public ResponseEntity<ApiResponse<FamilyResponse>> joinFamily(
            @Valid @RequestBody JoinFamilyRequest request) {
        System.out.println("[FamilyController] POST /api/kids/families/join - inviteCode: " + request.getInviteCode());
        UUID userId = getCurrentUserId();
        System.out.println("[FamilyController] Current user ID: " + userId);
        if (userId == null) {
            System.out.println("[FamilyController] User not authenticated");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            FamilyResponse response = familyService.joinByInviteCode(
                userId,
                request.getInviteCode(),
                request.getNickname(),
                request.getMemberId()
            );
            System.out.println("[FamilyController] Successfully joined family: " + response.getId());
            return ResponseEntity.ok(ApiResponse.ok(response, "Successfully joined family"));
        } catch (IllegalArgumentException e) {
            System.out.println("[FamilyController] Invalid invite code: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            System.out.println("[FamilyController] Join failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PutMapping("/{familyId}")
    public ResponseEntity<ApiResponse<FamilyResponse>> updateFamily(
            @PathVariable UUID familyId,
            @Valid @RequestBody UpdateFamilyNameRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }
        try {
            FamilyResponse updated = familyService.updateFamilyName(userId, familyId, request.getName());
            return ResponseEntity.ok(ApiResponse.ok(updated, "Family updated"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }
}

