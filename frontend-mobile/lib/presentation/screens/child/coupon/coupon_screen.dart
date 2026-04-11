import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/presentation/widgets/ticket_card.dart';
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
      backgroundColor: AppTheme.slate50,
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
                      onRefresh: () async {
                        ref.invalidate(myPurchasesProvider);
                        await ref.read(myPurchasesProvider.future);
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        itemCount: displayCoupons.length,
                        itemBuilder: (context, index) {
                          final purchase = displayCoupons[index];
                          return TicketCard(
                            key: ValueKey('${purchase.id}-${purchase.status}'),
                            id: purchase.id,
                            title: purchase.rewardTitle ?? '리워드',
                            ownerName: purchase.buyerNickname ?? user?.nickname ?? '나',
                            isUsed: purchase.status == 'used',
                            dateStr: AppDateUtils.DateUtils.formatTimeAgo(purchase.createdAt),
                            onUse: purchase.status == 'used'
                                ? null
                                : () => _handleUse(purchase.id),
                          );
                        },
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.confirmation_number, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '쿠폰함',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate800,
                  ),
                ),
                Text(
                  '보상으로 받은 쿠폰을 확인하세요!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final purchasesAsync = ref.watch(myPurchasesProvider);
    
    return Container(
      color: Colors.white,
      child: purchasesAsync.when(
        data: (purchases) {
          final availableCount = purchases.where((p) => p.status != 'used').length;
          final usedCount = purchases.where((p) => p.status == 'used').length;
          
          return TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.slate400,
            indicatorColor: AppTheme.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: '사용 가능 ($availableCount)'),
              Tab(text: '사용 완료 ($usedCount)'),
            ],
          );
        },
        loading: () => TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '사용 가능'),
            Tab(text: '사용 완료'),
          ],
        ),
        error: (_, __) => TabBar(
          controller: _tabController,
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
      onRefresh: () async {
        ref.invalidate(myPurchasesProvider);
        await ref.read(myPurchasesProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
          Icon(Icons.confirmation_number, size: 64, color: AppTheme.slate200),
          const SizedBox(height: 16),
          Text(
            isAvailable
                ? '아직 사용할 수 있는 쿠폰이 없어요!'
                : '아직 사용한 쿠폰이 없어요!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.slate600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '상점에서 미션 포인트로 쿠폰을 구매해보세요.',
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
