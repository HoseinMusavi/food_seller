// lib/features/product/domain/repositories/product_repository.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/product/domain/entities/option_group_entity.dart'; // *** ایمپورت جدید ***
import 'package:food_seller/features/product/domain/entities/product_category_entity.dart';
import 'package:food_seller/features/product/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts(int storeId);
  Future<Either<Failure, List<ProductCategoryEntity>>> getCategories(int storeId);
  Future<Either<Failure, void>> updateProductAvailability(
      {required int productId, required bool isAvailable});
  Future<Either<Failure, ProductEntity>> createProduct(ProductEntity product);
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product);

  // *** شروع بخش جدید (مدیریت آپشن‌ها) ***
  Future<Either<Failure, List<OptionGroupEntity>>> getStoreOptionGroups(int storeId);
  Future<Either<Failure, Set<int>>> getLinkedOptionGroupIds(int productId);
  Future<Either<Failure, OptionGroupEntity>> createOptionGroup({required int storeId, required String name});
  Future<Either<Failure, void>> createOption({required int optionGroupId, required String name, required double priceDelta});
  Future<Either<Failure, void>> linkOptionGroupToProduct({required int productId, required int optionGroupId});
  Future<Either<Failure, void>> unlinkOptionGroupFromProduct({required int productId, required int optionGroupId});
  // *** پایان بخش جدید ***
}