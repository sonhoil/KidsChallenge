package com.kidspoint.api.kids.mission.mapper;

import com.kidspoint.api.kids.mission.domain.Mission;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface MissionMapper {
    int insert(Mission mission);
    Mission selectById(@Param("id") UUID id);
    List<Mission> selectByFamilyId(@Param("familyId") UUID familyId);
    List<Mission> selectActiveByFamilyId(@Param("familyId") UUID familyId);
    int update(Mission mission);
    int delete(@Param("id") UUID id);
}
