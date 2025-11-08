// lib/features/orders/data/models/order_item_model.dart
import 'package:food_seller/features/orders/data/models/order_item_option_model.dart';
import 'package:food_seller/features/orders/domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    super.productId,
    required super.quantity,
    required super.priceAtPurchase,
    required super.productName,
    required super.options,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // --- منطق هوشمند برای خواندن Product ID ---
    final productData = json['product_id'];
    int? parsedProductId;
    if (productData is int) {
      parsedProductId = productData;
    } else if (productData is Map) {
      parsedProductId = (productData['id'] as num).toInt();
    } else {
      parsedProductId = null; // اگر محصول حذف شده باشد
    }

    // --- پارس کردن آپشن‌ها ---
    final List<OrderItemOptionModel> parsedOptions =
        json['order_item_options'] != null &&
                json['order_item_options'] is List
            ? (json['order_item_options'] as List)
                .map((option) => OrderItemOptionModel.fromJson(
                    option as Map<String, dynamic>))
                .toList()
            : []; // اگر آپشن نداشت، لیست خالی

    return OrderItemModel(
      id: (json['id'] as num).toInt(),
      productId: parsedProductId,
      quantity: (json['quantity'] as num).toInt(),
      priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
      productName: json['product_name'] as String,
      options: parsedOptions,
    );
  }
}