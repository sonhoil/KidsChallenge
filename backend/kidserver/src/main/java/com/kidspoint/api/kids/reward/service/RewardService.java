package com.kidspoint.api.kids.reward.service;

import com.kidspoint.api.auth.domain.User;
import com.kidspoint.api.auth.mapper.UserMapper;
import com.kidspoint.api.kids.family.domain.FamilyMember;
import com.kidspoint.api.kids.family.mapper.FamilyMemberMapper;
import com.kidspoint.api.kids.point.domain.PointAccount;
import com.kidspoint.api.kids.point.domain.PointTransaction;
import com.kidspoint.api.kids.point.mapper.PointTransactionMapper;
import com.kidspoint.api.kids.point.service.PointService;
import com.kidspoint.api.kids.reward.domain.Reward;
import com.kidspoint.api.kids.reward.domain.RewardPurchase;
import com.kidspoint.api.kids.reward.dto.*;
import com.kidspoint.api.kids.reward.mapper.RewardMapper;
import com.kidspoint.api.kids.reward.mapper.RewardPurchaseMapper;
import com.kidspoint.api.push.service.FcmPushService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class RewardService {

    private final RewardMapper rewardMapper;
    private final RewardPurchaseMapper rewardPurchaseMapper;
    private final FamilyMemberMapper familyMemberMapper;
    private final UserMapper userMapper;
    private final PointService pointService;
    private final PointTransactionMapper pointTransactionMapper;
    private final FcmPushService fcmPushService;

    @Autowired
    public RewardService(
            RewardMapper rewardMapper,
            RewardPurchaseMapper rewardPurchaseMapper,
            FamilyMemberMapper familyMemberMapper,
            UserMapper userMapper,
            PointService pointService,
            PointTransactionMapper pointTransactionMapper,
            FcmPushService fcmPushService) {
        this.rewardMapper = rewardMapper;
        this.rewardPurchaseMapper = rewardPurchaseMapper;
        this.familyMemberMapper = familyMemberMapper;
        this.userMapper = userMapper;
        this.pointService = pointService;
        this.pointTransactionMapper = pointTransactionMapper;
        this.fcmPushService = fcmPushService;
    }

    public RewardResponse createReward(UUID userId, CreateRewardRequest request) {
        // 부모 권한 확인
        FamilyMember member = familyMemberMapper.selectByFamilyAndUser(request.getFamilyId(), userId);
        if (member == null || member.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can create rewards");
        }

        Reward reward = new Reward();
        reward.setId(UUID.randomUUID());
        reward.setFamilyId(request.getFamilyId());
        reward.setTitle(request.getTitle());
        reward.setDescription(request.getDescription());
        reward.setPricePoints(request.getPricePoints());
        reward.setCategory(request.getCategory());
        reward.setIconType(request.getIconType());
        reward.setIsActive(true);
        reward.setCreatedBy(userId);
        reward.setCreatedAt(Instant.now());
        reward.setUpdatedAt(Instant.now());

        rewardMapper.insert(reward);
        return toRewardResponse(reward);
    }

    public List<RewardResponse> listRewardsByFamily(UUID familyId, Boolean activeOnly) {
        List<Reward> rewards;
        if (activeOnly != null && activeOnly) {
            rewards = rewardMapper.selectActiveByFamilyId(familyId);
        } else {
            rewards = rewardMapper.selectByFamilyId(familyId);
        }
        return rewards.stream()
            .map(this::toRewardResponse)
            .collect(Collectors.toList());
    }

    public RewardPurchaseResponse purchaseReward(UUID userId, UUID rewardId) {
        Reward reward = rewardMapper.selectById(rewardId);
        if (reward == null || !reward.getIsActive()) {
            throw new IllegalArgumentException("Reward not found or not available");
        }

        // 아이 권한 확인
        FamilyMember member = familyMemberMapper.selectByFamilyAndUser(reward.getFamilyId(), userId);
        if (member == null || member.getRole() != FamilyMember.FamilyRole.child) {
            throw new IllegalStateException("Only children can purchase rewards");
        }

        // 포인트 차감
        pointService.deductPoints(reward.getFamilyId(), userId, reward.getPricePoints(),
            "REWARD_PURCHASE", "REWARD", rewardId,
            "리워드 구매: " + reward.getTitle());

        // 포인트 트랜잭션 조회 (방금 생성된 것)
        PointAccount account = pointService.getOrCreateAccount(reward.getFamilyId(), userId);
        List<PointTransaction> transactions = pointTransactionMapper.selectByPointAccountIdOrderByCreatedAtDesc(account.getId(), 1);
        UUID pointTransactionId = transactions.isEmpty() ? null : transactions.get(0).getId();

        // 구매 내역 생성
        RewardPurchase purchase = new RewardPurchase();
        purchase.setId(UUID.randomUUID());
        purchase.setRewardId(rewardId);
        purchase.setBuyerId(userId);
        purchase.setFamilyId(reward.getFamilyId());
        purchase.setPointTransactionId(pointTransactionId);
        purchase.setStatus(RewardPurchase.PurchaseStatus.confirmed);
        purchase.setCreatedAt(Instant.now());
        purchase.setUpdatedAt(Instant.now());

        rewardPurchaseMapper.insert(purchase);

        notifyParentsStorePurchase(reward.getFamilyId(), member, reward);
        return toPurchaseResponse(purchase, reward, member);
    }

    private void notifyParentsStorePurchase(UUID familyId, FamilyMember buyerMember, Reward reward) {
        if (!fcmPushService.isFcmEnabled()) {
            return;
        }
        List<UUID> parentIds = familyMemberMapper.selectByFamilyId(familyId).stream()
            .filter(m -> m.getRole() == FamilyMember.FamilyRole.parent)
            .map(FamilyMember::getUserId)
            .collect(Collectors.toList());
        if (parentIds.isEmpty()) {
            return;
        }
        String buyerName = (buyerMember != null && buyerMember.getNickname() != null && !buyerMember.getNickname().isBlank())
            ? buyerMember.getNickname() : "아이";
        String title = reward.getTitle() != null ? reward.getTitle() : "쿠폰";
        Map<String, String> data = new HashMap<>();
        data.put(FcmPushService.DATA_TYPE, FcmPushService.TYPE_REWARD_PURCHASED);
        fcmPushService.sendToUsers(parentIds, "상점 구매 알림",
            buyerName + "님이 「" + title + "」을(를) 구매했어요.", data);
    }

    public List<RewardPurchaseResponse> getMyPurchases(UUID userId, String status) {
        List<RewardPurchase> purchases;
        if (status != null && !status.isEmpty()) {
            try {
                RewardPurchase.PurchaseStatus purchaseStatus = RewardPurchase.PurchaseStatus.valueOf(status);
                purchases = rewardPurchaseMapper.selectByBuyerIdAndStatus(userId, purchaseStatus);
            } catch (IllegalArgumentException e) {
                purchases = rewardPurchaseMapper.selectByBuyerId(userId);
            }
        } else {
            purchases = rewardPurchaseMapper.selectByBuyerId(userId);
        }

        return purchases.stream()
            .map(purchase -> {
                Reward reward = rewardMapper.selectById(purchase.getRewardId());
                FamilyMember member = familyMemberMapper.selectByFamilyAndUser(purchase.getFamilyId(), purchase.getBuyerId());
                return toPurchaseResponse(purchase, reward, member);
            })
            .collect(Collectors.toList());
    }

    public List<RewardPurchaseResponse> getFamilyPurchases(UUID userId, UUID familyId) {
        FamilyMember parentMember = familyMemberMapper.selectByFamilyAndUser(familyId, userId);
        if (parentMember == null || parentMember.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can view family purchases");
        }

        return rewardPurchaseMapper.selectByFamilyId(familyId).stream()
            .map(purchase -> {
                Reward reward = rewardMapper.selectById(purchase.getRewardId());
                FamilyMember member = familyMemberMapper.selectByFamilyAndUser(purchase.getFamilyId(), purchase.getBuyerId());
                return toPurchaseResponse(purchase, reward, member);
            })
            .collect(Collectors.toList());
    }

    public RewardPurchaseResponse usePurchase(UUID userId, UUID purchaseId) {
        RewardPurchase purchase = rewardPurchaseMapper.selectById(purchaseId);
        if (purchase == null) {
            throw new IllegalArgumentException("Reward purchase not found");
        }

        // 본인만 사용 가능
        if (!purchase.getBuyerId().equals(userId)) {
            throw new IllegalStateException("Only the owner can use this reward");
        }

        if (purchase.getStatus() != RewardPurchase.PurchaseStatus.confirmed) {
            throw new IllegalStateException("Reward is not in a usable status");
        }

        purchase.setStatus(RewardPurchase.PurchaseStatus.used);
        purchase.setUpdatedAt(Instant.now());
        rewardPurchaseMapper.update(purchase);

        Reward reward = rewardMapper.selectById(purchase.getRewardId());
        FamilyMember member = familyMemberMapper.selectByFamilyAndUser(purchase.getFamilyId(), purchase.getBuyerId());
        return toPurchaseResponse(purchase, reward, member);
    }

    public RewardPurchaseResponse updatePurchaseStatusByParent(UUID userId, UUID purchaseId, String status) {
        RewardPurchase purchase = rewardPurchaseMapper.selectById(purchaseId);
        if (purchase == null) {
            throw new IllegalArgumentException("Reward purchase not found");
        }

        FamilyMember parentMember = familyMemberMapper.selectByFamilyAndUser(purchase.getFamilyId(), userId);
        if (parentMember == null || parentMember.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can manage reward purchases");
        }

        RewardPurchase.PurchaseStatus nextStatus;
        try {
            nextStatus = RewardPurchase.PurchaseStatus.valueOf(status);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid purchase status");
        }

        if (nextStatus != RewardPurchase.PurchaseStatus.confirmed
                && nextStatus != RewardPurchase.PurchaseStatus.used) {
            throw new IllegalArgumentException("Only confirmed or used status can be managed");
        }

        purchase.setStatus(nextStatus);
        purchase.setUpdatedAt(Instant.now());
        rewardPurchaseMapper.update(purchase);

        Reward reward = rewardMapper.selectById(purchase.getRewardId());
        FamilyMember member = familyMemberMapper.selectByFamilyAndUser(purchase.getFamilyId(), purchase.getBuyerId());
        return toPurchaseResponse(purchase, reward, member);
    }

    public RewardResponse updateReward(UUID userId, UUID rewardId, CreateRewardRequest request) {
        Reward reward = rewardMapper.selectById(rewardId);
        if (reward == null) {
            throw new IllegalArgumentException("Reward not found");
        }

        FamilyMember member = familyMemberMapper.selectByFamilyAndUser(reward.getFamilyId(), userId);
        if (member == null || member.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can update rewards");
        }

        reward.setTitle(request.getTitle());
        reward.setDescription(request.getDescription());
        reward.setPricePoints(request.getPricePoints());
        reward.setCategory(request.getCategory());
        reward.setIconType(request.getIconType());
        reward.setUpdatedAt(Instant.now());

        rewardMapper.update(reward);
        return toRewardResponse(reward);
    }

    public void deleteReward(UUID userId, UUID rewardId) {
        Reward reward = rewardMapper.selectById(rewardId);
        if (reward == null) {
            throw new IllegalArgumentException("Reward not found");
        }

        FamilyMember member = familyMemberMapper.selectByFamilyAndUser(reward.getFamilyId(), userId);
        if (member == null || member.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can delete rewards");
        }

        rewardMapper.delete(rewardId);
    }

    public RewardResponse updateRewardVisibility(UUID userId, UUID rewardId, boolean isActive) {
        Reward reward = rewardMapper.selectById(rewardId);
        if (reward == null) {
            throw new IllegalArgumentException("Reward not found");
        }

        FamilyMember member = familyMemberMapper.selectByFamilyAndUser(reward.getFamilyId(), userId);
        if (member == null || member.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can manage reward visibility");
        }

        reward.setIsActive(isActive);
        reward.setUpdatedAt(Instant.now());
        rewardMapper.update(reward);
        return toRewardResponse(reward);
    }

    private RewardResponse toRewardResponse(Reward reward) {
        RewardResponse response = new RewardResponse();
        response.setId(reward.getId());
        response.setFamilyId(reward.getFamilyId());
        response.setTitle(reward.getTitle());
        response.setDescription(reward.getDescription());
        response.setPricePoints(reward.getPricePoints());
        response.setCategory(reward.getCategory());
        response.setIconType(reward.getIconType());
        response.setIsActive(reward.getIsActive());
        response.setCreatedBy(reward.getCreatedBy());
        response.setCreatedAt(reward.getCreatedAt());
        response.setUpdatedAt(reward.getUpdatedAt());
        return response;
    }

    private RewardPurchaseResponse toPurchaseResponse(RewardPurchase purchase, Reward reward, FamilyMember member) {
        RewardPurchaseResponse response = new RewardPurchaseResponse();
        response.setId(purchase.getId());
        response.setRewardId(purchase.getRewardId());
        if (reward != null) {
            response.setRewardTitle(reward.getTitle());
            response.setRewardIconType(reward.getIconType());
        }
        response.setBuyerId(purchase.getBuyerId());
        if (member != null) {
            response.setBuyerNickname(member.getNickname());
        }
        response.setFamilyId(purchase.getFamilyId());
        response.setStatus(purchase.getStatus().name());
        response.setNotes(purchase.getNotes());
        response.setCreatedAt(purchase.getCreatedAt());
        response.setUpdatedAt(purchase.getUpdatedAt());
        return response;
    }
}
