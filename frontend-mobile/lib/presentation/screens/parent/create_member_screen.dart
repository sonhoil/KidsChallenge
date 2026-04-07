import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/family_provider.dart';

class CreateMemberScreen extends ConsumerStatefulWidget {
  const CreateMemberScreen({super.key});

  @override
  ConsumerState<CreateMemberScreen> createState() => _CreateMemberScreenState();
}

class _CreateMemberScreenState extends ConsumerState<CreateMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isSaving = false;
  String _role = 'child'; // 'parent' or 'child'

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    final family = ref.read(currentFamilyProvider);
    if (family == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('가족 정보가 없습니다. 다시 로그인해주세요.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final nickname = _nameController.text.trim();
      final age = _ageController.text.trim();

      final repo = ref.read(familyRepositoryProvider);
      await repo.addFamilyMember(family.id, {
        'role': _role, // 선택한 역할로 추가 (parent / child)
        'nickname': nickname,
        // 나이는 현재 백엔드 스키마에는 없으므로, 추후 확장 시 description 등에 포함 가능
        if (age.isNotEmpty) 'note': 'age=$age',
      });

      // 멤버 목록 갱신
      ref.invalidate(familyMembersProvider(family.id));

      if (!mounted) return;
      final message = _role == 'parent' ? '부모 계정이 추가되었습니다.' : '아이 계정이 추가되었습니다.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.emerald500));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('아이 계정 추가에 실패했습니다: $e'),
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
    final canSave = _nameController.text.trim().isNotEmpty && !_isSaving;

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          '가족 멤버 추가',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.slate800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.slate500),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: canSave ? _saveMember : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNameSection(),
                const SizedBox(height: 24),
                _buildRoleSection(),
                const SizedBox(height: 24),
                _buildAgeSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person, size: 18, color: AppTheme.slate500),
            SizedBox(width: 6),
            Text(
              '이름 (또는 닉네임)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '아이 이름을 입력해주세요',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppTheme.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppTheme.slate200),
            ),
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.slate800,
          ),
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '이름을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAgeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '나이 (선택사항)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.slate500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '예: 8',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppTheme.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppTheme.slate200),
            ),
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.slate800,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.family_restroom, size: 18, color: AppTheme.slate500),
            SizedBox(width: 6),
            Text(
              '역할 선택',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _role = 'parent';
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: _role == 'parent'
                      ? AppTheme.primaryLight.withOpacity(0.2)
                      : Colors.white,
                  side: BorderSide(
                    color: _role == 'parent' ? AppTheme.primary : AppTheme.slate200,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  '부모',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _role == 'parent' ? AppTheme.primary : AppTheme.slate500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _role = 'child';
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      _role == 'child' ? AppTheme.primaryLight.withOpacity(0.2) : Colors.white,
                  side: BorderSide(
                    color: _role == 'child' ? AppTheme.primary : AppTheme.slate200,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  '아이',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _role == 'child' ? AppTheme.primary : AppTheme.slate500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 프로필 사진 선택 섹션 제거됨
}
