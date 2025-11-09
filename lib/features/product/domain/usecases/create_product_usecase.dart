// lib/features/product/domain/usecases/create_product_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/product/domain/entities/product_entity.dart';
import 'package:food_seller/features/product/domain/repositories/product_repository.dart';

class CreateProductUseCase implements UseCase<ProductEntity, ProductEntity> {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(ProductEntity params) async {
    if (params.name.isEmpty || params.price <= 0 || params.storeId == 0) {
      return Left(ServerFailure(message: 'اطلاعات ضروری محصول ناقص است.'));
    }
    return await repository.createProduct(params);
  }
}