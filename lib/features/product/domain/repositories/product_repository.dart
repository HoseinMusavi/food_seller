// lib/features/product/domain/repositories/product_repository.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/product/domain/entities/product_category_entity.dart';
import 'package:food_seller/features/product/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts(int storeId);
  Future<Either<Failure, List<ProductCategoryEntity>>> getCategories(int storeId);
  Future<Either<Failure, void>> updateProductAvailability(
      {required int productId, required bool isAvailable});
  Future<Either<Failure, ProductEntity>> createProduct(ProductEntity product);
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product);
}