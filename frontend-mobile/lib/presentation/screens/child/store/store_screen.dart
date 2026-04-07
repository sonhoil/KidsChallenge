import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/presentation/widgets/reward_card.dart';
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

  IconData _getIconFromType(String? iconType) {
    switch (iconType?.toUpperCase()) {
      case 'GAME':
        return Icons.sports_esports;
      case 'PIZZA':
        return Icons.local_pizza;
      case 'TICKET':
        return Icons.confirmation_number;
      case 'ICECREAM':
        return Icons.icecream;
      case 'TV':
        return Icons.tv;
      case 'GIFT':
        return Icons.card_giftcard;
      default:
        return Icons.star;
    }
  }

  Color _getColorFromType(String? iconType) {
    switch (iconType?.toUpperCase()) {
      case 'GAME':
        return const Color(0xFF6366F1);
      case 'PIZZA':
        return const Color(0xFFF97316);
      case 'TICKET':
        return const Color(0xFF10B981);
      case 'ICECREAM':
        return const Color(0xFFEC4899);
      case 'TV':
        return const Color(0xFF8B5CF6);
      case 'GIFT':
        return const Color(0xFFF59E0B);
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final family = ref.watch(currentFamilyProvider);
    final rewardsAsync = family != null
        ? ref.watch(rewardsProvider(family.id))
        : const AsyncValue.loading();
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
              Expanded(
                child: rewardsAsync.when(
                  data: (rewards) {
                    if (rewards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store, size: 64, color: AppTheme.slate300),
                            const SizedBox(height: 16),
                            Text(
                              '등록된 리워드가 없어요',
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
                        if (family != null) {
                          ref.invalidate(rewardsProvider(family.id));
                          ref.invalidate(pointBalanceProvider(family.id));
                        }
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: rewards.length,
                          itemBuilder: (context, index) {
                            final reward = rewards[index];
                            final points = pointsAsync.valueOrNull ?? 0;
                            return RewardCard(
                              title: reward.title,
                              points: reward.pricePoints,
                              icon: Icon(
                                _getIconFromType(reward.iconType),
                                size: 40,
                                color: Colors.white,
                              ),
                              color: _getColorFromType(reward.iconType),
                              isSpecial: reward.category == 'SPECIAL',
                              disabled: points < reward.pricePoints,
                              onBuy: family != null
                                  ? () => _handleBuy(reward, family.id)
                                  : null,
                            );
                          },
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '쿠폰 상점 🎁',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '포인트를 보상으로 교환해봐요!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate500,
                  ),
                ),
              ],
            ),
            pointsAsync.when(
              data: (points) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.amber50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.amber200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.monetization_on, size: 20, color: AppTheme.amber500),
                    const SizedBox(width: 4),
                    Text(
                      '${points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
