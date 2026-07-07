import 'package:flutter/material.dart';
import '../../../core/models/student.dart';
import '../../../core/models/circle.dart';
import '../../../core/models/memorization_record.dart';
import '../../../core/constants/quran_data.dart';
import '../../../core/widgets/grade_chip_selector.dart';
import '../../../providers/academy_provider.dart';

// ==========================================
// حوار تعديل السلوك والملاحظات العامة للطالب
// ==========================================
class EditNotesAndBehaviorDialog extends StatefulWidget {
  final AcademyProvider provider;
  final Student student;

  const EditNotesAndBehaviorDialog({
    super.key,
    required this.provider,
    required this.student,
  });

  @override
  State<EditNotesAndBehaviorDialog> createState() =>
      _EditNotesAndBehaviorDialogState();
}

class _EditNotesAndBehaviorDialogState
    extends State<EditNotesAndBehaviorDialog> {
  late TextEditingController _notesController;
  late double _behaviorRating;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.student.notes);
    _behaviorRating = widget.student.behaviorRating;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('تعديل السلوك والملاحظات',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تقييم السلوك والانضباط:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _behaviorRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: theme.colorScheme.tertiary,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _behaviorRating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'ملاحظات المعلم العامة',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            widget.provider.updateStudentNotesAndBehavior(
              widget.student.id,
              _notesController.text.trim(),
              _behaviorRating,
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث بيانات الطالب بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('حفظ التغييرات'),
        ),
      ],
    );
  }
}

// ==========================================
// حوار تسجيل إنجاز يومي جديد (مع ملاحظات التقييم)
// ==========================================
class AddRecordDialog extends StatefulWidget {
  final AcademyProvider provider;
  final String studentId;
  final Circle circle;

  const AddRecordDialog({
    super.key,
    required this.provider,
    required this.studentId,
    required this.circle,
  });

  @override
  State<AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends State<AddRecordDialog> {
  late String _selectedSurah;
  late int _maxVerses;
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late RecordType _selectedType;
  late String _selectedTajweedRule;
  late bool _isLetterLesson;
  late String _selectedLetter;
  late String _selectedRule;
  late TextEditingController _pageController;
  late TextEditingController
      _recordNotesController; // ملاحظات خاصة بهذا التقييم
  late EvaluationGrade _selectedGrade;
  final _formKey = GlobalKey<FormState>();

  final _tajweedRulesList = [
    'مخارج الحروف وصفاتها',
    'أحكام النون الساكنة والتنوين',
    'أحكام الميم الساكنة',
    'المدود وأحكامها',
    'أحكام القلقلة',
    'أحكام الراء تفخيماً وترقيقاً',
    'مواضع السكت في القرآن',
    'النون والميم المشددتين',
    'أخرى / عام'
  ];

  final _lettersList = [
    'أ',
    'ب',
    'ت',
    'ث',
    'ج',
    'ح',
    'خ',
    'د',
    'ذ',
    'ر',
    'ز',
    'س',
    'ش',
    'ص',
    'ض',
    'ط',
    'ظ',
    'ع',
    'غ',
    'ف',
    'ق',
    'ك',
    'ل',
    'م',
    'ن',
    'هـ',
    'و',
    'ي'
  ];

  final _rulesList = [
    'حركة الفتحة',
    'حركة الضمة',
    'حركة الكسرة',
    'حكم السكون',
    'أحكام التنوين',
    'حكم الشدّة'
  ];

  @override
  void initState() {
    super.initState();
    final level = widget.circle.level;

    final List<Surah> surahList = QuranData.surahs;
    final firstSurah = surahList.first;
    _selectedSurah = firstSurah.name;
    _maxVerses = firstSurah.verses;
    
    _fromController = TextEditingController(text: '1');
    _toController = TextEditingController(text: '10');
    _selectedType = level == CircleLevel.memorization
        ? RecordType.memorization
        : RecordType.recitation;

    _selectedTajweedRule = _tajweedRulesList.first;

    _isLetterLesson = true;
    _selectedLetter = _lettersList.first;
    _selectedRule = _rulesList.first;
    _pageController = TextEditingController(text: '1');
    _recordNotesController = TextEditingController();

    _selectedGrade = EvaluationGrade.excellent;
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _pageController.dispose();
    _recordNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = widget.circle.level;

    String titleText = 'تسجيل إنجاز يومي جديد';
    if (level == CircleLevel.memorization) {
      titleText = 'سجل تسميع أو مراجعة جديد';
    } else if (level == CircleLevel.tajweed) {
      titleText = 'سجل تلاوة وتجويد جديد';
    } else if (level == CircleLevel.alphabets) {
      titleText = 'سجل القراءة والكتابة للمبتدئين';
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title:
          Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (level == CircleLevel.memorization) ...[
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<RecordType>(
                        title: const Text('حفظ جديد',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        value: RecordType.memorization,
                        groupValue: _selectedType,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<RecordType>(
                        title: const Text('مراجعة',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        value: RecordType.revision,
                        groupValue: _selectedType,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              if (level == CircleLevel.memorization ||
                  level == CircleLevel.tajweed) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedSurah,
                  decoration: const InputDecoration(
                      labelText: 'اختر السورة', border: OutlineInputBorder()),
                  items: QuranData.surahs
                      .map((s) =>
                          DropdownMenuItem<String>(value: s.name, child: Text(s.name)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedSurah = val;
                        final List<Surah> surahList = QuranData.surahs;
                        final surah = surahList
                            .firstWhere((item) => item.name == val);
                        _maxVerses = surah.verses;
                        _toController.text = '${surah.verses}';
                      });
                    }
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 6.0, right: 4.0, bottom: 12.0),
                  child: Text(
                    'عدد آيات سورة $_selectedSurah: $_maxVerses آية',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fromController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'من آية',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                        ),
                        onChanged: (val) {
                          final fromNum = int.tryParse(val);
                          final toNum = int.tryParse(_toController.text);
                          if (fromNum != null &&
                              toNum != null &&
                              fromNum > toNum &&
                              fromNum <= _maxVerses) {
                            setState(() {
                              _toController.text = '$fromNum';
                            });
                          }
                        },
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'مطلوب';
                          final num = int.tryParse(val);
                          if (num == null) return 'رقم غير صحيح';
                          if (num < 1 || num > _maxVerses) {
                            return 'بين 1 و$_maxVerses';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _toController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'إلى آية',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'مطلوب';
                          final num = int.tryParse(val);
                          if (num == null) return 'رقم غير صحيح';
                          final fromNum =
                              int.tryParse(_fromController.text) ?? 1;
                          if (num < fromNum || num > _maxVerses) {
                            return 'بين $fromNum و$_maxVerses';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                if (level == CircleLevel.tajweed) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTajweedRule,
                    decoration: const InputDecoration(
                      labelText: 'حكم التجويد المطبق',
                      border: OutlineInputBorder(),
                    ),
                    items: _tajweedRulesList
                        .map((rule) =>
                            DropdownMenuItem(value: rule, child: Text(rule)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedTajweedRule = val);
                      }
                    },
                  ),
                ],
              ] else if (level == CircleLevel.alphabets) ...[
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('حرف هجائي',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                        value: true,
                        groupValue: _isLetterLesson,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _isLetterLesson = val);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('حركة / قاعدة',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                        value: false,
                        groupValue: _isLetterLesson,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _isLetterLesson = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isLetterLesson)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLetter,
                    decoration: const InputDecoration(
                        labelText: 'اختر الحرف الهجائي',
                        border: OutlineInputBorder()),
                    items: _lettersList
                        .map((letter) => DropdownMenuItem(
                            value: letter, child: Text('حرف ($letter)')))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedLetter = val);
                      }
                    },
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRule,
                    decoration: const InputDecoration(
                        labelText: 'اختر الحركة أو القاعدة',
                        border: OutlineInputBorder()),
                    items: _rulesList
                        .map((rule) =>
                            DropdownMenuItem(value: rule, child: Text(rule)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRule = val);
                      }
                    },
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'رقم الصفحة',
                    hintText: 'مثال: 5',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'مطلوب';
                    if (int.tryParse(val) == null) return 'رقم غير صحيح';
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              // حقل الملاحظات الخاصة بالتقييم المضاف حديثاً بناء على طلب المستخدم
              TextFormField(
                controller: _recordNotesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات المعلم الخاصة بالتقييم',
                  hintText: 'اكتب ملاحظاتك على الحفظ أو الأداء هنا...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('التقييم اليومي:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              GradeChipSelector(
                selectedGrade: _selectedGrade,
                onChanged: (grade) => setState(() => _selectedGrade = grade),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final String evaluationNotes = _recordNotesController.text.trim();
              if (level == CircleLevel.memorization) {
                widget.provider.addStudentRecord(
                  studentId: widget.studentId,
                  circleId: widget.circle.id,
                  type: _selectedType,
                  surahName: _selectedSurah,
                  fromVerse: int.parse(_fromController.text),
                  toVerse: int.parse(_toController.text),
                  grade: _selectedGrade,
                  notes: evaluationNotes.isNotEmpty ? evaluationNotes : null,
                );
              } else if (level == CircleLevel.tajweed) {
                widget.provider.addStudentRecord(
                  studentId: widget.studentId,
                  circleId: widget.circle.id,
                  type: RecordType.recitation,
                  surahName: _selectedSurah,
                  fromVerse: int.parse(_fromController.text),
                  toVerse: int.parse(_toController.text),
                  tajweedRules: _selectedTajweedRule,
                  grade: _selectedGrade,
                  notes: evaluationNotes.isNotEmpty ? evaluationNotes : null,
                );
              } else if (level == CircleLevel.alphabets) {
                widget.provider.addStudentRecord(
                  studentId: widget.studentId,
                  circleId: widget.circle.id,
                  type: RecordType.alphabets,
                  lessonName:
                      _isLetterLesson ? 'حرف $_selectedLetter' : _selectedRule,
                  pageNumber: int.parse(_pageController.text),
                  grade: _selectedGrade,
                  notes: evaluationNotes.isNotEmpty ? evaluationNotes : null,
                );
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('تم تسجيل الإنجاز اليومي بنجاح'),
                    backgroundColor: Colors.green),
              );
            }
          },
          child: const Text('تسجيل'),
        ),
      ],
    );
  }
}

// ==========================================
// حوار تسجيل اختبار جزء جديد (مع ملاحظات التقييم)
// ==========================================
class AddTestDialog extends StatefulWidget {
  final AcademyProvider provider;
  final String studentId;
  final Circle circle;

  const AddTestDialog({
    super.key,
    required this.provider,
    required this.studentId,
    required this.circle,
  });

  @override
  State<AddTestDialog> createState() => _AddTestDialogState();
}

class _AddTestDialogState extends State<AddTestDialog> {
  late int _selectedJuz;
  late TextEditingController _scoreController;
  late TextEditingController _testerController;
  late TextEditingController _testNotesController; // ملاحظات خاصة بهذا الاختبار
  late EvaluationGrade _selectedGrade;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedJuz = 30;
    _scoreController = TextEditingController(text: '95');
    _testerController = TextEditingController(
      text: widget.circle.teacherName.isNotEmpty &&
              widget.circle.teacherName != 'غير محدد'
          ? widget.circle.teacherName
          : '',
    );
    _testNotesController = TextEditingController();
    _selectedGrade = EvaluationGrade.excellent;
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _testerController.dispose();
    _testNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('تسجيل اختبار جزء جديد',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _selectedJuz,
                decoration: const InputDecoration(
                    labelText: 'اختر الجزء', border: OutlineInputBorder()),
                items: List.generate(30, (index) => index + 1)
                    .map((j) =>
                        DropdownMenuItem(value: j, child: Text('الجزء $j')))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedJuz = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _scoreController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'الدرجة الكلية (من 100)',
                    border: OutlineInputBorder()),
                validator: (val) {
                  if (val == null) return 'حقل مطلوب';
                  final num = double.tryParse(val);
                  if (num == null || num < 0 || num > 100)
                    return 'الرجاء إدخال درجة بين 0 و 100';
                  return null;
                },
                onChanged: (val) {
                  final score = double.tryParse(val) ?? 0;
                  setState(() {
                    _selectedGrade = AcademyProvider.gradeFromScore(score);
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _testNotesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات المعلم الخاصة بالاختبار',
                  hintText: 'اكتب ملاحظاتك على مستوى اختبار الجزء هنا...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('التقدير المستحق (محسوب تلقائياً):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              GradeChipSelector(
                selectedGrade: _selectedGrade,
                onChanged: (grade) => setState(() => _selectedGrade = grade),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _testerController,
                decoration: const InputDecoration(
                    labelText: 'اسم الشيخ المختبر',
                    border: OutlineInputBorder()),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'حقل مطلوب';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final String testNotes = _testNotesController.text.trim();
              widget.provider.addStudentJuzTest(
                studentId: widget.studentId,
                circleId: widget.circle.id,
                juzNumber: _selectedJuz,
                score: double.parse(_scoreController.text),
                grade: _selectedGrade,
                testerName: _testerController.text.trim(),
                notes: testNotes.isNotEmpty ? testNotes : null,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('تم تسجيل اختبار الجزء بنجاح'),
                    backgroundColor: Colors.green),
              );
            }
          },
          child: const Text('تسجيل الاختبار'),
        ),
      ],
    );
  }
}
