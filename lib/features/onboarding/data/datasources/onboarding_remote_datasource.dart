// lib/features/onboarding/data/datasources/onboarding_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';

abstract class OnboardingRemoteDataSource {
  /// چک می‌کند آیا فروشگاهی با owner_id کاربر فعلی وجود دارد یا خیر.
  /// اگر وجود داشت، ID آن را برمی‌گرداند.
  Future<int?> getStoreIdForCurrentUser();

  /// یک فروشگاه جدید بر اساس اطلاعات فرم ثبت می‌کند.
  Future<void> createStore({
    required String name,
    required String address,
    required String cuisineType,
    required String deliveryTimeEstimate,
    required double latitude,
    required double longitude,
    required String ownerId,
  });
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final SupabaseClient supabaseClient;

  OnboardingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<int?> getStoreIdForCurrentUser() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(message: 'User not authenticated');
      }

      final response = await supabaseClient
          .from('stores')
          .select('id')
          .eq('owner_id', userId)
          .maybeSingle(); // .maybeSingle() عالی است، اگر نباشد null برمی‌گرداند

      if (response == null || response['id'] == null) {
        return null; // فروشگاهی ندارد
      }

      return response['id'] as int; // ID فروشگاه را برمی‌گرداند
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> createStore({
    required String name,
    required String address,
    required String cuisineType,
    required String deliveryTimeEstimate,
    required double latitude,
    required double longitude,
    required String ownerId,
  }) async {
    try {
      // ساختن آبجکت Point برای PostGIS
      final locationString = 'POINT($longitude $latitude)';

      await supabaseClient.from('stores').insert({
        'name': name,
        'address': address,
        'cuisine_type': cuisineType,
        'delivery_time_estimate': deliveryTimeEstimate,
        'location': locationString,
        'owner_id': ownerId,
        'logo_url': 'https://via.placeholder.com/300/CCCCCC/808080?text=Logo', // یک عکس موقت
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: 'خطا در ثبت فروشگاه: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}