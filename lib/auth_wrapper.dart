// lib/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/core/di/service_locator.dart';
import 'package:food_seller/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:food_seller/features/onboarding/presentation/pages/pages/store_registration_page.dart';

import 'package:food_seller/main_shell.dart';

/// این ویجت پس از لاگین موفق فراخوانی می‌شود
/// و چک می‌کند که کاربر باید به داشبورد برود یا به فرم ثبت‌نام فروشگاه
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OnboardingCubit>()..checkStoreStatus(),
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطا: ${state.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            // TODO: شاید بخواهیم کاربر را logout کنیم؟
          }
        },
        builder: (context, state) {
          if (state is OnboardingStoreFound) {
            // سناریو ب: فروشگاه دارد -> برو به داشبورد
            return MainShell(storeId: state.storeId);
          }

          if (state is OnboardingNoStoreFound || state is OnboardingStoreRegistering) {
            // سناریو الف: فروشگاه ندارد -> برو به فرم ثبت‌نام
            return const StoreRegistrationPage();
          }

          // حالت پیش‌فرض: در حال بررسی (OnboardingLoading)
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('در حال بررسی اطلاعات فروشگاه...'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}