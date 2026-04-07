import 'package:flutter/material.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';

class MissionCard extends StatelessWidget {
  final String title;
  final int points;
  final Widget icon;
  final String status; // 'todo', 'pending', 'approved'
  final VoidCallback? onComplete;

  const MissionCard({
    super.key,
    required this.title,
    required this.points,
    required this.icon,
    required this.status,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'approved';
    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isCompleted
              ? AppTheme.slate200
              : isPending
                  ? AppTheme.warning.withOpacity(0.3)
                  : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.slate200
                  : isPending
                      ? AppTheme.warning.withOpacity(0.2)
                      : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(20),
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
        backgroundColor: AppTheme.emerald400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
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
