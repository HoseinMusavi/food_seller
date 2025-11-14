// lib/features/settings/presentation/cubit/settings_cubit.dart
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/domain/usecases/upload_image_usecase.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/orders/domain/entities/store_entity.dart';
import 'package:food_seller/features/orders/data/models/store_model.dart';
import 'package:food_seller/features/settings/domain/usecases/get_store_details_usecase.dart';
import 'package:food_seller/features/settings/domain/usecases/update_store_logo_url_usecase.dart';
import 'package:food_seller/features/settings/domain/usecases/update_store_name_usecase.dart';
import 'package:food_seller/features/settings/domain/usecases/update_store_status_usecase.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetStoreDetailsUseCase getStoreDetailsUseCase;
  final UpdateStoreStatusUseCase updateStoreStatusUseCase;
  final UpdateStoreNameUseCase updateStoreNameUseCase;
  final UploadImageUseCase uploadImageUseCase;
  final UpdateStoreLogoUrlUseCase updateStoreLogoUrlUseCase;
  final int storeId;

  SettingsCubit({
    required this.getStoreDetailsUseCase,
    required this.updateStoreStatusUseCase,
    required this.updateStoreNameUseCase,
    required this.uploadImageUseCase,
    required this.updateStoreLogoUrlUseCase,
    required this.storeId,
  }) : super(SettingsInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  Future<void> loadStoreDetails() async {
    final currentState = state;
    if (currentState is! SettingsLoaded) {
      emit(SettingsLoading());
    }
    final result =
        await getStoreDetailsUseCase(GetStoreDetailsParams(storeId: storeId));

    result.fold(
      (failure) => emit(SettingsError(_mapFailureToMessage(failure))),
      (store) => emit(SettingsLoaded(store: store)),
    );
  }

  Future<void> updateStoreStatus(bool isOpen) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(currentState.copyWith(isUpdatingStatus: true));

    final result = await updateStoreStatusUseCase(
      UpdateStoreStatusParams(storeId: storeId, isOpen: isOpen),
    );

    result.fold(
      (failure) {
        emit(SettingsError(_mapFailureToMessage(failure)));
        emit(currentState.copyWith(isUpdatingStatus: false));
      },
      (_) {
        final updatedStore =
            (currentState.store as StoreModel).copyWith(isOpen: isOpen);
        emit(SettingsLoaded(store: updatedStore, isUpdatingStatus: false));
      },
    );
  }

  Future<void> updateStoreName(String newName) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(currentState.copyWith(isUpdatingStatus: true));

    final result = await updateStoreNameUseCase(
      UpdateStoreNameParams(storeId: storeId, newName: newName),
    );

    result.fold(
      (failure) {
        emit(SettingsError(_mapFailureToMessage(failure)));
        emit(currentState.copyWith(isUpdatingStatus: false));
      },
      (_) {
        final updatedStore =
            (currentState.store as StoreModel).copyWith(name: newName);
        emit(SettingsLoaded(store: updatedStore, isUpdatingStatus: false));
      },
    );
  }

  /// آپدیت عکس پروفایل فروشگاه
  Future<void> updateStoreImage(File imageFile) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(currentState.copyWith(isUpdatingStatus: true));

    // --- شروع بخش اصلاح شده ---
    // ۱. آپلود عکس
    // (کلاس صحیح UploadFileParams و پارامترهای صحیح file و bucketName استفاده شد)
    // (کلمه const حذف شد چون imageFile یک متغیر است)
    final uploadResult = await uploadImageUseCase(UploadFileParams(
      file: imageFile,
      bucketName: 'store-logos', // نام Bucket در Supabase
    ));
    // --- پایان بخش اصلاح شده ---

    await uploadResult.fold(
      (failure) {
        // خطا در آپلود
        emit(SettingsError(_mapFailureToMessage(failure)));
        emit(currentState.copyWith(isUpdatingStatus: false));
      },
      (newUrl) async {
        // ۲. آپدیت URL در جدول stores
        final updateResult = await updateStoreLogoUrlUseCase(
            UpdateStoreLogoUrlParams(storeId: storeId, newLogoUrl: newUrl));

        updateResult.fold(
          (failure) {
            // خطا در آپدیت دیتابیس
            emit(SettingsError(_mapFailureToMessage(failure)));
            emit(currentState.copyWith(isUpdatingStatus: false));
          },
          (_) {
            // موفقیت کامل!
            final updatedStore =
                (currentState.store as StoreModel).copyWith(logoUrl: newUrl);
            emit(SettingsLoaded(store: updatedStore, isUpdatingStatus: false));
          },
        );
      },
    );
  }
}