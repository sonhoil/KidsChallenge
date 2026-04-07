package com.kidspoint.api.kids.family.mapper;

import com.kidspoint.api.kids.family.domain.Family;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.UUID;

@Mapper
public interface FamilyMapper {
    int insert(Family family);
    Family selectById(@Param("id") UUID id);
    Family selectByInviteCode(@Param("inviteCode") String inviteCode);
    int update(Family family);
    int delete(@Param("id") UUID id);
}
