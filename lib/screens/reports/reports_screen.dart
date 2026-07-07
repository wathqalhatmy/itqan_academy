import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/circle.dart';
import '../../core/models/student.dart';
import '../../core/models/attendance.dart';
import '../../core/models/memorization_record.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/academy_provider.dart';
import '../../core/utils/file_exporter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Circle? _selectedCircle;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  final List<int> _years = List.generate(5, (index) => DateTime.now().year - index);
  final List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AcademyProvider>(context, listen: false);
    _selectedCircle = provider.selectedCircle ?? (provider.circles.isNotEmpty ? provider.circles.first : null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('التقارير الشهرية'),
            ),
            body: Consumer<AcademyProvider>(
              builder: (context, provider, child) {
                if (provider.circles.isEmpty) {
                  return const Center(child: Text('لا توجد حلقات متاحة لإنشاء تقارير'));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSelectionSection(provider),
                      const SizedBox(height: 24),
                      if (_selectedCircle != null) ...[
                        Text(
                          'خيارات التقرير',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildReportActionCard(
                          title: 'تقرير الحلقة الشامل',
                          subtitle: 'يتضمن إحصائيات الحضور والإنجاز لجميع طلاب الحلقة',
                          icon: Icons.groups_rounded,
                          color: colorScheme.primary,
                          onTap: () => _generateCircleMonthlyReport(provider),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'تقارير فردية للطلاب',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.getStudentsForCircle(_selectedCircle!.id).length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final student = provider.getStudentsForCircle(_selectedCircle!.id)[index];
                            return ListTile(
                              tileColor: colorScheme.surface,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                child: Text(student.name.substring(0, 1)),
                              ),
                              title: Text(student.name, style: const TextStyle(fontSize: 14)),
                              trailing: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 20),
                              onTap: () async {
                                // إظهار مؤشر تحميل بسيط
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('جاري جلب بيانات الطالب وتجهيز التقرير...'), duration: Duration(seconds: 1)),
                                );
                                await _generateStudentMonthlyReport(provider, student);
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionSection(AcademyProvider provider) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Circle>(
              initialValue: _selectedCircle,
              decoration: const InputDecoration(labelText: 'الحلقة', border: OutlineInputBorder()),
              items: provider.circles.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: (val) => setState(() => _selectedCircle = val),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedYear,
                    decoration: const InputDecoration(labelText: 'السنة', border: OutlineInputBorder()),
                    items: _years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                    onChanged: (val) { if (val != null) setState(() => _selectedYear = val); },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedMonth,
                    decoration: const InputDecoration(labelText: 'الشهر', border: OutlineInputBorder()),
                    items: List.generate(12, (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(_months[index]),
                    )),
                    onChanged: (val) { if (val != null) setState(() => _selectedMonth = val); },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }

  Future<void> _generateCircleMonthlyReport(AcademyProvider provider) async {
    if (_selectedCircle == null) return;
    
    // إظهار مؤشر تحميل
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري جلب بيانات طلاب الحلقة...'), duration: Duration(seconds: 1)),
    );

    final students = provider.getStudentsForCircle(_selectedCircle!.id);
    
    // التأكد من تحميل بيانات جميع الطلاب لضمان دقة التقرير
    for (var s in students) {
      await provider.loadStudentDetails(s.id);
    }

    final attendanceStats = provider.getMonthlyAttendanceStats(_selectedCircle!.id, _selectedYear, _selectedMonth);

    final rows = StringBuffer();
    for (var s in students) {
      final studentStats = attendanceStats[s.id] ?? {
        AttendanceStatus.present: 0,
        AttendanceStatus.late: 0,
        AttendanceStatus.absent: 0,
        AttendanceStatus.excused: 0,
      };
      
      final performance = provider.getStudentMonthlyPerformance(s.id, _selectedYear, _selectedMonth);
      final totalDays = studentStats.values.fold(0, (sum, val) => sum + val);
      final attendanceRate = totalDays == 0 ? 0 : ((studentStats[AttendanceStatus.present]! + studentStats[AttendanceStatus.late]!) / totalDays) * 100;

      rows.write('''
        <tr>
          <td>${s.name}</td>
          <td style="text-align: center;">${studentStats[AttendanceStatus.present]}</td>
          <td style="text-align: center;">${studentStats[AttendanceStatus.absent]}</td>
          <td style="text-align: center;">${attendanceRate.toStringAsFixed(0)}%</td>
          <td style="text-align: center;">${performance['memorizationCount']}</td>
          <td style="text-align: center;">${performance['revisionCount']}</td>
          <td style="text-align: center;">${(performance['avgGrade'] as double).toStringAsFixed(1)}</td>
        </tr>
      ''');
    }

    final html = _buildBaseHtmlReport(
      title: 'تقرير حلقة: ${_selectedCircle!.name}',
      subtitle: 'الملخص الشهري: ${_months[_selectedMonth-1]} $_selectedYear',
      content: '''
        <div class="meta-grid">
          <div class="meta-card"><h3>المعلم</h3><p>${_selectedCircle!.teacherName}</p></div>
          <div class="meta-card"><h3>المستوى</h3><p>${_selectedCircle!.level.nameAr}</p></div>
          <div class="meta-card"><h3>عدد الطلاب</h3><p>${students.length}</p></div>
        </div>
        <table>
          <thead>
            <tr>
              <th>اسم الطالب</th>
              <th>حضور</th>
              <th>غياب</th>
              <th>نسبة الالتزام</th>
              <th>حفظ جديد</th>
              <th>مراجعة</th>
              <th>متوسط التقييم</th>
            </tr>
          </thead>
          <tbody>
            ${rows.toString()}
          </tbody>
        </table>
      ''',
    );

    FileExporter.printHtmlReport(html, 'تقرير_حلقة_${_selectedCircle!.name}_$_selectedMonth');
  }

  Future<void> _generateStudentMonthlyReport(AcademyProvider provider, Student student) async {
    await provider.loadStudentDetails(student.id);
    final performance = provider.getStudentMonthlyPerformance(student.id, _selectedYear, _selectedMonth);
    final attendanceStats = provider.getMonthlyAttendanceStats(_selectedCircle!.id, _selectedYear, _selectedMonth)[student.id] ?? {
      AttendanceStatus.present: 0,
      AttendanceStatus.late: 0,
      AttendanceStatus.absent: 0,
      AttendanceStatus.excused: 0,
    };

    final totalDays = attendanceStats.values.fold(0, (sum, val) => sum + val);
    final attendanceRate = totalDays == 0 ? 0 : ((attendanceStats[AttendanceStatus.present]! + attendanceStats[AttendanceStatus.late]!) / totalDays) * 100;

    final records = performance['records'] as List<MemorizationRecord>;
    final recordRows = StringBuffer();
    for (var r in records) {
      recordRows.write('''
        <tr>
          <td>${r.date.day}/${r.date.month}</td>
          <td>${r.type.nameAr}</td>
          <td>${r.surahName ?? r.lessonName ?? '-'}</td>
          <td style="text-align: center;">${r.grade.nameAr}</td>
        </tr>
      ''');
    }

    final html = _buildBaseHtmlReport(
      title: 'تقرير الطالب: ${student.name}',
      subtitle: 'تقرير شهر: ${_months[_selectedMonth-1]} $_selectedYear',
      content: '''
        <div class="meta-grid">
          <div class="meta-card"><h3>الحلقة</h3><p>${_selectedCircle!.name}</p></div>
          <div class="meta-card"><h3>نسبة الحضور</h3><p>${attendanceRate.toStringAsFixed(0)}%</p></div>
          <div class="meta-card"><h3>إنجازات الشهر</h3><p>${records.length} سجل</p></div>
        </div>
        
        <h3>تفاصيل السجلات اليومية</h3>
        <table>
          <thead>
            <tr>
              <th>التاريخ</th>
              <th>النوع</th>
              <th>المحتوى</th>
              <th>التقييم</th>
            </tr>
          </thead>
          <tbody>
            ${recordRows.isEmpty ? '<tr><td colspan="4" style="text-align:center;">لا توجد سجلات لهذا الشهر</td></tr>' : recordRows.toString()}
          </tbody>
        </table>
      ''',
    );

    FileExporter.printHtmlReport(html, 'تقرير_طالب_${student.name}_$_selectedMonth');
  }

  String _buildBaseHtmlReport({required String title, required String subtitle, required String content}) {
    return '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;700;900&display=swap" rel="stylesheet">
  <style>
    body { font-family: 'Cairo', sans-serif; background-color: #f4f7f5; padding: 40px; color: #15201b; }
    .header { text-align: center; border-bottom: 3px double #053e2a; padding-bottom: 20px; margin-bottom: 30px; }
    .header h1 { color: #053e2a; margin: 0; }
    .meta-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
    .meta-card { background: white; padding: 15px; border-radius: 8px; border-right: 4px solid #c5a880; }
    .meta-card h3 { margin: 0; font-size: 12px; color: #42524a; }
    .meta-card p { margin: 5px 0 0 0; font-weight: bold; color: #053e2a; }
    table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; }
    th { background: #053e2a; color: white; padding: 12px; text-align: right; }
    td { padding: 10px; border-bottom: 1px solid #eef2ef; }
    @media print { body { background: white; padding: 0; } }
  </style>
</head>
<body>
  <div class="header">
    <h1>أكاديمية إتقان لتحفيظ القرآن</h1>
    <p>$title</p>
    <p style="font-size: 14px; color: #666;">$subtitle</p>
  </div>
  $content
  <div style="text-align: center; margin-top: 50px; font-size: 10px; color: #aaa;">
    تم إنشاء هذا التقرير تلقائياً بواسطة نظام أكاديمية إتقان - ${DateTime.now().toString()}
  </div>
  <script>window.onload = function() { window.print(); };</script>
</body>
</html>
    ''';
  }
}
