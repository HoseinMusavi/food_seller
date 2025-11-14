// lib/features/accounting/presentation/cubit/accounting_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart'; // <-- ایمپورت جدید
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/accounting/domain/entities/daily_summary_entity.dart';
import 'package:food_seller/features/accounting/domain/usecases/get_daily_summary_usecase.dart';
import 'package:food_seller/features/accounting/domain/usecases/get_sales_history_usecase.dart';

part 'accounting_state.dart';

class AccountingCubit extends Cubit<AccountingState> {
  final GetDailySummaryUseCase getDailySummaryUseCase;
  final GetSalesHistoryUseCase getSalesHistoryUseCase;
  final int storeId;

  AccountingCubit({
    required this.getDailySummaryUseCase,
    required this.getSalesHistoryUseCase,
    required this.storeId,
  }) : super(AccountingInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  Future<void> loadAccountingData() async {
    emit(AccountingLoading());

    final now = DateTime.now();
    // تاریخچه ۳۰ روز گذشته (بدون احتساب امروز)
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final yesterday = now.subtract(const Duration(days: 1));

    // واکشی همزمان فروش امروز و تاریخچه
    final results = await Future.wait([
      getDailySummaryUseCase(
          GetDailySummaryParams(storeId: storeId, date: now)),
      getSalesHistoryUseCase(GetSalesHistoryParams(
          storeId: storeId, startDate: thirtyDaysAgo, endDate: yesterday)),
    ]);

    // --- اصلاح شد: نتایج را به نوع Either کست می‌کنیم ---
    final todayResult = results[0] as Either<Failure, DailySummaryEntity>;
    final historyResult = results[1] as Either<Failure, List<DailySummaryEntity>>;
    // ---

    todayResult.fold(
      (failure) => emit(AccountingError(_mapFailureToMessage(failure))),
      (todaySummary) {
        historyResult.fold(
          (failure) => emit(AccountingError(_mapFailureToMessage(failure))),
          (salesHistory) {
            emit(AccountingLoaded(
              todaySummary: todaySummary,
              salesHistory: salesHistory,
            ));
          },
        );
      },
    );
  }
}