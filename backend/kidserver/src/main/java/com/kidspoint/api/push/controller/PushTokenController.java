package com.kidspoint.api.push.controller;

import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import com.kidspoint.api.push.dto.RegisterFcmTokenRequest;
import com.kidspoint.api.push.service.PushTokenService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/kids/push-tokens")
public class PushTokenController extends ApiControllerBase {

    private final PushTokenService pushTokenService;

    public PushTokenController(PushTokenService pushTokenService) {
        this.pushTokenService = pushTokenService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Void>> registerToken(@Valid @RequestBody RegisterFcmTokenRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }
        pushTokenService.registerOrUpdate(userId, request);
        return ResponseEntity.ok(ApiResponse.ok(null, "FCM token registered"));
    }
}
