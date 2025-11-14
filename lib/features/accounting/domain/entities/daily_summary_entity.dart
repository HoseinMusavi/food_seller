// lib/features/accounting/domain/entities/daily_summary_entity.dart
import 'package:equatable/equatable.dart';

class DailySummaryEntity extends Equatable {
  final DateTime salesDate;
  final double totalSales;
  final int totalOrders;

  const DailySummaryEntity({
    required this.salesDate,
    required this.totalSales,
    required this.totalOrders,
  });

  @override
  List<Object?> get props => [salesDate, totalSales, totalOrders];
}