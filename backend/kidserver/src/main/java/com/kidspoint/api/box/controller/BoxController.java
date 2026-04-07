package com.kidspoint.api.box.controller;

import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import com.kidspoint.api.box.dto.BoxResponse;
import com.kidspoint.api.box.dto.CreateBoxRequest;
import com.kidspoint.api.box.dto.UpdateBoxRequest;
import com.kidspoint.api.box.service.BoxService;
import com.kidspoint.api.box.util.QrCodeUtil;
import com.kidspoint.api.organization.util.OrganizationContext;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/boxes")
public class BoxController extends ApiControllerBase {

    private final BoxService boxService;

    @Autowired
    public BoxController(BoxService boxService) {
        this.boxService = boxService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<BoxResponse>>> listBoxes(
            @RequestParam(required = false) UUID orgId,
            @RequestParam(required = false, defaultValue = "50") Integer limit,
            @RequestParam(required = false, defaultValue = "0") Integer offset,
            HttpSession session) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        UUID organizationId = orgId != null ? orgId : 
            OrganizationContext.getCurrentOrgId(session)
                .orElseThrow(() -> new IllegalStateException("Organization context required"));

        try {
            List<BoxResponse> boxes = boxService.listBoxes(organizationId, limit, offset);
            return ResponseEntity.ok(ApiResponse.ok(boxes));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<BoxResponse>> createBox(
            @Valid @RequestBody CreateBoxRequest request,
            @RequestParam(required = false) UUID orgId,
            HttpSession session) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        UUID organizationId = orgId != null ? orgId : 
            OrganizationContext.getCurrentOrgId(session)
                .orElseThrow(() -> new IllegalStateException("Organization context required"));

        try {
            BoxResponse response = boxService.createBox(userId, organizationId, request);
            return ResponseEntity.status(HttpStatus.CREATED)
                .header("Location", "/api/boxes/" + response.getId())
                .body(ApiResponse.ok(response, "Box created successfully"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<BoxResponse>> getBox(
            @PathVariable UUID id,
            @RequestParam(required = false) UUID orgId,
            HttpSession session) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        UUID organizationId = orgId != null ? orgId : 
            OrganizationContext.getCurrentOrgId(session)
                .orElseThrow(() -> new IllegalStateException("Organization context required"));

        try {
            BoxResponse response = boxService.getBox(organizationId, id);
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<BoxResponse>> updateBox(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateBoxRequest request,
            @RequestParam(required = false) UUID orgId,
            HttpSession session) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        UUID organizationId = orgId != null ? orgId : 
            OrganizationContext.getCurrentOrgId(session)
                .orElseThrow(() -> new IllegalStateException("Organization context required"));

        try {
            BoxResponse response = boxService.updateBox(userId, organizationId, id, request);
            return ResponseEntity.ok(ApiResponse.ok(response, "Box updated successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteBox(
            @PathVariable UUID id,
            @RequestParam(required = false) UUID orgId,
            HttpSession session) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        UUID organizationId = orgId != null ? orgId : 
            OrganizationContext.getCurrentOrgId(session)
                .orElseThrow(() -> new IllegalStateException("Organization context required"));

        try {
            boxService.deleteBox(userId, organizationId, id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 박스 ID만으로 단체 ID 조회 (QR 스캔 딥링크용)
     */
    @GetMapping("/{id}/organization")
    public ResponseEntity<ApiResponse<UUID>> getBoxOrganization(@PathVariable UUID id) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            UUID organizationId = boxService.getBoxOrganizationId(id);
            return ResponseEntity.ok(ApiResponse.ok(organizationId));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/{id}/qr")
    public ResponseEntity<?> getBoxQrCode(
            @PathVariable UUID id,
            @RequestParam(required = false, defaultValue = "png") String format,
            @RequestParam(required = false, defaultValue = "256") Integer size,
            @RequestParam(required = false) UUID orgId,
            HttpSession session) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body("Not authenticated");
        }

        UUID organizationId = orgId != null ? orgId : 
            OrganizationContext.getCurrentOrgId(session)
                .orElseThrow(() -> new IllegalStateException("Organization context required"));

        // 박스 존재 확인
        BoxResponse box = boxService.getBox(organizationId, id);

        // size 검증
        if (size < 128 || size > 1024) {
            return ResponseEntity.badRequest()
                .body("Size must be between 128 and 1024");
        }

        // QR 코드 생성
        String content = box.getId().toString();
        HttpHeaders headers = new HttpHeaders();
        headers.setCacheControl("public, max-age=86400");

        try {
            if ("svg".equalsIgnoreCase(format)) {
                String svg = QrCodeUtil.generateQrCodeSvg(content, size);
                headers.setContentType(MediaType.valueOf("image/svg+xml"));
                return ResponseEntity.ok()
                    .headers(headers)
                    .body(svg);
            } else {
                byte[] png = QrCodeUtil.generateQrCodePng(content, size);
                headers.setContentType(MediaType.IMAGE_PNG);
                return ResponseEntity.ok()
                    .headers(headers)
                    .body(png);
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Failed to generate QR code: " + e.getMessage());
        }
    }
}
