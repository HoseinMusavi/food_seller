// lib/features/onboarding/data/repositories/onboarding_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/exceptions.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:food_seller/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:food_seller/features/onboarding/domain/usecases/create_store_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient; // برای گرفتن ownerId

  OnboardingRepositoryImpl(
      {required this.remoteDataSource, required this.supabaseClient});

  @override
  Future<Either<Failure, int?>> checkStoreExists() async {
    try {
      final storeId = await remoteDataSource.getStoreIdForCurrentUser();
      return Right(storeId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> createStore(CreateStoreParams params) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return Left(ServerFailure(message: 'User not authenticated'));
      }
      await remoteDataSource.createStore(
        name: params.name,
        address: params.address,
        cuisineType: params.cuisineType,
        deliveryTimeEstimate: params.deliveryTimeEstimate,
        latitude: params.latitude,
        longitude: params.longitude,
        ownerId: userId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}