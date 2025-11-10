// lib/features/settings/presentation/cubit/settings_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/orders/domain/entities/store_entity.dart';
import 'package:food_seller/features/orders/data/models/store_model.dart'; // <-- ایمپورت مدل برای copyWith
import 'package:food_seller/features/settings/domain/usecases/get_store_details_usecase.dart';
import 'package:food_seller/features/settings/domain/usecases/update_store_status_usecase.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetStoreDetailsUseCase getStoreDetailsUseCase;
  final UpdateStoreStatusUseCase updateStoreStatusUseCase;
  final int storeId;

  SettingsCubit({
    required this.getStoreDetailsUseCase,
    required this.updateStoreStatusUseCase,
    required this.storeId,
  }) : super(SettingsInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  /// بارگذاری اطلاعات اولیه فروشگاه (is_open)
  Future<void> loadStoreDetails() async {
    emit(SettingsLoading());
    final result =
        await getStoreDetailsUseCase(GetStoreDetailsParams(storeId: storeId));

    result.fold(
      (failure) => emit(SettingsError(_mapFailureToMessage(failure))),
      (store) => emit(SettingsLoaded(store: store)),
    );
  }

  /// آپدیت وضعیت باز/بسته بودن فروشگاه
  Future<void> updateStoreStatus(bool isOpen) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    // لودر را روی Switch فعال کن
    emit(currentState.copyWith(isUpdatingStatus: true));

    final result = await updateStoreStatusUseCase(
      UpdateStoreStatusParams(storeId: storeId, isOpen: isOpen),
    );

    result.fold(
      (failure) {
        // اگر خطا رخ داد، به کاربر اطلاع بده و به حالت قبل برگرد
        emit(SettingsError(_mapFailureToMessage(failure)));
        emit(currentState.copyWith(isUpdatingStatus: false));
      },
      (_) {
        // اگر موفق بود، اطلاعات فروشگاه را با وضعیت جدید آپدیت کن
        // ما باید StoreEntity را به StoreModel کست کنیم تا بتوانیم از copyWith استفاده کنیم
        final updatedStore = (currentState.store as StoreModel).copyWith(isOpen: isOpen);
        emit(SettingsLoaded(store: updatedStore, isUpdatingStatus: false));
      },
    );
  }
}