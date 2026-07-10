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
  bool _isLoadingPreview = false;
  List<dynamic>? _circleStatsCache;

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
    if (_selectedCircle != null) {
      _loadPreview();
    }
  }

  Future<void> _loadPreview() async {
    if (_selectedCircle == null) return;
    setState(() => _isLoadingPreview = true);
    try {
      final stats = await Provider.of<AcademyProvider>(context, listen: false)
          .getCircleMonthlyStats(_selectedCircle!.id, _selectedYear, _selectedMonth);
      setState(() {
        _circleStatsCache = stats;
        _isLoadingPreview = false;
      });
    } catch (e) {
      setState(() => _isLoadingPreview = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في جلب البيانات: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير الذكية')),
      body: Consumer<AcademyProvider>(
        builder: (context, provider, child) {
          if (provider.circles.isEmpty) {
            return const Center(child: Text('لا توجد حلقات متاحة لإنشاء تقارير'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSelectionSection(provider),
              const SizedBox(height: 24),
              if (_selectedCircle != null) ...[
                _buildPreviewHeader(theme),
                if (_isLoadingPreview)
                  const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
                else if (_circleStatsCache != null)
                  _buildStatsTable(theme, provider)
                else
                  const Center(child: Text('لا توجد بيانات لهذا الشهر')),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreviewHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('معاينة إحصائيات الشهر', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          TextButton.icon(
            onPressed: () => _generateCircleMonthlyReport(context.read<AcademyProvider>()),
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
            label: const Text('تقرير الحلقة الشامل', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTable(ThemeData theme, AcademyProvider provider) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('اسم الطالب', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('حضور', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('إنجاز', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 48),
              ],
            ),
          ),
          ..._circleStatsCache!.map((stat) {
            final studentId = stat['studentId'];
            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(stat['studentName'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text('الالتزام: ${stat['attendance']['rate']}%', style: TextStyle(fontSize: 11, color: theme.colorScheme.primary)),
                  trailing: IconButton(
                    icon: const Icon(Icons.download_rounded, size: 20),
                    onPressed: () => _generateStudentMonthlyReport(provider, studentId, stat['studentName']),
                    tooltip: 'تقرير الطالب',
                  ),
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    child: Text('${stat['achievement']['memorizationCount']}', style: TextStyle(fontSize: 12, color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSelectionSection(AcademyProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Circle>(
              initialValue: _selectedCircle,
              decoration: const InputDecoration(labelText: 'اختر الحلقة', prefixIcon: Icon(Icons.groups_rounded)),
              items: provider.circles.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: (val) {
                setState(() => _selectedCircle = val);
                _loadPreview();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedYear,
                    decoration: const InputDecoration(labelText: 'السنة'),
                    items: _years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedYear = val);
                        _loadPreview();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedMonth,
                    decoration: const InputDecoration(labelText: 'الشهر'),
                    items: List.generate(12, (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(_months[index]),
                    )),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedMonth = val);
                        _loadPreview();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateCircleMonthlyReport(AcademyProvider provider) async {
    if (_selectedCircle == null || _circleStatsCache == null) return;
    
    final rows = StringBuffer();
    for (var stat in _circleStatsCache!) {
      rows.write('''
        <tr>
          <td>${stat['studentName']}</td>
          <td style="text-align: center;">${stat['attendance']['present']}</td>
          <td style="text-align: center;">${stat['attendance']['absent']}</td>
          <td style="text-align: center;">${stat['attendance']['rate']}%</td>
          <td style="text-align: center;">${stat['achievement']['memorizationCount']}</td>
          <td style="text-align: center;">${stat['achievement']['revisionCount']}</td>
          <td style="text-align: center;">${stat['achievement']['avgGrade']}</td>
        </tr>
      ''');
    }

    final html = _buildBaseHtmlReport(
      title: 'تقرير إحصائيات الحلقة',
      subtitle: 'حلقة: ${_selectedCircle!.name} - ${_months[_selectedMonth-1]} $_selectedYear',
      content: '''
        <div class="meta-grid">
          <div class="meta-card"><h3>المعلم</h3><p>${_selectedCircle!.teacherName}</p></div>
          <div class="meta-card"><h3>المستوى</h3><p>${_selectedCircle!.level.nameAr}</p></div>
          <div class="meta-card"><h3>إجمالي الطلاب</h3><p>${_circleStatsCache!.length}</p></div>
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

  Future<void> _generateStudentMonthlyReport(AcademyProvider provider, String studentId, String studentName) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري إنشاء التقرير المفصل...'), duration: Duration(seconds: 1)));
    
    final reportData = await provider.getStudentMonthlyReportDetails(studentId, _selectedYear, _selectedMonth);
    final summary = reportData['summary'];
    final logs = reportData['dailyLogs'] as List<dynamic>;

    final recordRows = StringBuffer();
    for (var r in logs) {
      final RecordType type = RecordType.values.firstWhere((e) => e.name == r['type'], orElse: () => RecordType.memorization);
      final EvaluationGrade grade = EvaluationGrade.values.firstWhere((e) => e.name == r['grade'], orElse: () => EvaluationGrade.acceptable);
      final date = DateTime.parse(r['date']);

      recordRows.write('''
        <tr>
          <td>${date.day}/${date.month}</td>
          <td>${type.nameAr}</td>
          <td>${r['surahName'] ?? r['lessonName'] ?? '-'}</td>
          <td style="text-align: center;">${grade.nameAr}</td>
        </tr>
      ''');
    }

    final html = _buildBaseHtmlReport(
      title: 'تقرير أداء الطالب الشهري',
      subtitle: 'الطالب: $studentName - ${_months[_selectedMonth-1]} $_selectedYear',
      content: '''
        <div class="meta-grid">
          <div class="meta-card"><h3>نسبة الحضور</h3><p>${summary['attendanceRate']}%</p></div>
          <div class="meta-card"><h3>تقييم السلوك</h3><p>${reportData['behaviorRating']}/5</p></div>
          <div class="meta-card"><h3>عدد السجلات</h3><p>${logs.length}</p></div>
        </div>
        
        <h3 style="color:#053e2a; margin-top:30px; border-right:4px solid #c5a880; padding-right:10px;">تفاصيل السجل اليومي</h3>
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

        <div style="margin-top: 50px; display: grid; grid-template-columns: 1fr 1fr; gap: 40px;">
          <div style="border-top: 1px solid #ccc; text-align: center; padding-top: 10px;">توقيع المعلم</div>
          <div style="border-top: 1px solid #ccc; text-align: center; padding-top: 10px;">ختم وتوقيع الإدارة</div>
        </div>
      ''',
    );

    FileExporter.printHtmlReport(html, 'تقرير_طالب_${studentName}_$_selectedMonth');
  }

  String _buildBaseHtmlReport({required String title, required String subtitle, required String content}) {
    return '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;700;900&display=swap" rel="stylesheet">
  <style>
    body { font-family: 'Cairo', sans-serif; background-color: #fff; padding: 40px; color: #15201b; }
    .header { text-align: center; border-bottom: 3px double #053e2a; padding-bottom: 20px; margin-bottom: 30px; }
    .header h1 { color: #053e2a; margin: 0; font-size: 28px; }
    .meta-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
    .meta-card { background: #f9fbf9; padding: 15px; border-radius: 8px; border-right: 4px solid #c5a880; }
    .meta-card h3 { margin: 0; font-size: 12px; color: #42524a; }
    .meta-card p { margin: 5px 0 0 0; font-weight: bold; color: #053e2a; font-size: 16px; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; border: 1px solid #eef2ef; }
    th { background: #053e2a; color: white; padding: 12px; text-align: right; font-size: 14px; }
    td { padding: 10px; border-bottom: 1px solid #eef2ef; font-size: 13px; }
    @media print { body { padding: 20px; } .no-print { display: none; } }
  </style>
</head>
<body>
  <div class="header">
    <div style="font-size: 12px; color: #666; margin-bottom: 10px;">المملكة العربية السعودية<br>أكاديمية إتقان لعلوم القرآن</div>
    <h1>$title</h1>
    <p style="font-size: 14px; color: #053e2a; font-weight: bold; margin-top: 10px;">$subtitle</p>
  </div>
  $content
  <div style="text-align: center; margin-top: 60px; font-size: 10px; color: #aaa;">
    تم إنشاء هذا التقرير تلقائياً بواسطة نظام أكاديمية إتقان لإدارة الحلقات - ${DateTime.now().toString().split('.')[0]}
  </div>
  <script>window.onload = function() { window.print(); };</script>
</body>
</html>
    ''';
  }
}
