// lib/features/onboarding/domain/usecases/check_store_exists_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/onboarding/domain/repositories/onboarding_repository.dart';

class CheckStoreExistsUseCase implements UseCase<int?, NoParams> {
  final OnboardingRepository repository;
  CheckStoreExistsUseCase(this.repository);

  @override
  Future<Either<Failure, int?>> call(NoParams params) async {
    return await repository.checkStoreExists();
  }
}