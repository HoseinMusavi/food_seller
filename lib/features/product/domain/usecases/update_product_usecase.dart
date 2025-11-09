// lib/features/product/domain/usecases/update_product_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/product/domain/entities/product_entity.dart';
import 'package:food_seller/features/product/domain/repositories/product_repository.dart';

class UpdateProductUseCase implements UseCase<ProductEntity, ProductEntity> {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(ProductEntity params) async {
    if (params.name.isEmpty || params.price <= 0 || params.id == 0) {
      return Left(ServerFailure(message: 'اطلاعات محصول برای ویرایش ناقص است.'));
    }
    return await repository.updateProduct(params);
  }
}