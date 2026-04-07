package com.kidspoint.api.organization.mapper;

import com.kidspoint.api.organization.domain.Invitation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.UUID;

@Mapper
public interface InvitationMapper {
    void insert(Invitation invitation);
    Invitation selectByToken(String token);
    Invitation selectByOrganizationAndEmail(@Param("organizationId") UUID organizationId, @Param("email") String email);
    void updateAcceptedAt(@Param("id") UUID id, @Param("acceptedAt") java.time.Instant acceptedAt);
    void deleteExpired();
}
