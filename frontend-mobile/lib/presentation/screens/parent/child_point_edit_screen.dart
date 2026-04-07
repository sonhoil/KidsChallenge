import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/data/models/family_model.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/point_provider.dart';

/// 단일 아이의 포인트를 조정하는 화면
class ChildPointEditScreen extends ConsumerStatefulWidget {
  final FamilyMemberModel member;

  const ChildPointEditScreen({super.key, required this.member});

  @override
  ConsumerState<ChildPointEditScreen> createState() => _ChildPointEditScreenState();
}

class _ChildPointEditScreenState extends ConsumerState<ChildPointEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pointController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _pointController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final family = ref.read(currentFamilyProvider);
    final targetUserId = widget.member.userId;
    if (family == null || targetUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('포인트를 수정하려면 연결된 아이 계정이 필요합니다.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final signedAmount = int.parse(_pointController.text.trim());
    if (signedAmount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('0이 아닌 포인트 값을 입력해주세요.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(pointActionsProvider).adjustMemberPoints(
            familyId: family.id,
            targetUserId: targetUserId,
            signedAmount: signedAmount,
            reason: _reasonController.text,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('포인트가 수정되었습니다.'),
          backgroundColor: AppTheme.emerald500,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('포인트 수정에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final family = ref.watch(currentFamilyProvider);
    final targetUserId = widget.member.userId;
    final balanceAsync = (family != null && targetUserId != null)
        ? ref.watch(memberPointBalanceProvider((familyId: family.id, userId: targetUserId)))
        : const AsyncValue<int>.data(0);

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          '${widget.member.nickname ?? '아이'} 포인트 수정',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.slate800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.slate500),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '현재 포인트',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.slate200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emoji_events, size: 18, color: AppTheme.amber500),
                          const SizedBox(width: 8),
                          const Text(
                            '보유 포인트',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slate700,
                            ),
                          ),
                        ],
                      ),
                      balanceAsync.when(
                        data: (balance) => Text(
                          '$balance P',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.slate800,
                          ),
                        ),
                        loading: () => const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => Text(
                          targetUserId == null ? '계정 연결 필요' : '불러오기 실패',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '변경할 포인트',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pointController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '예: +100 또는 -50',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppTheme.slate200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppTheme.slate200),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '변경할 포인트를 입력해주세요';
                    }
                    final v = int.tryParse(value.trim());
                    if (v == null) {
                      return '정수 값을 입력해주세요 (예: 100, -50)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  '설명 (선택)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 2,
                  controller: _reasonController,
                  decoration: InputDecoration(
                    hintText: '포인트를 수정하는 이유를 적어주세요',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppTheme.slate200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppTheme.slate200),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving || targetUserId == null ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '포인트 수정하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

