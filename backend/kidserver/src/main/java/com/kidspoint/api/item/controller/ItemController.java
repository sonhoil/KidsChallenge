package com.kidspoint.api.item.controller;

import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import com.kidspoint.api.item.dto.CreateItemRequest;
import com.kidspoint.api.item.dto.ItemResponse;
import com.kidspoint.api.item.dto.MoveItemRequest;
import com.kidspoint.api.item.dto.UpdateItemRequest;
import com.kidspoint.api.item.service.ItemService;
import com.kidspoint.api.item.util.QrCodeUtil;
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
@RequestMapping("/api/items")
public class ItemController extends ApiControllerBase {

    private final ItemService itemService;

    @Autowired
    public ItemController(ItemService itemService) {
        this.itemService = itemService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ItemResponse>>> listItems(
            @RequestParam(required = false) UUID boxId,
            @RequestParam(required = false, defaultValue = "0") Integer page,
            @RequestParam(required = false, defaultValue = "50") Integer size,
            @RequestParam(required = false) UUID orgId,
            HttpSession session) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        if (boxId == null) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Box ID is required"));
        }

        UUID organizationId = orgId != null ? orgId : 
            OrganizationContext.getCurrentOrgId(session)
                .orElseThrow(() -> new IllegalStateException("Organization context required"));

        try {
            List<ItemResponse> items = itemService.listItemsByBox(boxId, organizationId, page, size);
            return ResponseEntity.ok(ApiResponse.ok(items));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ItemResponse>> createItem(
            @Valid @RequestBody CreateItemRequest request,
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
            ItemResponse response = itemService.createItem(userId, organizationId, request);
            return ResponseEntity.status(HttpStatus.CREATED)
                .header("Location", "/api/items/" + response.getId())
                .body(ApiResponse.ok(response, "Item created successfully"));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ItemResponse>> getItem(
            @PathVariable String id,
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
            ItemResponse response = itemService.getItemDetail(id, organizationId);
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ItemResponse>> updateItem(
            @PathVariable String id,
            @Valid @RequestBody UpdateItemRequest request,
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
            ItemResponse response = itemService.updateItem(id, organizationId, request);
            return ResponseEntity.ok(ApiResponse.ok(response, "Item updated successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteItem(
            @PathVariable String id,
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
            itemService.deleteItem(id, organizationId);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 관리자용 삭제 취소 (Restore)
     */
    @PostMapping("/{id}/restore")
    public ResponseEntity<ApiResponse<ItemResponse>> restoreItem(
            @PathVariable String id,
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
            ItemResponse response = itemService.restoreItem(userId, id, organizationId);
            return ResponseEntity.ok(ApiResponse.ok(response, "Item restored successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 관리자용 실제 삭제 (Hard delete)
     */
    @DeleteMapping("/{id}/permanent")
    public ResponseEntity<ApiResponse<Void>> permanentlyDeleteItem(
            @PathVariable String id,
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
            itemService.permanentlyDeleteItem(userId, id, organizationId);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/{id}/qr")
    public ResponseEntity<?> getItemQrCode(
            @PathVariable String id,
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

        // 아이템 존재 확인
        ItemResponse item = itemService.getItemDetail(id, organizationId);

        // size 검증
        if (size < 128 || size > 1024) {
            return ResponseEntity.badRequest()
                .body("Size must be between 128 and 1024");
        }

        // QR 코드 생성 (qr_uuid 사용)
        String content = item.getQrCode() != null ? item.getQrCode() : item.getId().toString();
        HttpHeaders headers = new HttpHeaders();
        headers.setCacheControl("public, max-age=86400");

        try {
            byte[] png = QrCodeUtil.generateQrCodePng(content, size);
            headers.setContentType(MediaType.IMAGE_PNG);
            return ResponseEntity.ok()
                .headers(headers)
                .body(png);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Failed to generate QR code: " + e.getMessage());
        }
    }

    @PostMapping("/{id}/use")
    public ResponseEntity<ApiResponse<ItemResponse>> useItem(
            @PathVariable String id,
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
            ItemResponse response = itemService.useItem(id, userId, organizationId);
            return ResponseEntity.ok(ApiResponse.ok(response, "Item is now in use"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{id}/return")
    public ResponseEntity<ApiResponse<ItemResponse>> returnItem(
            @PathVariable String id,
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
            ItemResponse response = itemService.returnItem(id, userId, organizationId);
            return ResponseEntity.ok(ApiResponse.ok(response, "Item returned successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{id}/move")
    public ResponseEntity<ApiResponse<ItemResponse>> moveItem(
            @PathVariable String id,
            @Valid @RequestBody MoveItemRequest request,
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
            ItemResponse response = itemService.moveItem(id, request.getTargetBoxId(), userId, organizationId);
            return ResponseEntity.ok(ApiResponse.ok(response, "Item moved successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        }
    }
}
