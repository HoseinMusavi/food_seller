// lib/features/orders/domain/usecases/get_orders_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:food_seller/features/orders/domain/repositories/order_repository.dart';

class GetOrdersUseCase
    implements UseCase<List<OrderEntity>, GetOrdersParams> {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(
      GetOrdersParams params) async {
    return await repository.getOrders(
      storeId: params.storeId,
      statuses: params.statuses,
    );
  }
}

class GetOrdersParams extends Equatable {
  final int storeId;
  final List<OrderStatus> statuses;

  const GetOrdersParams({required this.storeId, required this.statuses});

  @override
  List<Object?> get props => [storeId, statuses];
}