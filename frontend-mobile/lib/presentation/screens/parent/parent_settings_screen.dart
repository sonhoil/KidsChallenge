import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/family_provider.dart';

class ParentSettingsScreen extends ConsumerWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final family = ref.watch(currentFamilyProvider);

    if (family == null) {
      return const Scaffold(
        body: Center(
          child: Text('가족 정보가 없습니다. 다시 로그인해주세요.'),
        ),
      );
    }

    final membersAsync = ref.watch(familyMembersProvider(family.id));

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myFamiliesProvider);
                ref.invalidate(familyMembersProvider(family.id));
                await Future.wait([
                  ref.read(myFamiliesProvider.future),
                  ref.read(familyMembersProvider(family.id).future),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFamilyCard(context, ref, family, membersAsync),
                    const SizedBox(height: 16),
                    _buildAccountCard(context, ref, user),
                    const SizedBox(height: 16),
          _buildActionsCard(context, ref, family.inviteCode),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
    );
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
            const Text(
              '설정',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.slate800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyCard(
    BuildContext context,
    WidgetRef ref,
    dynamic family,
    AsyncValue membersAsync,
  ) {
    final members = membersAsync.valueOrNull ?? const [];
    final parentCount = members.where((member) => member.role == 'parent').length;
    final childCount = members.where((member) => member.role == 'child').length;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.family_restroom, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            family.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.slate800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showEditFamilyNameDialog(context, ref, family.id, family.name),
                          child: const Text('수정'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.shield,
                  label: '부모',
                  value: '$parentCount명',
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.child_care,
                  label: '아이',
                  value: '$childCount명',
                  color: AppTheme.emerald500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
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

  Widget _buildAccountCard(BuildContext context, WidgetRef ref, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '계정 정보',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.slate800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(
                width: 72,
                child: Text(
                  '닉네임',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  user?.nickname ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slate800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showEditNicknameDialog(context, ref),
                child: const Text('변경'),
              ),
            ],
          ),
          _buildInfoRow('역할', '부모'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 72,
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

  Widget _buildActionsCard(
    BuildContext context,
    WidgetRef ref,
    String? inviteCode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Column(
        children: [
          _buildActionItem(
            icon: Icons.people,
            iconColor: AppTheme.emerald500,
            iconBg: AppTheme.emerald100,
            label: '가족 관리로 이동',
            subtitle: '가족 멤버 추가/삭제를 관리해요',
            onTap: () => context.go('/parent/members'),
          ),
          const Divider(height: 1),
          _buildActionItem(
            icon: Icons.logout,
            iconColor: AppTheme.error,
            iconBg: const Color(0xFFFEE2E2),
            label: '로그아웃',
            subtitle: '현재 계정에서 로그아웃해요',
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.slate800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.slate500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.slate300),
          ],
        ),
      ),
    );
  }

  Future<void> _copyInviteCode(BuildContext context, String inviteCode) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('초대코드를 복사했습니다.'),
        backgroundColor: AppTheme.emerald500,
      ),
    );
  }

  Future<void> _showEditNicknameDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final current = ref.read(authStateProvider).user?.nickname ?? '';
    controller.text = current;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('닉네임 변경'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '새 닉네임을 입력하세요',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('저장')),
        ],
      ),
    );
    if (confirmed != true) return;
    final newNickname = controller.text.trim();
    if (newNickname.isEmpty) return;
    try {
      await ref.read(authStateProvider.notifier).updateNickname(newNickname);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임이 변경되었습니다.'),
          backgroundColor: AppTheme.emerald500,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('닉네임 변경에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    }
  }

  Future<void> _showEditFamilyNameDialog(
    BuildContext context,
    WidgetRef ref,
    String familyId,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('가족명 변경'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '새 가족명을 입력하세요'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('저장')),
        ],
      ),
    );
    if (confirmed != true) return;
    final newName = controller.text.trim();
    if (newName.isEmpty) return;
    try {
      final repo = ref.read(familyRepositoryProvider);
      final updated = await repo.updateFamilyName(familyId, newName);
      // 상태 갱신
      ref.read(currentFamilyProvider.notifier).state = updated;
      ref.invalidate(myFamiliesProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('가족명이 변경되었습니다.'),
          backgroundColor: AppTheme.emerald500,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('가족명 변경에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
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

    if (confirmed != true || !context.mounted) return;

    await ref.read(authStateProvider.notifier).logout();
    if (!context.mounted) return;
    context.go('/login');
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
                () => context.go('/parent/store'),
                false,
              ),
              _buildNavItem(
                context,
                Icons.settings,
                '설정',
                null,
                true,
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
