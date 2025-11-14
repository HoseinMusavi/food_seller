// lib/features/settings/presentation/pages/settings_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:food_seller/core/widgets/custom_network_image.dart'; // <-- حذف شد
import 'package:food_seller/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food_seller/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:food_seller/features/settings/presentation/pages/store_reviews_page.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authCubit = context.read<AuthCubit>();
    final settingsCubit = context.read<SettingsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات فروشگاه'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => settingsCubit.loadStoreDetails(),
          ),
        ],
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

            // ویجت لودر
            final pageLoader = state.isUpdatingStatus
                ? Container(
                    // --- اصلاح شد: استفاده از .withAlpha() به جای .withOpacity() ---
                    color: Colors.black.withAlpha((255 * 0.1).round()),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // --- بخش جدید: نمایش اطلاعات (اصلاح شده) ---
                    Center(
                      child: Stack(
                        children: [
                          // --- اصلاح شد: استفاده از CircleAvatar استاندارد ---
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            backgroundImage: (store.logoUrl != null &&
                                    store.logoUrl!.isNotEmpty)
                                ? NetworkImage(store.logoUrl!)
                                : null,
                            child: (store.logoUrl == null ||
                                    store.logoUrl!.isEmpty)
                                ? Icon(
                                    Icons.storefront_outlined,
                                    size: 50,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                          // ---
                          Positioned(
                            bottom: 0,
                            left: 0, // تغییر به چپ برای ظاهر فارسی
                            child: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt_outlined,
                                    size: 20, color: Colors.white),
                                onPressed: state.isUpdatingStatus
                                    ? null // غیرفعال در زمان لود
                                    : () => _pickImage(context, settingsCubit),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            store.name,
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: state.isUpdatingStatus
                                ? null // غیرفعال در زمان لود
                                : () => _editName(
                                    context, settingsCubit, store.name),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- قابلیت کلیدی: باز/بسته کردن فروشگاه ---
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: isOpen
                          ? theme.colorScheme.primary.withAlpha(40)
                          : theme.colorScheme.error.withAlpha(40),
                      child: SwitchListTile(
                        title: Text(
                          isOpen ? 'فروشگاه شما باز است' : 'فروشگاه شما بسته است',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isOpen
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
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
                        secondary: Icon(
                          isOpen
                              ? Icons.storefront_outlined
                              : Icons.no_food_outlined,
                          size: 30,
                          color: isOpen
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- سایر گزینه‌ها ---
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
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('ویرایش اطلاعات فروشگاه (بزودی)'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: (فاز ۵) رفتن به صفحه ویرایش اطلاعات فروشگاه
                      },
                    ),

                    const SizedBox(height: 40),

                    // --- دکمه خروج از حساب ---
                    ListTile(
                      leading:
                          Icon(Icons.logout, color: theme.colorScheme.error),
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
                ),

                // لودر سراسری
                pageLoader,
              ],
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('خطا در بارگذاری تنظیمات'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => settingsCubit.loadStoreDetails(),
                  child: const Text('تلاش مجدد'),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // --- متدهای کمکی برای ویرایش نام و عکس ---

  void _pickImage(BuildContext context, SettingsCubit cubit) async {
    final ImagePicker picker = ImagePicker();
    // استفاده از گالری
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      cubit.updateStoreImage(File(image.path));
    }
  }

  void _editName(
      BuildContext context, SettingsCubit cubit, String currentName) {
    final TextEditingController controller =
        TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تغییر نام فروشگاه'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'نام جدید'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty && newName != currentName) {
                  cubit.updateStoreName(newName);
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('ذخیره'),
            ),
          ],
        );
      },
    );
  }
}