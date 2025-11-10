// lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food_seller/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:food_seller/features/settings/presentation/pages/store_reviews_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // AuthCubit و SettingsCubit هر دو از MainShell فراهم شده‌اند
    final authCubit = context.read<AuthCubit>();
    final settingsCubit = context.read<SettingsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات فروشگاه'),
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading || state is SettingsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            final store = state.store;
            final bool isOpen = store.isOpen;
            
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // *** قابلیت کلیدی: باز/بسته کردن فروشگاه ***
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: isOpen ? theme.colorScheme.primary.withAlpha(40) : theme.colorScheme.error.withAlpha(40),
                  child: SwitchListTile(
                    title: Text(
                      isOpen ? 'فروشگاه شما باز است' : 'فروشگاه شما بسته است',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOpen ? theme.colorScheme.primary : theme.colorScheme.error,
                      ),
                    ),
                    subtitle: Text(
                      isOpen 
                        ? 'مشتریان می‌توانند سفارش ثبت کنند.' 
                        : 'مشتریان نمی‌توانند سفارش ثبت کنند.',
                    ),
                    value: isOpen,
                    onChanged: state.isUpdatingStatus 
                      ? null // اگر در حال آپدیت بود، سوییچ را غیرفعال کن
                      : (newValue) {
                          settingsCubit.updateStoreStatus(newValue);
                        },
                    secondary: state.isUpdatingStatus
                        ? const CircularProgressIndicator()
                        : Icon(
                            isOpen ? Icons.storefront_outlined : Icons.no_food_outlined,
                            size: 30,
                            color: isOpen ? theme.colorScheme.primary : theme.colorScheme.error,
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // --- سایر گزینه‌ها ---
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('ویرایش اطلاعات فروشگاه'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: (فاز ۵) رفتن به صفحه ویرایش اطلاعات فروشگاه
                    // (استفاده مجدد از StoreRegistrationPage در حالت ویرایش)
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.rate_review_outlined),
                  title: const Text('مشاهده نظرات مشتریان'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoreReviewsPage(storeId: store.id),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('تنظیمات اعلان‌ها'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                
                const SizedBox(height: 40),
                
                // --- دکمه خروج از حساب ---
                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: Text(
                    'خروج از حساب کاربری',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () {
                    // (AuthGate به طور خودکار به صفحه لاگین هدایت می‌کند)
                    authCubit.signOut();
                  },
                ),
              ],
            );
          }
          
          return const Center(child: Text('خطا در بارگذاری تنظیمات'));
        },
      ),
    );
  }
}