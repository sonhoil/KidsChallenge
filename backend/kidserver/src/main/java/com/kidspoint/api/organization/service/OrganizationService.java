package com.kidspoint.api.organization.service;

import com.kidspoint.api.auth.domain.User;
import com.kidspoint.api.auth.mapper.UserMapper;
import com.kidspoint.api.box.mapper.BoxMapper;
import com.kidspoint.api.organization.domain.Organization;
import com.kidspoint.api.organization.domain.OrganizationMember;
import com.kidspoint.api.organization.dto.*;
import com.kidspoint.api.organization.mapper.OrganizationMapper;
import com.kidspoint.api.organization.mapper.OrganizationMemberMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class OrganizationService {

    private final OrganizationMapper organizationMapper;
    private final OrganizationMemberMapper organizationMemberMapper;
    private final UserMapper userMapper;
    private final BoxMapper boxMapper;

    @Autowired
    public OrganizationService(
            OrganizationMapper organizationMapper,
            OrganizationMemberMapper organizationMemberMapper,
            UserMapper userMapper,
            BoxMapper boxMapper) {
        this.organizationMapper = organizationMapper;
        this.organizationMemberMapper = organizationMemberMapper;
        this.userMapper = userMapper;
        this.boxMapper = boxMapper;
    }

    public OrganizationResponse createOrganization(UUID userId, CreateOrganizationRequest request) {
        // 조직 생성
        Organization organization = new Organization();
        organization.setId(UUID.randomUUID());
        organization.setName(request.getName());
        organization.setDescription(request.getDescription());
        // 테스트를 위해 기본값을 premium으로 설정
        organization.setPlan(Organization.Plan.premium);
        organization.setBoxLimit(20); // 프리미엄 플랜: 20개 상자
        organization.setAllowPublicJoin(false); // 기본값: QR 스캔 가입 비활성화
        organization.setCreatedAt(Instant.now());
        organization.setUpdatedAt(Instant.now());

        organizationMapper.insert(organization);

        // 생성자를 admin으로 멤버십 추가
        OrganizationMember member = new OrganizationMember();
        member.setId(UUID.randomUUID());
        member.setOrganizationId(organization.getId());
        member.setUserId(userId);
        member.setRole(OrganizationMember.OrgRole.admin);
        member.setIsFavorite(false);
        member.setJoinedAt(Instant.now());
        member.setLastActive(Instant.now());

        organizationMemberMapper.insert(member);

        // 응답에 역할 정보 포함
        OrganizationResponse response = toResponse(organization);
        response.setRole(OrganizationMember.OrgRole.admin.name());
        return response;
    }

    public List<OrganizationResponse> listMyOrganizations(UUID userId) {
        List<Organization> organizations = organizationMapper.selectByUserId(userId);
        return organizations.stream()
            .map(org -> {
                OrganizationResponse response = toResponse(org);
                // 사용자의 역할 정보 추가
                OrganizationMember member = organizationMemberMapper.selectByUserAndOrg(userId, org.getId());
                if (member != null) {
                    response.setRole(member.getRole().name());
                }
                // 상자 개수 추가
                int boxCount = boxMapper.countByOrganization(org.getId());
                response.setBoxCount(boxCount);
                return response;
            })
            .collect(Collectors.toList());
    }

    public OrganizationResponse getOrganizationDetail(UUID userId, UUID organizationId) {
        // 멤버십 확인
        OrganizationMember member = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (member == null) {
            throw new IllegalStateException("Access denied: Not a member of this organization");
        }

        Organization organization = organizationMapper.selectById(organizationId);
        if (organization == null) {
            throw new IllegalArgumentException("Organization not found");
        }

        return toResponse(organization);
    }

    public OrganizationMember.OrgRole getUserRoleInOrg(UUID userId, UUID organizationId) {
        OrganizationMember.OrgRole role = organizationMemberMapper.selectRoleByUserAndOrg(userId, organizationId);
        if (role == null) {
            throw new IllegalStateException("User is not a member of this organization");
        }
        return role;
    }

    public List<MemberResponse> listMembers(UUID userId, UUID organizationId) {
        // 관리자 권한 확인
        OrganizationMember requester = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (requester == null || requester.getRole() != OrganizationMember.OrgRole.admin) {
            throw new IllegalStateException("Only admins can view member list");
        }

        // 멤버 목록 조회
        List<OrganizationMember> members = organizationMemberMapper.selectByOrganizationId(organizationId);
        
        return members.stream().map(member -> {
            User user = userMapper.selectById(member.getUserId());
            MemberResponse response = new MemberResponse();
            response.setId(member.getId());
            response.setUserId(member.getUserId());
            response.setName(user != null ? (user.getNickname() != null ? user.getNickname() : user.getUsername()) : "Unknown");
            response.setEmail(user != null ? user.getEmail() : "");
            response.setRole(member.getRole().name());
            response.setJoinedAt(member.getJoinedAt());
            response.setLastActive(member.getLastActive());
            return response;
        }).collect(Collectors.toList());
    }

    public void updateMemberRole(UUID userId, UUID organizationId, UUID memberId, UpdateMemberRoleRequest request) {
        // 관리자 권한 확인
        OrganizationMember requester = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (requester == null || requester.getRole() != OrganizationMember.OrgRole.admin) {
            throw new IllegalStateException("Only admins can update member roles");
        }

        // 멤버 조회
        OrganizationMember member = organizationMemberMapper.selectById(memberId);
        if (member == null || !member.getOrganizationId().equals(organizationId)) {
            throw new IllegalArgumentException("Member not found");
        }

        // 관리자가 1명인 경우 강등 방지
        if (member.getRole() == OrganizationMember.OrgRole.admin && 
            OrganizationMember.OrgRole.valueOf(request.getRole()) == OrganizationMember.OrgRole.member) {
            List<OrganizationMember> admins = organizationMemberMapper.selectByOrganizationId(organizationId)
                .stream()
                .filter(m -> m.getRole() == OrganizationMember.OrgRole.admin)
                .collect(Collectors.toList());
            if (admins.size() == 1) {
                throw new IllegalStateException("Cannot demote the last admin. At least one admin must remain.");
            }
        }

        // 역할 변경
        member.setRole(OrganizationMember.OrgRole.valueOf(request.getRole()));
        organizationMemberMapper.update(member);
    }

    public void removeMember(UUID userId, UUID organizationId, UUID memberId) {
        // 관리자 권한 확인
        OrganizationMember requester = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (requester == null || requester.getRole() != OrganizationMember.OrgRole.admin) {
            throw new IllegalStateException("Only admins can remove members");
        }

        // 멤버 조회
        OrganizationMember member = organizationMemberMapper.selectById(memberId);
        if (member == null || !member.getOrganizationId().equals(organizationId)) {
            throw new IllegalArgumentException("Member not found");
        }

        // 자기 자신은 제거할 수 없음
        if (member.getUserId().equals(userId)) {
            throw new IllegalStateException("Cannot remove yourself from the organization");
        }

        // 관리자가 1명인 경우 제거 방지
        if (member.getRole() == OrganizationMember.OrgRole.admin) {
            List<OrganizationMember> admins = organizationMemberMapper.selectByOrganizationId(organizationId)
                .stream()
                .filter(m -> m.getRole() == OrganizationMember.OrgRole.admin)
                .collect(Collectors.toList());
            if (admins.size() == 1) {
                throw new IllegalStateException("Cannot remove the last admin. At least one admin must remain.");
            }
        }

        // 멤버 제거
        organizationMemberMapper.delete(memberId);
    }

    public OrganizationResponse updateOrganization(UUID userId, UUID organizationId, UpdateOrganizationRequest request) {
        // 관리자 권한 확인
        OrganizationMember requester = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (requester == null || requester.getRole() != OrganizationMember.OrgRole.admin) {
            throw new IllegalStateException("Only admins can update organization");
        }

        // 단체 조회
        Organization organization = organizationMapper.selectById(organizationId);
        if (organization == null) {
            throw new IllegalArgumentException("Organization not found");
        }

        // 정보 업데이트 (기존 plan과 boxLimit은 유지)
        organization.setName(request.getName());
        if (request.getDescription() != null) {
            organization.setDescription(request.getDescription());
        }
        if (request.getAllowPublicJoin() != null) {
            organization.setAllowPublicJoin(request.getAllowPublicJoin());
        }
        organization.setUpdatedAt(Instant.now());
        
        int updated = organizationMapper.update(organization);
        if (updated == 0) {
            throw new IllegalStateException("Failed to update organization");
        }

        // 업데이트된 정보 다시 조회
        Organization updatedOrg = organizationMapper.selectById(organizationId);
        return toResponse(updatedOrg);
    }

    public void deleteOrganization(UUID userId, UUID organizationId) {
        // 관리자 권한 확인
        OrganizationMember requester = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (requester == null || requester.getRole() != OrganizationMember.OrgRole.admin) {
            throw new IllegalStateException("Only admins can delete organization");
        }

        // 단체 조회
        Organization organization = organizationMapper.selectById(organizationId);
        if (organization == null) {
            throw new IllegalArgumentException("Organization not found");
        }

        // 단체 삭제 (CASCADE로 멤버, 상자, 물품 등이 자동 삭제됨)
        organizationMapper.delete(organizationId);
    }

    /**
     * QR 코드 스캔으로 단체 가입 (박스 ID로 단체 찾기)
     */
    public void joinByBoxQr(UUID userId, UUID boxId) {
        // 박스 ID로 organizationId 찾기
        UUID organizationId = boxMapper.selectOrganizationIdByBoxId(boxId);
        if (organizationId == null) {
            throw new IllegalArgumentException("Box not found");
        }

        // 단체 조회
        Organization organization = organizationMapper.selectById(organizationId);
        if (organization == null) {
            throw new IllegalArgumentException("Organization not found");
        }

        // allowPublicJoin 확인
        if (organization.getAllowPublicJoin() == null || !organization.getAllowPublicJoin()) {
            throw new IllegalStateException("This organization does not allow public join via QR code");
        }

        // 이미 멤버인지 확인
        OrganizationMember existing = organizationMemberMapper.selectByUserAndOrg(userId, organizationId);
        if (existing != null) {
            throw new IllegalStateException("User is already a member of this organization");
        }

        // 멤버 추가 (기본 역할: member)
        OrganizationMember member = new OrganizationMember();
        member.setId(UUID.randomUUID());
        member.setOrganizationId(organizationId);
        member.setUserId(userId);
        member.setRole(OrganizationMember.OrgRole.member);
        member.setIsFavorite(false);
        member.setJoinedAt(Instant.now());
        member.setLastActive(Instant.now());

        organizationMemberMapper.insert(member);
    }

    /**
     * 사용자의 모든 조직 멤버십의 최근 접속 시간을 업데이트
     */
    public void updateLastActive(UUID userId) {
        organizationMemberMapper.updateLastActiveByUserId(userId, Instant.now());
    }

    /**
     * 특정 조직에서 사용자의 최근 접속 시간을 업데이트
     */
    public void updateLastActive(UUID userId, UUID organizationId) {
        organizationMemberMapper.updateLastActiveByUserAndOrg(userId, organizationId, Instant.now());
    }

    private OrganizationResponse toResponse(Organization organization) {
        OrganizationResponse response = new OrganizationResponse();
        response.setId(organization.getId());
        response.setName(organization.getName());
        response.setDescription(organization.getDescription());
        response.setPlan(organization.getPlan() != null ? organization.getPlan().name() : "free");
        response.setBoxLimit(organization.getBoxLimit());
        response.setAllowPublicJoin(organization.getAllowPublicJoin() != null ? organization.getAllowPublicJoin() : false);
        response.setCreatedAt(organization.getCreatedAt());
        response.setUpdatedAt(organization.getUpdatedAt());
        return response;
    }
}
