// lib/features/product/domain/usecases/manage_product_options_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/product/domain/entities/option_group_entity.dart';
import 'package:food_seller/features/product/domain/repositories/product_repository.dart';

// --- ۱. ایجاد گروه جدید ---
class CreateOptionGroupUseCase
    implements UseCase<OptionGroupEntity, CreateOptionGroupParams> {
  final ProductRepository repository;
  CreateOptionGroupUseCase(this.repository);

  @override
  Future<Either<Failure, OptionGroupEntity>> call(
      CreateOptionGroupParams params) async {
    if (params.name.trim().isEmpty) {
      return Left(ServerFailure(message: 'نام گروه نمی‌تواند خالی باشد'));
    }
    return await repository.createOptionGroup(
        storeId: params.storeId, name: params.name);
  }
}
class CreateOptionGroupParams extends Equatable {
  final int storeId;
  final String name;
  const CreateOptionGroupParams({required this.storeId, required this.name});
  @override
  List<Object?> get props => [storeId, name];
}


// --- ۲. ایجاد آپشن جدید در گروه ---
class CreateOptionUseCase implements UseCase<void, CreateOptionParams> {
  final ProductRepository repository;
  CreateOptionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateOptionParams params) async {
     if (params.name.trim().isEmpty) {
      return Left(ServerFailure(message: 'نام گزینه نمی‌تواند خالی باشد'));
    }
    return await repository.createOption(
      optionGroupId: params.optionGroupId,
      name: params.name,
      priceDelta: params.priceDelta,
    );
  }
}
class CreateOptionParams extends Equatable {
  final int optionGroupId;
  final String name;
  final double priceDelta;
  const CreateOptionParams(
      {required this.optionGroupId,
      required this.name,
      required this.priceDelta});
  @override
  List<Object?> get props => [optionGroupId, name, priceDelta];
}


// --- ۳. لینک کردن گروه به محصول ---
class LinkGroupToProductUseCase
    implements UseCase<void, LinkGroupToProductParams> {
  final ProductRepository repository;
  LinkGroupToProductUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LinkGroupToProductParams params) async {
    return await repository.linkOptionGroupToProduct(
      productId: params.productId,
      optionGroupId: params.optionGroupId,
    );
  }
}

// --- ۴. حذف لینک گروه از محصول ---
class UnlinkGroupFromProductUseCase
    implements UseCase<void, LinkGroupToProductParams> {
  final ProductRepository repository;
  UnlinkGroupFromProductUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LinkGroupToProductParams params) async {
    return await repository.unlinkOptionGroupFromProduct(
      productId: params.productId,
      optionGroupId: params.optionGroupId,
    );
  }
}

// (از پارامتر مشترک استفاده می‌کنیم)
class LinkGroupToProductParams extends Equatable {
  final int productId;
  final int optionGroupId;
  const LinkGroupToProductParams(
      {required this.productId, required this.optionGroupId});
  @override
  List<Object?> get props => [productId, optionGroupId];
}