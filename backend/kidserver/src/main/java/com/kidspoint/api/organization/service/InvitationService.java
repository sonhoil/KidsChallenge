package com.kidspoint.api.organization.service;

import com.kidspoint.api.organization.domain.Invitation;
import com.kidspoint.api.organization.domain.Organization;
import com.kidspoint.api.organization.domain.OrganizationMember;
import com.kidspoint.api.organization.dto.CreateInvitationRequest;
import com.kidspoint.api.organization.dto.InvitationResponse;
import com.kidspoint.api.organization.mapper.InvitationMapper;
import com.kidspoint.api.organization.mapper.OrganizationMapper;
import com.kidspoint.api.organization.mapper.OrganizationMemberMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;

@Service
@Transactional
public class InvitationService {

    private final InvitationMapper invitationMapper;
    private final OrganizationMapper organizationMapper;
    private final OrganizationMemberMapper organizationMemberMapper;

    @Value("${app.frontend-url:http://localhost:5173}")
    private String frontendUrl;

    @Autowired
    public InvitationService(
            InvitationMapper invitationMapper,
            OrganizationMapper organizationMapper,
            OrganizationMemberMapper organizationMemberMapper) {
        this.invitationMapper = invitationMapper;
        this.organizationMapper = organizationMapper;
        this.organizationMemberMapper = organizationMemberMapper;
    }

    /**
     * 초대 링크 생성
     */
    public InvitationResponse createInvitation(UUID userId, UUID organizationId, CreateInvitationRequest request) {
        // 조직 존재 확인
        Organization organization = organizationMapper.selectById(organizationId);
        if (organization == null) {
            throw new IllegalArgumentException("Organization not found");
        }

        // 사용자가 해당 조직의 admin인지 확인
        OrganizationMember member = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (member == null || member.getRole() != OrganizationMember.OrgRole.admin) {
            throw new IllegalStateException("Only admins can create invitations");
        }

        // 이미 초대된 이메일인지 확인 (만료되지 않은 초대)
        Invitation existing = invitationMapper.selectByOrganizationAndEmail(organizationId, request.getEmail());
        if (existing != null) {
            throw new IllegalStateException("Invitation already exists for this email");
        }

        // 토큰 생성
        String token = generateToken();

        // 초대 생성
        Invitation invitation = new Invitation();
        invitation.setId(UUID.randomUUID());
        invitation.setOrganizationId(organizationId);
        invitation.setEmail(request.getEmail());
        invitation.setRole(OrganizationMember.OrgRole.valueOf(request.getRole()));
        invitation.setToken(token);
        invitation.setExpiresAt(Instant.now().plusSeconds(7 * 24 * 60 * 60)); // 7일 후 만료
        invitation.setCreatedBy(userId);
        invitation.setCreatedAt(Instant.now());

        invitationMapper.insert(invitation);

        // 응답 생성
        InvitationResponse response = new InvitationResponse();
        response.setId(invitation.getId());
        response.setOrganizationId(organizationId);
        response.setOrganizationName(organization.getName());
        response.setEmail(request.getEmail());
        response.setRole(request.getRole());
        response.setInviteLink(frontendUrl + "/?jointoken=" + token);
        response.setExpiresAt(invitation.getExpiresAt());
        response.setCreatedAt(invitation.getCreatedAt());

        return response;
    }

    /**
     * 토큰으로 초대 정보 조회
     */
    public InvitationResponse getInvitationByToken(String token) {
        Invitation invitation = invitationMapper.selectByToken(token);
        if (invitation == null) {
            throw new IllegalArgumentException("Invalid invitation token");
        }

        if (invitation.getAcceptedAt() != null) {
            throw new IllegalStateException("Invitation already accepted");
        }

        if (invitation.getExpiresAt().isBefore(Instant.now())) {
            throw new IllegalStateException("Invitation has expired");
        }

        Organization organization = organizationMapper.selectById(invitation.getOrganizationId());
        if (organization == null) {
            throw new IllegalArgumentException("Organization not found");
        }

        InvitationResponse response = new InvitationResponse();
        response.setId(invitation.getId());
        response.setOrganizationId(invitation.getOrganizationId());
        response.setOrganizationName(organization.getName());
        response.setEmail(invitation.getEmail());
        response.setRole(invitation.getRole().name());
        response.setInviteLink(frontendUrl + "/?jointoken=" + token);
        response.setExpiresAt(invitation.getExpiresAt());
        response.setCreatedAt(invitation.getCreatedAt());

        return response;
    }

    /**
     * 토큰으로 단체 가입
     * @return 가입한 단체 ID
     */
    public UUID joinByToken(UUID userId, String token) {
        Invitation invitation = invitationMapper.selectByToken(token);
        if (invitation == null) {
            throw new IllegalArgumentException("Invalid invitation token");
        }

        // 초대 만료 확인
        if (invitation.getExpiresAt().isBefore(Instant.now())) {
            throw new IllegalStateException("Invitation has expired");
        }

        // 이미 멤버인지 확인 (현재 멤버인 경우만 차단)
        OrganizationMember existing = organizationMemberMapper.selectByUserAndOrg(userId, invitation.getOrganizationId());
        if (existing != null) {
            throw new IllegalStateException("User is already a member of this organization");
        }

        // 멤버 추가
        OrganizationMember member = new OrganizationMember();
        member.setId(UUID.randomUUID());
        member.setOrganizationId(invitation.getOrganizationId());
        member.setUserId(userId);
        member.setRole(invitation.getRole());
        member.setIsFavorite(false);
        member.setJoinedAt(Instant.now());
        member.setLastActive(Instant.now());

        organizationMemberMapper.insert(member);

        // 초대 수락 처리 (이미 수락된 경우에도 업데이트 - 탈퇴 후 재가입 시나리오 대응)
        if (invitation.getAcceptedAt() == null) {
            invitationMapper.updateAcceptedAt(invitation.getId(), Instant.now());
        }
        
        // 가입한 단체 ID 반환
        return invitation.getOrganizationId();
    }

    /**
     * 안전한 토큰 생성
     */
    private String generateToken() {
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
