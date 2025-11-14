// lib/features/settings/domain/repositories/settings_repository.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/orders/domain/entities/store_entity.dart'; // <-- استفاده مجدد از StoreEntity
import 'package:food_seller/features/settings/domain/entities/store_review_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, StoreEntity>> getStoreDetails(int storeId);
  Future<Either<Failure, void>> updateStoreStatus(
      {required int storeId, required bool isOpen});
  Future<Either<Failure, List<StoreReviewEntity>>> getStoreReviews(int storeId);

  // --- شروع بخش جدید ---
  Future<Either<Failure, void>> updateStoreName(
      {required int storeId, required String newName});
  Future<Either<Failure, void>> updateStoreLogoUrl(
      {required int storeId, required String newLogoUrl});
  // --- پایان بخش جدید ---
}