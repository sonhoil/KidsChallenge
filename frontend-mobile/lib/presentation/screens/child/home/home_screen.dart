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

  Widget _buildMissionIcon(String? iconType, {Color color = const Color(0xFF3B82F6)}) {
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
        ? ref.watch(pointBalanceProvider(family.id)) as AsyncValue<int>
        : const AsyncValue<int>.loading();

    return Scaffold(
      backgroundColor: AppTheme.slate50,
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
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.slate400,
        indicatorColor: AppTheme.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
                    // 스페셜(one_off) 우선 정렬
                    missions.sort((a, b) {
                      final ao = (a.oneOff == true) ? 0 : 1;
                      final bo = (b.oneOff == true) ? 0 : 1;
                      return ao.compareTo(bo);
                    });
                    if (missions.isEmpty) {
                      return RefreshIndicator(
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
                            Icon(Icons.task_alt, size: 64, color: AppTheme.slate300),
                            const SizedBox(height: 16),
                            Text(
                              '오늘 할 미션이 없어요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            ...missions.map((mission) {
                              final isOneOff = mission.oneOff == true;
                              final isRecentlyRejected = mission.recentlyRejected == true;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isOneOff)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.amber100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.amber200),
                                      ),
                                      child: const Text(
                                        '오늘만 수행 가능한 미션이에요!',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.amber600,
                                        ),
                                      ),
                                    ),
                                  if (isRecentlyRejected)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFF1F2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Color(0xFFFCA5A5)),
                                      ),
                                      child: const Text(
                                        '반려되었어요. 미션을 다시 수행해서 완료해보세요!',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.error,
                                        ),
                                      ),
                                    ),
                                  MissionCard(
                                    title: mission.missionTitle ?? '미션',
                                    points: mission.points,
                                    icon: _buildMissionIcon(mission.missionIconType, color: const Color(0xFF3B82F6)),
                                    status: mission.status,
                                    onComplete: mission.status == 'todo'
                                        ? () => _handleComplete(mission.id, mission.missionTitle ?? '미션')
                                        : null,
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
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
            onRefresh: () async {
              ref.invalidate(myApprovedMissionsThisWeekProvider);
              await ref.read(myApprovedMissionsThisWeekProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Icon(Icons.verified, size: 64, color: AppTheme.slate300),
                const SizedBox(height: 16),
                Text(
                  '지급된 미션이 없어요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate600,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myApprovedMissionsThisWeekProvider);
            await ref.read(myApprovedMissionsThisWeekProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
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
      loading: () => const Center(child: CircularProgressIndicator()),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE).withOpacity(0.8),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '오늘도 멋지게 시작해볼까?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.slate800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '오늘 할 미션을 확인해보자!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.slate500,
                    ),
                  ),
                ],
              ),
            ),
            pointsAsync.when(
              data: (points) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.amber100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.amber200, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.monetization_on, size: 20, color: AppTheme.amber600),
                    const SizedBox(width: 4),
                    Text(
                      '${points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} P',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.amber600,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => Container(
                padding: const EdgeInsets.all(10),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
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
