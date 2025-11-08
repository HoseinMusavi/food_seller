// lib/features/orders/data/models/order_item_option_model.dart
import 'package:food_seller/features/orders/domain/entities/order_item_option_entity.dart';

class OrderItemOptionModel extends OrderItemOptionEntity {
  const OrderItemOptionModel({
    required super.optionGroupName,
    required super.optionName,
    required super.priceDelta,
  });

  factory OrderItemOptionModel.fromJson(Map<String, dynamic> json) {
    return OrderItemOptionModel(
      optionGroupName: json['option_group_name'] as String,
      optionName: json['option_name'] as String,
      priceDelta: (json['price_delta'] as num).toDouble(),
    );
  }
}