import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/presentation/widgets/mission_card.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/mission_provider.dart';
import 'package:kids_challenge/data/models/mission_model.dart';
import 'package:confetti/confetti.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete(String assignmentId, String title) async {
    try {
      await ref.read(missionActionsProvider).completeMission(assignmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'$title' 완료! 부모님의 승인을 기다려주세요."),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  IconData _getIconFromType(String? iconType) {
    switch (iconType?.toUpperCase()) {
      case 'BED':
        return Icons.bed;
      case 'DOG':
      case 'PET':
        return Icons.pets;
      case 'BOOK':
        return Icons.menu_book;
      case 'TRASH':
        return Icons.delete_outline;
      case 'SPARKLES':
        return Icons.auto_awesome;
      default:
        return Icons.task;
    }
  }

  Widget _buildMissionIcon(String? iconType, {Color color = const Color(0xFF0284C7)}) {
    // 아이콘 타입이 이모지/문자이면 그대로 표시, 아니면 머티리얼 아이콘 매핑 사용
    if (iconType != null && iconType.trim().isNotEmpty) {
      final t = iconType.trim();
      final isEmojiOrNonAscii = t.runes.any((r) => r > 0x7F);
      if (isEmojiOrNonAscii || t.length <= 3) {
        return Text(
          t,
          style: const TextStyle(fontSize: 28),
        );
      }
    }
    return Icon(
      _getIconFromType(iconType),
      size: 32,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final family = ref.watch(currentFamilyProvider);
    final missionsAsync = ref.watch(myMissionsProvider);
    final approvedThisWeekAsync = ref.watch(myApprovedMissionsThisWeekProvider);
    final pointsAsync = family != null
        ? ref.watch(pointBalanceProvider(family.id))
        : const AsyncValue<int>.loading();

    return Scaffold(
      backgroundColor: AppTheme.childShellBackground,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(pointsAsync),
              _buildTabs(missionsAsync, approvedThisWeekAsync),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTodayList(context, ref, family, missionsAsync),
                    _buildApprovedList(context, ref, approvedThisWeekAsync),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.57,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(AsyncValue<List<MissionAssignmentModel>> missionsAsync,
      AsyncValue<List<MissionAssignmentModel>> approvedThisWeekAsync) {
    int todayCount = missionsAsync.maybeWhen(data: (d) => d.length, orElse: () => 0);
    int approvedCount = approvedThisWeekAsync.maybeWhen(data: (d) => d.length, orElse: () => 0);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.childCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.childSky700,
        unselectedLabelColor: AppTheme.slate400,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppTheme.childSky200.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorPadding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: [
          Tab(text: '오늘 할 일 ($todayCount)'),
          Tab(text: '지급된 미션 ($approvedCount)'),
        ],
      ),
    );
  }

  Widget _buildTodayList(BuildContext context, WidgetRef ref, dynamic family, AsyncValue<List<MissionAssignmentModel>> missionsAsync) {
    return missionsAsync.when(
                  data: (missions) {
                    // 승인 대기(pending)는 맨 아래, 그 외에서는 스페셜(one_off) 우선
                    missions.sort((a, b) {
                      final aPending = a.status == 'pending' ? 1 : 0;
                      final bPending = b.status == 'pending' ? 1 : 0;
                      if (aPending != bPending) {
                        return aPending.compareTo(bPending);
                      }
                      final ao = (a.oneOff == true) ? 0 : 1;
                      final bo = (b.oneOff == true) ? 0 : 1;
                      return ao.compareTo(bo);
                    });
                    if (missions.isEmpty) {
                      return RefreshIndicator(
                        color: AppTheme.childSky500,
                        onRefresh: () async {
                          ref.invalidate(myMissionsProvider);
                          if (family != null) {
                            ref.invalidate(pointBalanceProvider(family.id));
                          }
                          await Future.wait([
                            ref.read(myMissionsProvider.future),
                            if (family != null) ref.read(pointBalanceProvider(family.id).future),
                          ]);
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                            const Text('✨', textAlign: TextAlign.center, style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 16),
                            Text(
                              '오늘 할 미션이 없어요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.slate600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppTheme.childSky500,
                      onRefresh: () async {
                        ref.invalidate(myMissionsProvider);
                        if (family != null) {
                          ref.invalidate(pointBalanceProvider(family.id));
                        }
                        await Future.wait([
                          ref.read(myMissionsProvider.future),
                          if (family != null) ref.read(pointBalanceProvider(family.id).future),
                        ]);
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            ...missions.map((mission) {
                              return MissionCard(
                                title: mission.missionTitle ?? '미션',
                                points: mission.points,
                                icon: _buildMissionIcon(
                                  mission.missionIconType,
                                  color: AppTheme.childSky600,
                                ),
                                status: mission.status,
                                oneOff: mission.oneOff == true,
                                recentlyRejected: mission.recentlyRejected == true,
                                onComplete: mission.status == 'todo'
                                    ? () => _handleComplete(mission.id, mission.missionTitle ?? '미션')
                                    : null,
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppTheme.childSky500),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                        const SizedBox(height: 16),
                        Text(
                          '미션을 불러오는데 실패했습니다',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.invalidate(myMissionsProvider),
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                );
  }

  Widget _buildApprovedList(BuildContext context, WidgetRef ref, AsyncValue<List<MissionAssignmentModel>> approvedAsync) {
    return approvedAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return RefreshIndicator(
            color: AppTheme.childSky500,
            onRefresh: () async {
              ref.invalidate(myApprovedMissionsThisWeekProvider);
              await ref.read(myApprovedMissionsThisWeekProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                const Text('🏅', textAlign: TextAlign.center, style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text(
                  '지급된 미션이 없어요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slate600,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppTheme.childSky500,
          onRefresh: () async {
            ref.invalidate(myApprovedMissionsThisWeekProvider);
            await ref.read(myApprovedMissionsThisWeekProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                ...items.map((mission) => MissionCard(
                      title: mission.missionTitle ?? '미션',
                      points: mission.points,
                      icon: _buildMissionIcon(mission.missionIconType, color: AppTheme.emerald500),
                      status: mission.status,
                      onComplete: null,
                    )),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.childSky500)),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            const Text('지급된 미션을 불러오지 못했습니다'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(myApprovedMissionsThisWeekProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<int> pointsAsync) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '오늘의 미션',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.slate800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('🌟', style: TextStyle(fontSize: 22)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '오늘 할 일을 확인해보자!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slate400,
                    ),
                  ),
                ],
              ),
            ),
            pointsAsync.when(
              data: (points) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF9E6), Color(0xFFFFEFD5)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFFFE0A8)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on_rounded, size: 20, color: AppTheme.amber600),
                    const SizedBox(width: 4),
                    Text(
                      points.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.amber600,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.childSky500),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
