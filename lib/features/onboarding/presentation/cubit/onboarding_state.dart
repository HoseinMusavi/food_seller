// lib/features/onboarding/presentation/cubit/onboarding_state.dart
part of 'onboarding_cubit.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();
  @override
  List<Object?> get props => [];
}

// حالت اولیه، در حال بررسی
class OnboardingLoading extends OnboardingState {}

// کاربر فروشگاه دارد و به داشبورد هدایت می‌شود
class OnboardingStoreFound extends OnboardingState {
  final int storeId;
  const OnboardingStoreFound({required this.storeId});
  @override
  List<Object?> get props => [storeId];
}

// کاربر فروشگاه ندارد و به فرم ثبت‌نام هدایت می‌شود
class OnboardingNoStoreFound extends OnboardingState {}

// در حال ثبت فروشگاه جدید
class OnboardingStoreRegistering extends OnboardingState {}

// خطا در بررسی یا ثبت
class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError({required this.message});
  @override
  List<Object?> get props => [message];
}