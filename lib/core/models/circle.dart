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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacherName': teacherName,
      'studentIds': studentIds,
      'level': level.name,
    };
  }

  static List<String> _parseStudentIds(dynamic jsonVal) {
    if (jsonVal == null) return const [];
    if (jsonVal is List) {
      return jsonVal.map((e) => e.toString()).toList();
    }
    return [jsonVal.toString()];
  }

  factory Circle.fromJson(Map<String, dynamic> json) {
    return Circle(
      id: json['id'] as String,
      name: json['name'] as String,
      teacherName: json['teacherName'] as String,
      studentIds: _parseStudentIds(json['studentIds']),
      level: CircleLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => CircleLevel.memorization,
      ),
    );
  }
}
