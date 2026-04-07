import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/data/models/family_model.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/family_provider.dart';
import 'package:kids_challenge/presentation/state/mission_provider.dart';
import 'package:kids_challenge/presentation/state/reward_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final family = ref.watch(currentFamilyProvider);
    final membersAsync = family != null
        ? ref.watch(familyMembersProvider(family.id))
        : const AsyncValue<List<FamilyMemberModel>>.data([]);
    final missionsAsync = ref.watch(myMissionsProvider);
    final purchasesAsync = ref.watch(myPurchasesProvider);
    final pointsAsync = family != null
        ? ref.watch(pointBalanceProvider(family.id))
        : const AsyncValue<int>.data(0);

    final myMember = membersAsync.maybeWhen(
      data: (members) => members.cast<FamilyMemberModel?>().firstWhere(
            (member) => member?.userId == user?.id,
            orElse: () => null,
          ),
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(authStateProvider);
                ref.invalidate(myMissionsProvider);
                ref.invalidate(myPurchasesProvider);
                if (family != null) {
                  ref.invalidate(familyMembersProvider(family.id));
                  ref.invalidate(pointBalanceProvider(family.id));
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildStatsGrid(pointsAsync, missionsAsync, purchasesAsync),
                    const SizedBox(height: 24),
                    _buildMenuList(context, family),
                  ],
                ),
              ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '내 활동',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate800,
                  ),
                ),
                Text(
                  '최근 활동과 통계를 확인해봐요',
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

  Widget _buildProfileCard(
    user,
    FamilyModel? family,
    FamilyMemberModel? myMember,
    AsyncValue<int> pointsAsync,
    AsyncValue missionsAsync,
  ) {
    final displayName = myMember?.nickname ?? user?.nickname ?? user?.username ?? '아이';
    final points = pointsAsync.value ?? 0;
    final approvedCount = missionsAsync.valueOrNull
            ?.where((mission) => mission.status == 'approved')
            .length ??
        0;
    final level = (points ~/ 500) + 1;
    final nextLevelTarget = level * 500;
    final currentLevelBase = (level - 1) * 500;
    final progress = nextLevelTarget == currentLevelBase
        ? 0.0
        : ((points - currentLevelBase) / (nextLevelTarget - currentLevelBase))
            .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.slate100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Image.network(
                  myMember?.avatarUrl ??
                      'https://images.unsplash.com/photo-1758598737700-739b306988e0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 96,
                    height: 96,
                    color: AppTheme.slate200,
                    child: const Icon(Icons.person, size: 48),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.amber400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.slate800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'LV.$level ${approvedCount >= 20 ? '미션 마스터' : approvedCount >= 10 ? '도움 요정' : '첫 도전자'}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.slate100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '다음 레벨까지 ${nextLevelTarget - points}P',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.slate400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    AsyncValue<int> pointsAsync,
    AsyncValue missionsAsync,
    AsyncValue purchasesAsync,
  ) {
    final missions = missionsAsync.valueOrNull ?? const [];
    final purchases = purchasesAsync.valueOrNull ?? const [];
    final approvedCount = missions.where((mission) => mission.status == 'approved').length;
    final pendingCount = missions.where((mission) => mission.status == 'pending').length;
    final availableCoupons = purchases.where((purchase) => purchase.status != 'used').length;
    final points = pointsAsync.value ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.25,
      children: [
        _buildStatCard(
          icon: Icons.emoji_events,
          iconBg: AppTheme.amber100,
          iconColor: AppTheme.amber500,
          label: '완료한 미션',
          value: '$approvedCount개',
        ),
        _buildStatCard(
          icon: Icons.stars,
          iconBg: AppTheme.emerald100,
          iconColor: AppTheme.emerald500,
          label: '보유 포인트',
          value:
              '${points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}P',
        ),
        _buildStatCard(
          icon: Icons.hourglass_top,
          iconBg: AppTheme.primaryLight.withOpacity(0.25),
          iconColor: AppTheme.primary,
          label: '승인 대기',
          value: '$pendingCount개',
        ),
        _buildStatCard(
          icon: Icons.confirmation_number,
          iconBg: AppTheme.slate100,
          iconColor: AppTheme.slate600,
          label: '사용 가능한 쿠폰',
          value: '$availableCoupons장',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slate100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.slate400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.slate800,
            ),
          ),
        ],
      ),
    );
  }

  // 내 정보 섹션 제거됨 (프로필 정보 노출하지 않음)

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.slate800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, FamilyModel? family) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.slate100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications, color: Color(0xFFEF4444), size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '푸시 알림',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate700,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: AppTheme.primary,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 앱 설정 메뉴 제거
          _buildMenuItem(
            icon: Icons.logout,
            iconColor: AppTheme.error,
            iconBg: const Color(0xFFFEE2E2),
            label: '로그아웃',
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slate700,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.slate300),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              '로그아웃',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref.read(authStateProvider.notifier).logout();
    if (!mounted) return;
    context.go('/login');
  }
}
