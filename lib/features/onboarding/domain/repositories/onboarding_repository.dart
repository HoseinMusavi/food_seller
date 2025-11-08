// lib/features/onboarding/domain/repositories/onboarding_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../usecases/create_store_usecase.dart'; // (به زودی ساخته می‌شود)

abstract class OnboardingRepository {
  Future<Either<Failure, int?>> checkStoreExists();
  Future<Either<Failure, void>> createStore(CreateStoreParams params);
}