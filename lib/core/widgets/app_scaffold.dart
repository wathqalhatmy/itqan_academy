import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// غلاف موحد لجميع شاشات التطبيق.
/// يُطبّق تلقائياً: القيد بالعرض الأقصى + لون الخلفية المناسب للوضع.
///
/// الاستخدام البسيط (مع Scaffold مباشرة):
///   return AppScaffold(child: Scaffold(...));
///
/// الاستخدام مع PopScope أو أي wrapper:
///   return AppScaffold(child: PopScope(...));
class AppScaffold extends StatelessWidget {
  /// المحتوى: Scaffold أو PopScope أو أي Widget يُغلف Scaffold
  final Widget child;

  const AppScaffold({super.key, required this.child});

  /// [لـ backward compatibility] يقبل كلا المعاملين
  /// ignore: non_constant_identifier_names
  static AppScaffold scaffold({Key? key, required Widget scaffold}) =>
      AppScaffold(key: key, child: scaffold);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: child,
        ),
      ),
    );
  }
}
