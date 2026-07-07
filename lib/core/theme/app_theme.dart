import 'package:flutter/material.dart';

class AppTheme {
  // ألوان الهوية الرئيسية (الزمردي الفاخر والذهبي الملكي)
  static const Color primaryLight = Color(0xFF053E2A); // زمردي داكن
  static const Color primaryContainerLight = Color(0xFF0A5C3E); // زمردي متوسط
  static const Color secondaryLight = Color(0xFFC5A880); // ذهبي شامبين
  static const Color accentGold = Color(0xFFD4AF37); // ذهبي برّاق للأوسمة
  static const Color backgroundLight = Color(0xFFF4F7F5); // خلفية ثلجية زمردية ناعمة

  static const Color onSurfaceLight = Color(0xFF15201B);
  static const Color onSurfaceVariantLight = Color(0xFF42524A);

  // ألوان الوضع الداكن
  static const Color primaryDark = Color(0xFF14C18A); // زمردي مضيء ومريح للعين
  static const Color primaryContainerDark = Color(0xFF053E2A);
  static const Color secondaryDark = Color(0xFFDCD2C4);
  static const Color backgroundDark = Color(0xFF0B120F); // خلفية داكنة جداً بلمحة زمردية عميقة
  static const Color surfaceDark = Color(0xFF121B17); // أسطح البطاقات داكنة
  static const Color onSurfaceDark = Color(0xFFE4E9E6);
  static const Color onSurfaceVariantDark = Color(0xFFA2B0AA);

  // --- ألوان معنوية موحدة (Semantic Colors) ---
  static const Color successGreen = Color(0xFF2E7D32); // حاضر / متقن / ممتاز
  static const Color warningOrange = Color(0xFFEF6C00); // متأخر / مراجعة / جيد جداً
  static const Color errorRed = Color(0xFFC62828); // غائب / مقبول
  static const Color infoBlue = Color(0xFF1565C0); // بعذر / تلاوة / جيد
  static const Color alphabetsPurple = Color(0xFF6A1B9A); // تهجي / هجاء

  // سمة الوضع الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Tajawal',
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        primaryContainer: primaryContainerLight,
        secondary: secondaryLight,
        tertiary: accentGold,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF15201B),
        onSurface: onSurfaceLight,
        onSurfaceVariant: onSurfaceVariantLight,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 26,
          color: primaryLight,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: primaryLight,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: onSurfaceLight,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: onSurfaceVariantLight,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: secondaryLight,
        ),
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // سمة الوضع الداكن
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Tajawal',
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        primaryContainer: primaryContainerDark,
        secondary: secondaryDark,
        tertiary: accentGold,
        surface: surfaceDark,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: onSurfaceDark,
        onSurfaceVariant: onSurfaceVariantDark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 26,
          color: primaryDark,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: onSurfaceDark,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: onSurfaceDark,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: onSurfaceVariantDark,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: secondaryDark,
        ),
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: onSurfaceDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: onSurfaceDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
