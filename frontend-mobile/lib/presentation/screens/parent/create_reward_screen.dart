import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/data/models/reward_model.dart';
import 'package:kids_challenge/presentation/state/auth_provider.dart';
import 'package:kids_challenge/presentation/state/reward_provider.dart';

class CreateRewardScreen extends ConsumerStatefulWidget {
  final RewardModel? reward;

  const CreateRewardScreen({super.key, this.reward});

  @override
  ConsumerState<CreateRewardScreen> createState() => _CreateRewardScreenState();
}

class _CreateRewardScreenState extends ConsumerState<CreateRewardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _pointsController = TextEditingController();
  bool _isSaving = false;
  String _selectedIcon = '🎮';

  final List<String> _icons = const ['🎮', '💵', '🍿', '🎢', '🧸', '🚲', '📱', '🍕'];

  bool get _isEditMode => widget.reward != null;

  @override
  void initState() {
    super.initState();
    final reward = widget.reward;
    if (reward != null) {
      _titleController.text = reward.title;
      _pointsController.text = reward.pricePoints.toString();
      if (reward.iconType != null && reward.iconType!.isNotEmpty) {
        _selectedIcon = reward.iconType!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _saveReward() async {
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
      final repo = ref.read(rewardRepositoryProvider);
      final title = _titleController.text.trim();
      final points = int.tryParse(_pointsController.text.trim()) ?? 0;
      final request = {
        'familyId': family.id,
        'title': title,
        'pricePoints': points,
        'iconType': _selectedIcon,
      };

      if (_isEditMode) {
        await repo.updateReward(widget.reward!.id, request);
      } else {
        await repo.createReward(request);
      }

      // 리워드 목록 갱신
      ref.invalidate(rewardsProvider(family.id));
      ref.invalidate(allRewardsProvider(family.id));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? '보상이 수정되었습니다.' : '보상이 생성되었습니다.'),
          backgroundColor: AppTheme.emerald500,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('보상 생성에 실패했습니다: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 88),
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
    final canSave = _titleController.text.trim().isNotEmpty &&
        _pointsController.text.trim().isNotEmpty &&
        !_isSaving;

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          _isEditMode ? '보상 수정' : '새 보상 등록',
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
              onPressed: canSave ? _saveReward : null,
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
                _buildTitleAndIconSection(),
                const SizedBox(height: 24),
                _buildPointsSection(),
                const SizedBox(height: 12),
                const Text(
                  '아이들이 이 보상을 구매하기 위해 지불해야 할 포인트입니다.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndIconSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.title, size: 18, color: AppTheme.slate500),
            SizedBox(width: 6),
            Text(
              '보상 이름',
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.slate200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _selectedIcon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '예: 게임 1시간 이용권',
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
                    return '보상 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _icons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final icon = _icons[index];
              final isSelected = _selectedIcon == icon;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryLight.withOpacity(0.3) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.slate200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sell, size: 18, color: AppTheme.slate500),
            SizedBox(width: 6),
            Text(
              '필요 포인트',
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
          controller: _pointsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '500',
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppTheme.slate800,
            fontSize: 18,
          ),
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '포인트를 입력해주세요';
            }
            final parsed = int.tryParse(value.trim());
            if (parsed == null || parsed <= 0) {
              return '1 이상의 숫자를 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }
}
