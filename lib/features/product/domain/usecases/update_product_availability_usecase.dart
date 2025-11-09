// lib/features/product/domain/usecases/update_product_availability_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/product/domain/repositories/product_repository.dart';

class UpdateProductAvailabilityUseCase
    implements UseCase<void, UpdateAvailabilityParams> {
  final ProductRepository repository;

  UpdateProductAvailabilityUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
      UpdateAvailabilityParams params) async {
    return await repository.updateProductAvailability(
      productId: params.productId,
      isAvailable: params.isAvailable,
    );
  }
}

class UpdateAvailabilityParams extends Equatable {
  final int productId;
  final bool isAvailable;

  const UpdateAvailabilityParams(
      {required this.productId, required this.isAvailable});

  @override
  List<Object?> get props => [productId, isAvailable];
}