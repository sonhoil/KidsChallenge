import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/presentation/widgets/reward_list_row.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/reward_provider.dart';
import 'package:kids_challenge/data/models/reward_model.dart';
import 'package:confetti/confetti.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _handleBuy(RewardModel reward, String familyId) async {
    try {
      await ref.read(rewardActionsProvider).purchaseReward(reward.id, familyId);
      if (mounted) {
        _confettiController.play();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구매 완료! 🎉'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구매 실패: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final family = ref.watch(currentFamilyProvider);
    final rewardsAsync = family != null
        ? ref.watch(rewardsProvider(family.id))
        : const AsyncValue.loading();
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
              Expanded(
                child: rewardsAsync.when(
                  data: (rewards) {
                    if (rewards.isEmpty) {
                      return RefreshIndicator(
                        color: const Color(0xFFFF9EB5),
                        onRefresh: () async {
                          if (family != null) {
                            ref.invalidate(rewardsProvider(family.id));
                            ref.invalidate(pointBalanceProvider(family.id));
                            await Future.wait([
                              ref.read(rewardsProvider(family.id).future),
                              ref.read(pointBalanceProvider(family.id).future),
                            ]);
                          }
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                            const Text('🛒', textAlign: TextAlign.center, style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 16),
                            Text(
                              '아직 쿠폰이 없어요',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.slate600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '부모님이 등록하면 여기에 나와요',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.slate400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final points = pointsAsync.valueOrNull ?? 0;

                    return RefreshIndicator(
                      color: const Color(0xFFFF9EB5),
                      onRefresh: () async {
                        if (family != null) {
                          ref.invalidate(rewardsProvider(family.id));
                          ref.invalidate(pointBalanceProvider(family.id));
                          await Future.wait([
                            ref.read(rewardsProvider(family.id).future),
                            ref.read(pointBalanceProvider(family.id).future),
                          ]);
                        }
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: rewards.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final reward = rewards[index];
                          final canBuy = points >= reward.pricePoints;
                          final onBuy = family != null && canBuy
                              ? () => _handleBuy(reward, family.id)
                              : null;
                          return RewardListRow(
                            iconType: reward.iconType,
                            iconBg: AppTheme.childRewardIconWellBackground,
                            title: reward.title,
                            showSpecialBadge: reward.category == 'SPECIAL',
                            metaLine: Row(
                              children: [
                                Icon(Icons.stars_rounded, size: 16, color: AppTheme.amber500),
                                const SizedBox(width: 4),
                                Text(
                                  '${reward.pricePoints}P',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.slate600,
                                  ),
                                ),
                              ],
                            ),
                            actionLabel: canBuy ? '교환' : '부족',
                            actionPrimary: canBuy,
                            onAction: onBuy,
                            onRowTap: onBuy,
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF9EB5))),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                        const SizedBox(height: 16),
                        Text(
                          '리워드를 불러오는데 실패했습니다',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            if (family != null) {
                              ref.invalidate(rewardsProvider(family.id));
                            }
                          },
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildHeader(AsyncValue<int> pointsAsync) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.06),
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
                        '쿠폰 상점',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.slate800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('🎁', style: TextStyle(fontSize: 22)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '포인트로 교환해요',
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
                      '${points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF9EB5)),
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
