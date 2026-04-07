package com.kidspoint.api.organization.controller;

import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import com.kidspoint.api.organization.dto.CreateInvitationRequest;
import com.kidspoint.api.organization.dto.InvitationResponse;
import com.kidspoint.api.organization.dto.JoinByTokenRequest;
import com.kidspoint.api.organization.service.InvitationService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/organizations")
public class InvitationController extends ApiControllerBase {

    private final InvitationService invitationService;

    @Autowired
    public InvitationController(InvitationService invitationService) {
        this.invitationService = invitationService;
    }

    /**
     * 초대 링크 생성
     */
    @PostMapping("/{organizationId}/invitations")
    public ResponseEntity<ApiResponse<InvitationResponse>> createInvitation(
            @PathVariable UUID organizationId,
            @Valid @RequestBody CreateInvitationRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            InvitationResponse response = invitationService.createInvitation(userId, organizationId, request);
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Invitation created successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 토큰으로 초대 정보 조회
     */
    @GetMapping("/invitations/{token}")
    public ResponseEntity<ApiResponse<InvitationResponse>> getInvitationByToken(@PathVariable String token) {
        try {
            InvitationResponse response = invitationService.getInvitationByToken(token);
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 토큰으로 단체 가입
     */
    @PostMapping("/invitations/join")
    public ResponseEntity<ApiResponse<java.util.Map<String, String>>> joinByToken(
            @Valid @RequestBody JoinByTokenRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            UUID organizationId = invitationService.joinByToken(userId, request.getToken());
            java.util.Map<String, String> responseData = new java.util.HashMap<>();
            responseData.put("organizationId", organizationId.toString());
            return ResponseEntity.ok(ApiResponse.ok(responseData, "Successfully joined organization"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }
}
