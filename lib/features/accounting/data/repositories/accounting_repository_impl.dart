// lib/features/accounting/data/repositories/accounting_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/exceptions.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/accounting/data/datasources/accounting_remote_datasource.dart';
import 'package:food_seller/features/accounting/domain/entities/daily_summary_entity.dart';
import 'package:food_seller/features/accounting/domain/repositories/accounting_repository.dart';

class AccountingRepositoryImpl implements AccountingRepository {
  final AccountingRemoteDataSource remoteDataSource;

  AccountingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DailySummaryEntity>> getDailySummary(
      {required int storeId, required DateTime date}) async {
    try {
      // --- اصلاح شد: استفاده از پارامتر نام‌دار ---
      final model =
          await remoteDataSource.getDailySummary(storeId: storeId, date: date);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<DailySummaryEntity>>> getSalesHistory(
      {required int storeId,
      required DateTime startDate,
      required DateTime endDate}) async {
    try {
      // --- اصلاح شد: استفاده از پارامتر نام‌دار ---
      final models = await remoteDataSource.getSalesHistory(
          storeId: storeId, startDate: startDate, endDate: endDate);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}