// lib/features/accounting/data/models/daily_summary_model.dart
import 'package:food_seller/features/accounting/domain/entities/daily_summary_entity.dart';

class DailySummaryModel extends DailySummaryEntity {
  const DailySummaryModel({
    required super.salesDate,
    required super.totalSales,
    required super.totalOrders,
  });

  factory DailySummaryModel.fromJson(Map<String, dynamic> json) {
    return DailySummaryModel(
      // اگر از RPC 'get_sales_history' بیاید، 'sales_date' وجود دارد
      // اگر از RPC 'get_daily_sales_summary' بیاید، 'sales_date' وجود ندارد و باید دستی ست شود
      salesDate: DateTime.parse(json['sales_date']),
      totalSales: (json['total_sales'] as num).toDouble(),
      totalOrders: (json['total_orders'] as num).toInt(),
    );
  }

  // این متد برای RPC 'get_daily_sales_summary' استفاده می‌شود
  factory DailySummaryModel.fromDailyRpc(Map<String, dynamic> json, DateTime date) {
     return DailySummaryModel(
      salesDate: date,
      totalSales: (json['total_sales'] as num).toDouble(),
      totalOrders: (json['total_orders'] as num).toInt(),
    );
  }
}