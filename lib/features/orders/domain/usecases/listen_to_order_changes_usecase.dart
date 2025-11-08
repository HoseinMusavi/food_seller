// lib/features/orders/domain/usecases/listen_to_order_changes_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:food_seller/features/orders/domain/repositories/order_repository.dart';

class ListenToOrderChangesUseCase
    implements UseCase<Stream<List<OrderEntity>>, ListenToOrdersParams> {
  final OrderRepository repository;

  ListenToOrderChangesUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<List<OrderEntity>>>> call(
      ListenToOrdersParams params) async {
    return await repository.listenToOrderChanges(storeId: params.storeId);
  }
}

class ListenToOrdersParams extends Equatable {
  final int storeId;

  const ListenToOrdersParams({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}