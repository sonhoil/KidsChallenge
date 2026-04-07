package com.kidspoint.api.kids.mission.mapper;

import com.kidspoint.api.kids.mission.domain.MissionAssignment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Mapper
public interface MissionAssignmentMapper {
    int insert(MissionAssignment assignment);
    MissionAssignment selectById(@Param("id") UUID id);
    List<MissionAssignment> selectByAssigneeId(@Param("assigneeId") UUID assigneeId);
    List<MissionAssignment> selectByFamilyIdAndAssigneeId(@Param("familyId") UUID familyId, @Param("assigneeId") UUID assigneeId);
    List<MissionAssignment> selectByAssigneeIdAndStatus(@Param("assigneeId") UUID assigneeId, @Param("status") MissionAssignment.MissionStatus status);
    List<MissionAssignment> selectPendingByFamilyId(@Param("familyId") UUID familyId);
    List<MissionAssignment> selectByFamilyId(@Param("familyId") UUID familyId);
    List<MissionAssignment> selectByAssigneeIdAndDueDate(@Param("assigneeId") UUID assigneeId, @Param("dueDate") LocalDate dueDate);
    List<MissionAssignment> selectApprovedByAssigneeAndDate(@Param("assigneeId") UUID assigneeId, @Param("dueDate") LocalDate dueDate);
    List<MissionAssignment> selectApprovedByAssigneeBetweenDates(@Param("assigneeId") UUID assigneeId,
                                                                 @Param("startDate") LocalDate startDate,
                                                                 @Param("endDate") LocalDate endDate);
    int update(MissionAssignment assignment);
    int delete(@Param("id") UUID id);
    int countByMissionAssigneeAndDueDate(@Param("missionId") UUID missionId,
                                         @Param("assigneeId") UUID assigneeId,
                                         @Param("dueDate") LocalDate dueDate);
    int countByMissionAssigneeBetweenDates(@Param("missionId") UUID missionId,
                                           @Param("assigneeId") UUID assigneeId,
                                           @Param("startDate") LocalDate startDate,
                                           @Param("endDate") LocalDate endDate);
}
