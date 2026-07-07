import 'package:flutter/material.dart';
import '../models/circle.dart';
import '../theme/app_theme.dart';

/// شارة مستوى الحلقة القرآنية (حفظ / تجويد / هجاء).
class LevelBadge extends StatelessWidget {
  final CircleLevel level;

  const LevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (Color textColor, Color bgColor) = switch (level) {
      CircleLevel.memorization => (
          colorScheme.primary,
          colorScheme.primary.withValues(alpha: 0.1),
        ),
      CircleLevel.tajweed => (
          colorScheme.secondary,
          colorScheme.secondary.withValues(alpha: 0.15),
        ),
      CircleLevel.alphabets => (
          colorScheme.primaryContainer,
          colorScheme.primaryContainer.withValues(alpha: 0.1),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        level.nameAr,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
