package com.kidspoint.api.organization.mapper;

import com.kidspoint.api.organization.domain.Organization;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface OrganizationMapper {
    int insert(Organization organization);
    Organization selectById(@Param("id") UUID id);
    List<Organization> selectByUserId(@Param("userId") UUID userId);
    int update(Organization organization);
    int delete(@Param("id") UUID id);
}
