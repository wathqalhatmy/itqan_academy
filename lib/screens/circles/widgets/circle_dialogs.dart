import 'package:flutter/material.dart';
import '../../../core/models/circle.dart';
import '../../../core/models/student.dart';
import '../../../core/models/memorization_record.dart';
import '../../../core/models/attendance.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_exporter.dart';
import '../../../providers/academy_provider.dart';

// ─────────────────────────────────────────────
// 1. حوار تأكيد التحضير السريع
// ─────────────────────────────────────────────
void showQuickAttendanceConfirm(
    BuildContext context, AcademyProvider provider, Circle circle) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('التحضير السريع (حضور للكل)',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text(
          'هل تريد تسجيل جميع طلاب الحلقة كـ "حضور" لتاريخ اليوم؟'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white),
          onPressed: () {
            provider.markAllAsPresent(circle.id, DateTime.now());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('تم تحضير جميع الطلاب بنجاح'),
                  backgroundColor: AppTheme.successGreen),
            );
          },
          child: const Text('تأكيد'),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
// 2. حوار تعديل بيانات الحلقة
// ─────────────────────────────────────────────
void showEditCircleDialog(
    BuildContext context, AcademyProvider provider, Circle circle) {
  final nameController = TextEditingController(text: circle.name);
  final teacherController = TextEditingController(text: circle.teacherName);
  CircleLevel selectedLevel = circle.level;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تعديل بيانات الحلقة',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'اسم الحلقة',
                      border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: teacherController,
                  decoration: const InputDecoration(
                      labelText: 'اسم الشيخ المعلم',
                      border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CircleLevel>(
                  initialValue: selectedLevel,
                  decoration: const InputDecoration(
                      labelText: 'مستوى الحلقة التعليمي',
                      border: OutlineInputBorder()),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  provider.updateCircle(circle.id, nameController.text.trim(),
                      teacherController.text.trim(), selectedLevel);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('تم تحديث الحلقة بنجاح'),
                        backgroundColor: AppTheme.successGreen),
                  );
                }
              },
              child: const Text('حفظ التغييرات'),
            ),
          ],
        );
      });
    },
  );
}

// ─────────────────────────────────────────────
// 3. حوار تأكيد حذف الحلقة
// ─────────────────────────────────────────────
void showDeleteCircleDialog(
    BuildContext context, AcademyProvider provider, Circle circle) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('حذف الحلقة نهائياً؟',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      content: Text(
          'هل أنت متأكد من حذف "${circle.name}" بالكامل؟ سيتم مسح كافة سجلات الحضور والتسميع المرتبطة بهذه الحلقة ولا يمكن التراجع.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () {
            final messenger = ScaffoldMessenger.of(context);
            provider.deleteCircle(circle.id);
            Navigator.pop(context);
            Navigator.pop(context);
            messenger.showSnackBar(
              const SnackBar(
                  content: Text('تم حذف الحلقة بنجاح'),
                  backgroundColor: Colors.red),
            );
          },
          child: const Text('تأكيد الحذف'),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
// 4. حوار إضافة طالب جديد للحلقة
// ─────────────────────────────────────────────
void showAddStudentDialog(
    BuildContext context, AcademyProvider provider, String circleId) {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String selectedCircleId = circleId;
  StudentStatus selectedStatus = StudentStatus.newStudent;

  showDialog(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(
              'إضافة طالب جديد',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الطالب رباعي',
                        hintText: 'مثال: أحمد محمد علي محمود',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'الرجاء إدخال اسم الطالب';
                        }
                        final trimmed = v.trim();
                        if (RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]')
                            .hasMatch(trimmed)) {
                          return 'الاسم يجب أن يحتوي على حروف فقط';
                        }
                        if (trimmed.split(RegExp(r'\s+')).length < 4) {
                          return 'الرجاء إدخال الاسم رباعياً (4 أسماء على الأقل)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'العمر',
                        hintText: 'مثال: 15',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'الرجاء إدخال عمر الطالب';
                        }
                        final age = int.tryParse(v);
                        if (age == null || age <= 0 || age > 100) {
                          return 'الرجاء إدخال عمر صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم هاتف ولي الأمر',
                        hintText: 'مثال: 0501234567',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'الرجاء إدخال رقم الهاتف';
                        }
                        if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v.trim())) {
                          return 'الرجاء إدخال رقم هاتف صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCircleId,
                      decoration: const InputDecoration(
                        labelText: 'الحلقة القرآنية',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      items: provider.circles
                          .map((c) => DropdownMenuItem<String>(
                              value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedCircleId = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<StudentStatus>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'حالة الطالب',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      items: StudentStatus.values
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(s.nameAr)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedStatus = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات إضافية (اختياري)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    provider.addStudentToCircle(
                      circleId: selectedCircleId,
                      name: nameController.text.trim(),
                      age: int.parse(ageController.text.trim()),
                      phoneNumber: phoneController.text.trim(),
                      status: selectedStatus,
                      notes: notesController.text.trim(),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تمت إضافة الطالب بنجاح للحلقة المحددة'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          );
        },
      );
    },
  );
}

// ─────────────────────────────────────────────
// 5. حوار تأكيد إزالة طالب من الحلقة
// ─────────────────────────────────────────────
void showRemoveStudentFromCircleDialog(BuildContext context,
    AcademyProvider provider, String circleId, Student student) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('إزالة الطالب من الحلقة؟',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(
          'هل أنت متأكد من إزالة الطالب "${student.name}" من هذه الحلقة فقط؟ لن يتم حذف بياناته العامة وسجلاته من النظام.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, foregroundColor: Colors.white),
          onPressed: () {
            provider.removeStudentFromCircle(circleId, student.id);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('تمت إزالة الطالب من الحلقة'),
                  backgroundColor: Colors.orange),
            );
          },
          child: const Text('تأكيد الإزالة'),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
// 6. حوار تأكيد حذف طالب نهائياً
// ─────────────────────────────────────────────
void showDeleteStudentDialog(
    BuildContext context, AcademyProvider provider, Student student) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('حذف الطالب نهائياً من النظام؟',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      content: Text(
          'هل أنت متأكد من حذف الطالب "${student.name}" نهائياً؟ سيؤدي هذا لمسح كافة بياناته وسجلات تسميعه وحضوره بالكامل من النظام ولا يمكن التراجع.'),
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

// ─────────────────────────────────────────────
// 7. تصدير الحلقة كـ CSV
// ─────────────────────────────────────────────
void exportCircleToExcel(AcademyProvider provider, Circle circle) {
  final students = provider.getStudentsForCircle(circle.id);
  final buffer = StringBuffer();
  buffer.write('\uFEFF'); // UTF-8 BOM
  buffer.writeln(
      'اسم الطالب,تقييم السلوك,الأجزاء المجتازة,عدد إنجازات الحفظ,عدد إنجازات المراجعة,نسبة الحضور والالتزام');

  for (var s in students) {
    final records = provider.getStudentRecords(s.id);
    final memCount =
        records.where((r) => r.type == RecordType.memorization).length;
    final revCount =
        records.where((r) => r.type == RecordType.revision).length;
    final attendanceRate = provider.getStudentAttendanceRate(s.id, circle.id);
    final escapedName = s.name.contains(',') ? '"${s.name}"' : s.name;

    buffer.writeln('$escapedName,'
        '${s.behaviorRating.toStringAsFixed(1)},'
        '"${s.completedJuz.join(' - ')}",'
        '$memCount,'
        '$revCount,'
        '${attendanceRate.toStringAsFixed(0)}%');
  }

  FileExporter.downloadCsv(
      buffer.toString(), 'تقرير_حلقة_${circle.name.replaceAll(' ', '_')}.csv');
}

// ─────────────────────────────────────────────
// 8. تصدير الحلقة كـ PDF
// ─────────────────────────────────────────────
void exportCircleToPdf(AcademyProvider provider, Circle circle) {
  final students = provider.getStudentsForCircle(circle.id);
  final rows = StringBuffer();

  for (var s in students) {
    final records = provider.getStudentRecords(s.id);
    final memCount =
        records.where((r) => r.type == RecordType.memorization).length;
    final revCount =
        records.where((r) => r.type == RecordType.revision).length;
    final attendance = provider.getAttendanceForStudent(s.id);
    final presentCount = attendance
        .where((a) =>
            a.circleId == circle.id && a.status == AttendanceStatus.present)
        .length;
    final lateCount = attendance
        .where(
            (a) => a.circleId == circle.id && a.status == AttendanceStatus.late)
        .length;
    final total = attendance.where((a) => a.circleId == circle.id).length;
    final rate = total == 0 ? 100 : ((presentCount + lateCount) / total) * 100;

    rows.write('''
      <tr>
        <td style="padding:12px 15px;border-bottom:1px solid #eef2ef">${s.name}</td>
        <td style="padding:12px 15px;border-bottom:1px solid #eef2ef;text-align:center">${s.behaviorRating.toStringAsFixed(1)} / 5.0</td>
        <td style="padding:12px 15px;border-bottom:1px solid #eef2ef;text-align:center;font-weight:bold;color:#0a5c3e">${s.completedJuz.join(' - ')}</td>
        <td style="padding:12px 15px;border-bottom:1px solid #eef2ef;text-align:center">$memCount</td>
        <td style="padding:12px 15px;border-bottom:1px solid #eef2ef;text-align:center">$revCount</td>
        <td style="padding:12px 15px;border-bottom:1px solid #eef2ef;text-align:center;font-weight:bold;color:${rate >= 70 ? '#2e7d32' : '#c62828'}">${rate.toStringAsFixed(0)}%</td>
      </tr>
    ''');
  }

  final html = _buildBaseHtml(
    title: 'تقرير حلقة: ${circle.name}',
    subtitle: 'الأداء والتحصيل الشهري للحلقة',
    metaCards: '''
      <div class="meta-card"><h3>اسم الحلقة</h3><p>${circle.name}</p></div>
      <div class="meta-card"><h3>المعلم المشرف</h3><p>${circle.teacherName}</p></div>
      <div class="meta-card"><h3>المستوى التعليمي</h3><p>${circle.level.nameAr}</p></div>
    ''',
    tableHeaders: '<th>اسم الطالب</th><th>السلوك</th><th>الأجزاء</th><th>حفظ</th><th>مراجعة</th><th>الحضور</th>',
    tableRows: rows.toString(),
  );

  FileExporter.printHtmlReport(html, 'تقرير_حلقة_${circle.name}');
}

// ─────────────────────────────────────────────
// مساعد: بناء HTML أساسي موحد للتقارير
// ─────────────────────────────────────────────
String _buildBaseHtml({
  required String title,
  required String subtitle,
  required String metaCards,
  required String tableHeaders,
  required String tableRows,
}) {
  return '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <title>$title</title>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;700;900&display=swap" rel="stylesheet">
  <style>
    body { font-family: 'Cairo', sans-serif; background: #f4f7f5; color: #15201b; margin: 0; padding: 40px; }
    .header { text-align: center; border-bottom: 3px double #053e2a; padding-bottom: 20px; margin-bottom: 30px; }
    .header h1 { color: #053e2a; margin: 0; font-size: 28px; font-weight: 900; }
    .header p { margin: 5px 0; color: #42524a; font-size: 16px; }
    .meta-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
    .meta-card { background: white; padding: 15px; border-radius: 8px; border-right: 4px solid #c5a880; }
    .meta-card h3 { margin: 0 0 5px 0; font-size: 12px; color: #42524a; }
    .meta-card p { margin: 0; font-size: 18px; font-weight: bold; color: #053e2a; }
    table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; margin-bottom: 30px; }
    th { padding: 12px 15px; text-align: right; background: #053e2a; color: white; font-weight: bold; }
    @media print { body { background: white; padding: 0; } }
  </style>
  <script>window.onload = function() { window.print(); };</script>
</head>
<body>
  <div class="header">
    <h1>أكاديمية إتقان لتحفيظ القرآن</h1>
    <p>$subtitle</p>
  </div>
  <div class="meta-grid">$metaCards</div>
  <table>
    <thead><tr>$tableHeaders</tr></thead>
    <tbody>$tableRows</tbody>
  </table>
  <div style="text-align:center;margin-top:50px;color:#a2b0aa;font-size:11px">
    تاريخ تصدير التقرير: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - أكاديمية إتقان الرقمية
  </div>
</body>
</html>
''';
}
