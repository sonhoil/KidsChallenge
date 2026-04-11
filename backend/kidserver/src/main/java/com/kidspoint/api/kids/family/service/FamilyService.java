package com.kidspoint.api.kids.family.service;

import com.kidspoint.api.auth.domain.User;
import com.kidspoint.api.auth.mapper.UserMapper;
import com.kidspoint.api.kids.family.domain.Family;
import com.kidspoint.api.kids.family.domain.FamilyMember;
import com.kidspoint.api.kids.family.dto.CreateFamilyMemberRequest;
import com.kidspoint.api.kids.family.dto.CreateFamilyRequest;
import com.kidspoint.api.kids.family.dto.FamilyMemberResponse;
import com.kidspoint.api.kids.family.dto.FamilyResponse;
import com.kidspoint.api.kids.family.mapper.FamilyMapper;
import com.kidspoint.api.kids.family.mapper.FamilyMemberMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class FamilyService {

    private final FamilyMapper familyMapper;
    private final FamilyMemberMapper familyMemberMapper;
    private final UserMapper userMapper;

    @Autowired
    public FamilyService(FamilyMapper familyMapper, FamilyMemberMapper familyMemberMapper, UserMapper userMapper) {
        this.familyMapper = familyMapper;
        this.familyMemberMapper = familyMemberMapper;
        this.userMapper = userMapper;
    }

    public FamilyResponse createFamily(UUID userId, CreateFamilyRequest request) {
        System.out.println("[FamilyService] Creating family for user: " + userId + ", name: " + request.getName());
        
        // 초대코드 생성 (6자리 랜덤 문자열)
        String inviteCode = generateInviteCode();
        System.out.println("[FamilyService] Generated invite code: " + inviteCode);
        
        Family family = new Family();
        family.setId(UUID.randomUUID());
        family.setName(request.getName() != null ? request.getName() : "우리 가족");
        family.setInviteCode(inviteCode);
        family.setCreatedAt(Instant.now());
        family.setUpdatedAt(Instant.now());

        familyMapper.insert(family);
        System.out.println("[FamilyService] Family created: " + family.getId());

        User user = userMapper.selectById(userId);
        String parentNickname = user != null ? user.getNickname() : null;

        // 부모로 멤버 추가
        FamilyMember member = new FamilyMember();
        member.setId(UUID.randomUUID());
        member.setFamilyId(family.getId());
        member.setUserId(userId);
        member.setRole(FamilyMember.FamilyRole.parent);
        member.setNickname(parentNickname);
        member.setAvatarUrl(null);
        member.setCreatedAt(Instant.now());
        member.setUpdatedAt(Instant.now());

        familyMemberMapper.insert(member);
        System.out.println("[FamilyService] Member added as parent");

        FamilyResponse response = toFamilyResponse(family);
        response.setRole(member.getRole().name());
        return response;
    }
    
    /**
     * 6자리 랜덤 초대코드 생성
     */
    private String generateInviteCode() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        java.util.Random random = new java.util.Random();
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < 6; i++) {
            code.append(chars.charAt(random.nextInt(chars.length())));
        }
        return code.toString();
    }

    public List<FamilyResponse> listMyFamilies(UUID userId) {
        List<FamilyMember> memberships = familyMemberMapper.selectByUserId(userId);
        return memberships.stream()
            .map(member -> {
                Family family = familyMapper.selectById(member.getFamilyId());
                if (family == null) {
                    return null;
                }
                FamilyResponse res = toFamilyResponse(family);
                res.setRole(member.getRole().name());
                return res;
            })
            .filter(java.util.Objects::nonNull)
            .collect(Collectors.toList());
    }

    public List<FamilyMemberResponse> listMembers(UUID userId, UUID familyId) {
        // 사용자가 이 가족의 멤버인지 확인 (간단히 존재 여부만 체크)
        FamilyMember self = familyMemberMapper.selectByFamilyAndUser(familyId, userId);
        if (self == null) {
            throw new IllegalStateException("Access denied: not a member of this family");
        }

        List<FamilyMember> members = familyMemberMapper.selectByFamilyId(familyId);
        return members.stream()
            .map(this::toFamilyMemberResponse)
            .collect(Collectors.toList());
    }

    public FamilyResponse updateFamilyName(UUID userId, UUID familyId, String name) {
        FamilyMember self = familyMemberMapper.selectByFamilyAndUser(familyId, userId);
        if (self == null || self.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can update family info");
        }
        Family family = familyMapper.selectById(familyId);
        if (family == null) {
            throw new IllegalArgumentException("Family not found");
        }
        family.setName(name);
        family.setUpdatedAt(Instant.now());
        familyMapper.update(family);
        FamilyResponse res = toFamilyResponse(family);
        res.setRole(self.getRole().name());
        return res;
    }

    public FamilyMemberResponse addMember(UUID userId, UUID familyId, CreateFamilyMemberRequest request) {
        // 부모만 멤버 추가 가능
        FamilyMember self = familyMemberMapper.selectByFamilyAndUser(familyId, userId);
        if (self == null || self.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can add family members");
        }

        Family family = familyMapper.selectById(familyId);
        if (family == null) {
            throw new IllegalArgumentException("Family not found");
        }

        FamilyMember.FamilyRole role;
        try {
            role = FamilyMember.FamilyRole.valueOf(request.getRole());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid role: " + request.getRole());
        }

        // userId 가 있는 경우에만 "이미 가족 멤버인지" 검사한다.
        // 아이 계정은 소셜/이메일 계정과 아직 연결되지 않았을 수 있으므로,
        // userId 가 null 인 경우는 중복 검사 없이 신규 멤버로 허용한다.
        if (request.getUserId() != null) {
            FamilyMember existing = familyMemberMapper.selectByFamilyAndUser(familyId, request.getUserId());
            if (existing != null) {
                throw new IllegalStateException("User is already a member of this family");
            }
        }

        FamilyMember member = new FamilyMember();
        member.setId(UUID.randomUUID());
        member.setFamilyId(familyId);
        member.setUserId(request.getUserId()); // NULL 가능
        member.setRole(role);
        member.setNickname(request.getNickname());
        member.setAvatarUrl(request.getAvatarUrl());
        member.setCreatedAt(Instant.now());
        member.setUpdatedAt(Instant.now());

        familyMemberMapper.insert(member);
        return toFamilyMemberResponse(member);
    }

    /**
     * 가족 멤버 삭제
     */
    public void deleteMember(UUID userId, UUID familyId, UUID memberId) {
        // 요청 사용자가 이 가족의 부모인지 확인
        FamilyMember self = familyMemberMapper.selectByFamilyAndUser(familyId, userId);
        if (self == null || self.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can delete family members");
        }

        FamilyMember target = familyMemberMapper.selectById(memberId);
        if (target == null || !target.getFamilyId().equals(familyId)) {
            throw new IllegalArgumentException("Family member not found");
        }

        // 마지막 부모를 삭제하는 것은 방지
        if (target.getRole() == FamilyMember.FamilyRole.parent) {
            List<FamilyMember> members = familyMemberMapper.selectByFamilyId(familyId);
            long parentCount = members.stream()
                .filter(m -> m.getRole() == FamilyMember.FamilyRole.parent)
                .count();
            if (parentCount <= 1) {
                throw new IllegalStateException("Cannot delete the last parent of the family");
            }
        }

        familyMemberMapper.delete(memberId);
    }

    private FamilyResponse toFamilyResponse(Family family) {
        FamilyResponse response = new FamilyResponse();
        response.setId(family.getId());
        response.setName(family.getName());
        response.setInviteCode(family.getInviteCode());
        response.setCreatedAt(family.getCreatedAt());
        response.setUpdatedAt(family.getUpdatedAt());
        return response;
    }

    /**
     * 초대코드로 가족 가입
     * 부모가 정해둔 역할(아이 또는 부모)로 가입
     */
    public FamilyResponse joinByInviteCode(UUID userId, String inviteCode, String nickname, UUID memberId) {
        System.out.println("[FamilyService] Joining family by invite code: " + inviteCode + ", userId: " + userId);
        
        // 초대코드로 가족 찾기
        Family family = familyMapper.selectByInviteCode(inviteCode);
        if (family == null) {
            System.out.println("[FamilyService] Family not found for invite code: " + inviteCode);
            throw new IllegalArgumentException("Invalid invite code");
        }
        
        System.out.println("[FamilyService] Family found: " + family.getId() + ", name: " + family.getName());
        
        // 이미 멤버인지 확인
        FamilyMember existing = familyMemberMapper.selectByFamilyAndUser(family.getId(), userId);
        if (existing != null) {
            System.out.println("[FamilyService] User is already a member of this family");
            FamilyResponse response = toFamilyResponse(family);
            response.setRole(existing.getRole().name());
            return response;
        }

        if (memberId != null) {
            FamilyMember targetMember = familyMemberMapper.selectById(memberId);
            if (targetMember == null || !targetMember.getFamilyId().equals(family.getId())) {
                throw new IllegalArgumentException("Invalid member invite");
            }
            if (targetMember.getRole() != FamilyMember.FamilyRole.child) {
                throw new IllegalStateException("Only child profiles can be linked with this invite");
            }
            if (targetMember.getUserId() != null) {
                throw new IllegalStateException("This child profile is already linked to another account");
            }

            targetMember.setUserId(userId);
            if ((targetMember.getNickname() == null || targetMember.getNickname().isBlank())
                    && nickname != null && !nickname.isBlank()) {
                targetMember.setNickname(nickname);
            }
            targetMember.setUpdatedAt(Instant.now());
            familyMemberMapper.update(targetMember);

            FamilyResponse response = toFamilyResponse(family);
            response.setRole(targetMember.getRole().name());
            return response;
        }
        
        // 부모가 정해둔 역할 확인 (가족의 첫 번째 부모 멤버를 찾아서 역할 결정)
        // 기본적으로는 child 역할로 가입하지만, 부모가 이미 있으면 child, 없으면 parent
        List<FamilyMember> existingMembers = familyMemberMapper.selectByFamilyId(family.getId());
        FamilyMember.FamilyRole role;
        boolean hasParent = existingMembers.stream()
            .anyMatch(m -> m.getRole() == FamilyMember.FamilyRole.parent);
        
        if (hasParent) {
            // 부모가 있으면 아이로 가입
            role = FamilyMember.FamilyRole.child;
            System.out.println("[FamilyService] Parent exists, joining as child");
        } else {
            // 부모가 없으면 부모로 가입
            role = FamilyMember.FamilyRole.parent;
            System.out.println("[FamilyService] No parent exists, joining as parent");
        }
        
        // 멤버 추가
        FamilyMember member = new FamilyMember();
        member.setId(UUID.randomUUID());
        member.setFamilyId(family.getId());
        member.setUserId(userId);
        member.setRole(role);
        member.setNickname(nickname);
        member.setAvatarUrl(null);
        member.setCreatedAt(Instant.now());
        member.setUpdatedAt(Instant.now());
        
        familyMemberMapper.insert(member);
        System.out.println("[FamilyService] Member added successfully with role: " + role);
        
        // 포인트 계좌 생성 (아이인 경우만)
        if (role == FamilyMember.FamilyRole.child) {
            // PointAccount는 PointService에서 생성하도록 하거나, 여기서 직접 생성
            // 일단 여기서는 생성하지 않고, 필요시 PointService 호출
        }
        
        FamilyResponse response = toFamilyResponse(family);
        response.setRole(role.name());
        return response;
    }

    private FamilyMemberResponse toFamilyMemberResponse(FamilyMember member) {
        FamilyMemberResponse response = new FamilyMemberResponse();
        response.setId(member.getId());
        response.setFamilyId(member.getFamilyId());
        response.setUserId(member.getUserId());
        response.setRole(member.getRole().name());
        // 아이: 가족 멤버 별칭만 사용(연결 계정/부모 로그인명과 섞이지 않도록 users 테이블로 보강하지 않음)
        // 부모: 별칭이 비었을 때만 연결된 계정 닉네임 사용
        String displayNickname = member.getNickname();
        if (member.getRole() == FamilyMember.FamilyRole.child) {
            if (displayNickname != null) {
                displayNickname = displayNickname.trim();
                if (displayNickname.isEmpty()) {
                    displayNickname = null;
                }
            }
        } else {
            if ((displayNickname == null || displayNickname.isBlank()) && member.getUserId() != null) {
                User linkedUser = userMapper.selectById(member.getUserId());
                if (linkedUser != null && linkedUser.getNickname() != null && !linkedUser.getNickname().isBlank()) {
                    displayNickname = linkedUser.getNickname();
                }
            }
        }
        response.setNickname(displayNickname);
        response.setAvatarUrl(member.getAvatarUrl());
        response.setCreatedAt(member.getCreatedAt());
        response.setUpdatedAt(member.getUpdatedAt());
        return response;
    }

    /**
     * 부모만 가족 내 멤버 표시 이름(별칭) 수정
     */
    public FamilyMemberResponse updateMemberNickname(UUID currentUserId, UUID familyId, UUID memberId, String nickname) {
        FamilyMember self = familyMemberMapper.selectByFamilyAndUser(familyId, currentUserId);
        if (self == null || self.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can update member names");
        }
        FamilyMember target = familyMemberMapper.selectById(memberId);
        if (target == null || !target.getFamilyId().equals(familyId)) {
            throw new IllegalArgumentException("Family member not found");
        }
        if (target.getRole() != FamilyMember.FamilyRole.child) {
            throw new IllegalArgumentException("아이 멤버만 이름을 변경할 수 있습니다");
        }
        String trimmed = nickname != null ? nickname.trim() : "";
        if (trimmed.isEmpty()) {
            throw new IllegalArgumentException("이름을 입력해주세요");
        }
        if (trimmed.length() > 40) {
            throw new IllegalArgumentException("이름은 40자 이하로 입력해주세요");
        }
        target.setNickname(trimmed);
        target.setUpdatedAt(Instant.now());
        familyMemberMapper.update(target);
        return toFamilyMemberResponse(target);
    }
}

