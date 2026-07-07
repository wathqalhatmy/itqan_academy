import 'package:flutter/material.dart';
import '../../../core/models/student.dart';
import '../../../core/models/circle.dart';
import '../../../core/models/attendance.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/academy_provider.dart';
import 'student_dialogs.dart';

class StudentProfileCard extends StatelessWidget {
  final Student student;
  final Circle circle;
  final AcademyProvider provider;

  const StudentProfileCard({
    super.key,
    required this.student,
    required this.circle,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colorScheme.secondary.withValues(alpha: 0.12),
                  child: Icon(Icons.person, color: colorScheme.primary, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < student.behaviorRating.floor()
                                ? Icons.star_rounded
                                : (index < student.behaviorRating
                                    ? Icons.star_half_rounded
                                    : Icons.star_outline_rounded),
                            color: colorScheme.tertiary,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: colorScheme.primary, size: 20),
                  onPressed: () => _showEditNotesAndBehaviorDialog(context),
                  tooltip: 'تعديل السلوك والملاحظات',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildProfileBadge(
                  context: context,
                  icon: Icons.meeting_room_rounded,
                  label: 'الحلقة: ${circle.name}',
                  color: colorScheme.primary,
                ),
                _buildProfileBadge(
                  context: context,
                  icon: Icons.person_rounded,
                  label: 'المعلم: ${circle.teacherName}',
                  color: colorScheme.secondary,
                ),
                _buildProfileBadge(
                  context: context,
                  icon: Icons.bar_chart_rounded,
                  label: 'المستوى: ${circle.level.nameAr}',
                  color: colorScheme.tertiary,
                ),
                if (student.age != null)
                  _buildProfileBadge(
                    context: context,
                    icon: Icons.calendar_today_rounded,
                    label: 'العمر: ${student.age} سنة',
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                if (student.phoneNumber != null && student.phoneNumber!.isNotEmpty)
                  _buildProfileBadge(
                    context: context,
                    icon: Icons.phone_android_rounded,
                    label: 'الهاتف: ${student.phoneNumber}',
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                _buildProfileBadge(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  label: 'الحالة: ${student.status.nameAr}',
                  color: switch (student.status) {
                    StudentStatus.active     => colorScheme.primary,
                    StudentStatus.newStudent => colorScheme.secondary,
                    StudentStatus.suspended  => AppTheme.errorRed,
                    StudentStatus.graduated  => colorScheme.primaryContainer,
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes_rounded, size: 14, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'ملاحظات المعلم العامة',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.notes.isEmpty ? 'لا توجد ملاحظات مسجلة حالياً.' : student.notes,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      height: 1.3,
                      color: student.notes.isEmpty ? colorScheme.onSurfaceVariant.withValues(alpha: 0.55) : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'إحصائيات الحضور والالتزام',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final attendanceList = provider.getAttendanceForStudent(student.id);
                final presentCount = attendanceList.where((a) => a.status == AttendanceStatus.present).length;
                final lateCount = attendanceList.where((a) => a.status == AttendanceStatus.late).length;
                final absentCount = attendanceList.where((a) => a.status == AttendanceStatus.absent).length;
                final excusedCount = attendanceList.where((a) => a.status == AttendanceStatus.excused).length;
                final totalAttendance = attendanceList.length;
                final attendanceRate = totalAttendance == 0 
                    ? 100.0 
                    : ((presentCount + lateCount) / totalAttendance) * 100;
                
                return Row(
                  children: [
                    Expanded(child: _buildAttendanceStatItem('حاضر', '$presentCount', AppTheme.successGreen, theme)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildAttendanceStatItem('متأخر', '$lateCount', AppTheme.warningOrange, theme)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildAttendanceStatItem('غائب', '$absentCount', AppTheme.errorRed, theme)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildAttendanceStatItem('بعذر', '$excusedCount', AppTheme.infoBlue, theme)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildAttendanceStatItem(
                        'نسبة الحضور',
                        '${attendanceRate.toStringAsFixed(0)}%',
                        colorScheme.primary,
                        theme,
                        isPercent: true,
                      ),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? color.withValues(alpha: 0.9) : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatItem(String label, String value, Color color, ThemeData theme, {bool isPercent = false}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 0.8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isPercent ? 10 : 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 8, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showEditNotesAndBehaviorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditNotesAndBehaviorDialog(provider: provider, student: student),
    );
  }
}
