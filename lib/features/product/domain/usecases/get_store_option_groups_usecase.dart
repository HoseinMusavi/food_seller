// lib/features/product/domain/usecases/get_store_option_groups_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/product/domain/entities/option_group_entity.dart';
import 'package:food_seller/features/product/domain/repositories/product_repository.dart';

class GetStoreOptionGroupsUseCase
    implements UseCase<List<OptionGroupEntity>, GetStoreOptionGroupsParams> {
  final ProductRepository repository;

  GetStoreOptionGroupsUseCase(this.repository);

  @override
  Future<Either<Failure, List<OptionGroupEntity>>> call(
      GetStoreOptionGroupsParams params) async {
    return await repository.getStoreOptionGroups(params.storeId);
  }
}

class GetStoreOptionGroupsParams extends Equatable {
  final int storeId;
  const GetStoreOptionGroupsParams({required this.storeId});
  @override
  List<Object?> get props => [storeId];
}