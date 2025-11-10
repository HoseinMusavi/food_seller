// lib/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/core/di/service_locator.dart';
import 'package:food_seller/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food_seller/features/orders/presentation/cubit/order_management_cubit.dart';
import 'package:food_seller/features/orders/presentation/pages/order_dashboard_page.dart';
import 'package:food_seller/features/product/presentation/cubit/menu_management_cubit.dart';
import 'package:food_seller/features/product/presentation/pages/menu_management_page.dart';
// *** ایمپورت‌های جدید Settings ***
import 'package:food_seller/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:food_seller/features/settings/presentation/pages/settings_page.dart';


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
      
      // *** جایگزین شد: ***
      const SettingsPage(),       // تب ۲: تنظیمات
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
        // Cubit سفارش‌ها (از فاز ۲)
        BlocProvider(
          create: (context) => sl<OrderManagementCubit>(
            param1: widget.storeId,
          )..loadOrders(),
        ),
        // Cubit منو (از فاز ۳)
        BlocProvider(
          create: (context) => sl<MenuManagementCubit>(
            param1: widget.storeId,
          )..loadMenu(),
        ),
        
        // *** Cubit جدید برای تنظیمات ***
        BlocProvider(
          create: (context) => sl<SettingsCubit>(
            param1: widget.storeId,
          )..loadStoreDetails(), // ..loadStoreDetails() را بلافاصله فراخوانی می‌کند
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'تنظیمات',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary, // سبز
          unselectedItemColor: Colors.grey[700],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}