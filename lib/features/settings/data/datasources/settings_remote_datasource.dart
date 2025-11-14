// lib/features/settings/data/datasources/settings_remote_datasource.dart
import 'package:food_seller/core/error/exceptions.dart';
import 'package:food_seller/features/orders/data/models/store_model.dart';
import 'package:food_seller/features/settings/data/models/store_review_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SettingsRemoteDataSource {
  /// جزئیات فروشگاه (مانند is_open) را واکشی می‌کند
  Future<StoreModel> getStoreDetails(int storeId);

  /// وضعیت باز/بسته بودن فروشگاه را آپدیت می‌کند
  Future<void> updateStoreStatus({required int storeId, required bool isOpen});

  /// نظرات مشتریان را با RPC واکشی می‌کند
  Future<List<StoreReviewModel>> getStoreReviews(int storeId);

  // --- شروع بخش جدید ---

  /// نام فروشگاه را آپدیت می‌کند
  Future<void> updateStoreName({required int storeId, required String newName});

  /// URL لوگوی فروشگاه را آپدیت می‌کند
  Future<void> updateStoreLogoUrl(
      {required int storeId, required String newLogoUrl});
  
  // --- پایان بخش جدید ---
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final SupabaseClient supabaseClient;
  SettingsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<StoreModel> getStoreDetails(int storeId) async {
    try {
      final response = await supabaseClient
          .from('stores')
          .select()
          .eq('id', storeId)
          .single();
      return StoreModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateStoreStatus(
      {required int storeId, required bool isOpen}) async {
    try {
      await supabaseClient
          .from('stores')
          .update({'is_open': isOpen})
          .eq('id', storeId);
      // RLS (که در فاز ۰ ساختیم) چک می‌کند که ما مالک این فروشگاه باشیم
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<StoreReviewModel>> getStoreReviews(int storeId) async {
    try {
      // فراخوانی RPC 5 که قبلاً در بک‌اند تعریف کردیم
      final response = await supabaseClient.rpc(
        'get_store_reviews_with_customer',
        params: {'p_store_id': storeId},
      );

      return (response as List)
          .map((json) => StoreReviewModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // --- شروع بخش جدید ---

  @override
  Future<void> updateStoreName(
      {required int storeId, required String newName}) async {
    try {
      await supabaseClient
          .from('stores')
          .update({'name': newName})
          .eq('id', storeId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateStoreLogoUrl(
      {required int storeId, required String newLogoUrl}) async {
    try {
      await supabaseClient
          .from('stores')
          .update({'logo_url': newLogoUrl})
          .eq('id', storeId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
  // --- پایان بخش جدید ---
}