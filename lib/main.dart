// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- فایل‌های پروژه جدید ---
import 'package:food_seller/core/di/service_locator.dart' as di;
import 'package:food_seller/core/theme/app_theme.dart';
import 'package:food_seller/features/auth/presentation/pages/login_page.dart';
import 'package:food_seller/auth_wrapper.dart'; // <-- مسیریاب هوشمند جدید

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zjtnzzammmyuagxatwgf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqdG56emFtbW15dWFneGF0d2dmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQwNzI5NjksImV4cCI6MjA2OTY0ODk2OX0.arRyVtvhA0w5xdopkQC8bRZ0hnKKtIJIaXtYkoKMbJw',
  );

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اپ فروشنده فود اپ',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

// --- AuthGate (دروازه احراز هویت) - نسخه نهایی ---
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          // کاربر لاگین است -> وضعیت فروشگاه او را چک کن
          return const AuthWrapper();
        } else {
          // کاربر لاگین نیست -> به صفحه ورود بفرست
          return const LoginPage();
        }
      },
    );
  }
}