// lib/features/settings/domain/usecases/get_store_reviews_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/settings/domain/entities/store_review_entity.dart';
import 'package:food_seller/features/settings/domain/repositories/settings_repository.dart';

class GetStoreReviewsUseCase
    implements UseCase<List<StoreReviewEntity>, GetStoreReviewsParams> {
  final SettingsRepository repository;
  GetStoreReviewsUseCase(this.repository);

  @override
  Future<Either<Failure, List<StoreReviewEntity>>> call(
      GetStoreReviewsParams params) async {
    return await repository.getStoreReviews(params.storeId);
  }
}

class GetStoreReviewsParams extends Equatable {
  final int storeId;
  const GetStoreReviewsParams({required this.storeId});
  @override
  List<Object?> get props => [storeId];
}