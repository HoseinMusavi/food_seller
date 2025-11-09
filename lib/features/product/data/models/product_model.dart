// lib/features/product/data/models/product_model.dart
import 'package:food_seller/features/product/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.storeId,
    required super.name,
    required super.description,
    required super.price,
    super.discountPrice,
    required super.imageUrl,
    super.categoryId,
    super.categoryName,
    required super.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String? catName;
    if (json['product_categories'] != null &&
        json['product_categories'] is Map) {
      catName = json['product_categories']['name'] as String?;
    }

    return ProductModel(
      id: json['id'] as int,
      storeId: json['store_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? true,
      categoryId: json['category_id'] as int?,
      categoryName: catName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'category_id': categoryId,
    };
  }
}