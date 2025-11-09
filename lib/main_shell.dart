// lib/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/core/di/service_locator.dart';
import 'package:food_seller/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food_seller/features/orders/presentation/cubit/order_management_cubit.dart';
import 'package:food_seller/features/orders/presentation/pages/order_dashboard_page.dart';
import 'package:food_seller/features/product/presentation/cubit/menu_management_cubit.dart';
import 'package:food_seller/features/product/presentation/pages/menu_management_page.dart';

class SettingsPagePlaceholder extends StatelessWidget {
  const SettingsPagePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("صفحه تنظیمات\n(طراحی صفحه ۳)")),
    );
  }
}

class MainShell extends StatefulWidget {
  final int storeId;
  const MainShell({super.key, required this.storeId});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const OrderDashboardPage(),
      const MenuManagementPage(),
      const SettingsPagePlaceholder(),
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
        BlocProvider(
          create: (context) => sl<AuthCubit>(),
        ),
        BlocProvider(
          create: (context) => sl<OrderManagementCubit>(
            param1: widget.storeId,
          )..loadOrders(),
        ),
        BlocProvider(
          create: (context) => sl<MenuManagementCubit>(
            param1: widget.storeId,
          )..loadMenu(),
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
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[700],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}