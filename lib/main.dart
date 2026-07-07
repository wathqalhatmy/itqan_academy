import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/academy_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AcademyProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const ItqanAcademyApp(),
    ),
  );
}

class ItqanAcademyApp extends StatefulWidget {
  const ItqanAcademyApp({super.key});

  @override
  State<ItqanAcademyApp> createState() => ItqanAcademyAppState();

  static ItqanAcademyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<ItqanAcademyAppState>()!;
}

class ItqanAcademyAppState extends State<ItqanAcademyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أكاديمية إتقان',
      debugShowCheckedModeBanner: false,

      // إعدادات اللغة العربية ودعم RTL
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [Locale('ar', 'AE')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // تطبيق السمات الاحترافية
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      // الشاشة الرئيسية للتطبيق مع حماية الدخول
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const DashboardScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
