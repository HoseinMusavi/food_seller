// lib/features/orders/domain/usecases/get_order_details_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:food_seller/features/orders/domain/repositories/order_repository.dart';

class GetOrderDetailsUseCase
    implements UseCase<OrderEntity, GetOrderDetailsParams> {
  final OrderRepository repository;

  GetOrderDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(
      GetOrderDetailsParams params) async {
    return await repository.getOrderDetails(orderId: params.orderId);
  }
}

class GetOrderDetailsParams extends Equatable {
  final int orderId;

  const GetOrderDetailsParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}