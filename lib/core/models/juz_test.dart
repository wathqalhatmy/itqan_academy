import 'memorization_record.dart';

class JuzTest {
  final String id;
  final String studentId;
  final String circleId;
  final DateTime date;
  final int juzNumber; // رقم الجزء من 1 إلى 30
  final double score; // الدرجة من 100
  final EvaluationGrade grade;
  final String testerName; // اسم المختبر
  final String? notes; // ملاحظات خاصة بهذا الاختبار

  JuzTest({
    required this.id,
    required this.studentId,
    required this.circleId,
    required this.date,
    required this.juzNumber,
    required this.score,
    required this.grade,
    required this.testerName,
    this.notes,
  });

  JuzTest copyWith({
    String? id,
    String? studentId,
    String? circleId,
    DateTime? date,
    int? juzNumber,
    double? score,
    EvaluationGrade? grade,
    String? testerName,
    String? notes,
  }) {
    return JuzTest(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      circleId: circleId ?? this.circleId,
      date: date ?? this.date,
      juzNumber: juzNumber ?? this.juzNumber,
      score: score ?? this.score,
      grade: grade ?? this.grade,
      testerName: testerName ?? this.testerName,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'circleId': circleId,
      'date': date.toIso8601String(),
      'juzNumber': juzNumber,
      'score': score,
      'grade': grade.name,
      'testerName': testerName,
      'notes': notes,
    };
  }

  factory JuzTest.fromJson(Map<String, dynamic> json) {
    return JuzTest(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      circleId: json['circleId'] as String,
      date: DateTime.parse(json['date'] as String),
      juzNumber: json['juzNumber'] as int,
      score: (json['score'] as num).toDouble(),
      grade: EvaluationGrade.values.firstWhere(
        (e) => e.name == json['grade'],
        orElse: () => EvaluationGrade.acceptable,
      ),
      testerName: json['testerName'] as String,
      notes: json['notes'] as String?,
    );
  }
}
