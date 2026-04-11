import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/data/models/reward_model.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/reward_provider.dart';

class ParentStoreScreen extends ConsumerWidget {
  const ParentStoreScreen({super.key});

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

    final rewardsAsync = ref.watch(allRewardsProvider(family.id));

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(allRewardsProvider(family.id));
                ref.invalidate(rewardsProvider(family.id));
                await Future.wait([
                  ref.read(allRewardsProvider(family.id).future),
                  ref.read(rewardsProvider(family.id).future),
                ]);
              },
              child: rewardsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 160),
                    Center(
                      child: Text(
                        '리워드를 불러오지 못했습니다\n$e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
                data: (rewards) => _buildRewardList(context, ref, family.id, rewards),
              ),
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/parent/create-reward'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('새 리워드'),
        ),
      ),
    );
  }

  Widget _buildRewardList(
    BuildContext context,
    WidgetRef ref,
    String familyId,
    List<RewardModel> rewards,
  ) {
    final activeCount = rewards.where((reward) => reward.isActive).length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Row(
            children: [
              _buildSummaryBadge(Icons.card_giftcard, '전체 ${rewards.length}개', AppTheme.primary),
              const SizedBox(width: 12),
              _buildSummaryBadge(Icons.visibility, '사용중 $activeCount개', AppTheme.emerald500),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (rewards.isEmpty)
          Container(
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
                  '등록된 리워드가 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '아이들이 포인트로 구매할 수 있는 보상을 추가해보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.slate500,
                  ),
                ),
              ],
            ),
          )
        else
          ...rewards.map((reward) => _buildRewardCard(context, ref, familyId, reward)),
        const SizedBox(height: 96),
      ],
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

  Widget _buildRewardCard(
    BuildContext context,
    WidgetRef ref,
    String familyId,
    RewardModel reward,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: reward.isActive
                      ? AppTheme.primaryLight.withOpacity(0.18)
                      : AppTheme.slate100,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  reward.iconType ?? '🎁',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: reward.isActive ? AppTheme.slate800 : AppTheme.slate500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.amber50,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${reward.pricePoints} P',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.amber600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: reward.isActive
                                ? AppTheme.primaryLight.withOpacity(0.2)
                                : AppTheme.slate100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            reward.isActive ? '노출중' : '비활성',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: reward.isActive ? AppTheme.primary : AppTheme.slate500,
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
                    context.push('/parent/create-reward', extra: reward);
                    return;
                  }
                  if (value == 'toggleVisibility') {
                    await _confirmToggleVisibility(context, ref, familyId, reward);
                    return;
                  }
                  if (value == 'delete') {
                    await _confirmDeleteReward(context, ref, familyId, reward);
                  }
                },
                itemBuilder: (_) => [
                  if (reward.isActive)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('리워드 수정'),
                    ),
                  PopupMenuItem(
                    value: 'toggleVisibility',
                    child: Text(
                      reward.isActive ? '리워드 숨기기' : '다시 표시',
                      style: const TextStyle(color: AppTheme.error),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      '리워드 삭제',
                      style: const TextStyle(color: AppTheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if ((reward.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                reward.description!.trim(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.slate500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmToggleVisibility(
    BuildContext context,
    WidgetRef ref,
    String familyId,
    RewardModel reward,
  ) async {
    final willHide = reward.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(willHide ? '리워드 숨기기' : '리워드 다시 표시'),
        content: Text(
          willHide
              ? '\'${reward.title}\' 리워드를 숨길까요?\n아이 상점에는 더 이상 노출되지 않습니다.'
              : '\'${reward.title}\' 리워드를 다시 표시할까요?\n아이 상점에 다시 노출됩니다.',
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
      await ref.read(rewardActionsProvider).updateRewardVisibility(
            reward.id,
            familyId,
            !reward.isActive,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(willHide ? '리워드를 숨겼습니다.' : '리워드를 다시 표시했습니다.'),
          backgroundColor: AppTheme.emerald500,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('리워드 상태 변경에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _confirmDeleteReward(
    BuildContext context,
    WidgetRef ref,
    String familyId,
    RewardModel reward,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('리워드 삭제'),
        content: Text(
          '\'${reward.title}\' 리워드를 완전히 삭제할까요?\n구매 이력도 함께 삭제될 수 있으며 되돌릴 수 없습니다.',
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
      await ref.read(rewardActionsProvider).deleteReward(reward.id, familyId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('리워드를 삭제했습니다.'),
          backgroundColor: AppTheme.emerald500,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('리워드 삭제에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
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
                  '리워드 관리',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate800,
                  ),
                ),
                Text(
                  '아이들이 구매할 수 있는 보상을 등록하세요',
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
              _buildNavItem(
                context,
                Icons.dashboard,
                '대시보드',
                () => context.go('/parent'),
                false,
              ),
              _buildNavItem(
                context,
                Icons.list_alt,
                '미션',
                () => context.go('/parent/missions'),
                false,
              ),
              _buildNavItem(
                context,
                Icons.people,
                '멤버',
                () => context.go('/parent/members'),
                false,
              ),
              _buildNavItem(
                context,
                Icons.store,
                '상점',
                null,
                true,
              ),
              _buildNavItem(
                context,
                Icons.settings,
                '설정',
                () => context.go('/parent/settings'),
                false,
              ),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 4),
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
    );
  }
}
