package com.kidspoint.api.subscription.service;

import com.kidspoint.api.organization.domain.Organization;
import com.kidspoint.api.organization.domain.OrganizationMember;
import com.kidspoint.api.organization.mapper.OrganizationMapper;
import com.kidspoint.api.organization.mapper.OrganizationMemberMapper;
import com.kidspoint.api.subscription.domain.Subscription;
import com.kidspoint.api.subscription.dto.CreatePaymentRequest;
import com.kidspoint.api.subscription.dto.SubscriptionResponse;
import com.kidspoint.api.subscription.dto.VerifyIAPRequest;
import com.kidspoint.api.subscription.mapper.SubscriptionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@Transactional
public class SubscriptionService {

    private final SubscriptionMapper subscriptionMapper;
    private final OrganizationMapper organizationMapper;
    private final OrganizationMemberMapper organizationMemberMapper;

    @Autowired
    public SubscriptionService(
            SubscriptionMapper subscriptionMapper,
            OrganizationMapper organizationMapper,
            OrganizationMemberMapper organizationMemberMapper) {
        this.subscriptionMapper = subscriptionMapper;
        this.organizationMapper = organizationMapper;
        this.organizationMemberMapper = organizationMemberMapper;
    }

    /**
     * 결제 성공 후 프리미엄 플랜으로 업그레이드
     */
    public SubscriptionResponse createSubscription(UUID userId, CreatePaymentRequest request) {
        UUID organizationId = UUID.fromString(request.getOrganizationId());

        // 관리자 권한 확인
        OrganizationMember requester = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (requester == null || requester.getRole() != OrganizationMember.OrgRole.admin) {
            throw new IllegalStateException("Only admins can create subscriptions");
        }

        // 단체 조회
        Organization organization = organizationMapper.selectById(organizationId);
        if (organization == null) {
            throw new IllegalArgumentException("Organization not found");
        }

        // 이미 프리미엄인 경우 확인
        if (organization.getPlan() == Organization.Plan.premium) {
            throw new IllegalStateException("Organization is already on premium plan");
        }

        // 구독 생성
        Subscription subscription = new Subscription();
        subscription.setId(UUID.randomUUID());
        subscription.setOrganizationId(organizationId);
        subscription.setPaymentProvider(request.getPaymentProvider());
        subscription.setPaymentId(request.getProviderPaymentId());
        subscription.setCustomerId(request.getCustomerId());
        subscription.setStatus(Subscription.Status.active);
        
        // 구독 기간 설정 (월간 구독: 30일)
        Instant now = Instant.now();
        subscription.setCurrentPeriodStart(now);
        subscription.setCurrentPeriodEnd(now.plusSeconds(30L * 24 * 60 * 60)); // 30일 후
        subscription.setTrialEnd(null); // 트라이얼 없음
        subscription.setCreatedAt(now);
        subscription.setUpdatedAt(now);

        subscriptionMapper.insert(subscription);

        // 단체 플랜 업그레이드
        organization.setPlan(Organization.Plan.premium);
        organization.setBoxLimit(20); // 프리미엄 플랜: 20개 상자
        organization.setUpdatedAt(now);
        organizationMapper.update(organization);

        return toResponse(subscription);
    }

    /**
     * 구독 취소
     */
    public void cancelSubscription(UUID userId, UUID organizationId) {
        // 관리자 권한 확인
        OrganizationMember requester = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (requester == null || requester.getRole() != OrganizationMember.OrgRole.admin) {
            throw new IllegalStateException("Only admins can cancel subscriptions");
        }

        Subscription subscription = subscriptionMapper.selectByOrganizationId(organizationId);
        if (subscription == null) {
            throw new IllegalArgumentException("Subscription not found");
        }

        // 구독 상태를 canceled로 변경
        subscription.setStatus(Subscription.Status.canceled);
        subscription.setUpdatedAt(Instant.now());
        subscriptionMapper.update(subscription);

        // 단체 플랜을 free로 다운그레이드 (다음 결제 주기까지는 프리미엄 유지)
        // 또는 즉시 다운그레이드할지 결정 필요
        // 현재는 구독 기간이 끝날 때까지 프리미엄 유지
    }

    /**
     * 구독 조회
     */
    public SubscriptionResponse getSubscription(UUID userId, UUID organizationId) {
        // 멤버십 확인
        OrganizationMember member = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (member == null) {
            throw new IllegalStateException("Access denied: Not a member of this organization");
        }

        Subscription subscription = subscriptionMapper.selectByOrganizationId(organizationId);
        if (subscription == null) {
            throw new IllegalArgumentException("Subscription not found");
        }

        return toResponse(subscription);
    }

    /**
     * 인앱 구매 영수증 검증 및 구독 생성
     */
    public SubscriptionResponse verifyIAPAndCreateSubscription(UUID userId, VerifyIAPRequest request) {
        UUID organizationId = UUID.fromString(request.getOrganizationId());

        // 관리자 권한 확인
        OrganizationMember requester = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (requester == null || requester.getRole() != OrganizationMember.OrgRole.admin) {
            throw new IllegalStateException("Only admins can create subscriptions");
        }

        // 영수증 검증 (Google Play 또는 App Store)
        boolean isValid = verifyReceipt(request);
        if (!isValid) {
            throw new IllegalStateException("Invalid receipt");
        }

        // 단체 조회
        Organization organization = organizationMapper.selectById(organizationId);
        if (organization == null) {
            throw new IllegalArgumentException("Organization not found");
        }

        // 이미 프리미엄인 경우 확인
        if (organization.getPlan() == Organization.Plan.premium) {
            throw new IllegalStateException("Organization is already on premium plan");
        }

        // 구독 생성
        Subscription subscription = new Subscription();
        subscription.setId(UUID.randomUUID());
        subscription.setOrganizationId(organizationId);
        subscription.setPaymentProvider("iap_" + request.getPlatform()); // "iap_android" or "iap_ios"
        subscription.setPaymentId(request.getTransactionId());
        subscription.setCustomerId(request.getPurchaseToken() != null ? request.getPurchaseToken() : request.getTransactionId());
        subscription.setStatus(Subscription.Status.active);
        
        // 구독 기간 설정 (월간 구독: 30일)
        Instant now = Instant.now();
        subscription.setCurrentPeriodStart(now);
        subscription.setCurrentPeriodEnd(now.plusSeconds(30L * 24 * 60 * 60)); // 30일 후
        subscription.setTrialEnd(null);
        subscription.setCreatedAt(now);
        subscription.setUpdatedAt(now);

        subscriptionMapper.insert(subscription);

        // 단체 플랜 업그레이드
        organization.setPlan(Organization.Plan.premium);
        organization.setBoxLimit(20); // 프리미엄 플랜: 20개 상자
        organization.setUpdatedAt(now);
        organizationMapper.update(organization);

        return toResponse(subscription);
    }

    /**
     * 영수증 검증 (Google Play 또는 App Store)
     * TODO: 실제 검증 로직 구현 필요
     * - Android: Google Play Developer API 사용
     * - iOS: App Store Server API 사용
     */
    private boolean verifyReceipt(VerifyIAPRequest request) {
        // 테스트 모드: test_receipt_data 또는 test_purchase_token으로 시작하는 경우 허용
        if (request.getReceipt() != null && request.getReceipt().startsWith("test_")) {
            return true;
        }
        if (request.getPurchaseToken() != null && request.getPurchaseToken().startsWith("test_")) {
            return true;
        }
        
        // TODO: 실제 영수증 검증 로직 구현
        // Android의 경우:
        // - Google Play Developer API의 purchases.subscriptions.verify 호출
        // - purchaseToken을 사용하여 검증
        // iOS의 경우:
        // - App Store Server API의 verifyReceipt 엔드포인트 호출
        // - receipt data를 사용하여 검증
        
        // 현재는 기본 검증만 수행 (실제로는 각 플랫폼 API 호출 필요)
        if (request.getPlatform().equals("android")) {
            return request.getPurchaseToken() != null && !request.getPurchaseToken().isEmpty();
        } else if (request.getPlatform().equals("ios")) {
            return request.getReceipt() != null && !request.getReceipt().isEmpty();
        }
        return false;
    }

    private SubscriptionResponse toResponse(Subscription subscription) {
        SubscriptionResponse response = new SubscriptionResponse();
        response.setId(subscription.getId());
        response.setOrganizationId(subscription.getOrganizationId());
        response.setPaymentProvider(subscription.getPaymentProvider());
        response.setStatus(subscription.getStatus() != null ? subscription.getStatus().name() : "trial");
        response.setCurrentPeriodStart(subscription.getCurrentPeriodStart());
        response.setCurrentPeriodEnd(subscription.getCurrentPeriodEnd());
        response.setTrialEnd(subscription.getTrialEnd());
        response.setCreatedAt(subscription.getCreatedAt());
        response.setUpdatedAt(subscription.getUpdatedAt());
        return response;
    }
}
