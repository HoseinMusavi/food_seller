// lib/features/accounting/domain/repositories/accounting_repository.dart
import 'package:dartz/dartz.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/accounting/domain/entities/daily_summary_entity.dart';

abstract class AccountingRepository {
  Future<Either<Failure, DailySummaryEntity>> getDailySummary(
      {required int storeId, required DateTime date});

  Future<Either<Failure, List<DailySummaryEntity>>> getSalesHistory(
      {required int storeId,
      required DateTime startDate,
      required DateTime endDate});
}