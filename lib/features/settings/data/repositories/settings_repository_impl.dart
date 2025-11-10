// lib/features/settings/data/repositories/settings_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/exceptions.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/orders/domain/entities/store_entity.dart';
import 'package:food_seller/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:food_seller/features/settings/domain/entities/store_review_entity.dart';
import 'package:food_seller/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;
  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StoreEntity>> getStoreDetails(int storeId) async {
    try {
      final storeModel = await remoteDataSource.getStoreDetails(storeId);
      return Right(storeModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
  
  @override
  Future<Either<Failure, List<StoreReviewEntity>>> getStoreReviews(int storeId) async {
     try {
      final reviewModels = await remoteDataSource.getStoreReviews(storeId);
      return Right(reviewModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateStoreStatus({required int storeId, required bool isOpen}) async {
     try {
      await remoteDataSource.updateStoreStatus(storeId: storeId, isOpen: isOpen);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}