import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/attendance.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../providers/academy_provider.dart';

class MonthlyAttendanceScreen extends StatefulWidget {
  const MonthlyAttendanceScreen({super.key});

  @override
  State<MonthlyAttendanceScreen> createState() => _MonthlyAttendanceScreenState();
}

class _MonthlyAttendanceScreenState extends State<MonthlyAttendanceScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  final List<int> _years = List.generate(5, (index) => DateTime.now().year - index);
  final List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ملخص الحضور الشهري'),
        ),
        body: Consumer<AcademyProvider>(
          builder: (context, provider, child) {
            final circle = provider.selectedCircle;
            if (circle == null) {
              return const Center(child: Text('الرجاء اختيار حلقة أولاً'));
            }

            final students = provider.getStudentsForCircle(circle.id);
            final stats = provider.getMonthlyAttendanceStats(
                circle.id, _selectedYear, _selectedMonth);

            return Column(
              children: [
                // فلتر السنة والشهر
                Container(
                  padding: const EdgeInsets.all(16),
                  color: colorScheme.surface,
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedYear,
                          decoration: const InputDecoration(
                            labelText: 'السنة',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _years
                              .map((y) =>
                                  DropdownMenuItem(value: y, child: Text('$y')))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedYear = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedMonth,
                          decoration: const InputDecoration(
                            labelText: 'الشهر',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: List.generate(
                              12,
                              (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text(_months[index]),
                                  )),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedMonth = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // قائمة الطلاب والإحصائيات
                Expanded(
                  child: students.isEmpty
                      ? const Center(child: Text('لا يوجد طلاب في هذه الحلقة'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: students.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final studentStats = stats[student.id] ?? {
                              AttendanceStatus.present: 0,
                              AttendanceStatus.late: 0,
                              AttendanceStatus.absent: 0,
                              AttendanceStatus.excused: 0,
                            };
                            final total = studentStats.values.fold(0, (a, b) => a + b);
                            final present = (studentStats[AttendanceStatus.present] ?? 0) +
                                (studentStats[AttendanceStatus.late] ?? 0);
                            final rate = total == 0 ? 100 : ((present / total) * 100).round();

                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          student.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: (rate >= 70
                                                    ? colorScheme.primary
                                                    : AppTheme.errorRed)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '$rate%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: rate >= 70
                                                  ? colorScheme.primary
                                                  : AppTheme.errorRed,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatItem('حاضر',
                                            studentStats[AttendanceStatus.present]!,
                                            colorScheme.primary),
                                        _buildStatItem('متأخر',
                                            studentStats[AttendanceStatus.late]!,
                                            colorScheme.secondary),
                                        _buildStatItem('غائب',
                                            studentStats[AttendanceStatus.absent]!,
                                            AppTheme.errorRed),
                                        _buildStatItem('بعذر',
                                            studentStats[AttendanceStatus.excused]!,
                                            colorScheme.onSurfaceVariant),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$value',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
