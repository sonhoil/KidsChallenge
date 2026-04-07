import 'package:flutter/material.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/data/models/family_model.dart';
import 'package:kids_challenge/presentation/screens/parent/child_point_edit_screen.dart';

/// 라우팅상의 기존 경로 유지를 위해 남겨두되,
/// 실제 화면은 ChildPointEditScreen 으로 교체하는 래퍼 역할만 수행한다.
import 'package:go_router/go_router.dart';

class PointAdjustmentScreen extends StatelessWidget {
  final FamilyMemberModel? member;

  const PointAdjustmentScreen({super.key, this.member});

  @override
  Widget build(BuildContext context) {
    if (member == null) {
      return Scaffold(
        backgroundColor: AppTheme.slate50,
        appBar: AppBar(
          title: const Text('포인트 지급/차감'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('아이 정보가 없습니다. 멤버 화면에서 다시 시도해주세요.'),
        ),
      );
    }

    // 실제 구현은 ChildPointEditScreen 이 담당
    return ChildPointEditScreen(member: member!);
  }
}
