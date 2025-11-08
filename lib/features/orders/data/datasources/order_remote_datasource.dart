// lib/features/orders/data/datasources/order_remote_datasource.dart
import 'package:food_seller/core/error/exceptions.dart';
import 'package:food_seller/features/orders/data/models/order_model.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders(
      {required int storeId, required List<OrderStatus> statuses});
  Stream<List<OrderModel>> listenToOrderChanges({required int storeId});
  Future<void> updateOrderStatus(
      {required int orderId, required OrderStatus newStatus});
  Future<OrderModel> getOrderDetails({required int orderId});
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final SupabaseClient supabaseClient;

  OrderRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<OrderModel>> getOrders(
      {required int storeId, required List<OrderStatus> statuses}) {
    try {
      // *** کوئری اصلاح شد ***
      // حالا آیتم‌های سفارش را هم Join می‌کنیم
      final response = supabaseClient
          .from('orders')
          .select('''
            *, 
            customers(full_name),
            order_items(*, order_item_options(*))
          ''') // *** پایان اصلاح ***
          .eq('store_id', storeId)
          .filter('status', 'in', statuses.map((s) => s.name).toList())
          .order('created_at', ascending: false) 
          .then((data) =>
              data.map((json) => OrderModel.fromJson(json)).toList());

      return response;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<OrderModel>> listenToOrderChanges({required int storeId}) {
    try {
      // *** کوئری اصلاح شد ***
      // حالا آیتم‌ها و مشتری را هم در Stream می‌گیریم
      final stream = supabaseClient
          .from('orders')
          .stream(primaryKey: ['id'])
          .eq('store_id', storeId)
          .order('created_at', ascending: false);
          
      return stream.map((maps) {
         return maps.map((json) {
            // RLS تضمین می‌کند که ما فقط سفارش‌های خودمان را می‌گیریم
            // اما Realtime join پیچیده را برنمی‌گرداند.
            // بنابراین ما باید به صورت دستی داده‌ها را از نو واکشی کنیم
            // (این یک محدودیت در Supabase Realtime است)
            // Cubit ما این را مدیریت خواهد کرد.
            // برای سادگی، فعلاً فرض می‌کنیم Cubit دوباره loadOrders() را صدا می‌زند.
            
            // **اصلاح**: ما کوئری کامل را در پاسخ به Realtime واکشی می‌کنیم
            // این کمی سنگین است اما دقیق‌ترین داده را تضمین می‌کند.
            // (در Cubit این را بهینه‌تر خواهیم کرد)
            
            // **اصلاح ساده‌تر:**
            // ما فقط سفارش‌های خام را از stream می‌گیریم
            // و Cubit را مجبور می‌کنیم کل لیست را دوباره واکشی کند.
            // این کار را در Cubit انجام خواهیم داد.
            
            // فعلاً فقط json خام را پارس می‌کنیم (بدون join)
             return OrderModel.fromJson(json);
         }).toList();
      });

    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
  
  // ... (متدهای updateOrderStatus و getOrderDetails بدون تغییر باقی می‌مانند) ...
  @override
  Future<void> updateOrderStatus(
      {required int orderId, required OrderStatus newStatus}) async {
    try {
      await supabaseClient
          .from('orders')
          .update({'status': newStatus.name}) 
          .eq('id', orderId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<OrderModel> getOrderDetails({required int orderId}) async {
     try {
      final response = await supabaseClient
          .from('orders')
          .select(
            '''
            *, 
            customers(full_name, phone), 
            addresses(*, location:location::text), 
            order_items(*, order_item_options(*))
            '''
          )
          .eq('id', orderId)
          .single(); 

      return OrderModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}