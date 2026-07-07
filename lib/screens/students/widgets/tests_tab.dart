import 'package:flutter/material.dart';
import '../../../core/models/juz_test.dart';
import '../../../core/models/memorization_record.dart';
import '../../../core/theme/app_theme.dart';

class TestsTab extends StatelessWidget {
  final List<JuzTest> tests;

  const TestsTab({
    super.key,
    required this.tests,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_outlined, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            const Text('لا توجد سجلات اختبار أجزاء بعد', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: tests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = tests[index];

        Color gradeColor = Colors.grey;
        switch (t.grade) {
          case EvaluationGrade.excellent:
            gradeColor = colorScheme.primary;
            break;
          case EvaluationGrade.veryGood:
            gradeColor = colorScheme.primaryContainer;
            break;
          case EvaluationGrade.good:
            gradeColor = colorScheme.secondary;
            break;
          case EvaluationGrade.acceptable:
            gradeColor = colorScheme.onSurfaceVariant;
            break;
        }

        return Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.tertiary.withValues(alpha: 0.12),
                  child: Text(
                    '${t.juzNumber}',
                    style: TextStyle(color: colorScheme.tertiary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختبار الجزء ${t.juzNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'المختبر: ${t.testerName}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                      ),
                      if (t.notes != null && t.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.03)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.speaker_notes_rounded, size: 10, color: colorScheme.primary),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  t.notes!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الدرجة: ${t.score.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: gradeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.date.day}/${t.date.month}/${t.date.year}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 9,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
