// lib/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/core/di/service_locator.dart';
import 'package:food_seller/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food_seller/features/orders/presentation/cubit/order_management_cubit.dart';
import 'package:food_seller/features/orders/presentation/pages/order_dashboard_page.dart';
import 'package:food_seller/features/product/presentation/cubit/menu_management_cubit.dart';
import 'package:food_seller/features/product/presentation/pages/menu_management_page.dart';
import 'package:food_seller/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:food_seller/features/settings/presentation/pages/settings_page.dart';

// --- ایمپورت‌های جدید ---
import 'package:food_seller/features/accounting/presentation/cubit/accounting_cubit.dart';
import 'package:food_seller/features/accounting/presentation/pages/accounting_page.dart';
// ---

class MainShell extends StatefulWidget {
  final int storeId; // ID فروشگاه را از AuthWrapper دریافت می‌کنیم
  const MainShell({super.key, required this.storeId});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0; // شروع از تب سفارش‌ها

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const OrderDashboardPage(), // تب ۰: سفارش‌ها
      const MenuManagementPage(), // تب ۱: منو
      // --- بخش جدید ---
      const AccountingPage(), // تب ۲: حسابداری
      // ---
      const SettingsPage(), // تب ۳: تنظیمات
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthCubit (برای دکمه خروج)
        BlocProvider(
          create: (context) => sl<AuthCubit>(),
        ),
        // Cubit سفارش‌ها
        BlocProvider(
          create: (context) => sl<OrderManagementCubit>(
            param1: widget.storeId,
          )..loadOrders(),
        ),
        // Cubit منو
        BlocProvider(
          create: (context) => sl<MenuManagementCubit>(
            param1: widget.storeId,
          )..loadMenu(),
        ),

        // Cubit تنظیمات
        BlocProvider(
          create: (context) => sl<SettingsCubit>(
            param1: widget.storeId,
          )..loadStoreDetails(),
        ),
        
        // --- Cubit جدید برای حسابداری ---
        BlocProvider(
          create: (context) => sl<AccountingCubit>(
            param1: widget.storeId,
          )..loadAccountingData(), // ..loadAccountingData() را فراخوانی می‌کند
        ),
        // ---
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        // --- بخش اصلاح شده ---
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'سفارش‌ها',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'منو',
            ),
            // --- تب جدید ---
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'حسابداری',
            ),
            // ---
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'تنظیمات',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[700],
          onTap: _onItemTapped,
        ),
        // --- پایان بخش اصلاح شده ---
      ),
    );
  }
}