// lib/features/accounting/domain/usecases/get_daily_summary_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/accounting/domain/entities/daily_summary_entity.dart';
import 'package:food_seller/features/accounting/domain/repositories/accounting_repository.dart';

class GetDailySummaryUseCase
    implements UseCase<DailySummaryEntity, GetDailySummaryParams> {
  final AccountingRepository repository;
  GetDailySummaryUseCase(this.repository);

  @override
  Future<Either<Failure, DailySummaryEntity>> call(
      GetDailySummaryParams params) async {
    return await repository.getDailySummary(
      storeId: params.storeId,
      date: params.date,
    );
  }
}

class GetDailySummaryParams extends Equatable {
  final int storeId;
  final DateTime date;

  const GetDailySummaryParams({required this.storeId, required this.date});

  @override
  List<Object?> get props => [storeId, date];
}