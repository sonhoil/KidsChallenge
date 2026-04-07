package com.kidspoint.api.subscription.controller;

import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import com.kidspoint.api.subscription.dto.CreatePaymentRequest;
import com.kidspoint.api.subscription.dto.SubscriptionResponse;
import com.kidspoint.api.subscription.dto.VerifyIAPRequest;
import com.kidspoint.api.subscription.service.SubscriptionService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/subscriptions")
public class SubscriptionController extends ApiControllerBase {

    private final SubscriptionService subscriptionService;

    @Autowired
    public SubscriptionController(SubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    /**
     * 결제 성공 후 프리미엄 플랜으로 업그레이드
     */
    @PostMapping("/create")
    public ResponseEntity<ApiResponse<SubscriptionResponse>> createSubscription(
            @Valid @RequestBody CreatePaymentRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            SubscriptionResponse response = subscriptionService.createSubscription(userId, request);
            return ResponseEntity.ok(ApiResponse.ok(response, "Premium subscription activated successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 구독 조회
     */
    @GetMapping("/organization/{organizationId}")
    public ResponseEntity<ApiResponse<SubscriptionResponse>> getSubscription(
            @PathVariable UUID organizationId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            SubscriptionResponse response = subscriptionService.getSubscription(userId, organizationId);
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 구독 취소
     */
    @PostMapping("/organization/{organizationId}/cancel")
    public ResponseEntity<ApiResponse<Void>> cancelSubscription(
            @PathVariable UUID organizationId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            subscriptionService.cancelSubscription(userId, organizationId);
            return ResponseEntity.ok(ApiResponse.ok(null, "Subscription canceled successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 인앱 구매 영수증 검증 및 구독 생성
     */
    @PostMapping("/verify-iap")
    public ResponseEntity<ApiResponse<SubscriptionResponse>> verifyIAP(
            @Valid @RequestBody VerifyIAPRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            SubscriptionResponse response = subscriptionService.verifyIAPAndCreateSubscription(userId, request);
            return ResponseEntity.ok(ApiResponse.ok(response, "Premium subscription activated successfully via IAP"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }
}
