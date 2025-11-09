// lib/features/product/domain/entities/product_entity.dart
import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final int storeId;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final int? categoryId;
  final String? categoryName; // این را از JOIN می‌گیریم
  final bool isAvailable;

  const ProductEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    this.categoryId,
    this.categoryName,
    required this.isAvailable,
  });

  double get finalPrice => discountPrice ?? price;

  @override
  List<Object?> get props => [
        id,
        storeId,
        name,
        price,
        discountPrice,
        imageUrl,
        categoryId,
        isAvailable
      ];
}