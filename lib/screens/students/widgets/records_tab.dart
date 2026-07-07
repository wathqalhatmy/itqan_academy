import 'package:flutter/material.dart';
import '../../../core/models/memorization_record.dart';
import '../../../core/theme/app_theme.dart';

class RecordsTab extends StatelessWidget {
  final List<MemorizationRecord> records;

  const RecordsTab({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_edu_rounded, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            const Text('لا توجد سجلات تسميع أو مراجعة حالياً', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = records[index];
        
        String typeLabel = '';
        Color typeColor = Colors.grey;
        Color typeTextColor = Colors.white;
        
        switch (r.type) {
          case RecordType.memorization:
            typeLabel = 'حفظ';
            typeColor = colorScheme.primary.withValues(alpha: 0.12);
            typeTextColor = colorScheme.primary;
            break;
          case RecordType.revision:
            typeLabel = 'مراجعة';
            typeColor = colorScheme.secondary.withValues(alpha: 0.15);
            typeTextColor = colorScheme.onSecondary;
            break;
          case RecordType.recitation:
            typeLabel = 'تلاوة';
            typeColor = colorScheme.primaryContainer.withValues(alpha: 0.15);
            typeTextColor = colorScheme.primaryContainer;
            break;
          case RecordType.alphabets:
            typeLabel = 'تهجي';
            typeColor = colorScheme.tertiary.withValues(alpha: 0.15);
            typeTextColor = colorScheme.tertiary;
            break;
        }

        Color gradeColor = Colors.grey;
        switch (r.grade) {
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      color: typeTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.type == RecordType.alphabets
                            ? '${r.lessonName}'
                            : 'سورة ${r.surahName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        r.type == RecordType.alphabets
                            ? 'صفحة: ${r.pageNumber}'
                            : 'الآيات: من ${r.fromVerse} إلى ${r.toVerse}${r.tajweedRules != null && r.tajweedRules!.isNotEmpty ? ' | التجويد: ${r.tajweedRules}' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                      ),
                      if (r.notes != null && r.notes!.isNotEmpty) ...[
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
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  r.notes!,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: gradeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: gradeColor.withValues(alpha: 0.2), width: 0.8),
                      ),
                      child: Text(
                        r.grade.nameAr,
                        style: TextStyle(
                          color: gradeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${r.date.day}/${r.date.month}/${r.date.year}',
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
