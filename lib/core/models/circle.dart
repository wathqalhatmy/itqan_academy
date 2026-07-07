enum CircleLevel {
  memorization(nameAr: 'حفظ ومراجعة', code: 'memorization'),
  tajweed(nameAr: 'قراءة وتجويد', code: 'tajweed'),
  alphabets(nameAr: 'قراءة وكتابة', code: 'alphabets');

  final String nameAr;
  final String code;
  const CircleLevel({required this.nameAr, required this.code});
}

class Circle {
  final String id;
  final String name;
  final String teacherName;
  final List<String> studentIds;
  final CircleLevel level;

  Circle({
    required this.id,
    required this.name,
    required this.teacherName,
    required this.studentIds,
    this.level = CircleLevel.memorization,
  });

  Circle copyWith({
    String? id,
    String? name,
    String? teacherName,
    List<String>? studentIds,
    CircleLevel? level,
  }) {
    return Circle(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherName: teacherName ?? this.teacherName,
      studentIds: studentIds ?? this.studentIds,
      level: level ?? this.level,
    );
  }
}
