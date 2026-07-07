import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/models/student.dart';
import '../core/models/circle.dart';
import '../core/models/attendance.dart';
import '../core/models/memorization_record.dart';
import '../core/models/juz_test.dart';
import '../data/repositories/mock_repository.dart';

class AcademyProvider extends ChangeNotifier {
  final MockRepository _repository = MockRepository();

  List<Circle> _circles = [];
  List<Student> _students = [];
  Circle? _selectedCircle;

  List<Circle> get circles => _circles;
  List<Student> get students => _students;
  Circle? get selectedCircle => _selectedCircle;

  /// إجمالي الطلاب المسجّلين فعلياً في الحلقات (لا يشمل المحذوفين أو غير الموزّعين)
  int get totalEnrolledStudents =>
      _circles.expand((c) => c.studentIds).toSet().length;

  /// قائمة الطلاب غير الموزعين في أي حلقة
  List<Student> get unassignedStudents {
    final assignedIds = _circles.expand((c) => c.studentIds).toSet();
    return _students.where((s) => !assignedIds.contains(s.id)).toList();
  }

  AcademyProvider() {
    refreshData();
  }

  /// تحميل شامل لكل البيانات من المستودع.
  /// استخدمه فقط عند العمليات التي تؤثر على علاقات متعددة (حذف حلقة، إضافة طالب ...).
  void refreshData() {
    _circles = _repository.getCircles();
    _students = _repository.getStudents();
    if (_selectedCircle != null) {
      // تحديث الحلقة المحددة لتشمل التغييرات الجديدة
      _selectedCircle = _repository.getCircleById(_selectedCircle!.id);
    }
    notifyListeners();
  }

  void selectCircle(Circle? circle) {
    _selectedCircle = circle;
    notifyListeners();
  }

  // --- إدارة الحلقات ---
  void addCircle(String name, String teacherName, CircleLevel level) {
    final newCircle = Circle(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      teacherName: teacherName,
      studentIds: [],
      level: level,
    );
    _repository.addCircle(newCircle);
    // تؤثر على قائمة الحلقات وإحصائيات الداشبورد — تحميل شامل
    refreshData();
  }

  // --- إدارة الطلاب ---
  void addStudentToCircle({
    required String circleId,
    required String name,
    required int age,
    required String phoneNumber,
    required StudentStatus status,
    String notes = '',
  }) {
    final studentId = 's_${DateTime.now().millisecondsSinceEpoch}';
    final newStudent = Student(
      id: studentId,
      name: name,
      notes: notes,
      age: age,
      phoneNumber: phoneNumber,
      status: status,
      behaviorRating: 5.0,
      completedJuz: [],
    );

    _repository.addStudent(newStudent);

    final circle = _repository.getCircleById(circleId);
    if (circle != null) {
      final updatedIds = List<String>.from(circle.studentIds)..add(studentId);
      _repository.updateCircle(circle.copyWith(studentIds: updatedIds));
    }
    refreshData();
  }

  /// تنسيب/إعادة تنسيب طالب لحلقة معينة
  void assignStudentToCircle(String studentId, String circleId) {
    // 1. إزالة الطالب من أي حلقة أخرى أولاً (لضمان عدم التكرار)
    for (var circle in _circles) {
      if (circle.studentIds.contains(studentId)) {
        final updatedIds = List<String>.from(circle.studentIds)..remove(studentId);
        _repository.updateCircle(circle.copyWith(studentIds: updatedIds));
      }
    }

    // 2. إضافته للحلقة المستهدفة
    final targetCircle = _repository.getCircleById(circleId);
    if (targetCircle != null) {
      final updatedIds = List<String>.from(targetCircle.studentIds)..add(studentId);
      _repository.updateCircle(targetCircle.copyWith(studentIds: updatedIds));
    }

    // 3. تحديث شامل للبيانات
    refreshData();
  }

  void updateStudentNotesAndBehavior(String studentId, String notes, double behaviorRating) {
    final student = _repository.getStudentById(studentId);
    if (student != null) {
      _repository.updateStudent(student.copyWith(notes: notes, behaviorRating: behaviorRating));
      // تحديث محلي: نحدّث فقط الطالب المتأثر في القائمة المحلية دون إعادة تحميل كامل
      final idx = _students.indexWhere((s) => s.id == studentId);
      if (idx != -1) {
        _students[idx] = student.copyWith(notes: notes, behaviorRating: behaviorRating);
      }
      notifyListeners();
    }
  }

  List<Student> getStudentsForCircle(String circleId) {
    return _repository.getStudentsForCircle(circleId);
  }

  // --- إدارة الحضور والغياب ---
  List<Attendance> getAttendanceForDateAndCircle(String circleId, DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final savedList = _repository.getAttendanceForDateAndCircle(circleId, normalizedDate);
    final circleStudents = getStudentsForCircle(circleId);

    // نتحقق من وجود سجل حضور لكل طالب حالي في الحلقة.
    // إذا لم يكن له سجل محفوظ (كطالب جديد مضاف لاحقاً)، ننشئ له سجلاً افتراضياً غير محضر.
    return circleStudents.map((student) {
      final existingIndex = savedList.indexWhere((a) => a.studentId == student.id);
      if (existingIndex != -1) {
        return savedList[existingIndex];
      } else {
        return Attendance(
          id: 'att_${student.id}_${normalizedDate.millisecondsSinceEpoch}',
          studentId: student.id,
          circleId: circleId,
          date: normalizedDate,
          status: AttendanceStatus.unmarked,
          arrivalTime: null,
        );
      }
    }).toList();
  }

  void saveCircleAttendance(List<Attendance> attendances) {
    _repository.saveAttendance(attendances);
    // الحضور لا يؤثر على هيكل الحلقات — notifyListeners كافٍ
    notifyListeners();
  }

  // --- إحصائيات التقارير الشهرية ---

  /// الحصول على إحصائيات الحضور لجميع طلاب حلقة في شهر معين
  Map<String, Map<AttendanceStatus, int>> getMonthlyAttendanceStats(String circleId, int year, int month) {
    final students = getStudentsForCircle(circleId);
    final Map<String, Map<AttendanceStatus, int>> stats = {};

    for (var student in students) {
      final studentAttendance = _repository.getAttendanceForStudent(student.id)
          .where((a) => a.circleId == circleId && a.date.year == year && a.date.month == month);
      
      final Map<AttendanceStatus, int> studentStats = {
        AttendanceStatus.present: 0,
        AttendanceStatus.late: 0,
        AttendanceStatus.absent: 0,
        AttendanceStatus.excused: 0,
      };

      for (var a in studentAttendance) {
        studentStats[a.status] = (studentStats[a.status] ?? 0) + 1;
      }
      stats[student.id] = studentStats;
    }

    return stats;
  }

  /// الحصول على نسبة الحضور والالتزام لطالب في حلقة معينة
  double getStudentAttendanceRate(String studentId, String circleId) {
    final attendanceList = _repository.getAttendanceForStudent(studentId);
    final circleAttendance = attendanceList.where((a) => a.circleId == circleId).toList();
    
    if (circleAttendance.isEmpty) return 0.0;

    final presentCount = circleAttendance.where((a) => a.status == AttendanceStatus.present).length;
    final lateCount = circleAttendance.where((a) => a.status == AttendanceStatus.late).length;
    
    return ((presentCount + lateCount) / circleAttendance.length) * 100;
  }

  /// تحضير جميع طلاب الحلقة كـ "حضور" لتاريخ معين (تحضير سريع)
  void markAllAsPresent(String circleId, DateTime date) {
    final students = getStudentsForCircle(circleId);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    final List<Attendance> attendanceList = students.map((s) => Attendance(
      id: 'att_${s.id}_${normalizedDate.millisecondsSinceEpoch}',
      studentId: s.id,
      circleId: circleId,
      date: normalizedDate,
      status: AttendanceStatus.present,
      arrivalTime: DateTime(normalizedDate.year, normalizedDate.month, normalizedDate.day, 16, 0),
    )).toList();

    _repository.saveAttendance(attendanceList);
    notifyListeners();
  }

  /// الحصول على ملخص إنجازات الطالب خلال شهر معين
  Map<String, dynamic> getStudentMonthlyPerformance(String studentId, int year, int month) {
    final records = _repository.getRecordsForStudent(studentId)
        .where((r) => r.date.year == year && r.date.month == month).toList();
    
    final tests = _repository.getTestsForStudent(studentId)
        .where((t) => t.date.year == year && t.date.month == month).toList();

    // حساب تقريبي للإنجاز (هنا يمكن تحسين المنطق حسب كيفية تخزين البيانات)
    for (var r in records) {
      if (r.type == RecordType.memorization) {
        if (r.toVerse != null && r.fromVerse != null) {
          // تبسيط: نعتبر كل 15 آية صفحة تقريباً أو حسب الحاجة
        } else if (r.pageNumber != null) {
        }
      } else if (r.type == RecordType.revision) {
      }
    }

    double avgGrade = 0.0;
    if (records.isNotEmpty) {
      final gradeMap = {
        EvaluationGrade.excellent: 4,
        EvaluationGrade.veryGood: 3,
        EvaluationGrade.good: 2,
        EvaluationGrade.acceptable: 1,
      };
      int totalPoints = records.fold(0, (sum, r) => sum + (gradeMap[r.grade] ?? 0));
      avgGrade = totalPoints / records.length;
    }

    return {
      'memorizationCount': records.where((r) => r.type == RecordType.memorization).length,
      'revisionCount': records.where((r) => r.type == RecordType.revision).length,
      'testsCount': tests.length,
      'avgGrade': avgGrade,
      'records': records,
      'tests': tests,
    };
  }

  // --- إدارة الحفظ والمراجعة والاختبارات ---
  List<MemorizationRecord> getStudentRecords(String studentId) {
    return _repository.getRecordsForStudent(studentId);
  }

  void addStudentRecord({
    required String studentId,
    required String circleId,
    required RecordType type,
    String? surahName,
    int? fromVerse,
    int? toVerse,
    String? lessonName,
    int? pageNumber,
    String? tajweedRules,
    required EvaluationGrade grade,
    String? notes,
  }) {
    if (circleId.isEmpty) return;

    final record = MemorizationRecord(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      circleId: circleId,
      date: DateTime.now(),
      type: type,
      surahName: surahName,
      fromVerse: fromVerse,
      toVerse: toVerse,
      lessonName: lessonName,
      pageNumber: pageNumber,
      tajweedRules: tajweedRules,
      grade: grade,
      notes: notes,
    );
    _repository.addMemorizationRecord(record);
    notifyListeners();
  }

  List<JuzTest> getStudentTests(String studentId) {
    return _repository.getTestsForStudent(studentId);
  }

  void addStudentJuzTest({
    required String studentId,
    required String circleId,
    required int juzNumber,
    required double score,
    required EvaluationGrade grade,
    required String testerName,
    String? notes,
  }) {
    if (circleId.isEmpty) return;

    final test = JuzTest(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      circleId: circleId,
      date: DateTime.now(),
      juzNumber: juzNumber,
      score: score,
      grade: grade,
      testerName: testerName,
      notes: notes,
    );
    _repository.addJuzTest(test);
    refreshData();
  }

  // --- دوال إضافية للحذف والتعديل وإحصائيات حضور الطالب ---

  List<Attendance> getAttendanceForStudent(String studentId) {
    return _repository.getAttendanceForStudent(studentId);
  }

  void deleteCircle(String circleId) {
    _repository.deleteCircle(circleId);
    if (_selectedCircle?.id == circleId) {
      _selectedCircle = null;
    }
    // تؤثر على هيكل البيانات كاملاً — تحميل شامل
    refreshData();
  }

  void removeStudentFromCircle(String circleId, String studentId) {
    _repository.removeStudentFromCircle(circleId, studentId);
    // تؤثر على علاقة الطالب بالحلقة — تحميل شامل
    refreshData();
  }

  void deleteStudentPermanently(String studentId) {
    _repository.deleteStudentPermanently(studentId);
    // تؤثر على جميع البيانات المرتبطة بالطالب — تحميل شامل
    refreshData();
  }

  void updateCircle(String circleId, String name, String teacherName, CircleLevel level) {
    final circle = _repository.getCircleById(circleId);
    if (circle != null) {
      _repository.updateCircle(circle.copyWith(name: name, teacherName: teacherName, level: level));
      // تؤثر على بيانات الحلقة في جميع الشاشات — تحميل شامل
      refreshData();
    }
  }

  /// تحديد التقدير تلقائياً بناءً على الدرجة (يستخدم الثوابت المركزية)
  static EvaluationGrade gradeFromScore(double score) {
    if (score >= AppConstants.excellentThreshold) return EvaluationGrade.excellent;
    if (score >= AppConstants.veryGoodThreshold)  return EvaluationGrade.veryGood;
    if (score >= AppConstants.goodThreshold)      return EvaluationGrade.good;
    return EvaluationGrade.acceptable;
  }
}
