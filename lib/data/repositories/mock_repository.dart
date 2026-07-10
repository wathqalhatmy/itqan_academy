import '../../core/models/student.dart';
import '../../core/models/circle.dart';
import '../../core/models/attendance.dart';
import '../../core/models/memorization_record.dart';
import '../../core/models/juz_test.dart';
import '../../core/constants/app_constants.dart';
import 'academy_repository.dart';

class MockRepository implements AcademyRepository {
  // بيانات الطلاب في الذاكرة
  final List<Student> _students = [
    Student(id: 's1', name: 'أنس بن مالك', notes: 'ممتاز في التجويد ومخارج الحروف', behaviorRating: 5.0, completedJuz: [30, 29]),
    Student(id: 's2', name: 'عبد الرحمن بن عوف', notes: 'يحتاج لتركيز أكبر في مراجعة الأوجه المتشابهة', behaviorRating: 4.5, completedJuz: [30]),
    Student(id: 's3', name: 'عبد الله بن عمر', notes: 'ملتزم جداً بالحضور اليومي والتسميع', behaviorRating: 5.0, completedJuz: [30, 29, 28]),
    Student(id: 's4', name: 'معاذ بن جبل', notes: 'متميز في سرعة الحفظ الجديد', behaviorRating: 4.8, completedJuz: [30]),
    Student(id: 's5', name: 'سعد بن أبي وقاص', notes: 'يتأخر أحياناً عن بدء الحلقة', behaviorRating: 3.8, completedJuz: []),
    Student(id: 's6', name: 'خالد بن الوليد', notes: 'نشيط وذو همة عالية في المراجعة', behaviorRating: 5.0, completedJuz: [30, 29]),
    Student(id: 's7', name: 'سلمان الفارسي', notes: 'يحتاج لمتابعة مستمرة في التلاوة الصحيحة', behaviorRating: 4.2, completedJuz: []),
    Student(id: 's8', name: 'أبو عبيدة بن الجراح', notes: 'هادئ ومثابر جداً', behaviorRating: 5.0, completedJuz: [30, 29, 28, 27]),
  ];

  // بيانات الحلقات في الذاكرة
  final List<Circle> _circles = [
    Circle(
      id: 'c1',
      name: 'حلقة عاصم بن أبي النجود',
      teacherName: 'الشيخ أحمد المحمود',
      studentIds: ['s1', 's2', 's3'],
      level: CircleLevel.memorization,
    ),
    Circle(
      id: 'c2',
      name: 'حلقة نافع المدني',
      teacherName: 'الشيخ عمر الفاروق',
      studentIds: ['s4', 's5', 's6'],
      level: CircleLevel.tajweed,
    ),
    Circle(
      id: 'c3',
      name: 'حلقة ابن كثير المكي',
      teacherName: 'الشيخ عبد الرحمن السعدي',
      studentIds: ['s7', 's8'],
      level: CircleLevel.alphabets,
    ),
  ];

  // سجلات الحضور والغياب
  final List<Attendance> _attendanceRecords = [];

  // سجلات الحفظ والمراجعة
  final List<MemorizationRecord> _memorizationRecords = [
    MemorizationRecord(
      id: 'r1',
      studentId: 's1',
      circleId: 'c1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: RecordType.memorization,
      surahName: 'الملك',
      fromVerse: 1,
      toVerse: 15,
      grade: EvaluationGrade.excellent,
    ),
    MemorizationRecord(
      id: 'r2',
      studentId: 's1',
      circleId: 'c1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: RecordType.revision,
      surahName: 'النبأ',
      fromVerse: 1,
      toVerse: 40,
      grade: EvaluationGrade.veryGood,
    ),
    MemorizationRecord(
      id: 'r3',
      studentId: 's3',
      circleId: 'c1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: RecordType.memorization,
      surahName: 'المرسلات',
      fromVerse: 1,
      toVerse: 25,
      grade: EvaluationGrade.good,
    ),
  ];

  // سجلات اختبارات الأجزاء
  final List<JuzTest> _juzTests = [
    JuzTest(
      id: 't1',
      studentId: 's1',
      circleId: 'c1',
      date: DateTime.now().subtract(const Duration(days: 10)),
      juzNumber: 30,
      score: 98.5,
      grade: EvaluationGrade.excellent,
      testerName: 'أ. عبد الله الكندري',
    ),
    JuzTest(
      id: 't2',
      studentId: 's3',
      circleId: 'c1',
      date: DateTime.now().subtract(const Duration(days: 15)),
      juzNumber: 30,
      score: 92.0,
      grade: EvaluationGrade.veryGood,
      testerName: 'أ. عبد الله الكندري',
    ),
  ];

  MockRepository() {
    // ملء بيانات حضور افتراضية لليوم السابق للتوضيح
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    _attendanceRecords.addAll([
      Attendance(id: 'a1', studentId: 's1', circleId: 'c1', date: yesterday, status: AttendanceStatus.present, arrivalTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 16, 0)),
      Attendance(id: 'a2', studentId: 's2', circleId: 'c1', date: yesterday, status: AttendanceStatus.late, arrivalTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 16, 25)),
      Attendance(id: 'a3', studentId: 's3', circleId: 'c1', date: yesterday, status: AttendanceStatus.present, arrivalTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 15, 55)),
      Attendance(id: 'a4', studentId: 's4', circleId: 'c2', date: yesterday, status: AttendanceStatus.present, arrivalTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 16, 5)),
      Attendance(id: 'a5', studentId: 's5', circleId: 'c2', date: yesterday, status: AttendanceStatus.absent),
      Attendance(id: 'a6', studentId: 's6', circleId: 'c2', date: yesterday, status: AttendanceStatus.excused),
      Attendance(id: 'a7', studentId: 's7', circleId: 'c3', date: yesterday, status: AttendanceStatus.present, arrivalTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 16, 10)),
      Attendance(id: 'a8', studentId: 's8', circleId: 'c3', date: yesterday, status: AttendanceStatus.present, arrivalTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 15, 50)),
    ]);
  }

  // --- دوال إدارة الحلقات ---
  @override
  Future<List<Circle>> getCircles() async => List.unmodifiable(_circles);

  @override
  Future<Circle?> getCircleById(String id) async {
    try {
      return _circles.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addCircle(Circle circle) async {
    _circles.add(circle);
  }

  @override
  Future<void> updateCircle(Circle circle) async {
    final idx = _circles.indexWhere((c) => c.id == circle.id);
    if (idx != -1) {
      _circles[idx] = circle;
    }
  }

  @override
  Future<void> deleteCircle(String circleId) async {
    _circles.removeWhere((c) => c.id == circleId);
    _attendanceRecords.removeWhere((a) => a.circleId == circleId);
    _memorizationRecords.removeWhere((r) => r.circleId == circleId);
    _juzTests.removeWhere((t) => t.circleId == circleId);
  }

  // --- دوال إدارة الطلاب ---
  @override
  Future<List<Student>> getStudents() async => List.unmodifiable(_students);

  @override
  Future<List<Student>> getStudentsForCircle(String circleId) async {
    final circle = await getCircleById(circleId);
    if (circle == null) return [];
    return _students.where((s) => circle.studentIds.contains(s.id)).toList();
  }

  @override
  Future<Student?> getStudentById(String id) async {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Student> addStudent(Student student) async {
    _students.add(student);
    return student;
  }

  @override
  Future<void> updateStudent(Student student) async {
    final idx = _students.indexWhere((s) => s.id == student.id);
    if (idx != -1) {
      _students[idx] = student;
    }
  }

  @override
  Future<void> deleteStudentPermanently(String studentId) async {
    _students.removeWhere((s) => s.id == studentId);
    for (var i = 0; i < _circles.length; i++) {
      if (_circles[i].studentIds.contains(studentId)) {
        final updatedIds = List<String>.from(_circles[i].studentIds)..remove(studentId);
        _circles[i] = _circles[i].copyWith(studentIds: updatedIds);
      }
    }
    _attendanceRecords.removeWhere((a) => a.studentId == studentId);
    _memorizationRecords.removeWhere((r) => r.studentId == studentId);
    _juzTests.removeWhere((t) => t.studentId == studentId);
  }

  @override
  Future<void> removeStudentFromCircle(String circleId, String studentId) async {
    final circle = await getCircleById(circleId);
    if (circle != null) {
      final updatedIds = List<String>.from(circle.studentIds)..remove(studentId);
      await updateCircle(circle.copyWith(studentIds: updatedIds));
    }
  }

  // --- دوال إدارة الحضور ---
  @override
  Future<List<Attendance>> getAttendanceForDateAndCircle(String circleId, DateTime date) async {
    return _attendanceRecords.where((a) =>
        a.circleId == circleId &&
        a.date.year == date.year &&
        a.date.month == date.month &&
        a.date.day == date.day
    ).toList();
  }

  @override
  Future<List<Attendance>> getAttendanceForStudent(String studentId) async {
    return _attendanceRecords.where((a) => a.studentId == studentId).toList();
  }

  @override
  Future<void> saveAttendance(List<Attendance> attendances) async {
    for (var a in attendances) {
      // إزالة السجل القديم إن وجد
      _attendanceRecords.removeWhere((item) =>
          item.studentId == a.studentId &&
          item.circleId == a.circleId &&
          item.date.year == a.date.year &&
          item.date.month == a.date.month &&
          item.date.day == a.date.day
      );
      _attendanceRecords.add(a);
    }
  }

  // --- سجل الحفظ والمراجعة ---
  @override
  Future<List<MemorizationRecord>> getRecordsForStudent(String studentId) async {
    return _memorizationRecords.where((r) => r.studentId == studentId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> addMemorizationRecord(MemorizationRecord record) async {
    _memorizationRecords.add(record);
  }

  // --- سجل اختبارات الأجزاء ---
  @override
  Future<List<JuzTest>> getTestsForStudent(String studentId) async {
    return _juzTests.where((t) => t.studentId == studentId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> addJuzTest(JuzTest test) async {
    _juzTests.add(test);
    
    // إضافة الجزء لقائمة الأجزاء المجتازة للطالب تلقائياً إذا اجتاز الاختبار
    if (test.score >= AppConstants.juzPassingScore) {
      final student = await getStudentById(test.studentId);
      if (student != null && !student.completedJuz.contains(test.juzNumber)) {
        final updatedCompletedJuz = List<int>.from(student.completedJuz)..add(test.juzNumber);
        await updateStudent(student.copyWith(completedJuz: updatedCompletedJuz));
      }
    }
  }
}
