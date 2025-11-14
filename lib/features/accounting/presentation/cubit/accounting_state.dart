// lib/features/accounting/presentation/cubit/accounting_state.dart
part of 'accounting_cubit.dart';



abstract class AccountingState extends Equatable {
  const AccountingState();
  @override
  List<Object> get props => [];
}

class AccountingInitial extends AccountingState {}

class AccountingLoading extends AccountingState {}

class AccountingError extends AccountingState {
  final String message;
  const AccountingError(this.message);
  @override
  List<Object> get props => [message];
}

class AccountingLoaded extends AccountingState {
  // خلاصه فروش امروز
  final DailySummaryEntity todaySummary;
  // تاریخچه فروش روزهای قبل
  final List<DailySummaryEntity> salesHistory;

  const AccountingLoaded({
    required this.todaySummary,
    required this.salesHistory,
  });

  @override
  List<Object> get props => [todaySummary, salesHistory];
}