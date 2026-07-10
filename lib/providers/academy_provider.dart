import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/models/student.dart';
import '../core/models/circle.dart';
import '../core/models/attendance.dart';
import '../core/models/memorization_record.dart';
import '../core/models/juz_test.dart';
import '../data/repositories/academy_repository.dart';
import '../data/repositories/django_repository.dart';
import 'auth_provider.dart';

class AcademyProvider extends ChangeNotifier {
  final AcademyRepository _repository = DjangoRepository();

  List<Circle> _circles = [];
  List<Student> _students = [];
  Circle? _selectedCircle;
  bool _hasLoadedData = false;
  
  // بيانات مساعدة (Caches) لتجنب الـ Future في الواجهات
  final Map<String, List<Student>> _circleStudentsCache = {};
  final Map<String, List<MemorizationRecord>> _studentRecordsCache = {};
  final Map<String, List<JuzTest>> _studentTestsCache = {};
  final Map<String, List<Attendance>> _studentAttendanceCache = {};

  List<Circle> get circles => _circles;
  List<Student> get students => _students;
  Circle? get selectedCircle => _selectedCircle;

  int get totalEnrolledStudents =>
      _circles.expand((c) => c.studentIds).toSet().length;

  List<Student> get unassignedStudents {
    final assignedIds = _circles.expand((c) => c.studentIds).toSet();
    return _students.where((s) => !assignedIds.contains(s.id)).toList();
  }

  AcademyProvider() {
    // إزالة refreshData من هنا لحماية الطلبات عند بدء التشغيل
  }

  void updateAuth(AuthProvider auth) {
    if (auth.isAuthenticated) {
      if (!_hasLoadedData) {
        _hasLoadedData = true;
        refreshData();
      }
    } else {
      _hasLoadedData = false;
      _circles = [];
      _students = [];
      _selectedCircle = null;
      _circleStudentsCache.clear();
      _studentRecordsCache.clear();
      _studentTestsCache.clear();
      _studentAttendanceCache.clear();
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    try {
      _circles = await _repository.getCircles();
      _students = await _repository.getStudents();
      if (_selectedCircle != null) {
        _selectedCircle = await _repository.getCircleById(_selectedCircle!.id);
      }
      
      // تحديث الكاش الأساسي للطلاب لكل حلقة بالتوازي لتسريع بدء تشغيل التطبيق
      await Future.wait(_circles.map((circle) async {
        _circleStudentsCache[circle.id] = await _repository.getStudentsForCircle(circle.id);
      }));
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error refreshing data in AcademyProvider: $e');
    }
  }

  // دوال وصول سريعة للبيانات من الكاش
  List<Student> getStudentsForCircle(String circleId) => _circleStudentsCache[circleId] ?? [];
  List<MemorizationRecord> getStudentRecords(String studentId) => _studentRecordsCache[studentId] ?? [];
  List<JuzTest> getStudentTests(String studentId) => _studentTestsCache[studentId] ?? [];
  List<Attendance> getAttendanceForStudent(String studentId) => _studentAttendanceCache[studentId] ?? [];

  Future<void> loadStudentDetails(String studentId) async {
    try {
      _studentRecordsCache[studentId] = await _repository.getRecordsForStudent(studentId);
      _studentTestsCache[studentId] = await _repository.getTestsForStudent(studentId);
      _studentAttendanceCache[studentId] = await _repository.getAttendanceForStudent(studentId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading student details: $e');
    }
  }

  void selectCircle(Circle? circle) {
    _selectedCircle = circle;
    notifyListeners();
  }

  // --- إدارة الحلقات ---
  Future<void> addCircle(String name, String teacherName, CircleLevel level) async {
    try {
      final newCircle = Circle(
        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        teacherName: teacherName,
        studentIds: [],
        level: level,
      );
      await _repository.addCircle(newCircle);
      await refreshData();
    } catch (e) {
      debugPrint('❌ Error adding circle: $e');
    }
  }

  // --- إدارة الطلاب ---
  Future<void> addStudentToCircle({
    required String circleId,
    required String name,
    required int age,
    required String phoneNumber,
    required StudentStatus status,
    String notes = '',
  }) async {
    try {
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

      // استلام كائن الطالب بعد حفظه حاملاً معرّف السيرفر الحقيقي (مثل "1")
      final createdStudent = await _repository.addStudent(newStudent);

      final circle = await _repository.getCircleById(circleId);
      if (circle != null) {
        // نستخدم معرّف قاعدة البيانات الحقيقي المرجّع من السيرفر لربطه بالحلقة بنجاح
        final updatedIds = List<String>.from(circle.studentIds)..add(createdStudent.id);
        await _repository.updateCircle(circle.copyWith(studentIds: updatedIds));
      }
      await refreshData();
    } catch (e) {
      debugPrint('❌ Error adding student to circle: $e');
    }
  }

  Future<void> assignStudentToCircle(String studentId, String circleId) async {
    try {
      for (var circle in _circles) {
        if (circle.studentIds.contains(studentId)) {
          final updatedIds = List<String>.from(circle.studentIds)..remove(studentId);
          await _repository.updateCircle(circle.copyWith(studentIds: updatedIds));
        }
      }

      final targetCircle = await _repository.getCircleById(circleId);
      if (targetCircle != null) {
        final updatedIds = List<String>.from(targetCircle.studentIds)..add(studentId);
        await _repository.updateCircle(targetCircle.copyWith(studentIds: updatedIds));
      }

      await refreshData();
    } catch (e) {
      debugPrint('❌ Error assigning student to circle: $e');
    }
  }

  Future<void> updateStudentNotesAndBehavior(String studentId, String notes, double behaviorRating) async {
    try {
      final student = await _repository.getStudentById(studentId);
      if (student != null) {
        await _repository.updateStudent(student.copyWith(notes: notes, behaviorRating: behaviorRating));
        await refreshData();
        await loadStudentDetails(studentId);
      }
    } catch (e) {
      debugPrint('❌ Error updating student notes and behavior: $e');
    }
  }

  // --- إدارة الحضور والغياب ---
  Future<List<Attendance>> getAttendanceForDateAndCircle(String circleId, DateTime date) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final savedList = await _repository.getAttendanceForDateAndCircle(circleId, normalizedDate);
      final circleStudents = getStudentsForCircle(circleId);

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
    } catch (e) {
      debugPrint('❌ Error getting attendance for date and circle: $e');
      return [];
    }
  }

  Future<void> saveCircleAttendance(List<Attendance> attendances) async {
    try {
      await _repository.saveAttendance(attendances);
      // تحديث الكاش للطلاب المتأثرين
      for (var a in attendances) {
         _studentAttendanceCache[a.studentId] = await _repository.getAttendanceForStudent(a.studentId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error saving circle attendance: $e');
    }
  }

  Map<String, Map<AttendanceStatus, int>> getMonthlyAttendanceStats(String circleId, int year, int month) {
    final students = getStudentsForCircle(circleId);
    final Map<String, Map<AttendanceStatus, int>> stats = {};

    for (var student in students) {
      final attendanceList = getAttendanceForStudent(student.id);
      final studentAttendance = attendanceList.where((a) => a.circleId == circleId && a.date.year == year && a.date.month == month);
      
      final Map<AttendanceStatus, int> studentStats = {
        AttendanceStatus.present: 0,
        AttendanceStatus.late: 0,
        AttendanceStatus.absent: 0,
        AttendanceStatus.excused: 0,
        AttendanceStatus.unmarked: 0,
      };

      for (var a in studentAttendance) {
        studentStats[a.status] = (studentStats[a.status] ?? 0) + 1;
      }
      stats[student.id] = studentStats;
    }

    return stats;
  }

  double getStudentAttendanceRate(String studentId, String circleId) {
    final attendanceList = getAttendanceForStudent(studentId);
    final circleAttendance = attendanceList.where((a) => a.circleId == circleId).toList();
    
    if (circleAttendance.isEmpty) return 0.0;

    final presentCount = circleAttendance.where((a) => a.status == AttendanceStatus.present).length;
    final lateCount = circleAttendance.where((a) => a.status == AttendanceStatus.late).length;
    
    return ((presentCount + lateCount) / circleAttendance.length) * 100;
  }

  Future<void> markAllAsPresent(String circleId, DateTime date) async {
    try {
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

      await _repository.saveAttendance(attendanceList);
      for (var s in students) {
         _studentAttendanceCache[s.id] = await _repository.getAttendanceForStudent(s.id);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error marking all present: $e');
    }
  }

  Map<String, dynamic> getStudentMonthlyPerformance(String studentId, int year, int month) {
    final recordList = getStudentRecords(studentId);
    final records = recordList.where((r) => r.date.year == year && r.date.month == month).toList();
    
    final testList = getStudentTests(studentId);
    final tests = testList.where((t) => t.date.year == year && t.date.month == month).toList();

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
  Future<void> addStudentRecord({
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
  }) async {
    if (circleId.isEmpty) return;

    try {
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
      await _repository.addMemorizationRecord(record);
      _studentRecordsCache[studentId] = await _repository.getRecordsForStudent(studentId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error adding student record: $e');
    }
  }

  Future<void> addStudentJuzTest({
    required String studentId,
    required String circleId,
    required int juzNumber,
    required double score,
    required EvaluationGrade grade,
    required String testerName,
    String? notes,
  }) async {
    if (circleId.isEmpty) return;

    try {
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
      await _repository.addJuzTest(test);
      _studentTestsCache[studentId] = await _repository.getTestsForStudent(studentId);
      await refreshData();
    } catch (e) {
      debugPrint('❌ Error adding student juz test: $e');
    }
  }

  Future<void> deleteCircle(String circleId) async {
    try {
      await _repository.deleteCircle(circleId);
      if (_selectedCircle?.id == circleId) {
        _selectedCircle = null;
      }
      await refreshData();
    } catch (e) {
      debugPrint('❌ Error deleting circle: $e');
    }
  }

  Future<void> removeStudentFromCircle(String circleId, String studentId) async {
    try {
      await _repository.removeStudentFromCircle(circleId, studentId);
      await refreshData();
    } catch (e) {
      debugPrint('❌ Error removing student from circle: $e');
    }
  }

  Future<void> deleteStudentPermanently(String studentId) async {
    try {
      await _repository.deleteStudentPermanently(studentId);
      await refreshData();
    } catch (e) {
      debugPrint('❌ Error deleting student permanently: $e');
    }
  }

  Future<void> updateCircle(String circleId, String name, String teacherName, CircleLevel level) async {
    try {
      final circle = await _repository.getCircleById(circleId);
      if (circle != null) {
        await _repository.updateCircle(circle.copyWith(name: name, teacherName: teacherName, level: level));
        await refreshData();
      }
    } catch (e) {
      debugPrint('❌ Error updating circle: $e');
    }
  }

  static EvaluationGrade gradeFromScore(double score) {
    if (score >= AppConstants.excellentThreshold) return EvaluationGrade.excellent;
    if (score >= AppConstants.veryGoodThreshold)  return EvaluationGrade.veryGood;
    if (score >= AppConstants.goodThreshold)      return EvaluationGrade.good;
    return EvaluationGrade.acceptable;
  }
}
