import 'package:flutter/material.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';
import 'package:kids_challenge/presentation/widgets/reward_icon_display.dart';

/// 상점·쿠폰함 공통: 목록 행 + 아이콘 칸 + 제목 + 메타 + 우측 액션 버튼
class RewardListRow extends StatelessWidget {
  const RewardListRow({
    super.key,
    required this.iconType,
    required this.iconBg,
    required this.title,
    required this.metaLine,
    required this.actionLabel,
    this.showSpecialBadge = false,
    this.actionPrimary = true,
    this.onAction,
    this.onRowTap,
    this.primaryButtonBackground,
    this.primaryButtonForeground,
  });

  final String? iconType;
  final Color iconBg;
  final String title;
  final Widget metaLine;
  final String actionLabel;
  final bool showSpecialBadge;
  /// true이고 [onAction]이 null이 아니면 분홍 버튼(교환·사용). false면 회색(부족·완료).
  final bool actionPrimary;
  final VoidCallback? onAction;
  final VoidCallback? onRowTap;
  /// null이면 상점 기본(분홍). 쿠폰함 등에서 하늘색 지정.
  final Color? primaryButtonBackground;
  final Color? primaryButtonForeground;

  @override
  Widget build(BuildContext context) {
    final content = Material(
      color: AppTheme.childRewardListCardBackground,
      elevation: 0,
      shadowColor: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onRowTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.childRewardListCardBackground,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.childCardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.childRewardIconWellBorder),
                  ),
                  alignment: Alignment.center,
                  child: RewardIconDisplay(
                    iconType: iconType,
                    size: 44,
                    materialIconColor: const Color(0xFF57534E),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showSpecialBadge)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE8EE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '특별',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE11D48),
                              ),
                            ),
                          ),
                        ),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF44403C),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      metaLine,
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: onAction,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        backgroundColor: onAction != null && actionPrimary
                            ? (primaryButtonBackground ?? const Color(0xFFFF9EB5))
                            : AppTheme.slate200,
                        foregroundColor: onAction != null && actionPrimary
                            ? (primaryButtonForeground ?? const Color(0xFF7C2D12))
                            : AppTheme.slate500,
                        disabledBackgroundColor: AppTheme.slate200,
                        disabledForegroundColor: AppTheme.slate400,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return content;
  }
}
