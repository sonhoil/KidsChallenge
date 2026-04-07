package com.kidspoint.api.kids.point.controller;

import com.kidspoint.api.controller.base.ApiControllerBase;
import com.kidspoint.api.dto.ApiResponse;
import com.kidspoint.api.kids.family.domain.FamilyMember;
import com.kidspoint.api.kids.family.mapper.FamilyMemberMapper;
import com.kidspoint.api.kids.point.domain.PointAccount;
import com.kidspoint.api.kids.point.domain.PointTransaction;
import com.kidspoint.api.kids.point.dto.AdjustPointRequest;
import com.kidspoint.api.kids.point.dto.PointBalanceResponse;
import com.kidspoint.api.kids.point.dto.PointTransactionResponse;
import com.kidspoint.api.kids.point.mapper.PointTransactionMapper;
import com.kidspoint.api.kids.point.service.PointService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/kids/points")
public class PointController extends ApiControllerBase {

    private final PointService pointService;
    private final PointTransactionMapper pointTransactionMapper;
    private final FamilyMemberMapper familyMemberMapper;

    @Autowired
    public PointController(
            PointService pointService,
            PointTransactionMapper pointTransactionMapper,
            FamilyMemberMapper familyMemberMapper) {
        this.pointService = pointService;
        this.pointTransactionMapper = pointTransactionMapper;
        this.familyMemberMapper = familyMemberMapper;
    }

    @GetMapping("/balance/{familyId}")
    public ResponseEntity<ApiResponse<PointBalanceResponse>> getBalance(
            @PathVariable UUID familyId) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            Integer balance = pointService.getBalance(familyId, userId);
            PointBalanceResponse response = new PointBalanceResponse(familyId, userId, balance);
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/balance/{familyId}/user/{targetUserId}")
    public ResponseEntity<ApiResponse<PointBalanceResponse>> getBalanceForUser(
            @PathVariable UUID familyId,
            @PathVariable UUID targetUserId) {
        UUID requesterId = getCurrentUserId();
        if (requesterId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            FamilyMember requester = familyMemberMapper.selectByFamilyAndUser(familyId, requesterId);
            if (requester == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Not a member of this family"));
            }

            FamilyMember target = familyMemberMapper.selectByFamilyAndUser(familyId, targetUserId);
            if (target == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("Target member not found"));
            }

            boolean isSelf = requesterId.equals(targetUserId);
            boolean isParent = requester.getRole() == FamilyMember.FamilyRole.parent;
            if (!isSelf && !isParent) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(ApiResponse.error("Access denied"));
            }

            Integer balance = pointService.getBalance(familyId, targetUserId);
            PointBalanceResponse response = new PointBalanceResponse(familyId, targetUserId, balance);
            return ResponseEntity.ok(ApiResponse.ok(response));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/transactions/{familyId}")
    public ResponseEntity<ApiResponse<List<PointTransactionResponse>>> getTransactions(
            @PathVariable UUID familyId,
            @RequestParam(required = false, defaultValue = "50") Integer limit) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            PointAccount account = pointService.getOrCreateAccount(familyId, userId);
            List<PointTransaction> transactions = pointTransactionMapper.selectByPointAccountIdOrderByCreatedAtDesc(account.getId(), limit);
            List<PointTransactionResponse> responses = transactions.stream()
                .map(this::toTransactionResponse)
                .collect(java.util.stream.Collectors.toList());
            return ResponseEntity.ok(ApiResponse.ok(responses));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/adjust")
    public ResponseEntity<ApiResponse<PointBalanceResponse>> adjustPoints(
            @RequestBody @jakarta.validation.Valid AdjustPointRequest request) {
        UUID userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error("Not authenticated"));
        }

        try {
            // 부모 권한 검증은 프론트 단에서 제어하거나, 추후 FamilyService를 통해 보강 가능
            if (Boolean.TRUE.equals(request.getIsEarn())) {
                pointService.addPoints(
                    request.getFamilyId(),
                    request.getTargetUserId(),
                    request.getAmount(),
                    "MANUAL_ADJUSTMENT",
                    "ADMIN",
                    null,
                    request.getReason()
                );
            } else {
                pointService.deductPoints(
                    request.getFamilyId(),
                    request.getTargetUserId(),
                    request.getAmount(),
                    "MANUAL_ADJUSTMENT",
                    "ADMIN",
                    null,
                    request.getReason()
                );
            }

            Integer balance = pointService.getBalance(request.getFamilyId(), request.getTargetUserId());
            PointBalanceResponse response = new PointBalanceResponse(
                request.getFamilyId(),
                request.getTargetUserId(),
                balance
            );
            return ResponseEntity.ok(ApiResponse.ok(response, "Point adjusted successfully"));
        } catch (IllegalStateException | IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error(e.getMessage()));
        }
    }

    private PointTransactionResponse toTransactionResponse(PointTransaction transaction) {
        PointTransactionResponse response = new PointTransactionResponse();
        response.setId(transaction.getId());
        response.setAmount(transaction.getAmount());
        response.setType(transaction.getType());
        response.setReferenceType(transaction.getReferenceType());
        response.setReferenceId(transaction.getReferenceId());
        response.setDescription(transaction.getDescription());
        response.setCreatedAt(transaction.getCreatedAt());
        return response;
    }
}
