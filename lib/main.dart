// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_seller/features/product/domain/entities/product_category_entity.dart';
import 'package:food_seller/features/product/presentation/pages/product_editor_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // *** ایمپورت Bloc ***

import 'package:food_seller/core/di/service_locator.dart' as di;
import 'package:food_seller/core/theme/app_theme.dart';
import 'package:food_seller/features/auth/presentation/pages/login_page.dart';
import 'package:food_seller/auth_wrapper.dart'; 
// *** ایمپورت Cubit ***
import 'package:food_seller/features/product/presentation/cubit/menu_management_cubit.dart';

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
      // *** فعال کردن onGenerateRoute ***
      onGenerateRoute: _onGenerateRoute, 
    );
  }

  // *** تابع مسیریابی جدید ***
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/add-product':
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final int? storeId = args['storeId'];
          final List<ProductCategoryEntity>? categories = args['categories'];
          final MenuManagementCubit? menuCubit = args['menuCubit'];

          if (storeId != null && categories != null && menuCubit != null) {
            return MaterialPageRoute(
              // ما Cubit صفحه "منو" را به صفحه "ویرایشگر" می‌دهیم
              // تا پس از ذخیره، بتوانیم آن را رفرش کنیم
              builder: (_) => BlocProvider.value(
                value: menuCubit,
                child: ProductEditorPage(
                  storeId: storeId,
                  categories: categories,
                ),
              ),
            );
          }
        }
        return _errorRoute();

      // (در آینده)
      // case '/edit-product':
      //   ...
      //   return MaterialPageRoute(...)

      default:
        return null;
    }
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطا')),
        body: const Center(child: Text('خطا در بارگذاری صفحه')),
      );
    });
  }
}

// --- AuthGate (بدون تغییر) ---
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          return const AuthWrapper();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}