package com.kidspoint.api.kids.mission.service;

import com.kidspoint.api.auth.domain.User;
import com.kidspoint.api.auth.mapper.UserMapper;
import com.kidspoint.api.kids.family.domain.FamilyMember;
import com.kidspoint.api.kids.family.mapper.FamilyMemberMapper;
import com.kidspoint.api.kids.mission.domain.Mission;
import com.kidspoint.api.kids.mission.domain.MissionAssignment;
import com.kidspoint.api.kids.mission.domain.MissionLog;
import com.kidspoint.api.kids.mission.dto.*;
import com.kidspoint.api.kids.mission.mapper.MissionAssignmentMapper;
import com.kidspoint.api.kids.mission.mapper.MissionLogMapper;
import com.kidspoint.api.kids.mission.mapper.MissionMapper;
import com.kidspoint.api.kids.point.service.PointService;
import com.kidspoint.api.push.service.FcmPushService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class MissionService {

    private static final Logger log = LoggerFactory.getLogger(MissionService.class);

    private final MissionMapper missionMapper;
    private final MissionAssignmentMapper missionAssignmentMapper;
    private final MissionLogMapper missionLogMapper;
    private final FamilyMemberMapper familyMemberMapper;
    private final UserMapper userMapper;
    private final PointService pointService;
    private final FcmPushService fcmPushService;

    @Autowired
    public MissionService(
            MissionMapper missionMapper,
            MissionAssignmentMapper missionAssignmentMapper,
            MissionLogMapper missionLogMapper,
            FamilyMemberMapper familyMemberMapper,
            UserMapper userMapper,
            PointService pointService,
            FcmPushService fcmPushService) {
        this.missionMapper = missionMapper;
        this.missionAssignmentMapper = missionAssignmentMapper;
        this.missionLogMapper = missionLogMapper;
        this.familyMemberMapper = familyMemberMapper;
        this.userMapper = userMapper;
        this.pointService = pointService;
        this.fcmPushService = fcmPushService;
    }

    public MissionResponse createMission(UUID userId, CreateMissionRequest request) {
        // 가족 멤버 확인
        FamilyMember member = familyMemberMapper.selectByFamilyAndUser(request.getFamilyId(), userId);
        if (member == null || member.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can create missions");
        }

        Mission mission = new Mission();
        mission.setId(UUID.randomUUID());
        mission.setFamilyId(request.getFamilyId());
        mission.setTitle(request.getTitle());
        mission.setDescription(request.getDescription());
        mission.setDefaultPoints(request.getDefaultPoints());
        mission.setIconType(request.getIconType());
        mission.setIsActive(true);
        mission.setCreatedBy(userId);
        mission.setCreatedAt(Instant.now());
        mission.setUpdatedAt(Instant.now());

        missionMapper.insert(mission);
        return toMissionResponse(mission);
    }

    public List<MissionResponse> listMissionsByFamily(UUID familyId, Boolean activeOnly) {
        List<Mission> missions = Boolean.TRUE.equals(activeOnly)
            ? missionMapper.selectActiveByFamilyId(familyId)
            : missionMapper.selectByFamilyId(familyId);
        return missions.stream()
            .map(this::toMissionResponse)
            .collect(Collectors.toList());
    }

    public MissionResponse updateMission(UUID userId, UUID missionId, CreateMissionRequest request) {
        Mission mission = missionMapper.selectById(missionId);
        if (mission == null) {
            throw new IllegalArgumentException("Mission not found");
        }

        // 부모 권한 확인
        FamilyMember parentMember = familyMemberMapper.selectByFamilyAndUser(mission.getFamilyId(), userId);
        if (parentMember == null || parentMember.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can update missions");
        }

        mission.setTitle(request.getTitle());
        mission.setDescription(request.getDescription());
        mission.setDefaultPoints(request.getDefaultPoints());
        mission.setIconType(request.getIconType());
        mission.setUpdatedAt(Instant.now());

        missionMapper.update(mission);
        return toMissionResponse(mission);
    }

    public void deleteMission(UUID userId, UUID missionId) {
        Mission mission = missionMapper.selectById(missionId);
        if (mission == null) {
            throw new IllegalArgumentException("Mission not found");
        }

        // 부모 권한 확인
        FamilyMember parentMember = familyMemberMapper.selectByFamilyAndUser(mission.getFamilyId(), userId);
        if (parentMember == null || parentMember.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can delete missions");
        }

        missionMapper.delete(missionId);
    }

    public MissionResponse updateMissionVisibility(UUID userId, UUID missionId, boolean isActive) {
        Mission mission = missionMapper.selectById(missionId);
        if (mission == null) {
            throw new IllegalArgumentException("Mission not found");
        }

        FamilyMember parentMember = familyMemberMapper.selectByFamilyAndUser(mission.getFamilyId(), userId);
        if (parentMember == null || parentMember.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can manage mission visibility");
        }

        mission.setIsActive(isActive);
        mission.setUpdatedAt(Instant.now());
        missionMapper.update(mission);
        return toMissionResponse(mission);
    }

    public MissionAssignmentResponse assignMission(UUID userId, AssignMissionRequest request) {
        // 부모 권한 확인
        FamilyMember parentMember = familyMemberMapper.selectByFamilyAndUser(request.getFamilyId(), userId);
        if (parentMember == null || parentMember.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can assign missions");
        }

        // 아이가 가족에 속하는지 확인
        FamilyMember childMember = familyMemberMapper.selectByFamilyAndUser(request.getFamilyId(), request.getAssigneeId());
        if (childMember == null || childMember.getRole() != FamilyMember.FamilyRole.child) {
            throw new IllegalStateException("Assignee must be a child in the family");
        }

        // 미션 조회
        Mission mission = missionMapper.selectById(request.getMissionId());
        if (mission == null || !mission.getFamilyId().equals(request.getFamilyId())) {
            throw new IllegalArgumentException("Mission not found");
        }

        // 포인트 결정 (요청에 없으면 미션 기본값 사용)
        Integer points = request.getPoints() != null ? request.getPoints() : mission.getDefaultPoints();

        MissionAssignment assignment = new MissionAssignment();
        assignment.setId(UUID.randomUUID());
        assignment.setMissionId(request.getMissionId());
        assignment.setAssigneeId(request.getAssigneeId());
        assignment.setAssignedBy(userId);
        assignment.setFamilyId(request.getFamilyId());
        assignment.setDueDate(request.getDueDate());
        assignment.setStatus(MissionAssignment.MissionStatus.todo);
        assignment.setPoints(points);
        assignment.setCreatedAt(Instant.now());
        assignment.setUpdatedAt(Instant.now());

        missionAssignmentMapper.insert(assignment);

        // 로그 기록
        logStatusChange(assignment.getId(), null, MissionAssignment.MissionStatus.todo, userId, null);

        return toAssignmentResponse(assignment, mission, childMember);
    }

    public MissionAssignmentResponse completeMission(UUID userId, UUID assignmentId) {
        System.out.println("[MissionService] completeMission start userId=" + userId + " assignmentId=" + assignmentId);
        MissionAssignment assignment = missionAssignmentMapper.selectById(assignmentId);
        if (assignment == null) {
            System.out.println("[MissionService] completeMission: assignment not found");
            throw new IllegalArgumentException("Mission assignment not found");
        }
        System.out.println("[MissionService] completeMission: loaded status=" + assignment.getStatus()
            + " assigneeId=" + assignment.getAssigneeId() + " familyId=" + assignment.getFamilyId());

        // 본인만 완료 가능
        if (!assignment.getAssigneeId().equals(userId)) {
            System.out.println("[MissionService] completeMission: assignee mismatch (only assignee can complete)");
            throw new IllegalStateException("Only the assignee can complete this mission");
        }

        // 상태 확인
        if (assignment.getStatus() != MissionAssignment.MissionStatus.todo) {
            System.out.println("[MissionService] completeMission: not todo (current=" + assignment.getStatus() + ")");
            throw new IllegalStateException("Mission is not in todo status");
        }

        // 상태 변경: todo -> pending
        MissionAssignment.MissionStatus oldStatus = assignment.getStatus();
        assignment.setStatus(MissionAssignment.MissionStatus.pending);
        assignment.setUpdatedAt(Instant.now());
        missionAssignmentMapper.update(assignment);
        System.out.println("[MissionService] completeMission: DB updated todo -> pending assignmentId=" + assignmentId);

        // 로그 기록
        logStatusChange(assignmentId, oldStatus, MissionAssignment.MissionStatus.pending, userId, null);
        System.out.println("[MissionService] completeMission: mission_log inserted");

        Mission mission = missionMapper.selectById(assignment.getMissionId());
        FamilyMember member = familyMemberMapper.selectByFamilyAndUser(assignment.getFamilyId(), assignment.getAssigneeId());
        String missionTitle = mission != null ? mission.getTitle() : null;
        System.out.println("[MissionService] completeMission: mission=" + (mission != null ? mission.getId() : "null")
            + " title=" + missionTitle);
        System.out.println("[Mission] complete: assignmentId=" + assignmentId + " familyId=" + assignment.getFamilyId()
            + " assigneeId=" + userId + " -> pending, notify parents");
        notifyParentsMissionSubmit(assignment.getFamilyId(), member, mission);
        System.out.println("[MissionService] completeMission: notifyParentsMissionSubmit done, building response");
        return toAssignmentResponse(assignment, mission, member);
    }

    public MissionAssignmentResponse approveMission(UUID userId, UUID assignmentId) {
        MissionAssignment assignment = missionAssignmentMapper.selectById(assignmentId);
        if (assignment == null) {
            throw new IllegalArgumentException("Mission assignment not found");
        }

        // 부모 권한 확인
        FamilyMember parentMember = familyMemberMapper.selectByFamilyAndUser(assignment.getFamilyId(), userId);
        if (parentMember == null || parentMember.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can approve missions");
        }

        // 상태 확인
        if (assignment.getStatus() != MissionAssignment.MissionStatus.pending) {
            throw new IllegalStateException("Mission is not in pending status");
        }

        // 상태 변경: pending -> approved
        MissionAssignment.MissionStatus oldStatus = assignment.getStatus();
        assignment.setStatus(MissionAssignment.MissionStatus.approved);
        assignment.setUpdatedAt(Instant.now());
        missionAssignmentMapper.update(assignment);

        // 포인트 적립
        pointService.addPoints(assignment.getFamilyId(), assignment.getAssigneeId(), 
            assignment.getPoints(), "MISSION_REWARD", "MISSION_ASSIGNMENT", assignment.getId(),
            "미션 완료: " + (assignment.getPoints() != null ? assignment.getPoints() : 0) + "P");

        // 로그 기록
        logStatusChange(assignmentId, oldStatus, MissionAssignment.MissionStatus.approved, userId, null);

        Mission mission = missionMapper.selectById(assignment.getMissionId());
        FamilyMember member = familyMemberMapper.selectByFamilyAndUser(assignment.getFamilyId(), assignment.getAssigneeId());
        notifyChildMissionResult(assignment.getAssigneeId(), true, mission);
        return toAssignmentResponse(assignment, mission, member);
    }

    public MissionAssignmentResponse rejectMission(UUID userId, UUID assignmentId, RejectMissionRequest request) {
        MissionAssignment assignment = missionAssignmentMapper.selectById(assignmentId);
        if (assignment == null) {
            throw new IllegalArgumentException("Mission assignment not found");
        }

        // 부모 권한 확인
        FamilyMember parentMember = familyMemberMapper.selectByFamilyAndUser(assignment.getFamilyId(), userId);
        if (parentMember == null || parentMember.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can reject missions");
        }

        // 상태 확인
        if (assignment.getStatus() != MissionAssignment.MissionStatus.pending) {
            throw new IllegalStateException("Mission is not in pending status");
        }

        // 반려 시 다시 수행 가능하도록: pending -> todo
        MissionAssignment.MissionStatus oldStatus = assignment.getStatus();
        assignment.setStatus(MissionAssignment.MissionStatus.todo);
        assignment.setUpdatedAt(Instant.now());
        missionAssignmentMapper.update(assignment);

        // 로그 기록
        String comment = request != null ? request.getComment() : null;
        String mergedComment = (comment == null || comment.isBlank())
            ? "rejected: redo required"
            : "rejected: " + comment;
        logStatusChange(assignmentId, oldStatus, MissionAssignment.MissionStatus.todo, userId, mergedComment);

        Mission mission = missionMapper.selectById(assignment.getMissionId());
        FamilyMember member = familyMemberMapper.selectByFamilyAndUser(assignment.getFamilyId(), assignment.getAssigneeId());
        notifyChildMissionResult(assignment.getAssigneeId(), false, mission);
        return toAssignmentResponse(assignment, mission, member);
    }

    public List<MissionAssignmentResponse> getMyMissions(UUID userId, LocalDate dueDate) {
        System.out.println("[MissionService] getMyMissions called - userId: " + userId + ", dueDate: " + dueDate);
        // 1) 대상 날짜 결정
        LocalDate targetDate = (dueDate != null) ? dueDate : LocalDate.now();

        // 2) 사용자가 속한 가족(아이 역할만) 조회
        List<FamilyMember> myMemberships = familyMemberMapper.selectByUserId(userId);
        List<FamilyMember> childMemberships = myMemberships.stream()
            .filter(m -> m.getRole() == FamilyMember.FamilyRole.child)
            .collect(Collectors.toList());

        // 3) 각 가족의 활성 미션 중 '매일' 미션에 대해, 오늘자 할당이 없으면 생성
        for (FamilyMember childMember : childMemberships) {
            UUID familyId = childMember.getFamilyId();
            List<Mission> activeMissions = missionMapper.selectActiveByFamilyId(familyId);
            for (Mission mission : activeMissions) {
                if (!shouldGenerateForToday(mission, userId, targetDate)) {
                    continue;
                }
                int exists = missionAssignmentMapper.countByMissionAssigneeAndDueDate(
                    mission.getId(), userId, targetDate
                );
                if (exists == 0) {
                    MissionAssignment assignment = new MissionAssignment();
                    assignment.setId(UUID.randomUUID());
                    assignment.setMissionId(mission.getId());
                    assignment.setAssigneeId(userId);
                    // 미션 생성자를 할당한 사람으로 기록 (없으면 본인으로)
                    assignment.setAssignedBy(mission.getCreatedBy() != null ? mission.getCreatedBy() : userId);
                    assignment.setFamilyId(familyId);
                    assignment.setDueDate(targetDate);
                    assignment.setStatus(MissionAssignment.MissionStatus.todo);
                    assignment.setPoints(mission.getDefaultPoints());
                    assignment.setCreatedAt(Instant.now());
                    assignment.setUpdatedAt(Instant.now());
                    missionAssignmentMapper.insert(assignment);
                    logStatusChange(assignment.getId(), null, MissionAssignment.MissionStatus.todo, assignment.getAssignedBy(), null);
                }
            }
        }

        // 4) 조회: 날짜가 주어졌으면 해당 날짜 기준으로만 보여줌
        List<MissionAssignment> assignments = (dueDate != null)
            ? missionAssignmentMapper.selectByAssigneeIdAndDueDate(userId, targetDate)
            : missionAssignmentMapper.selectByAssigneeId(userId);

        System.out.println("[MissionService] Found " + assignments.size() + " assignments");

        return assignments.stream()
            .map(assignment -> {
                Mission mission = missionMapper.selectById(assignment.getMissionId());
                // due_date가 NULL인 항목은 one_off만 허용
                if (assignment.getDueDate() == null && mission != null) {
                    String desc = mission.getDescription();
                    String frequency = null;
                    if (desc != null) {
                        for (String raw : desc.split("\n")) {
                            String line = raw.trim();
                            if (line.startsWith("frequency=")) {
                                frequency = line.substring("frequency=".length());
                                break;
                            }
                        }
                    }
                    if (!"one_off".equalsIgnoreCase(frequency)) {
                        return null; // 필터링
                    }
                }
                FamilyMember member = familyMemberMapper.selectByFamilyAndUser(assignment.getFamilyId(), assignment.getAssigneeId());
                return toAssignmentResponse(assignment, mission, member);
            })
            .filter(r -> r != null)
            .collect(Collectors.toList());
    }

    public List<MissionAssignmentResponse> getMyApprovedMissionsByDate(UUID userId, LocalDate dueDate) {
        LocalDate targetDate = (dueDate != null) ? dueDate : LocalDate.now();
        List<MissionAssignment> assignments = missionAssignmentMapper.selectApprovedByAssigneeAndDate(userId, targetDate);
        return assignments.stream()
            .map(assignment -> {
                Mission mission = missionMapper.selectById(assignment.getMissionId());
                FamilyMember member = familyMemberMapper.selectByFamilyAndUser(assignment.getFamilyId(), assignment.getAssigneeId());
                return toAssignmentResponse(assignment, mission, member);
            })
            .collect(Collectors.toList());
    }

    public List<MissionAssignmentResponse> getMyApprovedMissionsInRange(UUID userId, LocalDate startDate, LocalDate endDate) {
        LocalDate start = startDate != null ? startDate : LocalDate.now().minusDays(6);
        LocalDate end = endDate != null ? endDate : LocalDate.now();
        List<MissionAssignment> assignments = missionAssignmentMapper.selectApprovedByAssigneeBetweenDates(userId, start, end);
        return assignments.stream()
            .map(assignment -> {
                Mission mission = missionMapper.selectById(assignment.getMissionId());
                FamilyMember member = familyMemberMapper.selectByFamilyAndUser(assignment.getFamilyId(), assignment.getAssigneeId());
                return toAssignmentResponse(assignment, mission, member);
            })
            .collect(Collectors.toList());
    }
    /**
     * 미션 설명의 메타를 읽어 오늘 생성이 필요한지 판단한다.
     * 현재는 frequency=daily 만 처리. (필요 시 custom_days/weekend 등 확장)
     */
    private boolean shouldGenerateForToday(Mission mission, UUID userId, LocalDate targetDate) {
        if (mission.getIsActive() == null || !mission.getIsActive()) {
            return false;
        }
        String desc = mission.getDescription();
        if (desc == null) {
            return false;
        }
        String frequency = null;
        String assignee = null;
        String daysLine = null;
        for (String rawLine : desc.split("\n")) {
            String line = rawLine.trim();
            if (line.startsWith("frequency=")) {
                frequency = line.substring("frequency=".length());
            } else if (line.startsWith("assignee=")) {
                assignee = line.substring("assignee=".length());
            } else if (line.startsWith("days=")) {
                daysLine = line.substring("days=".length());
            }
        }
        // 대상이 전체이거나 특정 사용자일 때만 생성
        boolean isAssigneeIncluded;
        if (assignee == null || assignee.isEmpty() || "all".equalsIgnoreCase(assignee)) {
            isAssigneeIncluded = true;
        } else {
            isAssigneeIncluded = assignee.equalsIgnoreCase(userId.toString());
        }
        if (!isAssigneeIncluded) {
            return false;
        }

        // 빈도별 생성 조건
        if ("daily".equalsIgnoreCase(frequency)) {
            return true;
        }
        if ("custom_days".equalsIgnoreCase(frequency)) {
            if (daysLine == null || daysLine.trim().isEmpty()) return false;
            String todayKey = dayOfWeekKey(targetDate);
            for (String d : daysLine.split(",")) {
                if (todayKey.equalsIgnoreCase(d.trim())) {
                    return true;
                }
            }
            return false;
        }
        if ("weekend".equalsIgnoreCase(frequency)) {
            switch (targetDate.getDayOfWeek()) {
                case SATURDAY:
                case SUNDAY:
                    return true;
                default:
                    return false;
            }
        }
        if ("weekly_1".equalsIgnoreCase(frequency)) {
            // 이번 주(월~일)에 이미 한 번 생성되었는지 확인
            LocalDate startOfWeek = targetDate.minusDays((targetDate.getDayOfWeek().getValue() + 6) % 7); // 월요일 기준
            LocalDate endOfWeek = startOfWeek.plusDays(6);
            int cnt = missionAssignmentMapper.countByMissionAssigneeBetweenDates(
                mission.getId(), userId, startOfWeek, endOfWeek
            );
            return cnt == 0;
        }

        // 알 수 없는 빈도는 생성하지 않음
        return false;
    }

    private String dayOfWeekKey(LocalDate date) {
        switch (date.getDayOfWeek()) {
            case MONDAY: return "mon";
            case TUESDAY: return "tue";
            case WEDNESDAY: return "wed";
            case THURSDAY: return "thu";
            case FRIDAY: return "fri";
            case SATURDAY: return "sat";
            case SUNDAY: return "sun";
            default: return "";
        }
    }

    public List<MissionAssignmentResponse> getPendingMissions(UUID userId, UUID familyId) {
        // 부모 권한 확인
        FamilyMember parentMember = familyMemberMapper.selectByFamilyAndUser(familyId, userId);
        if (parentMember == null || parentMember.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can view pending missions");
        }

        List<MissionAssignment> assignments = missionAssignmentMapper.selectPendingByFamilyId(familyId);
        return assignments.stream()
            .map(assignment -> {
                Mission mission = missionMapper.selectById(assignment.getMissionId());
                FamilyMember member = familyMemberMapper.selectByFamilyAndUser(assignment.getFamilyId(), assignment.getAssigneeId());
                return toAssignmentResponse(assignment, mission, member);
            })
            .collect(Collectors.toList());
    }

    public List<MissionAssignmentResponse> getAssignmentsByFamily(UUID userId, UUID familyId) {
        FamilyMember parentMember = familyMemberMapper.selectByFamilyAndUser(familyId, userId);
        if (parentMember == null || parentMember.getRole() != FamilyMember.FamilyRole.parent) {
            throw new IllegalStateException("Only parents can view family assignments");
        }

        List<MissionAssignment> assignments = missionAssignmentMapper.selectByFamilyId(familyId);
        return assignments.stream()
            .map(assignment -> {
                Mission mission = missionMapper.selectById(assignment.getMissionId());
                FamilyMember member = familyMemberMapper.selectByFamilyAndUser(assignment.getFamilyId(), assignment.getAssigneeId());
                return toAssignmentResponse(assignment, mission, member);
            })
            .collect(Collectors.toList());
    }

    public List<MissionAssignmentResponse> getMissionsByFamilyAndUser(UUID requesterId, UUID familyId, UUID targetUserId) {
        FamilyMember requester = familyMemberMapper.selectByFamilyAndUser(familyId, requesterId);
        if (requester == null) {
            throw new IllegalStateException("Not a member of this family");
        }

        FamilyMember target = familyMemberMapper.selectByFamilyAndUser(familyId, targetUserId);
        if (target == null) {
            throw new IllegalArgumentException("Target member not found");
        }

        boolean isSelf = requesterId.equals(targetUserId);
        boolean isParent = requester.getRole() == FamilyMember.FamilyRole.parent;
        if (!isSelf && !isParent) {
            throw new IllegalStateException("Access denied");
        }

        List<MissionAssignment> assignments =
            missionAssignmentMapper.selectByFamilyIdAndAssigneeId(familyId, targetUserId);

        return assignments.stream()
            .map(assignment -> {
                Mission mission = missionMapper.selectById(assignment.getMissionId());
                FamilyMember member = familyMemberMapper.selectByFamilyAndUser(assignment.getFamilyId(), assignment.getAssigneeId());
                return toAssignmentResponse(assignment, mission, member);
            })
            .collect(Collectors.toList());
    }

    private void logStatusChange(UUID assignmentId, MissionAssignment.MissionStatus fromStatus, 
                                 MissionAssignment.MissionStatus toStatus, UUID changedBy, String comment) {
        MissionLog log = new MissionLog();
        log.setId(UUID.randomUUID());
        log.setMissionAssignmentId(assignmentId);
        log.setFromStatus(fromStatus);
        log.setToStatus(toStatus);
        log.setChangedBy(changedBy);
        log.setComment(comment);
        log.setCreatedAt(Instant.now());
        missionLogMapper.insert(log);
    }

    private MissionResponse toMissionResponse(Mission mission) {
        MissionResponse response = new MissionResponse();
        response.setId(mission.getId());
        response.setFamilyId(mission.getFamilyId());
        response.setTitle(mission.getTitle());
        response.setDescription(mission.getDescription());
        response.setDefaultPoints(mission.getDefaultPoints());
        response.setIconType(mission.getIconType());
        response.setIsActive(mission.getIsActive());
        response.setCreatedBy(mission.getCreatedBy());
        response.setCreatedAt(mission.getCreatedAt());
        response.setUpdatedAt(mission.getUpdatedAt());
        return response;
    }

    private MissionAssignmentResponse toAssignmentResponse(MissionAssignment assignment, Mission mission, FamilyMember member) {
        MissionAssignmentResponse response = new MissionAssignmentResponse();
        response.setId(assignment.getId());
        response.setMissionId(assignment.getMissionId());
        if (mission != null) {
            response.setMissionTitle(mission.getTitle());
            response.setMissionIconType(mission.getIconType());
            // one_off 여부 파생
            String desc = mission.getDescription();
            String frequency = null;
            if (desc != null) {
                for (String raw : desc.split("\n")) {
                    String line = raw.trim();
                    if (line.startsWith("frequency=")) {
                        frequency = line.substring("frequency=".length());
                        break;
                    }
                }
            }
            response.setOneOff("one_off".equalsIgnoreCase(frequency));
        }
        response.setAssigneeId(assignment.getAssigneeId());
        if (member != null) {
            response.setAssigneeNickname(member.getNickname());
        }
        response.setAssignedBy(assignment.getAssignedBy());
        response.setFamilyId(assignment.getFamilyId());
        response.setDueDate(assignment.getDueDate());
        response.setStatus(assignment.getStatus().name());
        response.setPoints(assignment.getPoints());
        response.setCreatedAt(assignment.getCreatedAt());
        response.setUpdatedAt(assignment.getUpdatedAt());
        // 최근 반려 여부: 가장 최근 로그가 to_status=todo 이면서 comment가 "rejected:"로 시작하면 true
        try {
            List<MissionLog> logs = missionLogMapper.selectByMissionAssignmentId(assignment.getId());
            if (logs != null && !logs.isEmpty()) {
                MissionLog latest = logs.get(0);
                boolean isRejectedRedo = latest.getToStatus() == MissionAssignment.MissionStatus.todo
                    && latest.getComment() != null
                    && latest.getComment().toLowerCase().startsWith("rejected:");
                response.setRecentlyRejected(isRejectedRedo);
            } else {
                response.setRecentlyRejected(false);
            }
        } catch (Exception e) {
            response.setRecentlyRejected(false);
        }
        return response;
    }

    private void notifyParentsMissionSubmit(UUID familyId, FamilyMember childMember, Mission mission) {
        System.out.println("[MissionService] notifyParentsMissionSubmit: familyId=" + familyId
            + " fcmEnabled=" + fcmPushService.isFcmEnabled());
        if (!fcmPushService.isFcmEnabled()) {
            System.out.println("[MissionService] [FCM] notifyParentsMissionSubmit SKIPPED: Firebase not initialized (set FIREBASE_SERVICE_ACCOUNT_B64 on server)");
            log.warn("[FCM] notifyParentsMissionSubmit skipped: Firebase not initialized (set FIREBASE_SERVICE_ACCOUNT_B64 on server)");
            return;
        }
        List<UUID> parentIds = familyMemberMapper.selectByFamilyId(familyId).stream()
            .filter(m -> m.getRole() == FamilyMember.FamilyRole.parent)
            .map(FamilyMember::getUserId)
            .collect(Collectors.toList());
        System.out.println("[MissionService] notifyParentsMissionSubmit: parent userIds=" + parentIds);
        if (parentIds.isEmpty()) {
            System.out.println("[MissionService] [FCM] notifyParentsMissionSubmit SKIPPED: no parent role in familyId=" + familyId);
            log.warn("[FCM] notifyParentsMissionSubmit skipped: no parent role in familyId={}", familyId);
            return;
        }
        String childName = (childMember != null && childMember.getNickname() != null && !childMember.getNickname().isBlank())
            ? childMember.getNickname() : "아이";
        String mTitle = mission != null && mission.getTitle() != null ? mission.getTitle() : "미션";
        System.out.println("[MissionService] [FCM] sendToUsers parent count=" + parentIds.size() + " type=MISSION_SUBMIT child=" + childName);
        Map<String, String> data = new HashMap<>();
        data.put(FcmPushService.DATA_TYPE, FcmPushService.TYPE_MISSION_SUBMIT);
        fcmPushService.sendToUsers(parentIds, "미션 완료 요청",
            childName + "님이 「" + mTitle + "」을(를) 끝냈어요! 확인해보세요.", data);
    }

    private void notifyChildMissionResult(UUID childUserId, boolean approved, Mission mission) {
        if (!fcmPushService.isFcmEnabled()) {
            log.warn("[FCM] notifyChildMissionResult skipped: Firebase not initialized");
            return;
        }
        String mTitle = mission != null && mission.getTitle() != null ? mission.getTitle() : "미션";
        Map<String, String> data = new HashMap<>();
        data.put(FcmPushService.DATA_TYPE, approved ? FcmPushService.TYPE_MISSION_APPROVED : FcmPushService.TYPE_MISSION_REJECTED);
        if (approved) {
            fcmPushService.sendToUser(childUserId, "미션이 승인됐어요 🎉",
                "「" + mTitle + "」 획득 포인트를 확인해보세요!", data);
        } else {
            fcmPushService.sendToUser(childUserId, "미션이 반려됐어요",
                "「" + mTitle + "」을(를) 다시 도전해보세요.", data);
        }
    }
}
