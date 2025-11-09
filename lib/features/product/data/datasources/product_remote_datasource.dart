// lib/features/product/data/datasources/product_remote_datasource.dart
import 'package:food_seller/core/error/exceptions.dart';
import 'package:food_seller/features/product/data/models/option_group_model.dart'; // *** ایمپورت جدید ***
import 'package:food_seller/features/product/data/models/product_category_model.dart';
import 'package:food_seller/features/product/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts(int storeId);
  Future<List<ProductCategoryModel>> getCategories(int storeId);
  Future<void> updateProductAvailability(
      {required int productId, required bool isAvailable});
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);

  // *** شروع بخش جدید (مدیریت آپشن‌ها) ***
  
  /// تمام گروه‌های آپشن (با آپشن‌های داخلشان) برای یک فروشگاه را می‌گیرد
  Future<List<OptionGroupModel>> getStoreOptionGroups(int storeId);
  
  /// ID گروه‌هایی که به یک محصول خاص لینک شده‌اند را برمی‌گرداند
  Future<Set<int>> getLinkedOptionGroupIds(int productId);
  
  /// یک گروه آپشن جدید برای فروشگاه می‌سازد
  Future<OptionGroupModel> createOptionGroup({required int storeId, required String name});
  
  /// یک آپشن جدید به یک گروه اضافه می‌کند
  Future<void> createOption({required int optionGroupId, required String name, required double priceDelta});
  
  /// یک گروه آپشن را به یک محصول لینک می‌کند
  Future<void> linkOptionGroupToProduct({required int productId, required int optionGroupId});
  
  /// لینک یک گروه آپشن از یک محصول را حذف می‌کند
  Future<void> unlinkOptionGroupFromProduct({required int productId, required int optionGroupId});
  
  // (متدهای ویرایش و حذف آپشن‌ها در آینده اضافه خواهند شد)
  
  // *** پایان بخش جدید ***
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProductRemoteDataSourceImpl({required this.supabaseClient});

  // ... (متدهای getCategories, getProducts, updateProductAvailability, createProduct, updateProduct بدون تغییر) ...
  @override
  Future<List<ProductCategoryModel>> getCategories(int storeId) async {
    try {
      final response = await supabaseClient
          .from('product_categories')
          .select()
          .eq('store_id', storeId)
          .order('sort_order', ascending: true);
      return response
          .map((json) => ProductCategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(message: 'خطا در واکشی دسته‌بندی‌ها: ${e.toString()}');
    }
  }
  @override
  Future<List<ProductModel>> getProducts(int storeId) async {
    try {
      final response = await supabaseClient
          .from('products')
          .select('*, product_categories(name)')
          .eq('store_id', storeId);
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'خطا در واکشی محصولات: ${e.toString()}');
    }
  }
  @override
  Future<void> updateProductAvailability(
      {required int productId, required bool isAvailable}) async {
    try {
      await supabaseClient
          .from('products')
          .update({'is_available': isAvailable})
          .eq('id', productId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'خطا در آپدیت محصول: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final productMap = product.toJson()..remove('id');
      final response = await supabaseClient
          .from('products')
          .insert(productMap)
          .select()
          .single();
      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'خطا در ایجاد محصول: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final productMap = product.toJson();
      final response = await supabaseClient
          .from('products')
          .update(productMap)
          .eq('id', product.id)
          .select()
          .single();
      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'خطا در آپدیت محصول: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // *** پیاده‌سازی متدهای جدید آپشن ***

  @override
  Future<List<OptionGroupModel>> getStoreOptionGroups(int storeId) async {
    try {
      // تمام گروه‌ها و آپشن‌های تودرتو مربوط به این فروشگاه را واکشی کن
      final response = await supabaseClient
          .from('option_groups')
          .select('*, options(*)')
          .eq('store_id', storeId);
      return response
          .map((json) => OptionGroupModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(message: 'خطا در واکشی گروه‌های آپشن: ${e.toString()}');
    }
  }

  @override
  Future<Set<int>> getLinkedOptionGroupIds(int productId) async {
     try {
      final response = await supabaseClient
          .from('product_option_groups')
          .select('option_group_id')
          .eq('product_id', productId);
      
      return response
          .map((json) => (json['option_group_id'] as num).toInt())
          .toSet();
    } catch (e) {
      throw ServerException(message: 'خطا در واکشی آپشن‌های لینک شده: ${e.toString()}');
    }
  }

  @override
  Future<OptionGroupModel> createOptionGroup({required int storeId, required String name}) async {
    try {
      final response = await supabaseClient
          .from('option_groups')
          .insert({'store_id': storeId, 'name': name})
          .select()
          .single();
      return OptionGroupModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'خطا در ایجاد گروه آپشن: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> createOption({required int optionGroupId, required String name, required double priceDelta}) async {
     try {
      await supabaseClient
          .from('options')
          .insert({
            'option_group_id': optionGroupId, 
            'name': name,
            'price_delta': priceDelta
          });
    } on PostgrestException catch (e) {
      throw ServerException(message: 'خطا در ایجاد آپشن: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> linkOptionGroupToProduct({required int productId, required int optionGroupId}) async {
    try {
      await supabaseClient
          .from('product_option_groups')
          .insert({
            'product_id': productId,
            'option_group_id': optionGroupId,
          });
    } on PostgrestException catch (e) {
      // اگر از قبل وجود داشت، خطا را نادیده بگیر
      if(e.code == '23505') { // unique_violation
        return;
      }
      throw ServerException(message: 'خطا در لینک کردن آپشن: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> unlinkOptionGroupFromProduct({required int productId, required int optionGroupId}) async {
     try {
      await supabaseClient
          .from('product_option_groups')
          .delete()
          .eq('product_id', productId)
          .eq('option_group_id', optionGroupId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'خطا در حذف لینک آپشن: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}