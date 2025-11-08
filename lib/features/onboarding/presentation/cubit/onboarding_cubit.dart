// lib/features/onboarding/presentation/cubit/onboarding_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/onboarding/domain/usecases/check_store_exists_usecase.dart';
import 'package:food_seller/features/onboarding/domain/usecases/create_store_usecase.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final CheckStoreExistsUseCase checkStoreExistsUseCase;
  final CreateStoreUseCase createStoreUseCase;

  OnboardingCubit({
    required this.checkStoreExistsUseCase,
    required this.createStoreUseCase,
  }) : super(OnboardingLoading());

  /// این متد چک می‌کند که آیا کاربر فروشگاه دارد یا خیر
  Future<void> checkStoreStatus() async {
    emit(OnboardingLoading());
    final failureOrStoreId = await checkStoreExistsUseCase(NoParams());

    failureOrStoreId.fold(
      (failure) =>
          emit(OnboardingError(message: _mapFailureToMessage(failure))),
      (storeId) {
        if (storeId != null) {
          emit(OnboardingStoreFound(storeId: storeId));
        } else {
          emit(OnboardingNoStoreFound());
        }
      },
    );
  }

  /// این متد فروشگاه جدید را ثبت می‌کند
  Future<void> registerStore(CreateStoreParams params) async {
    emit(OnboardingStoreRegistering());
    final failureOrSuccess = await createStoreUseCase(params);

    failureOrSuccess.fold(
      (failure) =>
          emit(OnboardingError(message: _mapFailureToMessage(failure))),
      (_) {
        // پس از موفقیت، دوباره وضعیت را چک می‌کنیم
        // که این بار OnboardingStoreFound را برمی‌گرداند
        checkStoreStatus();
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'An unknown error occurred';
  }
}