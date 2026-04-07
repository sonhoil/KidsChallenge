package com.kidspoint.api.kids.family.mapper;

import com.kidspoint.api.kids.family.domain.FamilyMember;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface FamilyMemberMapper {
    int insert(FamilyMember familyMember);
    FamilyMember selectById(@Param("id") UUID id);
    FamilyMember selectByFamilyAndUser(@Param("familyId") UUID familyId, @Param("userId") UUID userId);
    List<FamilyMember> selectByFamilyId(@Param("familyId") UUID familyId);
    List<FamilyMember> selectByUserId(@Param("userId") UUID userId);
    int update(FamilyMember familyMember);
    int delete(@Param("id") UUID id);
    int deleteByFamilyAndUser(@Param("familyId") UUID familyId, @Param("userId") UUID userId);
}
