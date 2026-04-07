import 'package:flutter/material.dart';
import 'package:kids_challenge/core/theme/app_theme.dart';

class TicketCard extends StatelessWidget {
  final String id;
  final String title;
  final String ownerName;
  final bool isUsed;
  final String dateStr;
  final VoidCallback? onUse;

  const TicketCard({
    super.key,
    required this.id,
    required this.title,
    required this.ownerName,
    required this.isUsed,
    required this.dateStr,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isUsed ? AppTheme.slate50 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUsed ? AppTheme.slate200 : AppTheme.primaryLight.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isUsed
                ? Colors.black.withOpacity(0.02)
                : AppTheme.primary.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$ownerName의 쿠폰',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slate500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isUsed ? AppTheme.slate600 : AppTheme.slate800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.slate400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 3,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(
                    color: AppTheme.slate200,
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
              ),
              child: CustomPaint(
                painter: DashedLinePainter(),
              ),
            ),
            Container(
              width: 112,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUsed ? AppTheme.slate100 : AppTheme.primaryLight.withOpacity(0.1),
              ),
              child: isUsed
                  ? Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.error, width: 3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '사용완료',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: onUse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        '지금 사용',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.slate200
      ..strokeWidth = 1;

    const dashWidth = 4;
    const dashSpace = 4;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
