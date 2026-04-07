package com.kidspoint.api.kids.point.mapper;

import com.kidspoint.api.kids.point.domain.PointAccount;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.UUID;

@Mapper
public interface PointAccountMapper {
    int insert(PointAccount account);
    PointAccount selectById(@Param("id") UUID id);
    PointAccount selectByFamilyAndUser(@Param("familyId") UUID familyId, @Param("userId") UUID userId);
    int update(PointAccount account);
}
