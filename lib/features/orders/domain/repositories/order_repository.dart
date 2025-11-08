// lib/features/orders/domain/repositories/order_repository.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders(
      {required int storeId, required List<OrderStatus> statuses});

  Future<Either<Failure, Stream<List<OrderEntity>>>> listenToOrderChanges(
      {required int storeId});

  Future<Either<Failure, void>> updateOrderStatus(
      {required int orderId, required OrderStatus newStatus});

  Future<Either<Failure, OrderEntity>> getOrderDetails({required int orderId});
}