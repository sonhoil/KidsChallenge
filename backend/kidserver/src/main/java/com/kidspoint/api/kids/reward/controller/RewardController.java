package com.kidspoint.api.kids.reward.controller;

import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import com.kidspoint.api.kids.reward.dto.*;
import com.kidspoint.api.kids.reward.service.RewardService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/kids/rewards")
public class RewardController extends ApiControllerBase {

    private final RewardService rewardService;

    @Autowired
    public RewardController(RewardService rewardService) {
        this.rewardService = rewardService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<RewardResponse>> createReward(
            @Valid @RequestBody CreateRewardRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            RewardResponse response = rewardService.createReward(userId, request);
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Reward created successfully"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/family/{familyId}")
    public ResponseEntity<ApiResponse<List<RewardResponse>>> listRewards(
            @PathVariable UUID familyId,
            @RequestParam(required = false, defaultValue = "true") Boolean activeOnly) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            List<RewardResponse> rewards = rewardService.listRewardsByFamily(familyId, activeOnly);
            return ResponseEntity.ok(ApiResponse.ok(rewards));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PutMapping("/{rewardId}")
    public ResponseEntity<ApiResponse<RewardResponse>> updateReward(
            @PathVariable UUID rewardId,
            @Valid @RequestBody CreateRewardRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            RewardResponse response = rewardService.updateReward(userId, rewardId, request);
            return ResponseEntity.ok(ApiResponse.ok(response, "Reward updated successfully"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/{rewardId}")
    public ResponseEntity<ApiResponse<Void>> deleteReward(
            @PathVariable UUID rewardId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            rewardService.deleteReward(userId, rewardId);
            return ResponseEntity.ok(ApiResponse.ok(null, "Reward deleted successfully"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{rewardId}/visibility")
    public ResponseEntity<ApiResponse<RewardResponse>> updateRewardVisibility(
            @PathVariable UUID rewardId,
            @Valid @RequestBody UpdateRewardVisibilityRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            RewardResponse response =
                rewardService.updateRewardVisibility(userId, rewardId, request.getIsActive());
            return ResponseEntity.ok(ApiResponse.ok(response, "Reward visibility updated successfully"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{rewardId}/purchase")
    public ResponseEntity<ApiResponse<RewardPurchaseResponse>> purchaseReward(
            @PathVariable UUID rewardId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            RewardPurchaseResponse response = rewardService.purchaseReward(userId, rewardId);
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Reward purchased successfully"));
        } catch (IllegalStateException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<List<RewardPurchaseResponse>>> getMyPurchases(
            @RequestParam(required = false) String status) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            List<RewardPurchaseResponse> purchases = rewardService.getMyPurchases(userId, status);
            return ResponseEntity.ok(ApiResponse.ok(purchases));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/family/{familyId}/purchases")
    public ResponseEntity<ApiResponse<List<RewardPurchaseResponse>>> getFamilyPurchases(
            @PathVariable UUID familyId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            List<RewardPurchaseResponse> purchases = rewardService.getFamilyPurchases(userId, familyId);
            return ResponseEntity.ok(ApiResponse.ok(purchases));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/purchases/{purchaseId}/use")
    public ResponseEntity<ApiResponse<RewardPurchaseResponse>> usePurchase(
            @PathVariable UUID purchaseId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            RewardPurchaseResponse response = rewardService.usePurchase(userId, purchaseId);
            return ResponseEntity.ok(ApiResponse.ok(response, "Reward used successfully"));
        } catch (IllegalStateException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/purchases/{purchaseId}/status")
    public ResponseEntity<ApiResponse<RewardPurchaseResponse>> updatePurchaseStatus(
            @PathVariable UUID purchaseId,
            @Valid @RequestBody UpdateRewardPurchaseStatusRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            RewardPurchaseResponse response =
                rewardService.updatePurchaseStatusByParent(userId, purchaseId, request.getStatus());
            return ResponseEntity.ok(ApiResponse.ok(response, "Reward purchase status updated successfully"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }
}
