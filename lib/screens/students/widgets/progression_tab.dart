import 'package:flutter/material.dart';
import '../../../core/models/student.dart';
import '../../../core/models/circle.dart';
import '../../../core/models/memorization_record.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/quran_data.dart';

class ProgressionTab extends StatelessWidget {
  final Student student;
  final CircleLevel level;
  final List<MemorizationRecord> records;

  const ProgressionTab({
    super.key,
    required this.student,
    required this.level,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    switch (level) {
      case CircleLevel.memorization:
        return _buildSurahProgressMap(context, records);
      case CircleLevel.tajweed:
        return _buildTajweedProgressList(context, records);
      case CircleLevel.alphabets:
        return _buildAlphabetsGrid(context, records);
    }
  }

  Widget _buildSurahProgressMap(
      BuildContext context, List<MemorizationRecord> records) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // تصفية سجلات الحفظ والمراجعة
    final memRecords =
        records.where((r) => r.type == RecordType.memorization).toList();
    final revRecords =
        records.where((r) => r.type == RecordType.revision).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: QuranData.surahs.length,
      itemBuilder: (context, index) {
        final surah = QuranData.surahs[index];
        final surahName = surah.name;
        final totalVerses = surah.verses;

        // البحث عن أعلى آية وصل إليها الطالب في هذه السورة
        final surahRecords =
            memRecords.where((r) => r.surahName == surahName).toList();

        // البحث عن عدد مرات المراجعة لهذه السورة
        final revisionCount =
            revRecords.where((r) => r.surahName == surahName).length;

        int maxVerse = 0;
        bool isCompleted = false;

        if (surahRecords.isNotEmpty) {
          for (var r in surahRecords) {
            if (r.toVerse != null && r.toVerse! > maxVerse) {
              maxVerse = r.toVerse!;
            }
          }
          if (maxVerse >= totalVerses) {
            isCompleted = true;
          }
        }

        Color statusColor = Colors.grey;
        String statusText = 'لم تبدأ';
        double progress = 0.0;

        if (isCompleted) {
          statusColor = AppTheme.successGreen;
          statusText = 'مكتملة';
          progress = 1.0;
        } else if (maxVerse > 0) {
          statusColor = colorScheme.secondary;
          statusText = 'جارية (آية $maxVerse)';
          progress = maxVerse / totalVerses;
        }

        return Card(
          elevation: 0.5,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                BorderSide(color: statusColor.withValues(alpha: 0.2), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: SurahAvatarTheme.radius,
                          backgroundColor: statusColor.withValues(alpha: 0.1),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: SurahAvatarTheme.spacing),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surahName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Row(
                              children: [
                                Text(
                                  '$totalVerses آية',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontSize: 9),
                                ),
                                if (revisionCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.refresh_rounded,
                                            size: 8,
                                            color: colorScheme.primary),
                                        const SizedBox(width: 2),
                                        Text(
                                          'مراجعة: $revisionCount',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: SurahBadgeTheme.verticalPadding),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(SurahBadgeTheme.borderRadius),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (progress > 0 && !isCompleted) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: statusColor.withValues(alpha: 0.1),
                      color: statusColor,
                      minHeight: SurahProgressBarTheme.height,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTajweedProgressList(
      BuildContext context, List<MemorizationRecord> records) {
    final skills = [
      {'title': 'مخارج الحروف وصفاتها', 'keyword': 'مخارج'},
      {'title': 'أحكام النون الساكنة والتنوين', 'keyword': 'نون'},
      {'title': 'أحكام الميم الساكنة', 'keyword': 'ميم'},
      {'title': 'المدود وأحكامها', 'keyword': 'مد'},
      {'title': 'أحكام القلقلة', 'keyword': 'قلقلة'},
      {'title': 'أحكام الراء تفخيماً وترقيقاً', 'keyword': 'تفخيم'},
      {'title': 'مواضع السكت في القرآن', 'keyword': 'سكت'},
      {'title': 'النون والميم المشددتين', 'keyword': 'مشددة'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        final title = skill['title']!;

        final matching = records.where(
            (r) => r.type == RecordType.recitation && r.tajweedRules == title);

        String statusLabel = 'لم يبدأ بعد';
        Color statusColor = Colors.grey;
        IconData statusIcon = Icons.radio_button_unchecked_rounded;

        if (matching.isNotEmpty) {
          final isMastered = matching.any((r) =>
              r.grade == EvaluationGrade.excellent ||
              r.grade == EvaluationGrade.veryGood);
          if (isMastered) {
            statusLabel = 'متقن';
            statusColor = AppTheme.successGreen;
            statusIcon = Icons.verified_rounded;
          } else {
            statusLabel = 'قيد التدريب';
            statusColor = AppTheme.warningOrange;
            statusIcon = Icons.timelapse_rounded;
          }
        }

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: statusColor.withValues(alpha: 0.1),
              child: Icon(statusIcon, color: statusColor, size: 18),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: statusColor.withValues(alpha: 0.2), width: 0.8),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlphabetsGrid(
      BuildContext context, List<MemorizationRecord> records) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final letters = [
      'أ',
      'ب',
      'ت',
      'ث',
      'ج',
      'ح',
      'خ',
      'د',
      'ذ',
      'ر',
      'ز',
      'س',
      'ش',
      'ص',
      'ض',
      'ط',
      'ظ',
      'ع',
      'غ',
      'ف',
      'ق',
      'ك',
      'ل',
      'م',
      'ن',
      'هـ',
      'و',
      'ي'
    ];

    final rules = [
      {'title': 'حركة الفتحة', 'keyword': 'فتحة'},
      {'title': 'حركة الضمة', 'keyword': 'ضمة'},
      {'title': 'حركة الكسرة', 'keyword': 'كسرة'},
      {'title': 'حكم السكون', 'keyword': 'سكون'},
      {'title': 'أحكام التنوين', 'keyword': 'تنوين'},
      {'title': 'حكم الشدّة', 'keyword': 'شد'},
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'لوحة إنجاز الحروف الهجائية',
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 14),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final letter = letters[index];
                final matching = records.where((r) =>
                    r.type == RecordType.alphabets &&
                    r.lessonName == 'حرف $letter');

                final isLearned = matching.isNotEmpty &&
                    matching.any((r) =>
                        r.grade == EvaluationGrade.excellent ||
                        r.grade == EvaluationGrade.veryGood);

                return Container(
                  decoration: BoxDecoration(
                    color: isLearned
                        ? colorScheme.primary.withValues(alpha: 0.08)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isLearned
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        letter,
                        style: TextStyle(
                          color: isLearned
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (isLearned)
                        const Positioned(
                          top: 1,
                          right: 1,
                          child: Icon(Icons.star_rounded,
                              size: 6, color: Colors.orange),
                        ),
                    ],
                  ),
                );
              },
              childCount: letters.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 18, bottom: 6),
            child: Text(
              'الحركات والقواعد الأساسية',
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 14),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 18),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final rule = rules[index];
                final title = rule['title']!;

                final matching = records.where((r) =>
                    r.type == RecordType.alphabets && r.lessonName == title);

                final isLearned = matching.isNotEmpty &&
                    matching.any((r) =>
                        r.grade == EvaluationGrade.excellent ||
                        r.grade == EvaluationGrade.veryGood);

                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  color: isLearned
                      ? AppTheme.successGreen.withValues(alpha: 0.06)
                      : theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isLearned
                          ? AppTheme.successGreen.withValues(alpha: 0.25)
                          : Colors.transparent,
                      width: isLearned ? 0.8 : 0,
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    leading: Icon(
                      isLearned
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isLearned
                          ? AppTheme.successGreen
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      size: 18,
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isLearned
                            ? AppTheme.successGreen
                            : colorScheme.onSurface,
                      ),
                    ),
                    trailing: isLearned
                        ? const Text('مكتملة 🌟',
                            style: TextStyle(
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 10))
                        : Text('قيد التعلم',
                            style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10)),
                  ),
                );
              },
              childCount: rules.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ثيمات مخصصة للعناصر
class SurahAvatarTheme {
  static const double radius = 16.0;
  static const double spacing = 12.0;
}

class SurahBadgeTheme {
  static const double verticalPadding = 4.0;
  static const double borderRadius = 12.0;
}

class SurahProgressBarTheme {
  static const double height = 6.0;
}
