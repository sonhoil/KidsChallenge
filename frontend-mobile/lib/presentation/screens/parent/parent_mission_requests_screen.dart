import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/data/models/mission_model.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/mission_provider.dart';

class ParentMissionRequestsScreen extends ConsumerStatefulWidget {
  const ParentMissionRequestsScreen({super.key});

  @override
  ConsumerState<ParentMissionRequestsScreen> createState() =>
      _ParentMissionRequestsScreenState();
}

class _ParentMissionRequestsScreenState
    extends ConsumerState<ParentMissionRequestsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final family = ref.watch(currentFamilyProvider);
    if (family == null) {
      return const Scaffold(
        body: Center(
          child: Text('가족 정보가 없습니다. 다시 로그인해주세요.'),
        ),
      );
    }

    final assignmentsAsync = ref.watch(familyAssignmentsProvider(family.id));

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          '승인 내역',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.slate800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(familyAssignmentsProvider(family.id));
          ref.invalidate(pendingMissionsProvider(family.id));
        },
        child: assignmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 160),
              Center(
                child: Text(
                  '미션 요청 내역을 불러오지 못했습니다\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.error),
                ),
              ),
            ],
          ),
          data: (assignments) {
            final filtered = assignments.where(_matchesFilter).toList();
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _buildFilterChips(assignments),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ...filtered.map((item) => _buildAssignmentCard(context, family.id, item)),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<MissionAssignmentModel> assignments) {
    final pendingCount = assignments.where((item) => item.status == 'pending').length;
    final approvedCount = assignments.where((item) => item.status == 'approved').length;
    final rejectedCount = assignments.where((item) => item.status == 'rejected').length;

    final chips = [
      ('all', '전체 ${assignments.length}'),
      ('pending', '대기 $pendingCount'),
      ('approved', '승인 $approvedCount'),
      ('rejected', '반려 $rejectedCount'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((chip) {
        final isSelected = _filter == chip.$1;
        return ChoiceChip(
          label: Text(chip.$2),
          selected: isSelected,
          onSelected: (_) => setState(() => _filter = chip.$1),
          selectedColor: AppTheme.primaryLight.withOpacity(0.25),
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? AppTheme.primary : AppTheme.slate600,
          ),
          side: BorderSide(
            color: isSelected ? AppTheme.primary : AppTheme.slate200,
          ),
          backgroundColor: Colors.white,
        );
      }).toList(),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    String familyId,
    MissionAssignmentModel item,
  ) {
    final statusColor = _statusColor(item.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.missionIconType?.isNotEmpty == true ? item.missionIconType! : '🏁',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.missionTitle ?? '미션',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.slate800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.assigneeNickname ?? '아이'} · ${_statusLabel(item.status)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.points} P',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.slate800,
                ),
              ),
            ],
          ),
          if (item.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _reject(context, familyId, item),
                    child: const Text('반려'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _approve(context, familyId, item),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.emerald500,
                    ),
                    child: const Text('승인'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: AppTheme.slate300),
          SizedBox(height: 12),
          Text(
            '표시할 내역이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.slate700,
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesFilter(MissionAssignmentModel item) {
    if (_filter == 'all') {
      return true;
    }
    return item.status == _filter;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppTheme.emerald500;
      case 'rejected':
        return AppTheme.error;
      case 'pending':
        return AppTheme.amber500;
      default:
        return AppTheme.slate500;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return '승인 완료';
      case 'rejected':
        return '반려됨';
      case 'pending':
        return '승인 대기';
      case 'todo':
        return '진행 중';
      default:
        return status;
    }
  }

  Future<void> _approve(
    BuildContext context,
    String familyId,
    MissionAssignmentModel item,
  ) async {
    try {
      await ref.read(missionActionsProvider).approveMission(item.id);
      if (!mounted) return;
      ref.invalidate(pendingMissionsProvider(familyId));
      ref.invalidate(familyAssignmentsProvider(familyId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('미션을 승인했습니다.'),
          backgroundColor: AppTheme.emerald500,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('승인 실패: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _reject(
    BuildContext context,
    String familyId,
    MissionAssignmentModel item,
  ) async {
    try {
      await ref.read(missionActionsProvider).rejectMission(item.id);
      if (!mounted) return;
      ref.invalidate(pendingMissionsProvider(familyId));
      ref.invalidate(familyAssignmentsProvider(familyId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('미션을 반려했습니다.'),
          backgroundColor: AppTheme.emerald500,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('반려 실패: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
}

