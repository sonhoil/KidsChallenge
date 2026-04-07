package com.kidspoint.api.organization.mapper;

import com.kidspoint.api.organization.domain.OrganizationMember;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface OrganizationMemberMapper {
    int insert(OrganizationMember member);
    OrganizationMember selectByUserAndOrg(
        @Param("userId") UUID userId,
        @Param("organizationId") UUID organizationId
    );
    OrganizationMember.OrgRole selectRoleByUserAndOrg(
        @Param("userId") UUID userId,
        @Param("organizationId") UUID organizationId
    );
    List<OrganizationMember> selectByOrganizationId(@Param("organizationId") UUID organizationId);
    OrganizationMember selectById(@Param("id") UUID id);
    int update(OrganizationMember member);
    int updateLastActiveByUserId(@Param("userId") UUID userId, @Param("lastActive") java.time.Instant lastActive);
    int updateLastActiveByUserAndOrg(@Param("userId") UUID userId, @Param("organizationId") UUID organizationId, @Param("lastActive") java.time.Instant lastActive);
    int delete(@Param("id") UUID id);
}
