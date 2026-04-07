import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/data/models/family_model.dart';
import 'package:kids_challenge/data/models/mission_model.dart';
import 'package:kids_challenge/data/models/reward_model.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/mission_provider.dart';
import 'package:kids_challenge/presentation/state/point_provider.dart';
import 'package:kids_challenge/presentation/state/reward_provider.dart';

class ChildStatsScreen extends ConsumerWidget {
  final FamilyMemberModel? member;

  const ChildStatsScreen({super.key, this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (member == null) {
      return Scaffold(
        backgroundColor: AppTheme.slate50,
        appBar: AppBar(
          title: const Text('활동 통계'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('아이 정보가 없습니다. 가족 관리 화면에서 다시 시도해주세요.'),
        ),
      );
    }

    final family = ref.watch(currentFamilyProvider);
    final userId = member!.userId;
    final missionsAsync = (family != null && userId != null)
        ? ref.watch(familyUserMissionsProvider((familyId: family.id, userId: userId)))
        : const AsyncValue<List<MissionAssignmentModel>>.data([]);
    final pointAsync = (family != null && userId != null)
        ? ref.watch(memberPointBalanceProvider((familyId: family.id, userId: userId)))
        : const AsyncValue<int>.data(0);
    final purchasesAsync = (family != null && userId != null)
        ? ref.watch(purchasesByUserProvider((familyId: family.id, userId: userId)))
        : const AsyncValue<List<RewardPurchaseModel>>.data([]);

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text('${member!.nickname ?? '아이'} 활동 통계'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (family != null && userId != null) {
            ref.invalidate(familyUserMissionsProvider((familyId: family.id, userId: userId)));
            ref.invalidate(memberPointBalanceProvider((familyId: family.id, userId: userId)));
            ref.invalidate(purchasesByUserProvider((familyId: family.id, userId: userId)));
            ref.invalidate(familyPurchasesProvider(family.id));
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(pointAsync),
              const SizedBox(height: 20),
              missionsAsync.when(
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                )),
                error: (e, _) => _buildErrorCard('$e'),
                data: (missions) {
                  final todoCount = missions.where((m) => m.status == 'todo').length;
                  final pendingCount = missions.where((m) => m.status == 'pending').length;
                  final approved = missions.where((m) => m.status == 'approved').toList();
                  final approvedCount = approved.length;
                  final rejectedCount = missions.where((m) => m.status == 'rejected').length;
                  final totalApprovedPoints =
                      approved.fold<int>(0, (sum, item) => sum + item.points);

                  final familyId = family?.id;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryGrid(
                        totalMissions: missions.length,
                        todoCount: todoCount,
                        pendingCount: pendingCount,
                        approvedCount: approvedCount,
                        rejectedCount: rejectedCount,
                        totalApprovedPoints: totalApprovedPoints,
                      ),
                      const SizedBox(height: 24),
                      if (familyId != null) ...[
                        _buildPurchaseCouponSection(context, ref, familyId, purchasesAsync),
                        const SizedBox(height: 24),
                      ],
                      _buildRecentActivitySection(missions),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(AsyncValue<int> pointAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
            child: Text(
              (member!.nickname?.isNotEmpty == true ? member!.nickname![0] : '아'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member!.nickname ?? '아이',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member!.userId == null ? '계정 연결이 필요해요' : '활동 현황을 확인해보세요',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate500,
                  ),
                ),
              ],
            ),
          ),
          pointAsync.when(
            data: (points) => _buildBadge('보유 $points P', AppTheme.amber500, AppTheme.amber50),
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => _buildBadge('포인트 오류', AppTheme.error, const Color(0xFFFFF1F2)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid({
    required int totalMissions,
    required int todoCount,
    required int pendingCount,
    required int approvedCount,
    required int rejectedCount,
    required int totalApprovedPoints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '요약',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildStatCard('총 미션', '$totalMissions개', Icons.assignment, AppTheme.primary),
            _buildStatCard('진행 중', '$todoCount개', Icons.play_circle_outline, AppTheme.emerald500),
            _buildStatCard('승인 대기', '$pendingCount개', Icons.hourglass_top, AppTheme.amber500),
            _buildStatCard('승인 완료', '$approvedCount개', Icons.check_circle_outline, AppTheme.primary),
            _buildStatCard('거절됨', '$rejectedCount개', Icons.cancel_outlined, AppTheme.error),
            _buildStatCard('누적 승인 포인트', '$totalApprovedPoints P', Icons.emoji_events, AppTheme.amber600),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(List<MissionAssignmentModel> missions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 활동',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 12),
        if (missions.isEmpty)
          _buildEmptyCard('아직 미션 활동이 없습니다.')
        else
          ...missions.take(8).map((mission) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _statusColor(mission.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _statusIcon(mission.status),
                        color: _statusColor(mission.status),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mission.missionTitle ?? '미션',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slate800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _statusLabel(mission.status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _statusColor(mission.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${mission.points}P',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.slate800,
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildPurchaseCouponSection(
    BuildContext context,
    WidgetRef ref,
    String familyId,
    AsyncValue<List<RewardPurchaseModel>> purchasesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '구매한 쿠폰',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 12),
        purchasesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => _buildErrorCard('$e'),
          data: (List<RewardPurchaseModel> coupons) {
            if (coupons.isEmpty) {
              return _buildEmptyCard('아직 구매한 쿠폰이 없습니다.');
            }

            return Column(
              children: coupons.take(10).map<Widget>((RewardPurchaseModel coupon) {
                final isUsed = coupon.status == 'used';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.slate200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.slate100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          coupon.rewardIconType ?? '🎁',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coupon.rewardTitle ?? '쿠폰',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _purchaseStatusLabel(coupon.status),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _purchaseStatusColor(coupon.status),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDate(coupon.updatedAt),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slate500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!isUsed)
                            SizedBox(
                              height: 32,
                              child: FilledButton(
                                onPressed: () => _markCouponUsed(
                                  context,
                                  ref,
                                  familyId,
                                  coupon,
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '사용 처리',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.slate100,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                '사용 완료',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.slate600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _markCouponUsed(
    BuildContext context,
    WidgetRef ref,
    String familyId,
    RewardPurchaseModel coupon,
  ) async {
    try {
      await ref.read(rewardActionsProvider).updatePurchaseStatus(
        familyId,
        coupon.id,
        'used',
      );
      ref.invalidate(purchasesByUserProvider((familyId: familyId, userId: coupon.buyerId)));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${coupon.rewardTitle ?? '쿠폰'}을 사용 처리했습니다.'),
          backgroundColor: AppTheme.emerald500,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('쿠폰 사용 처리에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slate500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.slate800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.slate500,
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 32, color: AppTheme.error),
          const SizedBox(height: 12),
          const Text(
            '통계를 불러오지 못했습니다.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.slate700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.slate500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_top;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'todo':
      default:
        return Icons.assignment_outlined;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppTheme.primary;
      case 'pending':
        return AppTheme.amber500;
      case 'rejected':
        return AppTheme.error;
      case 'todo':
      default:
        return AppTheme.emerald500;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return '승인 완료';
      case 'pending':
        return '승인 대기';
      case 'rejected':
        return '거절됨';
      case 'todo':
      default:
        return '진행 중';
    }
  }

  String _formatDate(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$month.$day';
  }

  Color _purchaseStatusColor(String status) {
    switch (status) {
      case 'used':
        return AppTheme.slate600;
      case 'confirmed':
        return AppTheme.primary;
      case 'pending':
        return AppTheme.amber500;
      case 'cancelled':
        return AppTheme.error;
      default:
        return AppTheme.slate500;
    }
  }

  String _purchaseStatusLabel(String status) {
    switch (status) {
      case 'used':
        return '사용 완료';
      case 'confirmed':
        return '사용 가능';
      case 'pending':
        return '승인 대기';
      case 'cancelled':
        return '취소됨';
      default:
        return status;
    }
  }
}
