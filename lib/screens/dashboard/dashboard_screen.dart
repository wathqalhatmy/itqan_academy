import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/circle.dart';
import '../../core/models/student.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_animations.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/level_badge.dart';
import '../../core/widgets/search_field.dart';
import '../../main.dart';
import '../../providers/academy_provider.dart';
import '../../providers/auth_provider.dart';
import '../circles/circle_detail_screen.dart';
import '../students/student_detail_screen.dart';
import '../reports/reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AcademyProvider>(
      builder: (context, provider, child) {
        final normalizedQuery = AppConstants.normalizeArabic(_searchQuery);
        final circles = provider.circles.where((c) {
          return AppConstants.normalizeArabic(c.name)
                  .contains(normalizedQuery) ||
              AppConstants.normalizeArabic(c.teacherName)
                  .contains(normalizedQuery);
        }).toList();

        final totalCircles = provider.circles.length;

        return AppScaffold(
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    color: isDark ? colorScheme.primary : colorScheme.secondary,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text('أكاديمية إتقان',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => ItqanAcademyApp.of(context).toggleTheme(),
                  tooltip: 'تغيير المظهر',
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  onPressed: () => _showLogoutDialog(context),
                  tooltip: 'تسجيل الخروج',
                ),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeBanner(context, isDark),
                    const SizedBox(height: 24),

                    // كروت الإحصائيات السريعة
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            title: ' ادارة الطلاب',
                            value: '$totalCircles',
                            icon: Icons.group_work_rounded,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context: context,
                            title: 'إجمالي التقارير',
                            value: 'شهري',
                            icon: Icons.assessment_rounded,
                            color: colorScheme.secondary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ReportsScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // عنوان القسم + عداد النتائج
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الحلقات القرآنية الحالية',
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '(${circles.length}) حلقة',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // حقل البحث
                    SearchField(
                      controller: _searchController,
                      hint: 'البحث باسم الحلقة أو المعلم...',
                      onChanged: (val) => setState(() => _searchQuery = val),
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                    const SizedBox(height: 16),

                    // قائمة الحلقات
                    if (circles.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 64,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text('لا توجد حلقات تطابق بحثك',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: circles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final circle = circles[index];
                          final studentsCount =
                              provider.getStudentsForCircle(circle.id).length;
                          return FadeSlideEntrance(
                            duration:
                                Duration(milliseconds: 250 + (index * 50)),
                            child: HoverScaleCard(
                              onTap: () {
                                provider.selectCircle(circle);
                                Navigator.push(
                                  context,
                                  PremiumPageRoute(
                                      child: const CircleDetailScreen()),
                                );
                              },
                              child: _buildCircleItem(
                                  context, circle, studentsCount, index),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 24),
                    if (Provider.of<AuthProvider>(context, listen: false).isAdmin)
                      _buildUnassignedSection(context, provider),
                  ],
                ),
              ),
            ),
            floatingActionButton: Provider.of<AuthProvider>(context, listen: false).isAdmin 
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddCircleDialog(context, provider),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة حلقة جديدة',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )
              : null,
          ),
        );
      },
    );
  }

  // ───── Widgets ─────

  Widget _buildWelcomeBanner(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colorScheme.surface,
                  colorScheme.primaryContainer.withValues(alpha: 0.4)
                ]
              : [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً بك في لوحة الإشراف 👋',
            style: theme.textTheme.titleLarge?.copyWith(
                color: isDark ? colorScheme.primary : Colors.white,
                fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'إدارة الحلقات وحضور الطلاب ومتابعة مستويات الحفظ والمراجعة والاختبارات اليومية بكل سهولة.',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? colorScheme.onSurface
                    : Colors.white.withValues(alpha: 0.9),
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleItem(
      BuildContext context, Circle circle, int studentsCount, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemColor =
        index % 2 == 0 ? colorScheme.primary : colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: itemColor, width: 5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: itemColor.withValues(alpha: 0.1),
            child: Icon(Icons.menu_book, color: itemColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(circle.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    LevelBadge(level: circle.level),
                    const SizedBox(width: 8),
                    Icon(Icons.person,
                        size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(circle.teacherName,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$studentsCount طلاب',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: colorScheme.primary, fontSize: 12)),
              ),
              const SizedBox(height: 4),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnassignedSection(
      BuildContext context, AcademyProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unassigned = provider.unassignedStudents;

    if (unassigned.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الطلاب غير الموزعين على الحلقات',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorRed),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${unassigned.length} طلاب',
                  style: TextStyle(
                      color: AppTheme.errorRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: unassigned.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final student = unassigned[index];
            return FadeSlideEntrance(
              duration: Duration(milliseconds: 250 + (index * 40)),
              child: HoverScaleCard(
                onTap: () => Navigator.push(
                  context,
                  PremiumPageRoute(
                      child: StudentDetailScreen(studentId: student.id)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(
                      right: 12, left: 8, top: 4, bottom: 4),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.errorRed.withValues(alpha: 0.1),
                    child: Text(student.name.substring(0, 1),
                        style: TextStyle(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  title: Text(student.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(
                    student.notes.isEmpty
                        ? 'طالب غير موزع حالياً'
                        : student.notes,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_link_rounded,
                            color: colorScheme.primary),
                        tooltip: 'تنسيب إلى حلقة',
                        onPressed: () => _showAssignToCircleDialog(
                            context, provider, student),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever_rounded,
                            color: Colors.red),
                        tooltip: 'حذف نهائي',
                        onPressed: () => _showDeleteUnassignedDialog(
                            context, provider, student),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ───── Dialogs ─────

  void _showAddCircleDialog(BuildContext context, AcademyProvider provider) {
    final nameController = TextEditingController();
    final teacherController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    CircleLevel selectedLevel = CircleLevel.memorization;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('إضافة حلقة جديدة',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الحلقة',
                      hintText: 'مثال: حلقة عاصم بن أبي النجود',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'الرجاء إدخال اسم الحلقة'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: teacherController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الشيخ المعلم',
                      hintText: 'مثال: الشيخ أحمد المحمود',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'الرجاء إدخال اسم المعلم'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CircleLevel>(
                    initialValue: selectedLevel,
                    decoration: const InputDecoration(
                      labelText: 'مستوى الحلقة التعليمي',
                      border: OutlineInputBorder(),
                    ),
                    items: CircleLevel.values
                        .map((l) =>
                            DropdownMenuItem(value: l, child: Text(l.nameAr)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => selectedLevel = v);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              StatefulBuilder(
                builder: (context, setBtnState) {
                  // سنقوم بتعريف الحالة داخل الـ StatefulBuilder ولكن سنستخدمها بشكل صحيح
                  // لاحظ: لمنع إعادة التصفير، يجب أن تكون المتغيرات جزءاً من حالة الـ StatefulBuilder نفسه
                  // أو نستخدم متغير خارجي إذا كان الحوار بسيطاً.
                  return _AddCircleButton(
                    provider: provider,
                    nameController: nameController,
                    teacherController: teacherController,
                    selectedLevel: selectedLevel,
                    formKey: formKey,
                  );
                }
              ),
            ],
          );
        });
      },
    );
  }

  void _showAssignToCircleDialog(
      BuildContext context, AcademyProvider provider, Student student) {
    Circle? selectedCircle =
        provider.circles.isNotEmpty ? provider.circles.first : null;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'تنسيب الطالب: ${student.name}',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'اختر الحلقة القرآنية التي ترغب في تنسيب الطالب إليها:',
                    style: TextStyle(fontSize: 13)),
                const SizedBox(height: 16),
                if (provider.circles.isEmpty)
                  const Text('لا توجد حلقات متاحة. يرجى إنشاء حلقة أولاً.',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12))
                else
                  DropdownButtonFormField<Circle>(
                    initialValue: selectedCircle,
                    decoration: const InputDecoration(
                        labelText: 'الحلقة المستهدفة',
                        border: OutlineInputBorder()),
                    items: provider.circles
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => selectedCircle = v);
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white),
                onPressed: provider.circles.isEmpty
                    ? null
                    : () {
                        if (selectedCircle != null) {
                          provider.assignStudentToCircle(
                              student.id, selectedCircle!.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'تم تنسيب ${student.name} إلى ${selectedCircle!.name} بنجاح'),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                        }
                      },
                child: const Text('تأكيد التنسيب'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showDeleteUnassignedDialog(
      BuildContext context, AcademyProvider provider, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الطالب نهائياً من النظام؟',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(
            'هل أنت متأكد من حذف الطالب "${student.name}" نهائياً؟ سيؤدي هذا لمسح كافة بياناته ولا يمكن التراجع.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              provider.deleteStudentPermanently(student.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('تم حذف الطالب نهائياً من النظام'),
                    backgroundColor: Colors.red),
              );
            },
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من النظام؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}

class _AddCircleButton extends StatefulWidget {
  final AcademyProvider provider;
  final TextEditingController nameController;
  final TextEditingController teacherController;
  final CircleLevel selectedLevel;
  final GlobalKey<FormState> formKey;

  const _AddCircleButton({
    required this.provider,
    required this.nameController,
    required this.teacherController,
    required this.selectedLevel,
    required this.formKey,
  });

  @override
  State<_AddCircleButton> createState() => _AddCircleButtonState();
}

class _AddCircleButtonState extends State<_AddCircleButton> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white),
      onPressed: _isSaving ? null : () async {
        if (widget.formKey.currentState!.validate()) {
          setState(() => _isSaving = true);
          try {
            await widget.provider.addCircle(
              widget.nameController.text.trim(),
              widget.teacherController.text.trim(),
              widget.selectedLevel,
            );
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('تمت إضافة الحلقة بنجاح'),
                    backgroundColor: AppTheme.primaryLight),
              );
            }
          } catch (e) {
            if (mounted) setState(() => _isSaving = false);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
              );
            }
          }
        }
      },
      child: _isSaving 
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : const Text('إضافة'),
    );
  }
}
