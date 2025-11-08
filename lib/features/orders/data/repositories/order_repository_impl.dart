// lib/features/orders/data/repositories/order_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/exceptions.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:food_seller/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders(
      {required int storeId, required List<OrderStatus> statuses}) async {
    try {
      final orderModels =
          await remoteDataSource.getOrders(storeId: storeId, statuses: statuses);
      return Right(orderModels); // مدل‌ها همان انتیتی هستند
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Stream<List<OrderEntity>>>> listenToOrderChanges(
      {required int storeId}) async {
    try {
      final stream = remoteDataSource.listenToOrderChanges(storeId: storeId);
      return Right(stream);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetails(
      {required int orderId}) async {
    try {
      final orderModel = await remoteDataSource.getOrderDetails(orderId: orderId);
      return Right(orderModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
      {required int orderId, required OrderStatus newStatus}) async {
    try {
      await remoteDataSource.updateOrderStatus(
          orderId: orderId, newStatus: newStatus);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}