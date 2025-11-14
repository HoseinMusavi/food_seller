// lib/features/accounting/domain/usecases/get_sales_history_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/accounting/domain/entities/daily_summary_entity.dart';
import 'package:food_seller/features/accounting/domain/repositories/accounting_repository.dart';

class GetSalesHistoryUseCase
    implements UseCase<List<DailySummaryEntity>, GetSalesHistoryParams> {
  final AccountingRepository repository;
  GetSalesHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<DailySummaryEntity>>> call(
      GetSalesHistoryParams params) async {
    return await repository.getSalesHistory(
      storeId: params.storeId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetSalesHistoryParams extends Equatable {
  final int storeId;
  final DateTime startDate;
  final DateTime endDate;

  const GetSalesHistoryParams(
      {required this.storeId,
      required this.startDate,
      required this.endDate});

  @override
  List<Object?> get props => [storeId, startDate, endDate];
}