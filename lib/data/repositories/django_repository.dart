import '../services/api_client.dart';
import '../../core/models/student.dart';
import '../../core/models/circle.dart';
import '../../core/models/attendance.dart';
import '../../core/models/memorization_record.dart';
import '../../core/models/juz_test.dart';
import 'academy_repository.dart';

class DjangoRepository implements AcademyRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<List<Circle>> getCircles() async {
    final response = await _apiClient.get('/circles/');
    return (response.data as List).map((json) => Circle.fromJson(json)).toList();
  }

  @override
  Future<Circle?> getCircleById(String id) async {
    final response = await _apiClient.get('/circles/$id/');
    return Circle.fromJson(response.data);
  }

  @override
  Future<void> addCircle(Circle circle) async {
    await _apiClient.post('/circles/', data: circle.toJson());
  }

  @override
  Future<void> updateCircle(Circle circle) async {
    await _apiClient.put('/circles/${circle.id}/', data: circle.toJson());
  }

  @override
  Future<void> deleteCircle(String circleId) async {
    await _apiClient.delete('/circles/$circleId/');
  }

  @override
  Future<List<Student>> getStudents() async {
    final response = await _apiClient.get('/students/');
    return (response.data as List).map((json) => Student.fromJson(json)).toList();
  }

  @override
  Future<List<Student>> getStudentsForCircle(String circleId) async {
    final response = await _apiClient.get('/circles/$circleId/students/');
    return (response.data as List).map((json) => Student.fromJson(json)).toList();
  }

  @override
  Future<Student?> getStudentById(String id) async {
    final response = await _apiClient.get('/students/$id/');
    return Student.fromJson(response.data);
  }

  @override
  Future<Student> addStudent(Student student) async {
    final response = await _apiClient.post('/students/', data: student.toJson());
    return Student.fromJson(response.data);
  }

  @override
  Future<void> updateStudent(Student student) async {
    await _apiClient.put('/students/${student.id}/', data: student.toJson());
  }

  @override
  Future<void> deleteStudentPermanently(String studentId) async {
    await _apiClient.delete('/students/$studentId/');
  }

  @override
  Future<void> removeStudentFromCircle(String circleId, String studentId) async {
    await _apiClient.post('/circles/$circleId/remove-student/', data: {'student_id': studentId});
  }

  @override
  Future<List<Attendance>> getAttendanceForDateAndCircle(String circleId, DateTime date) async {
    final response = await _apiClient.get('/attendance/', queryParameters: {
      'circle_id': circleId,
      'date': date.toIso8601String().split('T')[0],
    });
    return (response.data as List).map((json) => Attendance.fromJson(json)).toList();
  }

  @override
  Future<List<Attendance>> getAttendanceForStudent(String studentId) async {
    final response = await _apiClient.get('/students/$studentId/attendance/');
    return (response.data as List).map((json) => Attendance.fromJson(json)).toList();
  }

  @override
  Future<void> saveAttendance(List<Attendance> attendances) async {
    final data = attendances.map((a) => a.toJson()).toList();
    await _apiClient.post('/attendance/bulk-save/', data: data);
  }

  @override
  Future<List<MemorizationRecord>> getRecordsForStudent(String studentId) async {
    final response = await _apiClient.get('/students/$studentId/records/');
    return (response.data as List).map((json) => MemorizationRecord.fromJson(json)).toList();
  }

  @override
  Future<void> addMemorizationRecord(MemorizationRecord record) async {
    await _apiClient.post('/records/', data: record.toJson());
  }

  @override
  Future<List<JuzTest>> getTestsForStudent(String studentId) async {
    final response = await _apiClient.get('/students/$studentId/tests/');
    return (response.data as List).map((json) => JuzTest.fromJson(json)).toList();
  }

  @override
  Future<void> addJuzTest(JuzTest test) async {
    await _apiClient.post('/tests/', data: test.toJson());
  }
}
