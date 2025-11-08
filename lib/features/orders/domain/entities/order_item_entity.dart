// lib/features/orders/domain/entities/order_item_entity.dart
import 'package:equatable/equatable.dart';
import 'order_item_option_entity.dart';

// (ProductEntity فعلا ایمپورت نشده، چون در این فایل لازم نیست)
// import 'package:food_seller/features/product/domain/entities/product_entity.dart'; 

class OrderItemEntity extends Equatable {
  final int id;
  final int? productId;
  // final ProductEntity? product; // (فعلا به این نیاز نداریم)
  final int quantity;
  final double priceAtPurchase;
  final String productName;
  final List<OrderItemOptionEntity> options;

  const OrderItemEntity({
    required this.id,
    this.productId,
    // this.product,
    required this.quantity,
    required this.priceAtPurchase,
    required this.productName,
    required this.options,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        // product,
        quantity,
        priceAtPurchase,
        productName,
        options,
      ];
}