import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/student.dart';
import '../../core/models/circle.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../providers/academy_provider.dart';
import 'widgets/student_profile_card.dart';
import 'widgets/progression_tab.dart';
import 'widgets/records_tab.dart';
import 'widgets/tests_tab.dart';
import 'widgets/student_dialogs.dart';
import '../../core/utils/file_exporter.dart';
import '../../core/models/memorization_record.dart';
import '../../core/models/attendance.dart';

class StudentDetailScreen extends StatefulWidget {
  final String studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppScaffold(
      child: Consumer<AcademyProvider>(
            builder: (context, provider, child) {
              final student = provider.students.firstWhere(
                (s) => s.id == widget.studentId,
                orElse: () => Student(id: '', name: 'غير معروف'),
              );

              if (student.id.isEmpty) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('الملف الشخصي للطالب'),
                    elevation: 0,
                  ),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 64, color: colorScheme.error),
                        const SizedBox(height: 16),
                        const Text('الطالب غير موجود أو تم حذفه',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }

              final records = provider.getStudentRecords(student.id);
              final tests = provider.getStudentTests(student.id);
              final circle = provider.circles.firstWhere(
                (c) => c.studentIds.contains(student.id),
                orElse: () => Circle(
                  id: '',
                  name: 'غير محدد',
                  teacherName: 'غير محدد',
                  studentIds: [],
                  level: CircleLevel.memorization,
                ),
              );

              String recordButtonText = 'إنجاز يومي';
              String secondTabTitle = 'سجل التسميع';

              if (circle.level == CircleLevel.memorization) {
                recordButtonText = 'تسميع / مراجعة';
                secondTabTitle = 'سجل التسميع';
              } else if (circle.level == CircleLevel.tajweed) {
                recordButtonText = 'تسجيل تلاوة';
                secondTabTitle = 'سجل التلاوة';
              } else if (circle.level == CircleLevel.alphabets) {
                recordButtonText = 'تسجيل درس';
                secondTabTitle = 'سجل الدروس';
              }

              return Scaffold(
                appBar: AppBar(
                  title: const Text('الملف الشخصي للطالب'),
                  elevation: 0,
                  actions: [
                    if (circle.id.isNotEmpty)
                      PopupMenuButton<String>(
                        tooltip: 'تصدير تقرير الطالب',
                        onSelected: (val) {
                          if (val == 'export_excel') {
                            _exportStudentToExcel(provider, student, circle);
                          } else if (val == 'export_pdf') {
                            _exportStudentToPdf(provider, student, circle);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'export_excel',
                            child: Row(
                              children: [
                                Icon(Icons.table_view_rounded,
                                    color: colorScheme.onSurfaceVariant, size: 20),
                                const SizedBox(width: 8),
                                const Text('تصدير كشف Excel'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'export_pdf',
                            child: Row(
                              children: [
                                Icon(Icons.picture_as_pdf_rounded,
                                    color: colorScheme.onSurfaceVariant, size: 20),
                                const SizedBox(width: 8),
                                const Text('طباعة كشف PDF'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                body: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StudentProfileCard(
                                student: student,
                                circle: circle,
                                provider: provider,
                              ),
                              const SizedBox(height: 16),
                              if (circle.id.isEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.amber
                                            .withValues(alpha: 0.25)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded,
                                          color: Colors.amber, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'تنبيه: الطالب غير ملتحق بأي حلقة حالياً. يجب تنسيبه لحلقة لتتمكن من تسجيل الإنجازات اليومية أو اختبارات الأجزاء.',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: Colors.amber[900],
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: circle.id.isEmpty
                                            ? theme.disabledColor
                                                .withValues(alpha: 0.12)
                                            : colorScheme.primary,
                                        foregroundColor: circle.id.isEmpty
                                            ? theme.disabledColor
                                            : Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        elevation: circle.id.isEmpty ? 0 : 2,
                                      ),
                                      onPressed: circle.id.isEmpty
                                          ? null
                                          : () => _showAddRecordDialog(context,
                                              provider, student.id, circle),
                                      icon: const Icon(Icons.menu_book_rounded,
                                          size: 18),
                                      label: Text(recordButtonText,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: circle.id.isEmpty
                                            ? theme.disabledColor
                                            : colorScheme.primary,
                                        side: BorderSide(
                                            color: circle.id.isEmpty
                                                ? theme.disabledColor
                                                    .withValues(alpha: 0.3)
                                                : colorScheme.primary,
                                            width: 1.5),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      onPressed: circle.id.isEmpty
                                          ? null
                                          : () => _showAddTestDialog(context,
                                              provider, student.id, circle),
                                      icon: const Icon(Icons.verified_rounded,
                                          size: 18),
                                      label: const Text('تسجيل اختبار ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            labelColor: colorScheme.primary,
                            unselectedLabelColor: colorScheme.onSurfaceVariant,
                            indicatorColor: colorScheme.primary,
                            indicatorWeight: 3,
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                            tabs: [
                              const Tab(text: 'التقدم '),
                              Tab(text: secondTabTitle),
                              const Tab(text: 'الاختبارات'),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      // التبويب الأول: المهارات المنجزة حسب المستوى
                      ProgressionTab(
                        student: student,
                        level: circle.level,
                        records: records,
                      ),

                      // التبويب الثاني: سجل التسميع والمراجعة اليومي
                      RecordsTab(records: records),

                      // التبويب الثالث: اختبارات الأجزاء
                      TestsTab(tests: tests),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }

  void _showAddRecordDialog(BuildContext context, AcademyProvider provider,
      String studentId, Circle circle) {
    showDialog(
      context: context,
      builder: (context) => AddRecordDialog(
          provider: provider, studentId: studentId, circle: circle),
    );
  }

  void _showAddTestDialog(BuildContext context, AcademyProvider provider,
      String studentId, Circle circle) {
    showDialog(
      context: context,
      builder: (context) => AddTestDialog(
          provider: provider, studentId: studentId, circle: circle),
    );
  }

  void _exportStudentToExcel(
      AcademyProvider provider, Student student, Circle circle) {
    final records = provider.getStudentRecords(student.id);
    final buffer = StringBuffer();
    buffer.write('\uFEFF'); // UTF-8 BOM
    buffer.writeln(
        'التاريخ,نوع الإنجاز,السورة / الدرس,من آية / الصفحة,إلى آية,التقييم,الملاحظات');

    for (var r in records) {
      buffer.writeln('${r.date.day}/${r.date.month}/${r.date.year},'
          '${r.type.nameAr},'
          '${r.type == RecordType.alphabets ? r.lessonName : r.surahName},'
          '${r.type == RecordType.alphabets ? r.pageNumber : r.fromVerse},'
          '${r.type == RecordType.alphabets ? "" : r.toVerse},'
          '${r.grade.nameAr},'
          '"${r.notes ?? ""}"');
    }

    final String fileName =
        'تقرير_الطالب_${student.name.replaceAll(' ', '_')}.csv';
    FileExporter.downloadCsv(buffer.toString(), fileName);
  }

  void _exportStudentToPdf(
      AcademyProvider provider, Student student, Circle circle) {
    final records = provider.getStudentRecords(student.id);
    final attendanceList = provider.getAttendanceForStudent(student.id);

    final presentCount = attendanceList
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    final lateCount =
        attendanceList.where((a) => a.status == AttendanceStatus.late).length;
    final absentCount =
        attendanceList.where((a) => a.status == AttendanceStatus.absent).length;
    final excusedCount = attendanceList
        .where((a) => a.status == AttendanceStatus.excused)
        .length;
    final totalAttendance = attendanceList.length;
    final attendanceRate = totalAttendance == 0
        ? 100
        : ((presentCount + lateCount) / totalAttendance) * 100;

    final rows = StringBuffer();
    for (var r in records) {
      rows.write('''
        <tr>
          <td style="padding: 10px 12px; border-bottom: 1px solid #eef2ef;">${r.date.day}/${r.date.month}/${r.date.year}</td>
          <td style="padding: 10px 12px; border-bottom: 1px solid #eef2ef; font-weight: bold;">${r.type.nameAr}</td>
          <td style="padding: 10px 12px; border-bottom: 1px solid #eef2ef;">${r.type == RecordType.alphabets ? r.lessonName : r.surahName}</td>
          <td style="padding: 10px 12px; border-bottom: 1px solid #eef2ef; text-align: center;">
            ${r.type == RecordType.alphabets ? "صفحة: ${r.pageNumber}" : "من ${r.fromVerse} إلى ${r.toVerse}"}
          </td>
          <td style="padding: 10px 12px; border-bottom: 1px solid #eef2ef; text-align: center; font-weight: bold;">${r.grade.nameAr}</td>
          <td style="padding: 10px 12px; border-bottom: 1px solid #eef2ef; font-style: italic; color: #555;">${r.notes ?? "-"}</td>
        </tr>
      ''');
    }

    final String htmlContent = '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <title>تقرير الطالب: ${student.name}</title>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;700;900&display=swap" rel="stylesheet">
  <style>
    body {
      font-family: 'Cairo', sans-serif;
      background-color: #f4f7f5;
      color: #15201b;
      margin: 0;
      padding: 40px;
    }
    .header {
      text-align: center;
      border-bottom: 3px double #053e2a;
      padding-bottom: 20px;
      margin-bottom: 30px;
    }
    .header h1 {
      color: #053e2a;
      margin: 0;
      font-size: 28px;
      font-weight: 900;
    }
    .header p {
      margin: 5px 0;
      color: #42524a;
      font-size: 16px;
    }
    .meta-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 20px;
      margin-bottom: 30px;
    }
    .meta-card {
      background: white;
      padding: 15px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.05);
      border-right: 4px solid #c5a880;
    }
    .meta-card h3 {
      margin: 0 0 5px 0;
      font-size: 12px;
      color: #42524a;
    }
    .meta-card p {
      margin: 0;
      font-size: 18px;
      font-weight: bold;
      color: #053e2a;
    }
    .stats-card {
      background: #e8f5e9;
      border-right: 4px solid #2e7d32;
    }
    .stats-card p {
      color: #2e7d32;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      background: white;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 2px 4px rgba(0,0,0,0.05);
      margin-bottom: 30px;
    }
    th {
      padding: 12px 15px;
      text-align: right;
      border-bottom: 1px solid #eef2ef;
      background-color: #053e2a;
      color: white;
      font-weight: bold;
    }
    @media print {
      body { background: white; padding: 0; }
      .meta-card { box-shadow: none; border: 1px solid #ccc; }
      table { box-shadow: none; border: 1px solid #ccc; }
    }
  </style>
  <script>
    window.onload = function() {
      window.print();
    };
  </script>
</head>
<body>
  <div class="header">
    <h1>أكاديمية إتقان لتحفيظ القرآن</h1>
    <p>تقرير الأداء الفردي والتحصيل للطلاب</p>
  </div>
  
  <div class="meta-grid">
    <div class="meta-card">
      <h3>بيانات الطالب</h3>
      <p>${student.name} (الحلقة: ${circle.name})</p>
    </div>
    <div class="meta-card stats-card">
      <h3>إحصائيات الحضور</h3>
      <p>حاضر: $presentCount | متأخر: $lateCount | غائب: $absentCount | بعذر: $excusedCount | نسبة الحضور: ${attendanceRate.toStringAsFixed(0)}%</p>
    </div>
  </div>

  <h2>سجل التقييمات والإنجازات اليومية</h2>
  <table>
    <thead>
      <tr>
        <th>التاريخ</th>
        <th>نوع الإنجاز</th>
        <th>السورة / الدرس</th>
        <th style="text-align: center;">الآيات / الصفحة</th>
        <th style="text-align: center;">التقييم</th>
        <th>ملاحظات المعلم</th>
      </tr>
    </thead>
    <tbody>
      ${rows.toString()}
    </tbody>
  </table>
  
  <div style="text-align: center; margin-top: 50px; color: #a2b0aa; font-size: 11px;">
    تاريخ تصدير التقرير: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - أكاديمية إتقان الرقمية
  </div>
</body>
</html>
    ''';

    FileExporter.printHtmlReport(htmlContent, 'تقرير_طالب_${student.name}');
  }
}

// كلاس مساعد لتصميم شريط التبويبات الملتصق
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
