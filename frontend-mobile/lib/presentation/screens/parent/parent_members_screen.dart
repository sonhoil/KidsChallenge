import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_challenge/core/config/app_config.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/data/models/family_model.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/family_provider.dart';
import 'package:kids_challenge/presentation/state/point_provider.dart';
import 'package:go_router/go_router.dart';

class ParentMembersScreen extends ConsumerWidget {
  const ParentMembersScreen({super.key});

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

    final membersAsync = ref.watch(familyMembersProvider(family.id));

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: membersAsync.when(
              data: (members) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(familyMembersProvider(family.id));
                  await ref.read(familyMembersProvider(family.id).future);
                },
                child: _buildMemberList(context, members, ref),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  '멤버를 불러오는데 실패했습니다\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.error),
                ),
              ),
            ),
          ),
          _buildBottomNav(context),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/parent/create-member'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add),
          label: const Text('가족멤버 추가'),
        ),
      ),
    );
  }

  Widget _buildMemberList(BuildContext context, List<FamilyMemberModel> members, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ...members.map((member) => _buildMemberCard(context, ref, member)),
          const SizedBox(height: 96),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '가족 관리',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate800,
                  ),
                ),
                Text(
                  '가족 구성원을 관리하세요',
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

  Future<void> _confirmAndDeleteMember(
      BuildContext context, WidgetRef ref, FamilyMemberModel member) async {
    final family = ref.read(currentFamilyProvider);
    if (family == null) return;

    final isParent = member.role == 'parent';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isParent ? '부모 멤버 삭제' : '아이 멤버 삭제'),
        content: Text(
          isParent
              ? '이 부모 멤버를 삭제하시겠어요?\n가족에 최소 1명의 부모는 남아 있어야 합니다.'
              : '정말 이 아이 멤버를 삭제하시겠어요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final repo = ref.read(familyRepositoryProvider);
      await repo.deleteFamilyMember(family.id, member.id);
      // 목록 갱신
      ref.invalidate(familyMembersProvider(family.id));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('멤버가 삭제되었습니다.'),
          backgroundColor: AppTheme.emerald500,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('멤버 삭제에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    }
  }

  Widget _buildMemberCard(
      BuildContext context, WidgetRef ref, FamilyMemberModel member) {
    final family = ref.watch(currentFamilyProvider);
    final targetUserId = member.userId;
    final displayName = (member.nickname != null && member.nickname!.trim().isNotEmpty)
        ? member.nickname!.trim()
        : (member.role == 'parent' ? '부모' : '아이');
    final memberPointAsync = (family != null && targetUserId != null && member.role == 'child')
        ? ref.watch(memberPointBalanceProvider((familyId: family.id, userId: targetUserId)))
        : const AsyncValue<int>.data(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.slate200,
                child: Text(
                  (displayName.isNotEmpty ? displayName[0] : '멤'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                          Text(
                            displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        member.role == 'parent' ? '부모' : '아이',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmAndDeleteMember(context, ref, member);
                  } else if (value == 'invite') {
                    _copyInviteLink(context, ref, member);
                  } else if (value == 'rename') {
                    _showEditChildNicknameDialog(context, ref, member);
                  }
                },
                itemBuilder: (ctx) => [
                  if (member.role == 'child')
                    const PopupMenuItem(
                      value: 'rename',
                      child: Text('이름 수정'),
                    ),
                  if (member.role == 'child' && member.userId == null)
                    const PopupMenuItem(
                      value: 'invite',
                      child: Text('초대 링크 복사'),
                    ),
                  if (member.role == 'child')
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('멤버 삭제', style: TextStyle(color: AppTheme.error)),
                    ),
                ],
                icon: Icon(Icons.more_vert, color: AppTheme.slate400),
              )
            ],
          ),
          const SizedBox(height: 16),
          // 포인트 및 액션 영역: 아이 계정에만 표시
          if (member.role == 'child') ...[
            if (member.userId == null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '아직 계정이 연결되지 않았어요. 초대 링크를 보내서 이 프로필에 바로 연결할 수 있어요.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _copyInviteLink(context, ref, member),
                      child: const Text('링크 복사'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.slate50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, size: 16, color: AppTheme.amber500),
                      const SizedBox(width: 8),
                      Text(
                        '보유 포인트',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate600,
                        ),
                      ),
                    ],
                  ),
                  memberPointAsync.when(
                    data: (balance) => Text(
                      targetUserId == null ? '계정 연결 필요' : '$balance P',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.slate800,
                      ),
                    ),
                    loading: () => const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Text(
                      '불러오기 실패',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                      '/parent/child-stats',
                      extra: member,
                    ),
                    icon: const Icon(Icons.bar_chart, size: 16),
                    label: const Text('활동 통계'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (member.userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('포인트를 사용하려면 아이 계정 연결이 필요합니다.'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                        return;
                      }
                      context.push(
                        '/parent/point-adjustment',
                        extra: member,
                      );
                    },
                    icon: const Icon(Icons.account_balance_wallet, size: 16),
                    label: const Text('포인트 지급/차감'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.slate100,
                      foregroundColor: AppTheme.slate600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showEditChildNicknameDialog(
    BuildContext context,
    WidgetRef ref,
    FamilyMemberModel member,
  ) async {
    final family = ref.read(currentFamilyProvider);
    if (family == null) return;

    final controller = TextEditingController(
      text: (member.nickname != null && member.nickname!.trim().isNotEmpty)
          ? member.nickname!.trim()
          : '',
    );
    try {
      final saved = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('아이 이름'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: '가족에서 부를 이름',
              hintText: '예: 민수',
            ),
            autofocus: true,
            maxLength: 40,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final t = controller.text.trim();
                if (t.isEmpty) return;
                Navigator.of(ctx).pop(t);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      );

      if (saved == null || saved.isEmpty) return;

      final repo = ref.read(familyRepositoryProvider);
      await repo.updateMemberNickname(family.id, member.id, saved);
      ref.invalidate(familyMembersProvider(family.id));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이름이 저장되었습니다.'),
          backgroundColor: AppTheme.emerald500,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이름 저장에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _copyInviteLink(
    BuildContext context,
    WidgetRef ref,
    FamilyMemberModel member,
  ) async {
    final displayName = (member.nickname != null && member.nickname!.trim().isNotEmpty)
        ? member.nickname!.trim()
        : (member.role == 'parent' ? '부모' : '아이');
    final family = ref.read(currentFamilyProvider);
    if (family == null || family.inviteCode == null || family.inviteCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('초대코드가 없어 링크를 만들 수 없습니다.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final inviteUri = Uri.parse(AppConfig.inviteShareBaseUrl).replace(
      queryParameters: {
        'inviteCode': family.inviteCode!,
        'memberId': member.id,
      },
    );

    await Clipboard.setData(ClipboardData(text: inviteUri.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$displayName 초대 링크를 복사했습니다. 메신저로 붙여넣어 보내주세요.'),
        backgroundColor: AppTheme.emerald500,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
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
                null,
                true,
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
