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

  static StudentStatus fromString(String? s) => switch (s) {
        'newStudent' || 'مستجد'  => StudentStatus.newStudent,
        'suspended'  || 'موقوف'  => StudentStatus.suspended,
        'graduated'  || 'خريج'   => StudentStatus.graduated,
        _                         => StudentStatus.active,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'behaviorRating': behaviorRating,
      'completedJuz': completedJuz,
      'age': age,
      'phoneNumber': phoneNumber,
      'status': status.name,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] as String? ?? '',
      behaviorRating: (json['behaviorRating'] as num?)?.toDouble() ?? 5.0,
      completedJuz: (json['completedJuz'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      age: json['age'] as int?,
      phoneNumber: json['phoneNumber'] as String?,
      status: StudentStatusExt.fromString(json['status'] as String?),
    );
  }
}
