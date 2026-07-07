/// ثوابت التطبيق المركزية — يُعدَّل هنا فقط لأي تغيير في المعايير
class AppConstants {
  AppConstants._(); // منع الإنشاء

  // --- معايير الاختبارات والتقييم ---

  /// الحد الأدنى للدرجة المطلوبة لاعتبار اختبار الجزء ناجحاً
  static const double juzPassingScore = 60.0;

  /// حدود التقدير التلقائي (من الأعلى إلى الأدنى)
  static const double excellentThreshold = 90.0;
  static const double veryGoodThreshold  = 80.0;
  static const double goodThreshold      = 70.0;
  // أقل من goodThreshold = مقبول

  // --- معايير الحضور ---

  /// الحد الأدنى لنسبة الحضور المقبولة (%)
  static const double minAcceptableAttendance = 70.0;

  /// عدد الدقائق المسموح به للتأخر قبل اعتباره غياباً
  static const int lateToleranceMinutes = 15;

  // --- قيود الواجهة ---

  /// الحد الأقصى لعرض الصفحة على الويب
  static const double maxPageWidth = 600.0;

  /// توحيد وتطهير النصوص العربية لتسهيل عملية البحث
  static String normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '') // إزالة التشكيل العربي
        .toLowerCase()
        .trim();
  }
}
