enum AttendanceStatus {
  present,  // حاضر
  absent,   // غائب
  excused,  // غائب بعذر
  late,     // متأخر
  unmarked, // غير محضر
}

extension AttendanceStatusExt on AttendanceStatus {
  String get nameAr {
    switch (this) {
      case AttendanceStatus.present:
        return 'حاضر';
      case AttendanceStatus.absent:
        return 'غائب';
      case AttendanceStatus.excused:
        return 'غائب بعذر';
      case AttendanceStatus.late:
        return 'متأخر';
      case AttendanceStatus.unmarked:
        return 'غير محضر';
    }
  }
}

class Attendance {
  final String id;
  final String studentId;
  final String circleId;
  final DateTime date;
  final AttendanceStatus status;
  final DateTime? arrivalTime;
  final String? note; // ملاحظات على الحضور (مثل سبب الغياب)

  Attendance({
    required this.id,
    required this.studentId,
    required this.circleId,
    required this.date,
    required this.status,
    this.arrivalTime,
    this.note,
  });

  Attendance copyWith({
    String? id,
    String? studentId,
    String? circleId,
    DateTime? date,
    AttendanceStatus? status,
    DateTime? arrivalTime,
    String? note,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      circleId: circleId ?? this.circleId,
      date: date ?? this.date,
      status: status ?? this.status,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      note: note ?? this.note,
    );
  }
}
