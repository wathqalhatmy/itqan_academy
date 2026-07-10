import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/circle.dart';
import '../../core/models/student.dart';
import '../../core/models/attendance.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/search_field.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/academy_provider.dart';
import '../attendance/attendance_screen.dart';
import '../students/student_detail_screen.dart';
import '../reports/reports_screen.dart';
import '../../providers/auth_provider.dart';
import 'widgets/circle_dialogs.dart';

class CircleDetailScreen extends StatefulWidget {
  const CircleDetailScreen({super.key});

  @override
  State<CircleDetailScreen> createState() => _CircleDetailScreenState();
}

class _CircleDetailScreenState extends State<CircleDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AcademyProvider>(
      builder: (context, provider, child) {
        final circle = provider.selectedCircle;

        // حالة: لم يتم تحديد حلقة
        if (circle == null) {
          return AppScaffold(
            child: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined,
                          size: 80,
                          color: colorScheme.primary.withValues(alpha: 0.6)),
                      const SizedBox(height: 24),
                      Text('لم يتم تحديد حلقة حالياً',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        'يرجى اختيار إحدى الحلقات المتاحة من القائمة الرئيسية.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('العودة للرئيسية',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // فلترة الطلاب بالبحث
        final normalizedQuery = AppConstants.normalizeArabic(_searchQuery);
        final allStudents = provider.getStudentsForCircle(circle.id);
        final filteredStudents = allStudents.where((s) {
          return AppConstants.normalizeArabic(s.name)
                  .contains(normalizedQuery) ||
              AppConstants.normalizeArabic(s.notes).contains(normalizedQuery);
        }).toList();

        return AppScaffold(
          child: Scaffold(
            appBar: AppBar(
              title: Text(circle.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.flash_on_rounded),
                  tooltip: 'تحضير سريع للكل (حضور)',
                  onPressed: () =>
                      showQuickAttendanceConfirm(context, provider, circle),
                ),
                PopupMenuButton<String>(
                  tooltip: 'خيارات الحلقة',
                  onSelected: (val) {
                    switch (val) {
                      case 'edit':
                        showEditCircleDialog(context, provider, circle);
                        break;
                      case 'delete':
                        showDeleteCircleDialog(context, provider, circle);
                        break;
                      case 'export_excel':
                        exportCircleToExcel(provider, circle);
                        break;
                      case 'export_pdf':
                        exportCircleToPdf(provider, circle);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit, color: colorScheme.onSurfaceVariant, size: 20),
                        SizedBox(width: 8),
                        Text('تعديل بيانات الحلقة'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'export_excel',
                      child: Row(children: [
                        Icon(Icons.table_view_rounded,
                            color: colorScheme.onSurfaceVariant, size: 20),
                        SizedBox(width: 8),
                        Text('تصدير تقرير Excel'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'export_pdf',
                      child: Row(children: [
                        Icon(Icons.picture_as_pdf_rounded,
                            color: colorScheme.onSurfaceVariant, size: 20),
                        SizedBox(width: 8),
                        Text('طباعة تقرير PDF'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_forever, color: AppTheme.errorRed, size: 20),
                        SizedBox(width: 8),
                        Text('حذف الحلقة بالكامل'),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // بطاقة معلومات الحلقة
                    _buildCircleHeaderCard(context, circle),
                    const SizedBox(height: 20),

                    // أزرار العمليات السريعة
                    Text('العمليات اليومية للحلقة',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context: context,
                            title: 'الحضور والغياب',
                            subtitle: 'سجل حضور اليوم',
                            icon: Icons.assignment_turned_in_rounded,
                            color: colorScheme.primary,
                            onTap: () => Navigator.push(context,
                                PremiumPageRoute(
                                    child: const AttendanceScreen())),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildActionCard(
                            context: context,
                            title: 'التقارير الشهرية',
                            subtitle: 'عرض التقارير والأداء',
                            icon: Icons.bar_chart_rounded,
                            color: colorScheme.secondary,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ReportsScreen())),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // عنوان قائمة الطلاب + زر الإضافة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('طلاب الحلقة',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: () => showAddStudentDialog(
                              context, provider, circle.id),
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة طالب',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // حقل البحث
                    SearchField(
                      controller: _searchController,
                      hint: 'البحث عن طالب في هذه الحلقة...',
                      onChanged: (val) => setState(() => _searchQuery = val),
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                    const SizedBox(height: 16),

                    // قائمة الطلاب
                    if (filteredStudents.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Icon(Icons.people_outline_rounded,
                                  size: 64,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'لا يوجد طلاب يطابقون البحث'
                                    : 'لا يوجد طلاب في هذه الحلقة حالياً',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredStudents.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return FadeSlideEntrance(
                            duration:
                                Duration(milliseconds: 250 + (index * 40)),
                            child: HoverScaleCard(
                              onTap: () => Navigator.push(
                                context,
                                PremiumPageRoute(
                                    child: StudentDetailScreen(
                                        studentId: student.id)),
                              ),
                              child: _buildStudentTile(
                                  context, provider, circle, student, index),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ───── Widgets ─────

  Widget _buildCircleHeaderCard(BuildContext context, Circle circle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      color: colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.supervised_user_circle_rounded,
                  color: colorScheme.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المعلم: ${circle.teacherName}',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 17)),
                  const SizedBox(height: 4),
                  Text('المستوى: ${circle.level.nameAr}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                radius: 20,
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentTile(BuildContext context, AcademyProvider provider,
      Circle circle, Student student, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final completedCount = student.completedJuz.length;

    return ListTile(
      contentPadding:
          const EdgeInsets.only(right: 12, left: 8, top: 4, bottom: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Text(student.name.substring(0, 1),
                style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          // مؤشر حالة الحضور اليومي
          Positioned(
            bottom: 0,
            right: 0,
            child: Consumer<AcademyProvider>(
              builder: (context, prov, _) {
                final today = DateTime.now();
                return FutureBuilder<List<Attendance>>(
                  future: prov.getAttendanceForDateAndCircle(circle.id, today),
                  builder: (context, snapshot) {
                    final List<Attendance>? data = snapshot.data;
                    final attendance = data?.firstWhere(
                          (a) => a.studentId == student.id,
                          orElse: () => Attendance(
                              id: '',
                              studentId: student.id,
                              circleId: circle.id,
                              date: today,
                              status: AttendanceStatus.unmarked),
                        ) ??
                        Attendance(
                            id: '',
                            studentId: student.id,
                            circleId: circle.id,
                            date: today,
                            status: AttendanceStatus.unmarked);

                    if (attendance.id.isEmpty || attendance.status == AttendanceStatus.unmarked) {
                      return const SizedBox.shrink();
                    }

                    final AttendanceStatus status = attendance.status;
                    final (Color statusColor, IconData statusIcon) =
                        switch (status) {
                      AttendanceStatus.present => (
                          AppTheme.successGreen,
                          Icons.check_circle_rounded
                        ),
                      AttendanceStatus.late => (
                          AppTheme.warningOrange,
                          Icons.access_time_filled_rounded
                        ),
                      AttendanceStatus.absent => (
                          AppTheme.errorRed,
                          Icons.cancel_rounded
                        ),
                      AttendanceStatus.excused => (
                          AppTheme.infoBlue,
                          Icons.info_rounded
                        ),
                      AttendanceStatus.unmarked => (
                          Colors.grey,
                          Icons.radio_button_unchecked_rounded
                        ),
                    };

                    return Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          shape: BoxShape.circle),
                      child: Icon(statusIcon, size: 14, color: statusColor),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      title: Text(student.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 16, color: colorScheme.tertiary),
              const SizedBox(width: 4),
              Text(
                'السلوك: ${student.behaviorRating.toStringAsFixed(1)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (circle.level == CircleLevel.memorization)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$completedCount جزء',
                  style: TextStyle(
                      color: colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
            onSelected: (val) {
              if (val == 'remove') {
                showRemoveStudentFromCircleDialog(
                    context, provider, circle.id, student);
              } else if (val == 'delete') {
                showDeleteStudentDialog(context, provider, student);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'remove',
                child: Row(children: [
                  Icon(Icons.link_off_rounded, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Text('إزالة من هذه الحلقة',
                      style: TextStyle(fontSize: 13)),
                ]),
              ),
              if (Provider.of<AuthProvider>(context, listen: false).isAdmin)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_forever_rounded,
                        color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('حذف الطالب نهائياً',
                        style: TextStyle(fontSize: 13, color: Colors.red)),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
