import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/data/models/family_model.dart';
import 'package:kids_challenge/data/models/mission_model.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/family_provider.dart';
import 'package:kids_challenge/presentation/state/mission_provider.dart';

class ParentMissionsScreen extends ConsumerWidget {
  const ParentMissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(currentFamilyProvider);
    if (family == null) {
      return const Scaffold(
        body: Center(
          child: Text('가족 정보가 없습니다. 다시 로그인해주세요.'),
        ),
      );
    }

    final missionsAsync = ref.watch(allMissionsProvider(family.id));
    final membersAsync = ref.watch(familyMembersProvider(family.id));

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: missionsAsync.when(
              data: (missions) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(allMissionsProvider(family.id));
                  ref.invalidate(familyMembersProvider(family.id));
                  await Future.wait([
                    ref.read(allMissionsProvider(family.id).future),
                    ref.read(familyMembersProvider(family.id).future),
                  ]);
                },
                child: _buildMissionList(
                  context,
                  ref,
                  family.id,
                  missions,
                  membersAsync.value ?? const [],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  '미션을 불러오는데 실패했습니다\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.error),
                ),
              ),
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/parent/create-mission'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('새 미션'),
        ),
      ),
    );
  }

  Widget _buildMissionList(
    BuildContext context,
    WidgetRef ref,
    String familyId,
    List<MissionModel> missions,
    List<FamilyMemberModel> members,
  ) {
    final activeCount = missions.where((mission) => mission.isActive).length;
    final hiddenCount = missions.length - activeCount;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSummaryBadge(Icons.flag, '전체 ${missions.length}개', AppTheme.primary),
              const SizedBox(width: 12),
              _buildSummaryBadge(Icons.visibility, '노출중 $activeCount개', AppTheme.emerald500),
              const SizedBox(width: 12),
              _buildSummaryBadge(Icons.visibility_off, '숨김 $hiddenCount개', AppTheme.slate500),
            ],
          ),
          const SizedBox(height: 16),
          ...missions.map((mission) => _buildMissionCard(context, ref, familyId, mission, members)),
        ],
      ),
    );
  }

  Widget _buildSummaryBadge(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '미션 관리',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate800,
                  ),
                ),
                // 하단 메뉴 설명 문구 제거
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(
    BuildContext context,
    WidgetRef ref,
    String familyId,
    MissionModel mission,
    List<FamilyMemberModel> members,
  ) {
    final meta = _parseMissionMetaWithAuto(mission, members);
    if (meta.shouldAutoHide && mission.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ref.read(missionActionsProvider).updateMissionVisibility(mission.id, false);
          ref.invalidate(missionsProvider(familyId));
          ref.invalidate(allMissionsProvider(familyId));
        } catch (_) {}
      });
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mission.isActive ? Colors.white : AppTheme.slate50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: mission.isActive
                      ? AppTheme.primaryLight.withOpacity(0.2)
                      : AppTheme.slate200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    mission.iconType?.isNotEmpty == true ? mission.iconType! : '🏁',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '+${mission.defaultPoints} P',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.amber500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: mission.isActive
                                ? AppTheme.primaryLight.withOpacity(0.2)
                                : AppTheme.slate200,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            mission.isActive ? '노출중' : '숨김',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: mission.isActive ? AppTheme.primary : AppTheme.slate600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    context.push('/parent/create-mission', extra: mission);
                    return;
                  }
                  if (value == 'toggleVisibility') {
                    await _confirmToggleMissionVisibility(context, ref, familyId, mission);
                    return;
                  }
                  if (value == 'delete') {
                    await _confirmDeleteMission(context, ref, familyId, mission);
                  }
                },
                itemBuilder: (_) => [
                  if (mission.isActive)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('미션 수정'),
                    ),
                  PopupMenuItem(
                    value: 'toggleVisibility',
                    child: Text(
                      mission.isActive ? '미션 숨기기' : '다시 표시',
                      style: const TextStyle(color: AppTheme.error),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      '미션 삭제',
                      style: TextStyle(color: AppTheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.slate100),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppTheme.slate400),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    meta.scheduleLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate500,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.people, size: 16, color: AppTheme.slate400),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    meta.assigneeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate500,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmToggleMissionVisibility(
    BuildContext context,
    WidgetRef ref,
    String familyId,
    MissionModel mission,
  ) async {
    final willHide = mission.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(willHide ? '미션 숨기기' : '미션 다시 표시'),
        content: Text(
          willHide
              ? '\'${mission.title}\' 미션을 숨길까요?\n아이 화면에서는 더 이상 보이지 않습니다.'
              : '\'${mission.title}\' 미션을 다시 표시할까요?\n아이 화면에 다시 노출됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              '확인',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(missionActionsProvider).updateMissionVisibility(
            mission.id,
            !mission.isActive,
          );
      if (!context.mounted) return;
      ref.invalidate(missionsProvider(familyId));
      ref.invalidate(allMissionsProvider(familyId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(willHide ? '미션을 숨겼습니다.' : '미션을 다시 표시했습니다.'),
          backgroundColor: AppTheme.emerald500,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('미션 상태 변경에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    }
  }

  Future<void> _confirmDeleteMission(
    BuildContext context,
    WidgetRef ref,
    String familyId,
    MissionModel mission,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('미션 삭제'),
        content: Text(
          '\'${mission.title}\' 미션을 완전히 삭제할까요?\n기존 할당 및 진행 이력도 함께 삭제되며 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(missionActionsProvider).deleteMission(mission.id);
      if (!context.mounted) return;
      ref.invalidate(missionsProvider(familyId));
      ref.invalidate(allMissionsProvider(familyId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('미션을 삭제했습니다.'),
          backgroundColor: AppTheme.emerald500,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('미션 삭제에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    }
  }

  ({String scheduleLabel, String assigneeLabel}) _parseMissionMeta(
    String? description,
    List<FamilyMemberModel> members,
  ) {
    var frequency = 'daily';
    var assignee = 'all';
    final selectedDays = <String>[];

    if (description != null && description.trim().isNotEmpty) {
      for (final rawLine in description.split('\n')) {
        final line = rawLine.trim();
        if (line.startsWith('frequency=')) {
          frequency = line.substring('frequency='.length);
        } else if (line.startsWith('assignee=')) {
          assignee = line.substring('assignee='.length);
        } else if (line.startsWith('days=')) {
          selectedDays
            ..clear()
            ..addAll(line.substring('days='.length).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
        }
      }
    }

    final scheduleLabel = switch (frequency) {
      'daily' => '매일',
      'custom_days' => selectedDays.isEmpty ? '요일 지정' : selectedDays.map(_dayLabel).join(', '),
      'weekly_1' => '주 1회',
      'weekend' => '주말만',
      _ => '일정 미설정',
    };

    final assigneeLabel = assignee == 'all' ? '모든 아이' : _memberLabel(assignee, members);
    return (scheduleLabel: scheduleLabel, assigneeLabel: assigneeLabel);
  }

  ({String scheduleLabel, String assigneeLabel, bool shouldAutoHide}) _parseMissionMetaWithAuto(
    MissionModel mission,
    List<FamilyMemberModel> members,
  ) {
    var frequency = 'daily';
    var assignee = 'all';
    final selectedDays = <String>[];
    final description = mission.description;
    if (description != null && description.trim().isNotEmpty) {
      for (final rawLine in description.split('\n')) {
        final line = rawLine.trim();
        if (line.startsWith('frequency=')) {
          frequency = line.substring('frequency='.length);
        } else if (line.startsWith('assignee=')) {
          assignee = line.substring('assignee='.length);
        } else if (line.startsWith('days=')) {
          selectedDays
            ..clear()
            ..addAll(line.substring('days='.length).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
        }
      }
    }
    String scheduleLabel;
    bool shouldAutoHide = false;
    if (frequency == 'one_off') {
      final created = mission.createdAt.toLocal();
      scheduleLabel = _formatYMD(created);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final createdDay = DateTime(created.year, created.month, created.day);
      shouldAutoHide = createdDay.isBefore(today);
    } else {
      scheduleLabel = switch (frequency) {
        'daily' => '매일',
        'custom_days' => selectedDays.isEmpty ? '요일 지정' : selectedDays.map(_dayLabel).join(', '),
        'weekly_1' => '주 1회',
        'weekend' => '주말만',
        _ => '일정 미설정',
      };
    }
    final assigneeLabel = assignee == 'all' ? '모든 아이' : _memberLabel(assignee, members);
    return (scheduleLabel: scheduleLabel, assigneeLabel: assigneeLabel, shouldAutoHide: shouldAutoHide);
  }

  String _formatYMD(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
  String _memberLabel(String memberId, List<FamilyMemberModel> members) {
    for (final member in members) {
      if (member.id == memberId) {
        final nickname = member.nickname?.trim();
        return (nickname == null || nickname.isEmpty) ? '아이' : nickname;
      }
    }
    return '지정 멤버';
  }

  String _dayLabel(String value) {
    return switch (value) {
      'mon' => '월',
      'tue' => '화',
      'wed' => '수',
      'thu' => '목',
      'fri' => '금',
      'sat' => '토',
      'sun' => '일',
      _ => value,
    };
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.dashboard, '대시보드', () => context.go('/parent'), false),
              _buildNavItem(context, Icons.list_alt, '미션', null, true),
              _buildNavItem(context, Icons.people, '멤버', () => context.go('/parent/members'), false),
              _buildNavItem(context, Icons.store, '상점', () => context.go('/parent/store'), false),
              _buildNavItem(context, Icons.settings, '설정', () => context.go('/parent/settings'), false),
            ],
          ),
        ),
      ),
    );
  }

          Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onTap,
    bool isActive,
  ) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primaryLight.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: isActive ? AppTheme.primary : AppTheme.slate400,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? AppTheme.primary : AppTheme.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
  }
}
