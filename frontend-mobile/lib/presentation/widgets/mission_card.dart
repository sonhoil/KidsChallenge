import 'package:flutter/material.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';

class MissionCard extends StatelessWidget {
  final String title;
  final int points;
  final Widget icon;
  final String status; // 'todo', 'pending', 'approved'
  final VoidCallback? onComplete;
  /// 부모가 반려한 뒤 다시 할 수 있는 미션(todo)일 때 카드 안 상단에 안내
  final bool recentlyRejected;
  /// 스페셜(당일 한정) 미션일 때 카드 안에 안내
  final bool oneOff;

  const MissionCard({
    super.key,
    required this.title,
    required this.points,
    required this.icon,
    required this.status,
    this.onComplete,
    this.recentlyRejected = false,
    this.oneOff = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'approved';
    final isPending = status == 'pending';
    final showRejectedBanner = recentlyRejected && status == 'todo';
    final showOneOffBanner = oneOff;
    final hasInnerBanner = showOneOffBanner || showRejectedBanner;

    final borderColor = isCompleted
        ? AppTheme.slate200
        : isPending
            ? AppTheme.warning.withOpacity(0.35)
            : showRejectedBanner
                ? const Color(0xFFFCA5A5)
                : showOneOffBanner
                    ? AppTheme.amber200
                    : AppTheme.childCardBorder;
    final borderWidth =
        isCompleted || isPending || showRejectedBanner || showOneOffBanner ? 2.0 : 1.0;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.slate200
                : isPending
                    ? AppTheme.warning.withOpacity(0.2)
                    : AppTheme.childSky100,
            borderRadius: BorderRadius.circular(18),
          ),
          child: icon,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? AppTheme.slate400 : AppTheme.slate800,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: AppTheme.amber500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+$points P',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isCompleted ? AppTheme.slate400 : AppTheme.amber500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildActionButton(isCompleted, isPending),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasInnerBanner
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showOneOffBanner)
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, showRejectedBanner ? 6 : 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.amber100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.amber200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.today_rounded, size: 18, color: AppTheme.amber600),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '오늘만 수행 가능한 미션이에요!',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                height: 1.35,
                                color: AppTheme.amber600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (showRejectedBanner)
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, showOneOffBanner ? 0 : 10, 10, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFCCD0), width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.error),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '미션을 다시 수행해서 완료해보세요!',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                height: 1.35,
                                color: AppTheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: row,
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: row,
            ),
    );
  }

  Widget _buildActionButton(bool isCompleted, bool isPending) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.slate200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 16, color: AppTheme.slate500),
            const SizedBox(width: 4),
            Text(
              '지급됨',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.slate500,
              ),
            ),
          ],
        ),
      );
    }

    if (isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.warning.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.warning.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 16, color: AppTheme.warning),
            const SizedBox(width: 4),
            Text(
              '승인 대기',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.warning,
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: onComplete,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.childSky500,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: const Text(
        '완료하기',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
