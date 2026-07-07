enum RecordType {
  memorization, // حفظ
  revision,     // مراجعة
  recitation,   // تلاوة وقراءة
  alphabets,    // قراءة وكتابة
}

/// امتداد يوفر التسمية العربية لكل نوع سجل.
/// يُجنّب تكرار منطق switch في الشاشات المختلفة.
extension RecordTypeExt on RecordType {
  String get nameAr => switch (this) {
        RecordType.memorization => 'حفظ جديد',
        RecordType.revision     => 'مراجعة',
        RecordType.recitation   => 'تلاوة',
        RecordType.alphabets    => 'تهجي وقراءة',
      };
}

enum EvaluationGrade {
  excellent,  // ممتاز
  veryGood,   // جيد جداً
  good,       // جيد
  acceptable, // مقبول
}

extension EvaluationGradeExt on EvaluationGrade {
  String get nameAr {
    switch (this) {
      case EvaluationGrade.excellent:
        return 'ممتاز';
      case EvaluationGrade.veryGood:
        return 'جيد جداً';
      case EvaluationGrade.good:
        return 'جيد';
      case EvaluationGrade.acceptable:
        return 'مقبول';
    }
  }
}

class MemorizationRecord {
  final String id;
  final String studentId;
  final String circleId;
  final DateTime date;
  final RecordType type;
  final String? surahName;
  final int? fromVerse;
  final int? toVerse;
  final String? lessonName;
  final int? pageNumber;
  final String? tajweedRules;
  final EvaluationGrade grade;
  final String? notes; // ملاحظات خاصة بهذا التقييم

  MemorizationRecord({
    required this.id,
    required this.studentId,
    required this.circleId,
    required this.date,
    required this.type,
    this.surahName,
    this.fromVerse,
    this.toVerse,
    this.lessonName,
    this.pageNumber,
    this.tajweedRules,
    required this.grade,
    this.notes,
  });

  MemorizationRecord copyWith({
    String? id,
    String? studentId,
    String? circleId,
    DateTime? date,
    RecordType? type,
    String? surahName,
    int? fromVerse,
    int? toVerse,
    String? lessonName,
    int? pageNumber,
    String? tajweedRules,
    EvaluationGrade? grade,
    String? notes,
  }) {
    return MemorizationRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      circleId: circleId ?? this.circleId,
      date: date ?? this.date,
      type: type ?? this.type,
      surahName: surahName ?? this.surahName,
      fromVerse: fromVerse ?? this.fromVerse,
      toVerse: toVerse ?? this.toVerse,
      lessonName: lessonName ?? this.lessonName,
      pageNumber: pageNumber ?? this.pageNumber,
      tajweedRules: tajweedRules ?? this.tajweedRules,
      grade: grade ?? this.grade,
      notes: notes ?? this.notes,
    );
  }
}
