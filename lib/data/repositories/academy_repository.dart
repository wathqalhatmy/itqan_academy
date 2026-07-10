import '../../core/models/student.dart';
import '../../core/models/circle.dart';
import '../../core/models/attendance.dart';
import '../../core/models/memorization_record.dart';
import '../../core/models/juz_test.dart';

/// واجهة برمجة (Interface) للمستودع لضمان سهولة التبديل بين Mock و Django
abstract class AcademyRepository {
  // الحلقات
  Future<List<Circle>> getCircles();
  Future<Circle?> getCircleById(String id);
  Future<void> addCircle(Circle circle);
  Future<void> updateCircle(Circle circle);
  Future<void> deleteCircle(String circleId);

  // الطلاب
  Future<List<Student>> getStudents();
  Future<List<Student>> getStudentsForCircle(String circleId);
  Future<Student?> getStudentById(String id);
  Future<Student> addStudent(Student student);
  Future<void> updateStudent(Student student);
  Future<void> deleteStudentPermanently(String studentId);
  Future<void> removeStudentFromCircle(String circleId, String studentId);

  // الحضور
  Future<List<Attendance>> getAttendanceForDateAndCircle(String circleId, DateTime date);
  Future<List<Attendance>> getAttendanceForStudent(String studentId);
  Future<void> saveAttendance(List<Attendance> attendances);

  // السجلات والاختبارات
  Future<List<MemorizationRecord>> getRecordsForStudent(String studentId);
  Future<void> addMemorizationRecord(MemorizationRecord record);
  Future<List<JuzTest>> getTestsForStudent(String studentId);
  Future<void> addJuzTest(JuzTest test);
}
