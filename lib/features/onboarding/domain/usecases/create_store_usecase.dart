// lib/features/onboarding/domain/usecases/create_store_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/onboarding/domain/repositories/onboarding_repository.dart';

class CreateStoreUseCase implements UseCase<void, CreateStoreParams> {
  final OnboardingRepository repository;
  CreateStoreUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateStoreParams params) async {
    return await repository.createStore(params);
  }
}

class CreateStoreParams extends Equatable {
  final String name;
  final String address;
  final String cuisineType;
  final String deliveryTimeEstimate;
  final double latitude;
  final double longitude;

  const CreateStoreParams({
    required this.name,
    required this.address,
    required this.cuisineType,
    required this.deliveryTimeEstimate,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        name,
        address,
        cuisineType,
        deliveryTimeEstimate,
        latitude,
        longitude
      ];
}