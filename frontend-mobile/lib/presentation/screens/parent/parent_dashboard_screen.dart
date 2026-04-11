import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/presentation/widgets/pending_card.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/mission_provider.dart';
import 'package:kids_challenge/data/models/mission_model.dart';
import 'package:go_router/go_router.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final family = ref.read(currentFamilyProvider);
      if (family != null) {
        ref.invalidate(pendingMissionsProvider(family.id));
        await ref.read(pendingMissionsProvider(family.id).future);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final family = ref.watch(currentFamilyProvider);
    final pendingMissionsAsync = family != null
        ? ref.watch(pendingMissionsProvider(family.id)) as AsyncValue<List<MissionAssignmentModel>>
        : const AsyncValue<List<MissionAssignmentModel>>.loading();

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: family == null
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActionButtons(),
                        const SizedBox(height: 24),
                        _buildPendingSection(pendingMissionsAsync, null),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(pendingMissionsProvider(family.id));
                      ref.invalidate(pointBalanceProvider(family.id));
                      await Future.wait([
                        ref.read(pendingMissionsProvider(family.id).future),
                        ref.read(pointBalanceProvider(family.id).future),
                      ]);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildActionButtons(),
                          const SizedBox(height: 24),
                          _buildPendingSection(pendingMissionsAsync, family.id),
                        ],
                      ),
                    ),
                  ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
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
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '부모님 모드',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '승인 대기 중인 미션',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                Builder(
                  builder: (context) {
                    final family = ref.watch(currentFamilyProvider);
                    final pendingAsync = family != null
                        ? ref.watch(pendingMissionsProvider(family.id))
                        : const AsyncValue.loading();
                    
                    return pendingAsync.when(
                      data: (missions) => RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.slate500,
                          ),
                          children: [
                            TextSpan(
                              text: '${missions.length}건',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            const TextSpan(text: '의 미션이 승인을 기다리고 있어요'),
                          ],
                        ),
                      ),
                      loading: () => Text(
                        '로딩 중...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.slate500,
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => context.push('/parent/create-mission'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '새 미션 만들기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => context.push('/parent/mission-requests'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.emerald100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle, color: AppTheme.emerald500, size: 24),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '승인 내역 보기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingSection(AsyncValue<List<MissionAssignmentModel>> pendingAsync, String? familyId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Text(
                  '승인 요청',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.push('/parent/mission-requests'),
              child: Row(
                children: [
                  Text(
                    '전체보기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate400,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: AppTheme.slate400),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        pendingAsync.when(
          data: (missions) {
            if (missions.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.slate200, style: BorderStyle.solid, width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.slate100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle, size: 32, color: AppTheme.slate300),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '모두 확인했어요!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '새로운 승인 요청이 없습니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.slate500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: missions.map((mission) => PendingCard(
                    id: mission.id,
                    kidName: mission.assigneeNickname ?? '아이',
                    taskName: mission.missionTitle ?? '미션',
                    points: mission.points,
                    createdAt: mission.createdAt,
                    onApprove: () async {
                      try {
                        await ref.read(missionActionsProvider).approveMission(mission.id);
                        if (mounted && familyId != null) {
                          ref.invalidate(pendingMissionsProvider(familyId));
                          ref.invalidate(pointBalanceProvider(familyId));
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('승인 실패: ${e.toString()}'),
                              backgroundColor: AppTheme.error,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
                            ),
                          );
                        }
                      }
                    },
                    onReject: () async {
                      try {
                        await ref.read(missionActionsProvider).rejectMission(mission.id);
                        if (mounted && familyId != null) {
                          ref.invalidate(pendingMissionsProvider(familyId));
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('거절 실패: ${e.toString()}'),
                              backgroundColor: AppTheme.error,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
                            ),
                          );
                        }
                      }
                    },
                  )).toList(),
            );
          },
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          )),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.slate200),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 32, color: AppTheme.error),
                const SizedBox(height: 16),
                Text(
                  '미션을 불러오는데 실패했습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.slate500,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    if (familyId != null) {
                      ref.invalidate(pendingMissionsProvider(familyId));
                    }
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
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
              _buildNavItem(Icons.dashboard, '대시보드', true),
              _buildNavItem(Icons.list_alt, '미션', false, () => context.push('/parent/missions')),
              _buildNavItem(Icons.people, '멤버', false, () => context.push('/parent/members')),
              _buildNavItem(Icons.store, '상점', false, () => context.push('/parent/store')),
              _buildNavItem(Icons.settings, '설정', false, () => context.push('/parent/settings')),
            ],
          ),
        ),
      ),
    );
  }

          Widget _buildNavItem(IconData icon, String label, bool isActive, [VoidCallback? onTap]) {
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
