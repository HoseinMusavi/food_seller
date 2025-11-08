// lib/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/core/di/service_locator.dart';
import 'package:food_seller/features/auth/presentation/cubit/auth_cubit.dart';
// *** ایمپورت‌های جدید ***
import 'package:food_seller/features/orders/presentation/cubit/order_management_cubit.dart';
import 'package:food_seller/features/orders/presentation/pages/order_dashboard_page.dart';

// --- صفحات موقت برای تب‌های دیگر ---
class MenuPagePlaceholder extends StatelessWidget {
  const MenuPagePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("صفحه مدیریت منو\n(طراحی صفحه ۲)")),
    );
  }
}
class SettingsPagePlaceholder extends StatelessWidget {
  const SettingsPagePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("صفحه تنظیمات\n(طراحی صفحه ۳)")),
    );
  }
}
// --- پایان صفحات موقت ---


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
      // *** جایگزین شد: ***
      const OrderDashboardPage(),  // تب ۰: سفارش‌ها
      const MenuPagePlaceholder(),   // تب ۱: منو
      const SettingsPagePlaceholder(), // تب ۲: تنظیمات
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ما Cubitها را در اینجا فراهم می‌کنیم تا در تمام تب‌ها در دسترس باشند
    return MultiBlocProvider(
      providers: [
        // AuthCubit برای دکمه خروج در صفحه تنظیمات
        BlocProvider(
          create: (context) => sl<AuthCubit>(),
        ),
        // *** OrderManagementCubit اینجا فراهم می‌شود ***
        BlocProvider(
          create: (context) => sl<OrderManagementCubit>(
            param1: widget.storeId, // storeId حیاتی را به Cubit پاس می‌دهیم
          )..loadOrders(), // و بلافاصله دستور بارگذاری سفارش‌ها را می‌دهیم
        ),
        // TODO: در فازهای بعد Cubitهای Menu و Settings را اضافه می‌کنیم
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