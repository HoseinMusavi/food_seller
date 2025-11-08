// lib/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/core/di/service_locator.dart';
import 'package:food_seller/features/auth/presentation/cubit/auth_cubit.dart';

// صفحات موقت برای تب‌ها (در فازهای بعد ساخته می‌شوند)
class OrdersPagePlaceholder extends StatelessWidget {
  const OrdersPagePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("صفحه سفارش‌ها\n(طراحی صفحه ۱)")),
    );
  }
}

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
// پایان صفحات موقت


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
      const OrdersPagePlaceholder(), // تب ۰: سفارش‌ها
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
    // ما در اینجا AuthCubit را (که در فاز ۱ ساختیم) فراهم می‌کنیم
    // تا در صفحه تنظیمات بتوانیم از آن برای خروج (Logout) استفاده کنیم
    return BlocProvider(
      create: (context) => sl<AuthCubit>(),
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