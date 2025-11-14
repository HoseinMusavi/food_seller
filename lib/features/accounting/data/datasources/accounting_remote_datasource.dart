// lib/features/accounting/data/datasources/accounting_remote_datasource.dart
import 'package:food_seller/core/error/exceptions.dart';
import 'package:food_seller/features/accounting/data/models/daily_summary_model.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AccountingRemoteDataSource {
  Future<DailySummaryModel> getDailySummary(
      {required int storeId, required DateTime date});

  Future<List<DailySummaryModel>> getSalesHistory(
      {required int storeId,
      required DateTime startDate,
      required DateTime endDate});
}

class AccountingRemoteDataSourceImpl implements AccountingRemoteDataSource {
  final SupabaseClient supabaseClient;
  AccountingRemoteDataSourceImpl({required this.supabaseClient});

  // فرمتر تاریخ استاندارد برای Supabase
  final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<DailySummaryModel> getDailySummary(
      {required int storeId, required DateTime date}) async {
    try {
      final response = await supabaseClient.rpc(
        'get_daily_sales_summary',
        params: {
          'p_store_id': storeId,
          'p_date': _dateFormat.format(date),
        },
      ).single(); // این RPC همیشه یک ردیف برمی‌گرداند
      return DailySummaryModel.fromDailyRpc(response, date);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<DailySummaryModel>> getSalesHistory(
      {required int storeId,
      required DateTime startDate,
      required DateTime endDate}) async {
    try {
      final response = await supabaseClient.rpc(
        'get_sales_history',
        params: {
          'p_store_id': storeId,
          'p_start_date': _dateFormat.format(startDate),
          'p_end_date': _dateFormat.format(endDate),
        },
      );

      return (response as List)
          .map((json) => DailySummaryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}