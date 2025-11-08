// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // تعریف ثابت‌های رنگی بر اساس UI/UX اپ فروشنده
  static const Color _primaryColor = Color(0xFF00B16A); // سبز اکشن
  static const Color _secondaryColor = Color(0xFF1E1E1E); // متن اصلی
  static const Color _errorColor = Color(0xFFFF3B30); // قرمز اکشن
  static const Color _backgroundColor = Color(0xFFF8F9FA);
  static const Color _surfaceColor = Colors.white;
  static const Color _neutralColor = Color(0xFF6C757D); // متن ثانویه

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Vazir',
      brightness: Brightness.light,
      scaffoldBackgroundColor: _backgroundColor,

      // ۱. طرح رنگی اصلی (اصلاح شده)
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        secondary: _secondaryColor,
        error: _errorColor,
        surface: _surfaceColor, // جایگزین background
        surfaceDim: _backgroundColor, // استفاده از این برای پس‌زمینه اصلی
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: _secondaryColor, // جایگزین onBackground
        onSurfaceVariant: _neutralColor, // برای متن‌های خنثی
        outline: _neutralColor,
      ),

      // ۲. استایل‌های متنی
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w700, color: _secondaryColor),
        displayMedium: TextStyle(fontWeight: FontWeight.w700, color: _secondaryColor),
        displaySmall: TextStyle(fontWeight: FontWeight.w700, color: _secondaryColor),
        headlineLarge: TextStyle(fontWeight: FontWeight.w700, color: _secondaryColor),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: _secondaryColor),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: _secondaryColor),
        titleLarge: TextStyle(fontWeight: FontWeight.w500, color: _secondaryColor),
        titleMedium: TextStyle(fontWeight: FontWeight.w500, color: _secondaryColor),
        titleSmall: TextStyle(fontWeight: FontWeight.w500, color: _secondaryColor),
        bodyLarge: TextStyle(color: _secondaryColor),
        bodyMedium: TextStyle(color: _neutralColor), // متن ثانیه
        bodySmall: TextStyle(color: _neutralColor),
      ).apply(fontFamily: 'Vazir'),

      // ۳. تم ویجت‌های عمومی
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceColor, // پس‌زمینه سفید برای اپ‌بار
        foregroundColor: _secondaryColor, // آیکون‌ها و عنوان مشکی
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 18, 
          color: _secondaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 1.0,
        color: _surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Vazir',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _neutralColor,
          textStyle: const TextStyle(
            fontFamily: 'Vazir',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: _primaryColor, width: 2.0),
        ),
      ),

      // تب‌بار (اصلاح شده)
      // TabBarTheme -> TabBarThemeData
      tabBarTheme: const TabBarThemeData( 
        labelColor: _primaryColor,
        unselectedLabelColor: _neutralColor,
        indicatorColor: _primaryColor,
        labelStyle: TextStyle(
          fontFamily: 'Vazir',
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Vazir',
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // سوییچ‌ها (اصلاح شده)
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return _primaryColor;
            }
            return Colors.grey[300];
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              // استفاده از withAlpha برای رفع هشدار deprecation
              return _primaryColor.withAlpha(128); 
            }
            return Colors.grey[400];
          },
        ),
      ),
    );
  }
}