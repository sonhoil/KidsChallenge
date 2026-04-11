import 'package:flutter/material.dart';

/// 부모가 설정한 리워드 아이콘: 이모지(🎮 등) 또는 레거시 키워드(GAME, PIZZA …)
class RewardIconDisplay extends StatelessWidget {
  const RewardIconDisplay({
    super.key,
    required this.iconType,
    this.size = 40,
    this.fallbackEmoji = '🎁',
    this.materialIconColor,
  });

  final String? iconType;
  final double size;
  final String fallbackEmoji;
  final Color? materialIconColor;

  static bool _isEmojiOrShortVisual(String? t) {
    if (t == null || t.trim().isEmpty) return false;
    final s = t.trim();
    if (s.runes.any((r) => r > 0x7F)) return true;
    return s.length <= 3;
  }

  static IconData materialIconFromKeyword(String? iconType) {
    switch (iconType?.toUpperCase()) {
      case 'GAME':
        return Icons.sports_esports;
      case 'PIZZA':
        return Icons.local_pizza;
      case 'TICKET':
        return Icons.confirmation_number;
      case 'ICECREAM':
        return Icons.icecream;
      case 'TV':
        return Icons.tv;
      case 'GIFT':
        return Icons.card_giftcard;
      default:
        return Icons.card_giftcard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final raw = iconType?.trim();

    if (raw == null || raw.isEmpty) {
      return Text(fallbackEmoji, style: TextStyle(fontSize: size * 0.72));
    }

    if (_isEmojiOrShortVisual(raw)) {
      return Text(
        raw,
        style: TextStyle(fontSize: size * 0.72),
      );
    }

    return Icon(
      materialIconFromKeyword(raw),
      size: size * 0.72,
      color: materialIconColor ?? Colors.white,
    );
  }
}
