package com.kidspoint.api.kids.mission.mapper;

import com.kidspoint.api.kids.mission.domain.MissionLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.UUID;

@Mapper
public interface MissionLogMapper {
    int insert(MissionLog log);
    List<MissionLog> selectByMissionAssignmentId(@Param("missionAssignmentId") UUID missionAssignmentId);
}
