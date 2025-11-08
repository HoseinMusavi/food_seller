// lib/features/orders/data/models/order_model.dart
import 'package:food_seller/features/orders/data/models/address_model.dart';
import 'package:food_seller/features/orders/data/models/customer_model.dart';
import 'package:food_seller/features/orders/data/models/order_item_model.dart';
import 'package:food_seller/features/orders/data/models/store_model.dart'; // (اگرچه در این کوئری استفاده نمی‌شود، اما نگهش می‌داریم)
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:food_seller/features/orders/domain/entities/order_item_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.createdAt,
    required super.customerId,
    super.storeId,
    super.addressId,
    required super.subtotalPrice,
    required super.deliveryFee,
    required super.discountAmount,
    required super.totalPrice,
    required super.status,
    required super.items,
    super.store,
    super.address,
    super.customer,
    super.estimatedDeliveryTime,
    super.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // --- منطق خواندن Store ID (بدون تغییر) ---
    final storeData = json['store_id'];
    int? parsedStoreId;
    if (storeData is int) {
      parsedStoreId = storeData;
    } else if (storeData is Map) {
      parsedStoreId = (storeData['id'] as num).toInt();
    } else {
      parsedStoreId = null;
    }

    // --- منطق خواندن Address ID (بدون تغییر) ---
    final addressData = json['address_id'];
    int? parsedAddressId;
    if (addressData is int) {
      parsedAddressId = addressData;
    } else if (addressData is Map) {
      parsedAddressId = (addressData['id'] as num).toInt();
    } else {
      parsedAddressId = null;
    }

    // --- پارس کردن آیتم‌ها (بدون تغییر) ---
    final List<OrderItemEntity> parsedItems =
        json['order_items'] != null && json['order_items'] is List
            ? (json['order_items'] as List)
                .map((item) =>
                    OrderItemModel.fromJson(item as Map<String, dynamic>))
                .toList()
            : [];

    // --- پارس کردن مشتری (بدون تغییر) ---
    final CustomerModel? parsedCustomer = (json['customers'] is Map)
        ? CustomerModel.fromJson(json['customers'] as Map<String, dynamic>)
        : null;

    return OrderModel(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      customerId: json['customer_id'] as String,
      storeId: parsedStoreId,
      addressId: parsedAddressId,
      subtotalPrice: (json['subtotal_price'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: (json['status'] as String).toOrderStatus(),
      items: parsedItems,
      estimatedDeliveryTime: json['estimated_delivery_time'] as String?,
      notes: json['notes'] as String?,
      
      // (کوئری ما store را join نمی‌کند، چون فروشنده خودش store است)
      store: null, 
      
      // *** شروع بخش اصلاح شده ***
      // به جای 'address_id'، ما باید آبجکت 'addresses' (جمع) را بخوانیم
      address: (json['addresses'] is Map)
          ? AddressModel.fromJson(json['addresses'] as Map<String, dynamic>)
          : null,
      // *** پایان بخش اصلاح شده ***

      customer: parsedCustomer,
    );
  }
}