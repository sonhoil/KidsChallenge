import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/presentation/widgets/reward_list_row.dart';
import 'package:kids_challenge/presentation/state/reward_provider.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/core/utils/date_utils.dart' as AppDateUtils;
import 'package:confetti/confetti.dart';

class CouponScreen extends ConsumerStatefulWidget {
  const CouponScreen({super.key});

  @override
  ConsumerState<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends ConsumerState<CouponScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleUse(String purchaseId) async {
    try {
      await ref.read(rewardActionsProvider).usePurchase(purchaseId);
      if (mounted) {
        _confettiController.play();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('쿠폰을 사용했습니다! 🎉'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사용 실패: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(myPurchasesProvider);
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.childShellBackground,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildTabs(),
              Expanded(
                child: purchasesAsync.when(
                  data: (purchases) {
                    final availableCoupons = purchases.where((p) => p.status != 'used').toList();
                    final usedCoupons = purchases.where((p) => p.status == 'used').toList();
                    final displayCoupons = _tabController.index == 0 ? availableCoupons : usedCoupons;

                    if (displayCoupons.isEmpty) {
                      return _buildEmptyState(ref, _tabController.index == 0);
                    }

                    return RefreshIndicator(
                      color: AppTheme.childSky500,
                      onRefresh: () async {
                        ref.invalidate(myPurchasesProvider);
                        await ref.read(myPurchasesProvider.future);
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                        itemCount: displayCoupons.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final purchase = displayCoupons[index];
                          final isUsed = purchase.status == 'used';
                          final title = purchase.rewardTitle ?? '리워드';
                          final ownerLabel =
                              '${purchase.buyerNickname ?? user?.nickname ?? '나'}님 쿠폰';
                          final dateStr = AppDateUtils.DateUtils.formatTimeAgo(purchase.createdAt);
                          final onUse =
                              isUsed ? null : () => _handleUse(purchase.id);

                          return RewardListRow(
                            iconType: purchase.rewardIconType,
                            iconBg: AppTheme.childRewardIconWellBackground,
                            title: title,
                            primaryButtonBackground: AppTheme.childSky300,
                            primaryButtonForeground: AppTheme.childSky900,
                            showSpecialBadge: false,
                            metaLine: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ownerLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.slate400,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.schedule_rounded, size: 16, color: AppTheme.slate400),
                                    const SizedBox(width: 4),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            actionLabel: isUsed ? '완료' : '사용',
                            actionPrimary: !isUsed,
                            onAction: onUse,
                            onRowTap: onUse,
                          );
                        },
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator(color: AppTheme.childSky500)),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                        const SizedBox(height: 16),
                        Text(
                          '쿠폰을 불러오는데 실패했습니다',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.invalidate(myPurchasesProvider),
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

  Widget _buildHeader() {
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
                        '쿠폰함',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.slate800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('🎟️', style: TextStyle(fontSize: 22)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '받은 쿠폰을 확인해요',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slate400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final purchasesAsync = ref.watch(myPurchasesProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.childCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: purchasesAsync.when(
        data: (purchases) {
          final availableCount = purchases.where((p) => p.status != 'used').length;
          final usedCount = purchases.where((p) => p.status == 'used').length;

          return TabBar(
            controller: _tabController,
            labelColor: AppTheme.childSky700,
            unselectedLabelColor: AppTheme.slate400,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppTheme.childSky200.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorPadding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            tabs: [
              Tab(text: '사용 가능 ($availableCount)'),
              Tab(text: '사용 완료 ($usedCount)'),
            ],
          );
        },
        loading: () => TabBar(
          controller: _tabController,
          labelColor: AppTheme.childSky700,
          unselectedLabelColor: AppTheme.slate400,
          indicatorColor: Colors.transparent,
          tabs: const [
            Tab(text: '사용 가능'),
            Tab(text: '사용 완료'),
          ],
        ),
        error: (_, __) => TabBar(
          controller: _tabController,
          labelColor: AppTheme.childSky700,
          unselectedLabelColor: AppTheme.slate400,
          tabs: const [
            Tab(text: '사용 가능'),
            Tab(text: '사용 완료'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref, bool isAvailable) {
    return RefreshIndicator(
      color: AppTheme.childSky500,
      onRefresh: () async {
        ref.invalidate(myPurchasesProvider);
        await ref.read(myPurchasesProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
          const Text('🎟️', textAlign: TextAlign.center, style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            isAvailable ? '사용할 쿠폰이 없어요' : '사용한 쿠폰이 없어요',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.slate600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '상점에서 포인트로 쿠폰을 사면 여기에 쌓여요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.slate400,
            ),
          ),
        ],
      ),
    );
  }
}
