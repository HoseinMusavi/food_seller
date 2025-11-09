// lib/features/product/data/repositories/product_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/exceptions.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/product/data/datasources/product_remote_datasource.dart';
import 'package:food_seller/features/product/data/models/product_model.dart';
import 'package:food_seller/features/product/domain/entities/product_category_entity.dart';
import 'package:food_seller/features/product/domain/entities/product_entity.dart';
import 'package:food_seller/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  // ... (متدهای getCategories, getProducts, updateProductAvailability, createProduct بدون تغییر) ...
  @override
  Future<Either<Failure, List<ProductCategoryEntity>>> getCategories(
      int storeId) async {
    try {
      final models = await remoteDataSource.getCategories(storeId);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts(int storeId) async {
    try {
      final models = await remoteDataSource.getProducts(storeId);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateProductAvailability(
      {required int productId, required bool isAvailable}) async {
    try {
      await remoteDataSource.updateProductAvailability(
          productId: productId, isAvailable: isAvailable);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
      ProductEntity product) async {
    try {
      final productModel = ProductModel(
        id: product.id,
        storeId: product.storeId,
        name: product.name,
        description: product.description,
        price: product.price,
        discountPrice: product.discountPrice,
        imageUrl: product.imageUrl,
        isAvailable: product.isAvailable,
        categoryId: product.categoryId,
        categoryName: product.categoryName,
      );

      final newProduct = await remoteDataSource.createProduct(productModel);
      return Right(newProduct);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // *** پیاده‌سازی متد جدید ***
  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
      ProductEntity product) async {
    try {
      final productModel = ProductModel(
        id: product.id,
        storeId: product.storeId,
        name: product.name,
        description: product.description,
        price: product.price,
        discountPrice: product.discountPrice,
        imageUrl: product.imageUrl,
        isAvailable: product.isAvailable,
        categoryId: product.categoryId,
        categoryName: product.categoryName,
      );
      final updatedProduct = await remoteDataSource.updateProduct(productModel);
      return Right(updatedProduct);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}