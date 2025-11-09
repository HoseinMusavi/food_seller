// lib/features/product/domain/usecases/get_linked_option_groups_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/product/domain/repositories/product_repository.dart';

class GetLinkedOptionGroupIdsUseCase
    implements UseCase<Set<int>, GetLinkedOptionGroupIdsParams> {
  final ProductRepository repository;

  GetLinkedOptionGroupIdsUseCase(this.repository);

  @override
  Future<Either<Failure, Set<int>>> call(
      GetLinkedOptionGroupIdsParams params) async {
    return await repository.getLinkedOptionGroupIds(params.productId);
  }
}

class GetLinkedOptionGroupIdsParams extends Equatable {
  final int productId;
  const GetLinkedOptionGroupIdsParams({required this.productId});
  @override
  List<Object?> get props => [productId];
}