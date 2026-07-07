import 'package:flutter/material.dart';
import '../models/memorization_record.dart';

/// أزرار اختيار التقييم (ممتاز / جيد جداً / جيد / مقبول).
/// مُعاد استخدامها في AddRecordDialog و AddTestDialog.
class GradeChipSelector extends StatelessWidget {
  final EvaluationGrade selectedGrade;
  final ValueChanged<EvaluationGrade> onChanged;

  const GradeChipSelector({
    super.key,
    required this.selectedGrade,
    required this.onChanged,
  });

  Color gradeColor(EvaluationGrade grade, ColorScheme colorScheme) => switch (grade) {
        EvaluationGrade.excellent  => colorScheme.primary,
        EvaluationGrade.veryGood   => colorScheme.primaryContainer,
        EvaluationGrade.good       => colorScheme.secondary,
        EvaluationGrade.acceptable => colorScheme.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children: EvaluationGrade.values.map((grade) {
          final isSelected = selectedGrade == grade;
          final color = gradeColor(grade, colorScheme);
          return ChoiceChip(
            label: Text(grade.nameAr),
            selected: isSelected,
            selectedColor: color.withValues(alpha: 0.18),
            checkmarkColor: color,
            labelStyle: TextStyle(
              color: isSelected ? color : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            side: BorderSide(
              color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
            onSelected: (selected) {
              if (selected) onChanged(grade);
            },
          );
        }).toList(),
      ),
    );
  }
}
