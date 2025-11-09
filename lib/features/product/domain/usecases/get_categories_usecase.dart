// lib/features/product/domain/usecases/get_categories_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/product/domain/entities/product_category_entity.dart';
import 'package:food_seller/features/product/domain/repositories/product_repository.dart';

class GetCategoriesUseCase
    implements UseCase<List<ProductCategoryEntity>, GetCategoriesParams> {
  final ProductRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductCategoryEntity>>> call(
      GetCategoriesParams params) async {
    return await repository.getCategories(params.storeId);
  }
}

class GetCategoriesParams extends Equatable {
  final int storeId;

  const GetCategoriesParams({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}