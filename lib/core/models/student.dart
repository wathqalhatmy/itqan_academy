/// حالات الطالب المتاحة في النظام.
enum StudentStatus {
  active,    // نشط
  newStudent, // مستجد
  suspended, // موقوف
  graduated, // خريج
}

extension StudentStatusExt on StudentStatus {
  String get nameAr => switch (this) {
        StudentStatus.active     => 'نشط',
        StudentStatus.newStudent => 'مستجد',
        StudentStatus.suspended  => 'موقوف',
        StudentStatus.graduated  => 'خريج',
      };

  static StudentStatus fromString(String s) => switch (s) {
        'مستجد'  => StudentStatus.newStudent,
        'موقوف'  => StudentStatus.suspended,
        'خريج'   => StudentStatus.graduated,
        _         => StudentStatus.active,
      };
}

class Student {
  final String id;
  final String name;
  final String notes;
  final double behaviorRating; // من 1.0 إلى 5.0
  final List<int> completedJuz; // الأجزاء المجتازة بالكامل (1-30)
  final int? age;
  final String? phoneNumber;
  final StudentStatus status;

  Student({
    required this.id,
    required this.name,
    this.notes = '',
    this.behaviorRating = 5.0,
    this.completedJuz = const [],
    this.age,
    this.phoneNumber,
    this.status = StudentStatus.active,
  });

  Student copyWith({
    String? id,
    String? name,
    String? notes,
    double? behaviorRating,
    List<int>? completedJuz,
    int? age,
    String? phoneNumber,
    StudentStatus? status,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      behaviorRating: behaviorRating ?? this.behaviorRating,
      completedJuz: completedJuz ?? this.completedJuz,
      age: age ?? this.age,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
    );
  }
}
