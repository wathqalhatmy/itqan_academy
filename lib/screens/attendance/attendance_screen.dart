import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/attendance.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/search_field.dart';
import '../../providers/academy_provider.dart';
import 'monthly_attendance_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, AttendanceStatus> _tempStatuses = {};
  final Map<String, TimeOfDay> _tempArrivalTimes = {};
  final Map<String, String> _tempNotes = {}; // لتخزين الملاحظات مؤقتاً
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeAttendanceData();
  }

  Future<void> _initializeAttendanceData() async {
    final provider = Provider.of<AcademyProvider>(context, listen: false);
    final circle = provider.selectedCircle;
    if (circle == null) return;

    final students = provider.getStudentsForCircle(circle.id);
    final normalizedSelectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final savedAttendances = await provider.getAttendanceForDateAndCircle(circle.id, normalizedSelectedDate);

    _tempStatuses.clear();
    _tempArrivalTimes.clear();
    _tempNotes.clear();
    _hasUnsavedChanges = false;

    final now = TimeOfDay.now();

    for (var s in students) {
      final saved = savedAttendances.firstWhere(
        (a) => a.studentId == s.id,
        orElse: () => Attendance(
          id: '',
          studentId: s.id,
          circleId: circle.id,
          date: normalizedSelectedDate,
          status: AttendanceStatus.unmarked,
          arrivalTime: null,
        ),
      );
      _tempStatuses[s.id] = saved.status;
      _tempNotes[s.id] = saved.note ?? '';
      
      if (saved.arrivalTime != null) {
        _tempArrivalTimes[s.id] = TimeOfDay.fromDateTime(saved.arrivalTime!);
      } else {
        _tempArrivalTimes[s.id] = now;
      }
    }
    
    if (mounted) setState(() {});
  }

  void _selectDate(BuildContext context) async {
    if (_hasUnsavedChanges) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تنبيه: تغيير التاريخ'),
          content: const Text('لديك تغييرات غير محفوظة في كشف اليوم الحالي. هل تريد تجاهلها وتغيير التاريخ؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('تجاهل التغييرات', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _initializeAttendanceData();
      });
    }
  }

  void _selectTime(BuildContext context, String studentId) async {
    final TimeOfDay initialTime = _tempArrivalTimes[studentId] ?? TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        _tempArrivalTimes[studentId] = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _markAllAsPresent() {
    setState(() {
      for (var key in _tempStatuses.keys) {
        _tempStatuses[key] = AttendanceStatus.present;
      }
      _hasUnsavedChanges = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديد الجميع كحاضر'), duration: Duration(seconds: 1)),
    );
  }

  void _showNoteDialog(String studentId, String studentName) {
    final controller = TextEditingController(text: _tempNotes[studentId]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ملاحظة حضور: $studentName'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'مثال: غياب بسبب المرض، تأخر للمواصلات...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tempNotes[studentId] = controller.text.trim();
                _hasUnsavedChanges = true;
              });
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الخروج'),
            content: const Text('لديك تغييرات غير محفوظة. هل أنت متأكد من الخروج دون حفظ؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('خروج دون حفظ', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirm == true && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: AppScaffold(
        child: Scaffold(
              appBar: AppBar(
                title: Consumer<AcademyProvider>(
                  builder: (context, provider, _) {
                    final circleName = provider.selectedCircle?.name;
                    return Text(
                      circleName != null ? 'حضور: $circleName' : 'تسجيل الحضور والغياب',
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.playlist_add_check_rounded),
                    tooltip: 'تحضير الكل كحاضر',
                    onPressed: _markAllAsPresent,
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_rounded),
                    tooltip: 'الملخص الشهري',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MonthlyAttendanceScreen()),
                      );
                    },
                  ),
                ],
              ),
              bottomNavigationBar: Consumer<AcademyProvider>(
                builder: (context, provider, child) {
                  final circle = provider.selectedCircle;
                  final allStudents = circle != null ? provider.getStudentsForCircle(circle.id) : [];
                  if (allStudents.isEmpty) return const SizedBox.shrink();
                  
                  int presentCount = 0;
                  int lateCount = 0;
                  int absentCount = 0;
                  int excusedCount = 0;
                  
                  for(var s in allStudents) {
                    final status = _tempStatuses[s.id];
                    if (status == AttendanceStatus.present) presentCount++;
                    else if (status == AttendanceStatus.late) lateCount++;
                    else if (status == AttendanceStatus.absent) absentCount++;
                    else if (status == AttendanceStatus.excused) excusedCount++;
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, -5))
                      ],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                             _buildQuickStat('حاضر', presentCount, colorScheme.primary),
                             _buildQuickStat('تأخر', lateCount, colorScheme.secondary),
                             _buildQuickStat('غائب', absentCount, AppTheme.errorRed),
                             _buildQuickStat('بعذر', excusedCount, colorScheme.onSurfaceVariant),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Consumer<AcademyProvider>(
                        builder: (context, provider, _) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                            ),
                            onPressed: _isSaving ? null : () async {
                              setState(() => _isSaving = true);
                              try {
                                final normalizedSelectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                                final updatedList = allStudents.map((s) {
                                  final status = _tempStatuses[s.id] ?? AttendanceStatus.unmarked;
                                  final time = _tempArrivalTimes[s.id] ?? TimeOfDay.now();
                                  final note = _tempNotes[s.id];
                                  final arrivalDateTime = (status == AttendanceStatus.present || status == AttendanceStatus.late)
                                      ? DateTime(normalizedSelectedDate.year, normalizedSelectedDate.month, normalizedSelectedDate.day, time.hour, time.minute)
                                      : null;

                                  return Attendance(
                                    id: 'att_${s.id}_${normalizedSelectedDate.millisecondsSinceEpoch}',
                                    studentId: s.id,
                                    circleId: circle!.id,
                                    date: normalizedSelectedDate,
                                    status: status,
                                    arrivalTime: arrivalDateTime,
                                    note: note,
                                  );
                                }).toList();

                                await provider.saveCircleAttendance(updatedList);
                                if (mounted) {
                                  setState(() {
                                    _hasUnsavedChanges = false;
                                    _isSaving = false;
                                  });
                                }
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم حفظ التحضير بنجاح'), backgroundColor: Colors.green),
                                  );
                                }
                              } catch (e) {
                                if (mounted) setState(() => _isSaving = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('خطأ أثناء الحفظ: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            child: _isSaving 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('حفظ التعديلات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          );
                        }
                    ),
                        ),
                      ],
                    ),
                  );
                }
              ),
              body: Consumer<AcademyProvider>(
                builder: (context, provider, child) {
                  final circle = provider.selectedCircle;
                  if (circle == null) return const Center(child: Text('الرجاء اختيار حلقة'));
        
                  final allStudents = provider.getStudentsForCircle(circle.id);
                  final normalizedQuery = _searchQuery.trim().toLowerCase();
                  final students = allStudents.where((s) => s.name.toLowerCase().contains(normalizedQuery)).toList();
        
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: SearchField(
                          controller: _searchController,
                          hint: 'البحث عن طالب...',
                          onChanged: (val) => setState(() => _searchQuery = val),
                          onClear: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: colorScheme.primary.withValues(alpha: 0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            TextButton.icon(onPressed: () => _selectDate(context), icon: const Icon(Icons.edit_calendar, size: 18), label: const Text('تغيير التاريخ')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: students.isEmpty
                            ? const Center(child: Text('لا توجد نتائج'))
                            : ListView.separated(
                                padding: const EdgeInsets.all(12),
                                itemCount: students.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final student = students[index];
                                  final status = _tempStatuses[student.id] ?? AttendanceStatus.unmarked;
                                  final arrivalTime = _tempArrivalTimes[student.id] ?? TimeOfDay.now();
                                  final note = _tempNotes[student.id] ?? '';
         
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(child: Text(student.name[0])),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    if (status == AttendanceStatus.present || status == AttendanceStatus.late)
                                                      GestureDetector(
                                                        onTap: () => _selectTime(context, student.id),
                                                        child: Text('وقت الحضور: ${arrivalTime.format(context)}', style: TextStyle(color: colorScheme.primary, fontSize: 12)),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(note.isEmpty ? Icons.note_add_outlined : Icons.note_rounded, 
                                                     color: note.isEmpty ? Colors.grey : colorScheme.primary, size: 20),
                                                onPressed: () => _showNoteDialog(student.id, student.name),
                                                tooltip: 'إضافة ملاحظة',
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                               _buildStatusButton('حاضر', AttendanceStatus.present, colorScheme.primary, status, student.id),
                                               _buildStatusButton('متأخر', AttendanceStatus.late, colorScheme.secondary, status, student.id),
                                               _buildStatusButton('غائب', AttendanceStatus.absent, AppTheme.errorRed, status, student.id),
                                               _buildStatusButton('بعذر', AttendanceStatus.excused, colorScheme.onSurfaceVariant, status, student.id),
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
          ),
        );
      }

  Widget _buildStatusButton(String label, AttendanceStatus target, Color color, AttendanceStatus current, String studentId) {
    final isSelected = current == target;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () {
            setState(() {
              _tempStatuses[studentId] = target;
              _hasUnsavedChanges = true;
            });
            if (target == AttendanceStatus.late) _selectTime(context, studentId);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.3)),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, int value, Color color) {
    return Column(
      children: [
        Text('$value', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
