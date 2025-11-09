// lib/features/product/data/datasources/product_remote_datasource.dart
import 'package:food_seller/core/error/exceptions.dart';
import 'package:food_seller/features/product/data/models/product_category_model.dart';
import 'package:food_seller/features/product/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts(int storeId);
  Future<List<ProductCategoryModel>> getCategories(int storeId);
  Future<void> updateProductAvailability(
      {required int productId, required bool isAvailable});
  Future<ProductModel> createProduct(ProductModel product);
  
  // *** متد جدید ***
  Future<ProductModel> updateProduct(ProductModel product);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProductRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ProductCategoryModel>> getCategories(int storeId) async {
    // ... (کد بدون تغییر) ...
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
    // ... (کد بدون تغییر) ...
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
    // ... (کد بدون تغییر) ...
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
    // ... (کد بدون تغییر) ...
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

  // *** پیاده‌سازی متد جدید ***
  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      // .toJson() مدل را به Map تبدیل می‌کند
      final productMap = product.toJson();

      final response = await supabaseClient
          .from('products')
          .update(productMap)
          .eq('id', product.id) // آپدیت ردیفی که id آن مطابقت دارد
          .select() // محصول آپدیت شده را برگردان
          .single();

      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'خطا در آپدیت محصول: ${e.message}');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}