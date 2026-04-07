package com.kidspoint.api.category.controller;

import com.kidspoint.api.category.dto.CategoryResponse;
import com.kidspoint.api.category.dto.CreateCategoryRequest;
import com.kidspoint.api.category.dto.UpdateCategoryRequest;
import com.kidspoint.api.category.service.CategoryService;
import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import com.kidspoint.api.organization.util.OrganizationContext;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/categories")
public class CategoryController extends ApiControllerBase {

    private final CategoryService categoryService;

    @Autowired
    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<CategoryResponse>> createCategory(
            @Valid @RequestBody CreateCategoryRequest request,
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
            CategoryResponse response = categoryService.createCategory(organizationId, request);
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(response, "Category created successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<CategoryResponse>>> listCategories(
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

        List<CategoryResponse> categories = categoryService.listCategories(organizationId);
        return ResponseEntity.ok(ApiResponse.ok(categories));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CategoryResponse>> getCategory(
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
            CategoryResponse response = categoryService.getCategory(organizationId, id);
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<CategoryResponse>> updateCategory(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateCategoryRequest request,
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
            CategoryResponse response = categoryService.updateCategory(organizationId, id, request);
            return ResponseEntity.ok(ApiResponse.ok(response, "Category updated successfully"));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCategory(
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
            categoryService.deleteCategory(organizationId, id);
            return ResponseEntity.ok(ApiResponse.ok(null, "Category deleted successfully"));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage()));
        }
    }
}
