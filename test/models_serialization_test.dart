import 'package:flutter_test/flutter_test.dart';
import 'package:itqan_academy/core/models/student.dart';
import 'package:itqan_academy/core/models/circle.dart';
import 'package:itqan_academy/core/models/attendance.dart';
import 'package:itqan_academy/core/models/memorization_record.dart';
import 'package:itqan_academy/core/models/juz_test.dart';

void main() {
  group('Models Serialization Tests', () {
    test('Student serialization/deserialization', () {
      final student = Student(
        id: 's1',
        name: 'Ahmed',
        age: 10,
        status: StudentStatus.active,
        completedJuz: [30],
      );

      final json = student.toJson();
      final fromJson = Student.fromJson(json);

      expect(fromJson.id, student.id);
      expect(fromJson.name, student.name);
      expect(fromJson.status, student.status);
      expect(fromJson.completedJuz, student.completedJuz);
    });

    test('Circle serialization/deserialization', () {
      final circle = Circle(
        id: 'c1',
        name: 'Circle 1',
        teacherName: 'Teacher 1',
        studentIds: ['s1', 's2'],
        level: CircleLevel.tajweed,
      );

      final json = circle.toJson();
      final fromJson = Circle.fromJson(json);

      expect(fromJson.id, circle.id);
      expect(fromJson.name, circle.name);
      expect(fromJson.level, circle.level);
      expect(fromJson.studentIds, circle.studentIds);
    });

    test('Attendance serialization/deserialization', () {
      final attendance = Attendance(
        id: 'a1',
        studentId: 's1',
        circleId: 'c1',
        date: DateTime(2023, 10, 1),
        status: AttendanceStatus.present,
        arrivalTime: DateTime(2023, 10, 1, 16, 0),
      );

      final json = attendance.toJson();
      final fromJson = Attendance.fromJson(json);

      expect(fromJson.id, attendance.id);
      expect(fromJson.status, attendance.status);
      expect(fromJson.date, attendance.date);
    });

    test('MemorizationRecord serialization/deserialization', () {
      final record = MemorizationRecord(
        id: 'r1',
        studentId: 's1',
        circleId: 'c1',
        date: DateTime(2023, 10, 1),
        type: RecordType.memorization,
        surahName: 'Al-Baqarah',
        fromVerse: 1,
        toVerse: 10,
        grade: EvaluationGrade.excellent,
      );

      final json = record.toJson();
      final fromJson = MemorizationRecord.fromJson(json);

      expect(fromJson.id, record.id);
      expect(fromJson.type, record.type);
      expect(fromJson.grade, record.grade);
    });

    test('JuzTest serialization/deserialization', () {
      final test = JuzTest(
        id: 't1',
        studentId: 's1',
        circleId: 'c1',
        date: DateTime(2023, 10, 1),
        juzNumber: 30,
        score: 95.5,
        grade: EvaluationGrade.veryGood,
        testerName: 'Tester',
      );

      final json = test.toJson();
      final fromJson = JuzTest.fromJson(json);

      expect(fromJson.id, test.id);
      expect(fromJson.score, test.score);
      expect(fromJson.grade, test.grade);
    });
  });
}
