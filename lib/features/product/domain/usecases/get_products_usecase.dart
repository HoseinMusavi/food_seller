// lib/features/product/domain/usecases/get_products_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/product/domain/entities/product_entity.dart';
import 'package:food_seller/features/product/domain/repositories/product_repository.dart';

class GetProductsUseCase
    implements UseCase<List<ProductEntity>, GetProductsParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(
      GetProductsParams params) async {
    return await repository.getProducts(params.storeId);
  }
}

class GetProductsParams extends Equatable {
  final int storeId;

  const GetProductsParams({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}