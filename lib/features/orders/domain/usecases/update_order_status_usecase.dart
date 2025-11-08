// lib/features/orders/domain/usecases/update_order_status_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:food_seller/features/orders/domain/repositories/order_repository.dart';

class UpdateOrderStatusUseCase implements UseCase<void, UpdateOrderStatusParams> {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateOrderStatusParams params) async {
    return await repository.updateOrderStatus(
      orderId: params.orderId,
      newStatus: params.newStatus,
    );
  }
}

class UpdateOrderStatusParams extends Equatable {
  final int orderId;
  final OrderStatus newStatus;

  const UpdateOrderStatusParams(
      {required this.orderId, required this.newStatus});

  @override
  List<Object?> get props => [orderId, newStatus];
}